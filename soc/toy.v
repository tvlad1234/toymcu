
`default_nettype none

module toy #(parameter BAUD_DIV = 217)
  (
    input wire i_clk,
    input wire i_reset,
    input wire i_rx,
    output wire o_tx
  );

  reg [15:0] bus_read_data;
  reg [15:0] bus_write_data;
  wire [15:0] bus_addr;
  wire bus_we;

  wire [15:0] ram_read_data;
  wire [7:0] uart_read_data;

  always @(*)
  begin

    // RAM
    if (bus_addr <= 10'h3ff)
      bus_read_data = ram_read_data;

    // UART
    else if (bus_addr == 16'h0400 || bus_addr == 16'h0401) // UART
      bus_read_data = {8'd0, uart_read_data};

    else
      bus_read_data = 0;

  end

  wire div_ce;
  assign div_ce = 1;
  wire toy_ce;

  assign toy_ce = div_ce;

  wire halted;
  wire uart_int;

  // clk_div toy_clk_div(i_clk, i_reset, div_ce);
  uart #(.BAUD_DIV(BAUD_DIV)) toy_uart(i_clk, i_reset, bus_we, bus_addr, bus_write_data[7:0], uart_read_data, o_tx, i_rx, uart_int);
  ram toy_ram(i_clk, toy_ce, bus_we, bus_addr, bus_write_data, ram_read_data);
  cpu toy_cpu(i_clk, toy_ce, i_reset, bus_read_data, bus_write_data, bus_addr, bus_we, halted, uart_int);

endmodule
