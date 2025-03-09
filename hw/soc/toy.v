
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

  wire [15:0] interrupt_read_data;
  wire [15:0] interrupt_lines;
  wire toy_int;

  wire [7:0] uart_read_data;
  wire uart_int;

  always @(*)
  begin

    // RAM
    if (bus_addr <= 10'h3ff)
      bus_read_data = ram_read_data;

    // UART
    else if (bus_addr == 16'h0400 || bus_addr == 16'h0401) // UART
      bus_read_data = {8'd0, uart_read_data};

    // Interrupt controller
    else if(bus_addr == 16'h0410)
      bus_read_data = interrupt_read_data;

    else
      bus_read_data = 0;

  end

  wire toy_ce = 1;
  wire halted;

  assign interrupt_lines = {13'd0, 1'b0, 1'b0, uart_int};

  interrupt_ctrl toy_interrupt_ctrl(i_clk, i_reset, bus_we, bus_addr, bus_write_data, interrupt_read_data, interrupt_lines, toy_int);

  uart #(.BAUD_DIV(BAUD_DIV)) toy_uart(i_clk, i_reset, bus_we, bus_addr, bus_write_data[7:0], uart_read_data, o_tx, i_rx, uart_int);
  ram toy_ram(i_clk, toy_ce, bus_we, bus_addr, bus_write_data, ram_read_data);
  cpu toy_cpu(i_clk, toy_ce, i_reset, bus_read_data, bus_write_data, bus_addr, bus_we, halted, toy_int);

endmodule
