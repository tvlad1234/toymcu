
`timescale 1ns / 1ps
`default_nettype none

module tb_toy;

  reg clk, rst;
  wire halted;

  wire uart_tx, uart_rx, tx_ready;
  reg tx_go;
  reg [7:0] tx_data;

  wire [15:0] gpo;
  reg [15:0] gpi;

  toy #(.BAUD_DIV(16)) dut_toy(clk, rst, uart_rx, uart_tx, gpi, gpo);
  tx #(.BAUD_DIV(16)) dut_tx (clk, rst, tx_go, tx_data, uart_rx, tx_ready);

  always #1 clk = ~clk;

  initial
  begin

    $dumpfile("tb_toy.vcd");
    $dumpvars(0,tb_toy);

    gpi = 0;

    rst = 0;
    clk = 0;
    tx_go = 0;

    #1 rst = 1;
    #2 rst = 0;

    tx_data = 65;
    #8000 tx_go = 1;
    #2 tx_go = 0;

    tx_data = 68;
    #4000 tx_go = 1;
    #2 tx_go = 0;

    #10000 $finish;
  end

endmodule
