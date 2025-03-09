`default_nettype none

module timer #(parameter BASE_ADDR = 16'h0420)
  (
    input wire i_clk,
    input wire i_rst,
    input wire i_we,
    input wire [15:0] i_addr,
    input wire[15:0] i_data,
    output reg [15:0] o_data,

    output reg o_int_tick,
    output reg o_int_cnt
  );

  reg enable;
  reg [15:0] presc, cnt, div_cnt, cnt_cmp;

  always @(posedge i_clk)
  begin

    if(!i_rst)
    begin

      if (enable)
      begin
        if(cnt_cmp != 0)
        begin
          if(cnt == cnt_cmp)
          begin
            cnt <= 0;
            o_int_cnt <= 1;
          end
          else
            o_int_cnt <= 0;
        end
        else
          o_int_cnt <= 0;

        if(div_cnt == presc)
        begin
          div_cnt <= 1;
          o_int_tick <= 1;
          cnt <= cnt + 1;
        end
        else
        begin
          div_cnt <= div_cnt+1;
          o_int_tick <= 0;
        end
      end
      else
      begin
        o_int_tick <= 0;
        o_int_cnt <= 0;
      end

      case (i_addr)
        BASE_ADDR: // Counter
        begin
          if(i_we)
          begin
            cnt <= i_data;
          end
          else
          begin
            o_data <= cnt;
          end
        end


        BASE_ADDR + 1: // Prescaler
        begin
          if(i_we)
          begin
            presc <= i_data;
          end
          else
          begin
            o_data <= presc;
          end
        end


        BASE_ADDR + 2: // Enable
        begin
          if(i_we)
          begin
            enable <= i_data[0];
          end
          else
          begin
            o_data <= {15'd0, enable};
          end
        end

        BASE_ADDR + 3: // Counter compare
        begin
          if(i_we)
          begin
            cnt_cmp <= i_data;
          end
          else
          begin
            o_data <= cnt_cmp;
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
      o_int_tick <= 0;
      o_int_cnt <= 0;
      enable <= 0;
      presc <= 0;
      cnt <= 0;
      div_cnt <= 0;
      cnt_cmp <= 0;
    end

  end

endmodule
