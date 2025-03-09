`default_nettype none

module colorlight_toy_top
  (
    input wire i_clk,
    input wire i_nrst,
    input wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_led
  );

  localparam clock_freq = 25000000; // input clock frequency in Hz
  localparam baudrate = 9600; // baud rate

  reg rst;

  wire [15:0] gpi = 16'd0;
  wire [15:0] gpo;

  always @(posedge i_clk)
  begin
    rst <= ~i_nrst;
    o_led <= ~gpo[0];
  end

  toy #(.BAUD_DIV(clock_freq / baudrate)) u_toy(i_clk, rst, i_uart_rx, o_uart_tx, gpi, gpo);

endmodule
