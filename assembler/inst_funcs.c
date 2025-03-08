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

void macroIncDec(int macro, int rd, instr_t *instr)
{
    int opcode;
    if (macro)      // 0 is inc, 1 is dec
        opcode = 2; // SUB
    else
        opcode = 1; // ADD

    format1inst(instr, opcode, rd, rd, 1);
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
