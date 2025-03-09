`default_nettype none

module interrupt_ctrl #(parameter BASE_ADDR = 16'h0410)
  (
    input wire i_clk,
    input wire i_rst,
    input wire i_we,
    input wire [15:0] i_addr,
    input wire[15:0] i_data,
    output reg [15:0] o_data,

    input wire [15:0] i_lines,
    output reg o_int
  );

  reg [15:0] int_number, int_en;

  always @(posedge i_clk)
  begin

    if(!i_rst)
    begin
      if((i_lines & int_en) != 0)
      begin
        for(integer i = 0; i<16; i++)
          if(i_lines[i] && int_en[i])
          begin
            o_int <= 1;
            int_number <= i+1;
          end
      end
      else
        o_int <= 0;

      case (i_addr)
        BASE_ADDR:
        begin

          if(i_we)
          begin
            int_en <= i_data;
          end
          else
          begin
            o_data <= int_number;
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
      o_int <= 0;
      int_number <= 0;
      o_data <= 0;
      int_en <= 0;
    end

  end

endmodule
