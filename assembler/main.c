#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "assembler_types.h"

label_t labels[1024];
int num_labels = 0;

mem_loc_t memory[1024];
int num_mem_loc = 0;
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
        parseLine(lineptr, linenum++, filename);

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

    /*
    // load 1 into R1;
    memory[current_addr].instr.opcode = 7; // LDA
    memory[current_addr].instr.format = INST_FORMAT_2;
    memory[current_addr].type = MEM_TYPE_INST;
    memory[current_addr].instr.rd = 1;
    memory[current_addr].instr.addr = 1;
    memory[current_addr].instr.imm_type = IMM_DIRECT;
    current_addr++;
    */

    for (int i = 1; i < argc - 1; i++)
    {
        assembleFile(argv[i]);
        num_mem_loc = current_addr;
    }

    printf("%d memory locations used\n\n\r", num_mem_loc);

    /*
        printf("First pass result:\n\r");
        for (int i = 0; i < num_mem_loc; i++)
            showMemLoc(&memory[i]);
    */

    // Second pass:
    for (int i = 0; i < num_mem_loc; i++)
    {
        mem_loc_t *mem = &memory[i];

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
        }
    }

    /*
        printf("\n\rSecond pass result:\n\r");
        for (int i = 0; i < num_mem_loc; i++)
            showMemLoc(&memory[i]);
    */

    // Print assembled program to memory file

    FILE *outfile = fopen(argv[argc - 1], "w");

    if (!outfile)
    {
        fprintf(stdout, "Error opening file %s\n\r", argv[2]);
        return -1;
    }

    // printf("\n\rMemory contents:\n\r");
    for (int i = 0; i < num_mem_loc; i++)
    {
        uint16_t c;
        if (memory[i].type == MEM_TYPE_INST)
            c = machine_inst(&memory[i].instr);
        else if (memory[i].type == MEM_TYPE_DATA)
            c = memory[i].data;
        //   printf("%04x\n", c);
        fprintf(outfile, "%04x\n", c);
    }

    fclose(outfile);

    return 0;
}
