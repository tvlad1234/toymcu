#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "assembler_types.h"

uint16_t machine_inst(instr_t *inst)
{
    uint16_t i = 0;
    i = i + (inst->opcode << 12);
    i = i + (inst->rd << 8);

    if (inst->format == INST_FORMAT_1)
    {
        i = i + (inst->rs << 4);
        i = i + (inst->rt);
    }

    else if (inst->format == INST_FORMAT_2)
        i = i + (inst->addr);

    return i;
}

void format1inst(instr_t *instr, int opcode, int rd, int rs, int rt)
{
    instr->opcode = opcode;
    instr->format = INST_FORMAT_1;
    instr->rd = rd;
    instr->rs = rs;
    instr->rt = rt;
    instr->imm_type = IMM_DIRECT;
}

void format2inst(instr_t *instr, int opcode, int rd, int addr, int imm_type, char *label_name)
{
    instr->opcode = opcode;
    instr->format = INST_FORMAT_2;
    instr->rd = rd;
    instr->addr = addr;
    instr->imm_type = imm_type;

    if (imm_type != IMM_DIRECT)
        strcpy(instr->label_name, label_name);
}

void macroIncDec(int macro, int rd, mem_loc_t *mem, int *current_addr)
{
    int opcode;
    if (macro)      // 0 is inc, 1 is dec
        opcode = 2; // SUB
    else
        opcode = 1; // ADD

    format1inst(&mem->instr, opcode, rd, rd, 1);

    mem->type = MEM_TYPE_INST;
    mem->addr = *current_addr;
    *current_addr = *current_addr + 1;
}

void macroPop(int rd, mem_loc_t *mem, int *current_addr)
{
    // load rd from stack
    mem->type = MEM_TYPE_INST;
    mem->addr = *current_addr;
    format1inst(&mem->instr, 0x0A, rd, 0, 13);
    *current_addr = *current_addr + 1;

    // increment stack pointer
    macroIncDec(0, 13, mem + 1, current_addr);
}

void macroPush(int rd, mem_loc_t *mem, int *current_addr)
{
    // decrement stack pointer
    macroIncDec(1, 13, mem, current_addr);
    mem++;

    // store rd to stack
    mem->type = MEM_TYPE_INST;
    mem->addr = *current_addr;
    format1inst(&mem->instr, 0x0B, rd, 0, 13);
    *current_addr = *current_addr + 1;
}

void macroCall(mem_loc_t *mem, int *current_addr)
{
    char *func_name = mem->instr.label_name;
    // printf("CALL %s at addr %d\n\r", func_name, *current_addr);

    // push RC
    macroPush(12, mem, current_addr);
    mem += 2;

    // set code segment
    format2inst(&mem->instr, 7, 14, mem->instr.addr, IMM_SEGMENT, func_name);
    mem->instr.imm_labeled = 1;
    mem->addr = *current_addr;
    *current_addr = *current_addr + 1;
    mem++;

    // JL RC, OFFSET func_name
    format2inst(&mem->instr, 0xF, 12, mem->instr.addr, IMM_OFFSET, func_name);
    mem->instr.imm_labeled = 1;
    mem->addr = *current_addr;
    *current_addr = *current_addr + 1;
    mem++;

    // pop RC
    macroPop(12, mem, current_addr);
}

void macroRet(mem_loc_t *mem, int *current_addr)
{
    mem->type = MEM_TYPE_INST;
    mem->addr = *current_addr;
    format1inst(&mem->instr, 0xE, 12, 0, 0);
    *current_addr = *current_addr + 1;
}

void showMemLoc(mem_loc_t *mem)
{
    printf("at %d: ", mem->addr);
    if (mem->type == MEM_TYPE_DATA)
    {
        printf("0x%x %c (data)\n\r", mem->data, mem->data);
    }
    else if (mem->type == MEM_TYPE_INST)
    {
        instr_t *inst = &mem->instr;

        if (!inst->imm_labeled)
            printf("%04x ", machine_inst(inst));

        printf("%s ", opcode_strings[inst->opcode]);

        if (inst->format == INST_FORMAT_1)
            printf("%s, %s, %s", reg_names[inst->rd], reg_names[inst->rs], reg_names[inst->rt]);
        else if (inst->format == INST_FORMAT_2)
        {
            printf("%s, ", reg_names[inst->rd]);
            if (inst->imm_type == IMM_OFFSET)
                printf("OFFSET ");
            else if (inst->imm_type == IMM_SEGMENT)
                printf("SEGMENT ");

            if (inst->imm_labeled)
                printf("%s", inst->label_name);
            else
                printf("0x%x", inst->addr);
        }
        else if (inst->format == INST_FORMAT_J)
            printf("%s, ", reg_names[inst->rd]);
        printf("\n\r");
    }
    else
        printf("Unknown type \n\r");
}
