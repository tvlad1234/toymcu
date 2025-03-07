
`timescale 1ns / 1ps
`default_nettype none

module tb_toy;

  reg clk;
  reg rst;
  wire halted;
  wire we;
  wire uart_tx;
  reg interrupt;

  toy #(.BAUD_DIV(1)) dut_toy(clk, rst, uart_tx, interrupt);

  always #1 clk = ~clk;

  initial
  begin

    $dumpfile("tb_toy.vcd");
    $dumpvars(0,tb_toy);

    rst = 0;
    clk = 0;
    interrupt = 0;
    #1 rst = 1;
    #2 rst = 0;

    #4000 interrupt = 1;
    #2 interrupt = 0;

    #4200 interrupt = 1;
    #200 interrupt = 0;

    #10000 $finish;
  end

endmodule
