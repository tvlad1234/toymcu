/*
    Register file
    16 x 16bits
    13 general purpose registers (R1-R13), 
    2 segment registers (R14, R15),
    1 zero register (R0)
 
*/

`default_nettype none

module reg_file (
    input wire i_clk,
    input wire i_ce,
    input wire i_rst,
    input wire i_we,
    input wire [3:0] i_r1_addr,
    input wire [3:0] i_r2_addr,
    input wire [3:0] i_w_addr,
    input wire [15:0] i_w_data,
    output reg [15:0] o_r1_data,
    output reg [15:0] o_r2_data,
    output reg [15:0] o_seg_c,
    output reg [15:0] o_seg_d
  );

  // 16 bits      16 registers
  reg [15:0]  registers [0:15];

  always @ (posedge i_clk)
  begin
    if (i_rst)
    begin
      for(integer i = 0; i < 16; i = i+ 1)
        registers[i] <= 0;
    end
    else if (i_ce)
    begin
      if(i_we && i_w_addr != 0)
        registers[i_w_addr] <= i_w_data;

      o_seg_c <= registers[14];
      o_seg_d <= registers[15];

      o_r1_data <= registers[i_r1_addr];
      o_r2_data <= registers[i_r2_addr];
    end
  end

endmodule
