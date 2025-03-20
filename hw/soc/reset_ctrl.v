
`default_nettype none

module reset_ctrl (
    input wire i_clk,
    input wire i_rst,
    output reg o_rst
  );

    reg rst_sig;
    reg [1:0] state;

    initial
        state = 0;

    always @(posedge i_clk)
    begin

        o_rst <= i_rst || rst_sig;

        if(i_rst)
            state <= 0;
        else
        case (state)
            0: 
            begin 
                rst_sig <= 0;
                state <= state + 1;
            end

            1: 
            begin 
                rst_sig <= 1;
                state <= state + 1;
            end

            2: 
            begin 
                rst_sig <= 0;
                state <= state + 1;
            end

            3: state <= state;

            default: state <= 0;
        endcase
    end

endmodule
