`default_nettype none

module gpio #(parameter BASE_ADDR = 16'h0430)
  (
    input wire i_clk,
    input wire i_rst,
    input wire i_we,
    input wire [15:0] i_addr,
    input wire[15:0] i_data,
    output reg [15:0] o_data,

    input wire [15:0] i_gp,
    output reg [15:0] o_gp
  );


  always @(posedge i_clk)
  begin

    if(!i_rst)
    begin

      case (i_addr)
        BASE_ADDR: // GPIO data
        begin
          if(i_we)
          begin
            o_gp <= i_data;
          end
          else
          begin
            o_data <= i_gp;
          end
        end

        BASE_ADDR + 1: // Output toggle
        begin
          if(i_we)
          begin
            o_gp <= o_gp ^ i_data;
          end
          else
          begin
            o_data <= i_gp;
          end
        end

        default:
        begin
          o_data <= 0;
        end
      endcase
    end

    else
    begin
      o_gp <= 0;
      o_data <= 0;
    end

  end

endmodule
