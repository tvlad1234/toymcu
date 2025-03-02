
`default_nettype none

module toy #(parameter BAUD_DIV = 217)
  (
    input wire i_clk,
    input wire i_reset,
    output wire o_tx
  );

  reg [15:0] bus_read_data;
  reg [15:0] bus_write_data;
  wire [15:0] bus_read_addr;
  wire [15:0] bus_write_addr;
  wire bus_we;

  reg [9:0] ram_read_addr;
  reg [9:0] ram_write_addr;
  wire [15:0] ram_read_data;
  reg [15:0] ram_write_data;
  reg ram_we;


  reg [7:0] uart_tx_data;
  reg uart_go;
  wire uart_ready;

  wire [15:0] uart_status = {15'd0, uart_ready};

  always @(*) // read address
  begin
    if (bus_read_addr <= 10'h3ff) // RAM
    begin
      ram_read_addr = bus_read_addr[9:0];
      bus_read_data = ram_read_data;
    end
    else if (bus_read_addr == 16'h0400) // UART status register
    begin
      ram_read_addr = 0;
      bus_read_data = uart_status;
    end
    else
    begin
      ram_read_addr = 0;
      bus_read_data = 0;
    end
  end


  always @(*) // write address
  begin
    if(bus_write_addr <= 16'h03ff) // RAM
    begin
      ram_we = bus_we;
      ram_write_addr = bus_write_addr;
      ram_write_data = bus_write_data;

      uart_go = 0;
      uart_tx_data = 0;
    end

    else if (bus_write_addr == 16'h0400) // uart tx reg
    begin
      ram_we = 0;
      ram_write_addr = 0;
      ram_write_data = 0;

      uart_go = bus_we;
      uart_tx_data = bus_write_data;

    end
    else
    begin
      ram_we = 0;
      ram_write_addr = 0;
      ram_write_data = 0;

      uart_go = 0;
      uart_tx_data = 0;

    end
  end

  wire div_ce;
  assign div_ce = 1;
  wire toy_ce;
  wire o_halted;

  assign toy_ce = div_ce;

  // clk_div toy_clk_div(i_clk, i_reset, div_ce);
  tx #(.BAUD_DIV(BAUD_DIV)) toy_tx (i_clk, i_reset, uart_go, uart_tx_data, o_tx, uart_ready);
  ram toy_ram(i_clk, toy_ce, ram_we, ram_write_addr, ram_read_addr, ram_write_data, ram_read_data);
  cpu toy_cpu(i_clk, toy_ce, i_reset, bus_read_data, bus_write_data, bus_read_addr, bus_write_addr, bus_we, o_halted);

endmodule
