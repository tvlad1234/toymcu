/*
    1024 * 16bits RAM
      - synchronous read
      - synchronous write gated by write enable and clock enable
*/

`default_nettype none

module ram (
    input wire i_clk,
    input wire i_ce,
    input wire i_we,
    input wire [9:0] i_w_addr,
    input wire [9:0] i_r_addr,
    input wire [15:0] i_w_data,
    output reg [15:0] o_r_data
  );

  reg [15:0] mem [0:1023];
  initial
  begin
    $readmemh("programs/hello.mem", mem);
  end

  always @ (posedge i_clk)
  begin
    o_r_data <= mem[i_r_addr];
  end

  always @ (posedge i_clk)
  begin
    if(i_we && i_ce)
      mem[i_w_addr] <= i_w_data;
  end

endmodule
