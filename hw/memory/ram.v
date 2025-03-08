/*
    1024 * 16bits RAM
      - synchronous read and write
*/

`default_nettype none

module ram #(parameter BASE_ADDR = 0, parameter MEM_SIZE = 1024)
  (
    input wire i_clk,
    input wire i_ce,
    input wire i_we,
    input wire [15:0] i_addr,
    input wire [15:0] i_w_data,
    output reg [15:0] o_r_data
  );

  reg [15:0] mem [0:(MEM_SIZE - 1)];
  initial
  begin
    $readmemh("program/hello.mem", mem);
  end

  always @ (posedge i_clk)
  begin
    if(i_addr >= BASE_ADDR && i_addr < MEM_SIZE)
    begin
      o_r_data <= mem[i_addr];

      if(i_we && i_ce)
        mem[i_addr] <= i_w_data;
    end
  end

endmodule
