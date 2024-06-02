`default_nettype none 
module synchroFlop ( input wire  clockIn,
                                 clockOut,
                                 reset,
                                 D,
                     output wire Q );
  reg s_state_l;
  reg [1:0] s_states_h;
  wire [2:0] s_states = {s_states_h, s_state_l};

  wire [2:0] s_d = {s_states[1:0],{s_states[0] | D}};
  wire s_reset0 = reset | s_states[1];
  assign Q = s_states[2];
  
  always @(posedge clockIn or posedge s_reset0)
    if (s_reset0 == 1'b1) s_state_l <= 1'b0;
    else s_state_l <= s_d[0];
  
  always @(posedge clockOut or posedge reset)
    if (reset == 1'b1) s_states_h <= 0;
    else s_states_h <= s_d[2:1];
endmodule
