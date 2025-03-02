/*
    1024 * 16bits RAM
      - synchronous read
      - synchronous write gated by write enable and clock enable
*/

`default_nettype none

module ram (
    input wire i_clk,
    input wire i_ce,
    input wire i_we,
    input wire [9:0] i_w_addr,
    input wire [9:0] i_r_addr,
    input wire [15:0] i_w_data,
    output reg [15:0] o_r_data
  );

  reg [15:0] mem [0:1023];
  initial
  begin

    mem[0] = 16'h7101; // R1 stores the value 0x01

    // Set R7 to 800  (0x0320)
    mem[1] = 16'h7804; // R8 stores the value 4
    mem[2] = 16'h7732; // load 0x32 to R7
    mem[3] = 16'h5778; // shift left 4 positions

    mem[4] = 16'hA307; // load character (from addr in R7 into R3)

    // Set code segment to 0300 (routines area)
    mem[5] = 16'h7E03; // load 0x03 to RE (CS)

    mem[6] = 16'hFC02; // call output R3 to UART (link back through RC) (address 770)

    mem[7] = 16'h7E00; // set code segment to 0000 (main program area)
    mem[8] = 16'hC30B; // if R3 == 0 exit

    mem[9] = 16'h1771; // R7 <- R7 + R1 (increment message pointer)
    mem[10] = 16'hF004; // jump to reading the next character

    mem[11] = 0; // halt

    // Address 0x0302 = 770
    // UART output routine, from register R3

    // Set data segment to IO (0400)
    mem[770] = 16'h7f04; // load 04 to RF (DS)

    // Wait for UART ready
    mem[771] = 16'h8200; // Load 0400 + 0 (UART status) in R2
    mem[772] = 16'hC203; // if R2==0 (UART is not ready), branch to the CS + 3 (771)

    mem[773] = 16'h9300; // transmit

    mem[774] = 16'hEC00; // jump back to main program (at address RC)

    // Message:
    mem[800] = 16'h0048; // H
    mem[801] = 16'h0065; // e
    mem[802] = 16'h006C; // l
    mem[803] = 16'h006C; // l
    mem[804] = 16'h006f; // o
    mem[805] = 16'h0020; //
    mem[806] = 16'h0077; // w
    mem[807] = 16'h006f; // o
    mem[808] = 16'h0072; // r
    mem[809] = 16'h006c; // l
    mem[810] = 16'h0064; // d
    mem[811] = 16'h0021; // !
    mem[812] = 16'h000A; // newline
    mem[813] = 16'h000D; // carriage return
    mem[814] = 16'h0000; // string terminator

  end

  always @ (posedge i_clk)
  begin
    o_r_data <= mem[i_r_addr];
  end

  always @ (posedge i_clk)
  begin
    if(i_we && i_ce)
      mem[i_w_addr] <= i_w_data;
  end

endmodule
