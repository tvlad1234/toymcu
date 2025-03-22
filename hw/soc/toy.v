
`default_nettype none

module toy #(parameter BAUD_DIV = 217)
  (
    input wire i_clk,
    input wire i_reset,

    input wire i_rx,
    output wire o_tx,

    input wire [15:0] i_gp,
    output wire [15:0] o_gp
  );

  reg [15:0] bus_read_data;
  reg [15:0] bus_write_data;
  wire [15:0] bus_addr;
  wire bus_we;

  wire [15:0] ram_read_data;
  wire [15:0] rom_read_data;

  wire [15:0] interrupt_read_data;
  wire [15:0] interrupt_lines;
  wire toy_int;

  wire [7:0] uart_read_data;
  wire uart_int;

  wire [15:0] timer_read_data;
  wire timer_tick_int, timer_cnt_int;

  wire [15:0] gpio_read_data;

  always @(*)
  begin

    // RAM
    if (bus_addr <= 16'h03ff)
      bus_read_data = ram_read_data;

    // ROM
    else if (bus_addr >= 16'h2000 && bus_addr < 16'h2400)
      bus_read_data = rom_read_data;

    // UART
    else if (bus_addr >= 16'h0400 && bus_addr <= 16'h040F)
      bus_read_data = {8'd0, uart_read_data};

    // Interrupt controller
    else if(bus_addr >= 16'h0410 && bus_addr <= 16'h041F)
      bus_read_data = interrupt_read_data;

    // Timer
    else if(bus_addr >= 16'h0420 && bus_addr <= 16'h042F)
      bus_read_data = timer_read_data;

    // GPIO
    else if(bus_addr >= 16'h0430 && bus_addr <= 16'h043F)
      bus_read_data = gpio_read_data;

    else
      bus_read_data = 0;

  end

  wire toy_ce = 1;
  wire halted, toy_reset;
  wire [15:0] int_addr;

  assign interrupt_lines = {13'd0, timer_cnt_int, timer_tick_int, uart_int};

  reset_ctrl toy_reset_ctrl(i_clk, i_reset, toy_reset);
  interrupt_ctrl toy_interrupt_ctrl(i_clk, toy_reset, bus_we, bus_addr, bus_write_data, interrupt_read_data, int_addr,  interrupt_lines, toy_int);
  timer toy_timer(i_clk, toy_reset, bus_we, bus_addr, bus_write_data, timer_read_data, timer_tick_int, timer_cnt_int);
  gpio toy_gpio(i_clk, toy_reset, bus_we, bus_addr, bus_write_data, gpio_read_data, i_gp, o_gp);
  uart #(.BAUD_DIV(BAUD_DIV)) toy_uart(i_clk, toy_reset, bus_we, bus_addr, bus_write_data[7:0], uart_read_data, o_tx, i_rx, uart_int);
  ram toy_ram(i_clk, toy_ce, bus_we, bus_addr, bus_write_data, ram_read_data);
  rom toy_rom(i_clk, toy_ce, bus_addr, rom_read_data);
  cpu toy_cpu(i_clk, toy_ce, toy_reset, bus_read_data, bus_write_data, bus_addr, bus_we, halted, int_addr, toy_int);

endmodule
