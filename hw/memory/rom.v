/*
    1024 * 16bits ROM
      - synchronous read
*/

`default_nettype none

module rom #(parameter BASE_ADDR = 16'h2000, parameter MEM_SIZE = 1024)
  (
    input wire i_clk,
    input wire i_ce,
    input wire [15:0] i_addr,
    output reg [15:0] o_r_data
  );

  reg [15:0] mem [0:(MEM_SIZE - 1)];
  initial
  begin
    $readmemh("program/rom.mem", mem);
  end

  always @ (posedge i_clk)
  begin
    if(i_addr >= BASE_ADDR && i_addr < BASE_ADDR + MEM_SIZE)
    begin
      o_r_data <= mem[i_addr - BASE_ADDR];
    end
  end

endmodule
