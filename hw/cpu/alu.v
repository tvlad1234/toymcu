/*
    16-bit ALU module
    Possible operations:
      - addition
      - substraction
      - logic AND
      - logic XOR
      - logic left shift (unsigned)
      - arithmetic right shift (signed)  
*/

`default_nettype none

module alu (
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    input wire [2:0] i_op,
    output reg [15:0] o_r
  );

  wire [3:0] shamt = i_b[3:0]; // maximum shift allowed is 15bits

  always @ (*)
  begin
    case (i_op)
      3'b001 :
        o_r = i_a + i_b; // addition
      3'b010 :
        o_r = i_a - i_b; // subtraction
      3'b011 :
        o_r = i_a & i_b; // logic AND
      3'b100 :
        o_r = i_a ^ i_b; // logic XOR
      3'b101 :
        o_r = i_a << shamt; // unsigned left shift
      3'b110 :
        o_r = $signed(i_a) >>> shamt; // signed right shift
      default:
        o_r = 0;
    endcase
  end

endmodule
