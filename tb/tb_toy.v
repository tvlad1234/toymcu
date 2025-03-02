
`timescale 1ns / 1ps
`default_nettype none

module tb_toy;

  reg clk;
  reg rst;
  wire halted;
  wire we;
  wire uart_tx;

  toy #(.BAUD_DIV(1)) dut_toy(clk, rst, uart_tx);

  always #1 clk = ~clk;

  initial
  begin

    $dumpfile("tb_toy.vcd");
    $dumpvars(0,tb_toy);

    rst = 0;
    clk = 0;

    #1 rst = 1;
    #2 rst = 0;

    #10000 $finish;
  end

endmodule
