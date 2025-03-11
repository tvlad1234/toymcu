#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "assembler_types.h"

label_t labels[1024];
int num_labels = 0;

mem_loc_t mem_pass1[1024], mem_pass2[1024];
int num_loc_1 = 0, num_loc_2 = 0;
int current_addr = 0;

void addLabel(label_t *l, uint16_t addr, char *name)
{
    l->addr = addr;
    strcpy(l->name, name);
}

void assembleFile(char *filename)
{
    FILE *srcfile = fopen(filename, "r");

    if (!srcfile)
    {
        fprintf(stdout, "Error opening file %s\n\r", filename);
        exit(-1);
    }

    char lineptr[100];
    int linenum = 1;

    // Read and parse file line by line
    while (fgets(lineptr, sizeof(lineptr), srcfile))
    {
        mem_loc_t *m = mem_pass1 + current_addr;
        parseLine(lineptr, linenum++, filename, m, &current_addr);
    }

    fclose(srcfile);
}

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        printf("Not enough arguments!\n\r");
        exit(-1);
    }

    addLabel(&labels[num_labels++], 0x400, "UART_DATA");
    addLabel(&labels[num_labels++], 0x401, "UART_STATUS");

    addLabel(&labels[num_labels++], 0x410, "INT_CTRL");

    addLabel(&labels[num_labels++], 0x420, "TIM_CNT");
    addLabel(&labels[num_labels++], 0x421, "TIM_PRESC");
    addLabel(&labels[num_labels++], 0x422, "TIM_EN");
    addLabel(&labels[num_labels++], 0x423, "TIM_CNT_CMP");

    addLabel(&labels[num_labels++], 0x430, "GPIO_DATA");
    addLabel(&labels[num_labels++], 0x431, "GPIO_TOGGLE");

    for (int i = 1; i < argc - 1; i++)
    {
        assembleFile(argv[i]);
        num_loc_1 = current_addr;
    }

    /*
        printf("First pass result:\n\r");
        for (int i = 0; i < num_loc_1; i++)
            showMemLoc(&mem_pass1[i]);
    */

    // Macro expansion
    current_addr = 0;
    for (int i = 0; i < num_loc_1; i++)
    {
        mem_pass2[current_addr] = mem_pass1[i];
        mem_loc_t *mem = &(mem_pass2[current_addr]);

        mem->addr = current_addr;

        if (mem->type == MEM_TYPE_MACRO)
        {
            int macro = mem->instr.opcode;
            int rd = mem->instr.rd;

            if (macro == MACRO_INC || macro == MACRO_DEC)
                macroIncDec(macro, rd, mem, &current_addr);

            else if (macro == MACRO_PUSH)
                macroPush(rd, mem, &current_addr);

            else if (macro == MACRO_POP)
                macroPop(rd, mem, &current_addr);

            else if (macro == MACRO_CALL)
                macroCall(mem, &current_addr);
        }
        else
            current_addr++;
    }
    num_loc_2 = current_addr;

    // Label address resolution
    for (int i = 0; i < num_loc_2; i++)
    {
        mem_loc_t *mem = &mem_pass2[i];
        int label_id = mem->label_id;
        if (label_id)
        {
            labels[label_id].addr = i;
            printf("Label \"%s\" at addr %d\n\r", labels[label_id].name, labels[label_id].addr);
        }
    }

    // Label substitution
    current_addr = 0;
    for (int i = 0; i < num_loc_2; i++)
    {
        mem_loc_t *mem = &mem_pass2[current_addr];

        // check if instruction
        if (mem->type == MEM_TYPE_INST)
        {
            // if labeled, find and replace label
            if (mem->instr.imm_labeled)
            {
                int found_label = 0;
                for (int j = 0; j < num_labels && !found_label; j++)
                    if (!strcmp(mem->instr.label_name, labels[j].name))
                    {
                        found_label = 1;
                        mem->instr.addr = labels[j].addr;
                        mem->instr.imm_labeled = 0;
                    }

                if (!found_label)
                {
                    printf("\n\rIn file %s, at line %d: label \"%s\" not declared!\n\r", mem->instr.filename, mem->instr.linenum, mem->instr.label_name);
                    exit(-1);
                }
            }

            int addr = mem->instr.addr;
            int seg = addr / 256;
            int off = addr - (seg * 256);

            if (mem->instr.imm_type == IMM_OFFSET)
                mem->instr.addr = off;
            else if (mem->instr.imm_type == IMM_SEGMENT)
                mem->instr.addr = seg;
            mem->instr.imm_type = IMM_DIRECT;
            current_addr++;
        }
        else
            current_addr++;
    }

    printf("\n\rSecond pass result:\n\r");
    for (int i = 0; i < num_loc_2; i++)
        showMemLoc(&mem_pass2[i]);

    printf("%d memory locations used\n\n\r", num_loc_2);

    // Print assembled program to memory file

    FILE *outfile = fopen(argv[argc - 1], "w");

    if (!outfile)
    {
        fprintf(stdout, "Error opening file %s\n\r", argv[2]);
        return -1;
    }

    // printf("\n\rMemory contents:\n\r");
    for (int i = 0; i < num_loc_2; i++)
    {
        uint16_t c;
        if (mem_pass2[i].type == MEM_TYPE_INST)
            c = machine_inst(&mem_pass2[i].instr);
        else if (mem_pass2[i].type == MEM_TYPE_DATA)
            c = mem_pass2[i].data;
        //   printf("%04x\n", c);
        fprintf(outfile, "%04x\n", c);
    }

    fclose(outfile);

    return 0;
}
