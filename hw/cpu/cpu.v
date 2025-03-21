
`default_nettype none

module cpu (
    input wire i_clk,
    input wire i_ce,
    input wire i_rst,
    input wire [15:0] i_mem_read_data,
    output wire [15:0] o_mem_write_data,
    output reg [15:0] o_mem_addr,
    output reg o_ram_we,
    output reg o_halted,
    input wire i_int
  );

  localparam interrupt_vector = 16'h2002;

  // Internal signals:
  reg [15:0] pc;
  reg [15:0] next_pc;
  reg [15:0] ir;

  // Interrupt control
  reg interrupt, int_enable;
  reg [15:0] o_int_ret_pc;

  // Instruction decoding
  wire [3:0] inst_opcode = ir[15:12];
  wire [3:0] inst_dest = ir[11:8];
  wire [3:0] inst_src_s = ir[7:4];
  wire [3:0] inst_src_t = ir[3:0];
  wire [7:0] inst_addr_imm = ir[7:0];

  // Register signals
  reg [3:0] reg_addr_1;
  wire [3:0] reg_addr_2 = inst_src_t;
  wire [3:0] reg_addr_w = inst_dest;
  wire [15:0] reg_data_1;
  wire [15:0] reg_data_2;
  reg [15:0] reg_data_w;
  wire [15:0] reg_seg_c;
  wire [15:0] reg_seg_d;
  reg reg_we;

  assign o_mem_write_data = reg_data_1;

  // ALU signals
  wire [2:0] alu_opcode = inst_opcode[2:0];
  wire [15:0] alu_op1 = reg_data_1;
  wire [15:0] alu_op2 = reg_data_2;
  wire [15:0] alu_r;

  // CPU state
  reg [2:0] currentState;
  localparam state_reset = 3'd0;
  localparam state_read_inst = 3'd1;
  localparam state_fetch = 3'd2;
  localparam state_decode = 3'd3;
  localparam state_read_data = 3'd4;
  localparam state_writeback = 3'd5;

  // ALU instance
  alu cpu_alu(alu_op1, alu_op2, alu_opcode, alu_r);

  // Register file instance
  reg_file cpu_regs(i_clk, i_ce, i_rst, reg_we, reg_addr_1, reg_addr_2, reg_addr_w, reg_data_w, reg_data_1, reg_data_2, reg_seg_c, reg_seg_d);

  // Register write enable for first 8 opcodes and for hA and hF
  always @(currentState, inst_opcode)
  begin
    if( (currentState == state_writeback) && ((inst_opcode < 4'd9) || (inst_opcode == 4'hA) || (inst_opcode == 4'hF)) )
      reg_we = 1;
    else
      reg_we = 0;
  end

  /*
    Register write data source
      - ALU for the first 6 opcodes
      - immediate address for h7
      - memory for h8 and hA
      - PC for hF
  */
  always @(inst_opcode, alu_r, inst_addr_imm, i_mem_read_data, pc)
  begin
    if(inst_opcode <= 4'd6)
      reg_data_w = alu_r;
    else if(inst_opcode == 4'h7)
      reg_data_w = inst_addr_imm;
    else if(inst_opcode == 4'h8 || inst_opcode == 4'hA)
      reg_data_w = i_mem_read_data;
    else if(inst_opcode == 4'hF)
      reg_data_w = pc + 1;
    else
      reg_data_w = 0;

  end

  /*
     Source register for the first register read port
     (address for the second port (register T) is hardwired)
         - source s for first 6 opcodes
         - d for some others
  */
  always @(inst_opcode, inst_src_s, inst_dest)
  begin
    if(inst_opcode <= 4'd6)
      reg_addr_1 = inst_src_s;
    else
      reg_addr_1 = inst_dest;

  end

  /*
       Memory write enable
           - only for store instructions (h9 and hB)
  */
  always@(currentState, inst_opcode)
  begin
    if( (currentState == state_writeback) && (inst_opcode == 4'd9 || inst_opcode == 4'hB) )
      o_ram_we = 1;
    else
      o_ram_we = 0;
  end

  /*
    Memory read address
     - PC while fetching
     - immediate address (segmented addressing) for load (8) and store (9)
     - second register data port for indirect load (A) and store (B)
  */

  always @(currentState, pc, inst_addr_imm, reg_data_2)
  begin
    if(currentState == state_read_inst || currentState == state_fetch)
      o_mem_addr = pc;
    else if(inst_opcode == 4'h8 || inst_opcode == 4'h9)
      o_mem_addr = (reg_seg_d << 8) + inst_addr_imm;
    else if(inst_opcode == 4'hA || inst_opcode == 4'hB)
      o_mem_addr = reg_data_2;
    else
      o_mem_addr = 0;
  end

  /*
      Next value for PC
  */

  reg iret;

  always @(inst_opcode, reg_data_1, inst_addr_imm, pc, reg_addr_1, o_int_ret_pc)
  begin

    if((inst_opcode == 4'hF) || (inst_opcode == 4'hC && reg_data_1 == 0) || (inst_opcode == 4'hD && !reg_data_1[15] && reg_data_1 != 0) )
    begin
      next_pc = (reg_seg_c << 8) + inst_addr_imm;
      iret = 0;
    end

    else if(inst_opcode == 4'hE) // JMP
    begin
      // JMP R0 return from interrupt
      if(reg_addr_1 == 0)
      begin
        next_pc = o_int_ret_pc;
        iret = 1;
      end
      else
      begin
        next_pc = reg_data_1;
        iret = 0;
      end
    end

    else
    begin
      next_pc = pc + 1;
      iret = 0;
    end

  end

  always @(posedge i_clk)
  begin
    if(!i_rst)
    begin
      if (i_ce)
      begin

        if(i_int && int_enable)
        begin
          interrupt <= 1;
          int_enable <= 0;
        end

        if(!o_halted)
        begin
          case (currentState)

            state_reset: // from reset to fetch:
            begin
              interrupt <= 0;
              int_enable <= 1;
              pc <= 16'h2000;
              currentState <= state_read_inst;
            end

            state_read_inst:
            begin
              currentState <= state_fetch;
            end

            state_fetch: // from fetch to decode:
            begin
              ir <= i_mem_read_data;
              currentState <= state_decode;
            end

            state_decode: // from decode to execute:
            begin
              if(inst_opcode == 0) // if HALT opcode
                o_halted <= 1;
              currentState <= state_read_data;
            end

            state_read_data:
            begin
              currentState <= state_writeback;
            end

            state_writeback: // from writeback back to fetch:
            begin

              if(interrupt)
              begin
                pc <= interrupt_vector;
                o_int_ret_pc <= next_pc;
                interrupt <= 0;
              end
              else
                pc <= next_pc;

              if(iret)
                int_enable <= 1;

              currentState <= state_read_inst;
            end

            default:
              currentState <= state_reset;
          endcase
        end
      end
    end

    else // reset logic
    begin
      currentState <= state_reset;
      o_halted <= 0;
    end

  end

endmodule
