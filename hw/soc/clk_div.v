
`default_nettype none

module clk_div (
    input wire i_clk,
    input wire i_rst,
    output wire o_ce
  );

  localparam div_factor = 10;
  reg [7:0] div_cnt;

  assign o_ce = div_cnt == 1;

  always @(posedge i_clk)
  begin
    if(i_rst)
    begin
      div_cnt <= 0;
    end

    else
    begin
      if(div_cnt == div_factor)
        div_cnt <= 1;
      else
        div_cnt <= div_cnt+1;
    end

  end

endmodule
