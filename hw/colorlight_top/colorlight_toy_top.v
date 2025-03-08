`default_nettype none

module colorlight_toy_top
  (
    input wire i_clk,
    input wire i_nrst,
    input wire i_uart_rx,
    output wire o_uart_tx
  );

  localparam clock_freq = 25000000; // input clock frequency in Hz
  localparam baudrate = 9600; // baud rate

  reg rst;

  always @(posedge i_clk)
  begin
    rst <= ~i_nrst;
  end

  toy #(.BAUD_DIV(clock_freq / baudrate)) u_toy(i_clk, rst, i_uart_rx, o_uart_tx);

endmodule
