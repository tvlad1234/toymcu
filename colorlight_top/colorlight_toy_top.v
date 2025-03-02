`default_nettype none

module colorlight_toy_top
  (
    input wire i_clk,
    input wire i_nrst,
    output wire o_tx
  );

  localparam clock_freq = 25000000; // input clock frequency in Hz
  localparam baudrate = 9600; // baud rate

  reg rst;

  always @(posedge i_clk)
  begin
    rst <= i_nrst;
  end

  toy #(.BAUD_DIV(clock_freq / baudrate)) u_toy(i_clk, rst, o_tx);

endmodule
