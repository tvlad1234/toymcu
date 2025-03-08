`default_nettype none

module uart #(parameter BAUD_DIV = 128, parameter BASE_ADDR = 16'h0400)
  (
    input wire i_clk,
    input wire i_rst,
    input wire i_we,
    input wire [15:0] i_addr,
    input wire[7:0] i_data,
    output reg [7:0] o_data,

    output wire o_tx,
    input wire i_rx,

    output reg interrupt
  );

  reg [7:0] rx_data, tx_data;
  wire rx, rx_avail, rx_err, tx_ready;
  reg rx_ack, tx_go, tx_go_del;

  wire [7:0] status; // status register [rx available, rx error, tx ready]
  assign status = {5'd0, rx_avail, rx_err, tx_ready};

  always @(posedge i_clk)
  begin

    interrupt <= rx_avail || rx_err;

    if(!i_rst)
    begin
      tx_go_del <= tx_go;
      case (i_addr)
        BASE_ADDR:
        begin
          o_data <= rx_data;
          if(i_we)
          begin
            tx_data <= i_data;
            tx_go <= 1;
            rx_ack <= 0;
          end
          else
          begin
            tx_go <= 0;
            rx_ack <= 1;
          end
        end

        BASE_ADDR + 1:
        begin
          o_data <= status;
          if(i_we)
          begin
            tx_go <= 0;
            rx_ack <= 1;
          end
          else
          begin
            tx_go <= 0;
            rx_ack <= 0;
          end
        end

        default:
        begin
          tx_go <= 0;
          rx_ack <= 0;
        end
      endcase
    end

    else
    begin
      interrupt <= 0;
      tx_go <= 0;
      rx_ack <= 0;
      tx_go_del <= 0;
    end

  end


  rx #(.BAUD_DIV(BAUD_DIV)) u_rx (i_clk, i_rst, i_rx, rx_ack, rx_data, rx_err, rx_avail);
  tx #(.BAUD_DIV(BAUD_DIV)) u_tx (i_clk, i_rst, tx_go_del, tx_data, o_tx, tx_ready);

endmodule
