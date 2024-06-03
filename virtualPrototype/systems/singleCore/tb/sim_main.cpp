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

void set_pixel(Uint32 *buffer, int pos, Uint32 color)
{
    int x, y;
    if (pos < SCREEN_WIDTH * SCREEN_HEIGHT)
    {
        x = pos % (SCREEN_WIDTH);
        y = pos / (SCREEN_WIDTH);
        buffer[x + y * SCREEN_WIDTH] = color;
    }
    // else {
    //     pos -= SCREEN_WIDTH*SCREEN_HEIGHT/2;
    //     x = (SCREEN_WIDTH/2) + (pos % (SCREEN_WIDTH/2));
    //     y = pos / (SCREEN_WIDTH/2);
    // }
}

Uint32 *hdmi_screen;

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

int main(int argc, char **argv)
{
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Prevent unused variable warnings
    if (false && argc && argv)
    {
    }

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

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

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vtb_harness> top{new Vtb_harness{contextp.get(), "tb_top"}};

    // Handling the HDMI
    hdmi_screen = new Uint32[SCREEN_WIDTH * SCREEN_HEIGHT];
    int hdmi_p = 0;
    bool pixelClock_1d = false;
    std::thread thread_hdmi(game_loop);

    // Set Vtop's input signals
    int clock_counter = 0;
    top->clk = 0;
    top->clkX2 = 0;

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
                Uint8 r = top->red << 4;
                Uint8 g = top->green << 12;
                Uint8 b = top->blue << 20;
                Uint32 c = 0xFF000000 | r | g | b;
                set_pixel(hdmi_screen, hdmi_p, c);
                hdmi_p = (hdmi_p + 1) % (SCREEN_WIDTH * SCREEN_HEIGHT);
            }
        }
        pixelClock_1d = top->pixelClock;

        // Cam
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
                top->camData = 0xFFFF;
            else
                top->camData = 0;

            if (((clock_counter / 2) / 784) % 510 == 509)
                vsync = true;
        }
    }

    thread_hdmi.join();
    // Final model cleanup
    top->final();

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}
