// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "tb_harness.v"
#include "Vtb_harness.h"

// Include SDL2 stuff
#include <thread>
#include <SDL2/SDL.h>

#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

void set_pixel(Uint32 *buffer, int pos, SDL_Color color)
{
    buffer[pos] = *(Uint32 *)&color;
}

Uint32 *hdmi_screen;

uint8_t camera_registers[202] = {0};

void game_loop()
{
    // Open the SDL Window
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
        return;

    SDL_Window *window = SDL_CreateWindow("SDL2 Window",
                                          SDL_WINDOWPOS_CENTERED,
                                          SDL_WINDOWPOS_CENTERED,
                                          SCREEN_WIDTH, SCREEN_HEIGHT,
                                          0);

    if (!window)
        return;

    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if (renderer == nullptr)
        return;

    SDL_Event e;
    bool running = true;

    SDL_Texture *texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (texture == nullptr)
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return;
    }

    while (running)
    {
        while (SDL_PollEvent(&e) > 0)
        {
            switch (e.type)
            {
            case SDL_QUIT:
                running = false;
                break;
            }
        }

        SDL_UpdateTexture(texture, nullptr, hdmi_screen, SCREEN_WIDTH * sizeof(Uint32));
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, nullptr, nullptr);
        SDL_RenderPresent(renderer);
    }

    delete hdmi_screen;
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

void camera_i2c(Vtb_harness *top, int clock_counter)
{
    static int state = 0;
    static bool scl_1d = true;
    static int sclCounter = 0;

    static uint8_t device_address = 0;
    static uint8_t reg_address = 0;
    static int reg_data = 0;

    // IDLE

    if (state == 0)
    {
        //  && scl_1d && !top->scl
        if (!top->sdaMaster)
        {
            state = 1;
        }
        // positive edge of scl
    } else if (state > 4) {
        if (top->sdaMaster) { state = 0; }
    } else if (!scl_1d && top->scl) {
        if (state == 4) {
            state = 5;
        } else {
            reg_data = (top->sdaMaster & 0x1) | (reg_data << 1);
            sclCounter++;
            // 8 bits + ACK
            if (sclCounter == 9)
            {
                sclCounter = 0;
                // Device address
                if (state == 1)
                {
                    device_address = reg_data >> 2;
                    //printf("%d dev addr: %x\n", clock_counter, device_address);
                    state = 2;
                }
                // Register address
                else if (state == 2)
                {
                    reg_address = reg_data >> 1;
                    //printf("%d reg addr: %x\n", clock_counter, reg_address);
                    state = 3;
                // Data
                } else if (state == 3) {
                    camera_registers[reg_address] = reg_data >> 1;
                    //printf("%d cam[%x]=%x\n", clock_counter, reg_address, reg_data>>1);
                    state = 4;
                }
                reg_data = 0;
            }
        }
    }
    scl_1d = top->scl;
}

int main(int argc, char **argv) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Prevent unused variable warnings
    if (false && argc && argv)
    {
    }

#ifdef TRACE
    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");
#endif

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

#ifdef TRACE
    // Verilator must compute traced signals
    contextp->traceEverOn(true);
#endif

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    Vtb_harness* top = new Vtb_harness{contextp.get(), "tb_top"};

    // Handling the HDMI
    hdmi_screen = new Uint32[SCREEN_WIDTH * SCREEN_HEIGHT];
    int hdmi_p = 0;
    bool pixelClock_1d = false;
    std::thread thread_hdmi(game_loop);

    // Set Vtop's input signals
    int clock_counter = 0;
    top->clk = 0;
    top->clkX2 = 0;

    top->sdaDrivenSlave = 1;

    top->camData = 0xFF;
    top->camHsync = 1;
    top->camVsync = 0;
    bool vsync = true;

    // Simulate until $finish
    while (!contextp->gotFinish())
    {
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions just assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(1); // 1 timeprecision period passes...
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        if (clock_counter % 2 == 0)
            top->clk = !top->clk;
        if (clock_counter % 1 == 0)
            top->clkX2 = !top->clkX2;

        clock_counter++;

        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();

        // Read outputs
        //        VL_PRINTF("[%" PRId64 "] clk=%x rstl=%x iquad=%" PRIx64 " -> oquad=%" PRIx64
        //                  " owide=%x_%08x_%08x\n",
        //                  contextp->time(), top->clk, top->reset_l, top->in_quad, top->out_quad,
        //                  top->out_wide[2], top->out_wide[1], top->out_wide[0]);

        // HD Am I?
        if (top->pixelClock && !pixelClock_1d)
        {
            if (!top->horizontalSync && top->activePixel && !top->verticalSync)
            {
                SDL_Color color;
                color.b = top->red << 4;
                color.g = top->green << 4;
                color.r = top->blue << 4;
                color.a = 0xFF;
                set_pixel(hdmi_screen, hdmi_p, color);
                hdmi_p = (hdmi_p + 1) % (SCREEN_WIDTH * SCREEN_HEIGHT);
            }
        }
        pixelClock_1d = top->pixelClock;

// Cam
#if 1
        if (vsync)
        {
            int cam_counter = ((clock_counter / 2) / 784) % 510;
            if (cam_counter < 3)
                top->camVsync = 1;
            else if (cam_counter < 20)
                top->camVsync = 0;
            else
                vsync = false;
        }
        else
        {
            int cam_counter = (clock_counter / 2) % 784;

            top->camHsync = (cam_counter >= 80);

            if (cam_counter >= (80 + 45))
                top->camData = 0x5555;
            else
                top->camData = 0;

            //printf("%d\n", ((clock_counter / 2) / 784) % 510);
            if ((((clock_counter) / 2) / 784) % 510 == 0)
                vsync = true;
        }
#endif
        camera_i2c(top, clock_counter);
    }

    thread_hdmi.join();
    // Final model cleanup
    top->final();

    delete top;

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}
