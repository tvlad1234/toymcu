#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define SEP_SPACE " "

enum
{
    TYPE_OPCODE,
    TYPE_DATA,
};

enum
{
    OP_HALT,
    OP_ADD,
    OP_SUB,
    OP_AND,
    OP_XOR,
    OP_LSI,
    OP_RS,
    OP_LDA,
    OP_LD,
    OP_ST,
    OP_LDI,
    OP_STI,
    OP_BZ,
    OP_BP,
    OP_JMP,
    OP_JL,
    OP_NUMBER
};

char opcode_strings[][10] = {"HALT", "ADD", "SUB", "AND", "XOR", "LS", "RS", "LDA", "LD", "ST", "LDI", "STI", "BZ", "BP", "JMP", "JL"};

enum
{
    MACRO_INC,
    MACRO_DEC,
    MACRO_PUSH,
    MACRO_POP,
    MACRO_NUMBER
};

char macro_strings[][10] = {"INC", "DEC", "PUSH", "POP"};

char reg_names[][10] = {"R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "RA", "RB", "RC", "SP", "CS", "DS"};

enum
{
    INST_FORMAT_1 = 1,
    INST_FORMAT_2,
    INST_FORMAT_J,
    INST_HALT
};

enum
{
    IMM_DIRECT,
    IMM_OFFSET,
    IMM_SEGMENT
};

enum
{
    LINE_UNKNOWN = 0,
    LINE_DATA,
    LINE_OPCODE,
    LINE_MACRO
};

struct instr_struct
{
    uint8_t opcode;
    uint8_t format;
    uint16_t addr;
    uint8_t imm_labeled;
    uint8_t imm_type;
    uint8_t rd, rs, rt;
    char label_name[50];
    int linenum;
};
typedef struct instr_struct instr_t;

enum
{
    MEM_TYPE_INST,
    MEM_TYPE_DATA
};

struct mem_loc_struct
{
    int type;
    uint16_t addr;
    uint16_t data;
    instr_t instr;
};
typedef struct mem_loc_struct mem_loc_t;

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

struct label_struct
{
    uint16_t addr;
    char name[50];
};
typedef struct label_struct label_t;

label_t labels[50];
int num_labels = 0;

mem_loc_t memory[1024];
int num_mem_loc = 0;

#define REG_EXPECT_NAME -1
#define REG_EXPECT_COMMA -2
#define REG_INVALID_REG -3

int getReg(char name[], int comma)
{
    int reg = -1;

    if (comma)
    {
        if (name[strlen(name) - 1] != ',')
            return REG_EXPECT_COMMA;
        name[strlen(name) - 1] = 0;
    }

    for (int i = 0; i < 16; i++)
        if (!strcmp(name, reg_names[i]))
            reg = i;

    if (reg == -1)
        return REG_EXPECT_NAME;

    return reg;
}

void assert_reg(int reg, int linenum)
{
    if (reg == REG_EXPECT_NAME)
    {
        printf("\n\rAt line %d: expected register name \n\r", linenum);
        exit(-1);
    }
    else if (reg == REG_EXPECT_COMMA)
    {
        printf("\n\rAt line %d: expected comma after register name\n\r", linenum);
        exit(-1);
    }
    else if (reg == REG_INVALID_REG)
    {
        printf("\n\rAt line %d: invalid register R%d\n\r", linenum, reg);
        exit(-1);
    }
}

int getValue(char token_ptr[])
{
    int addr;
    if (token_ptr[0] == '0' && token_ptr[1] == 'x')
    {
        sscanf(token_ptr + 2, "%x", &addr);
        return addr;
    }

    if (token_ptr[0] == '\'')
        return token_ptr[1];

    else
    {
        int l = strlen(token_ptr);
        for (int i = 0; i < l; i++)
            if (token_ptr[i] > '9' || token_ptr[i] < '0')
                return -1;
    }
    return atoi(token_ptr);
}

void getImm(char str1[], char str2[], int *imm_p, int *type_p)
{
    int addr, imm_type;

    if (!strcmp(str1, "OFFSET"))
        imm_type = IMM_OFFSET;
    else if (!strcmp(str1, "SEGMENT"))
        imm_type = IMM_SEGMENT;
    else
        imm_type = IMM_DIRECT;

    if (imm_type == IMM_DIRECT)
        addr = getValue(str1);
    else
        addr = getValue(str2);

    *imm_p = addr;
    *type_p = imm_type;
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

int main(int argc, char *argv[])
{

    if (argc < 3)
    {
        printf("Not enough arguments!\n\r");
        exit(-1);
    }

    FILE *srcfile = fopen(argv[1], "r");

    if (!srcfile)
    {
        fprintf(stdout, "Error opening file %s\n\r", argv[1]);
        return -1;
    }

    char line[40][40];
    int linenum = 0;
    int r;
    size_t readlen;

    int current_addr = 0;

    // load 1 into R1;
    memory[current_addr].instr.opcode = 7; // LDA
    memory[current_addr].instr.format = INST_FORMAT_2;
    memory[current_addr].type = MEM_TYPE_INST;
    memory[current_addr].instr.rd = 1;
    memory[current_addr].instr.addr = 1;
    memory[current_addr].instr.imm_type = IMM_DIRECT;
    current_addr++;

    do
    {
        // Read line from source file
        char *lineptr;
        r = getline(&lineptr, &readlen, srcfile); // must replace getline with something else
        linenum++;
        if (lineptr[0] == '#')
            continue;
        char *lineptr_b = lineptr;
        // Break it into tokens
        char *p = strtok(lineptr, SEP_SPACE);
        int token_num = 0;
        while (p)
        {

            if (p[strlen(p) - 1] == '\n')
                p[strlen(p) - 1] = 0;

            strcpy(line[token_num], p);
            token_num++;
            p = strtok(NULL, SEP_SPACE);
        }

        // if (lineptr_b)
        //   free(lineptr_b);

        // Process tokens
        int current_token = 0;
        char *token_ptr = line[current_token];

        if (token_ptr[0] == 0)
            continue;

        // check if first token is label:
        if (current_token == 0 && token_ptr[strlen(token_ptr) - 1] == ':')
        {
            token_ptr[strlen(token_ptr) - 1] = 0;

            strcpy(labels[num_labels].name, token_ptr);
            labels[num_labels].addr = current_addr;

            printf("Label \"%s\" at addr %d\n\r", labels[num_labels].name, labels[num_labels].addr);

            num_labels++;
            token_ptr = line[++current_token];
        }

        if (current_token < token_num)
        {
            int line_type = 0;
            // search for opcode:
            uint8_t opcode;
            for (int i = 0; i < OP_NUMBER && !line_type; i++)
                if (!strcmp(token_ptr, opcode_strings[i]))
                {
                    line_type = LINE_OPCODE;
                    opcode = i;
                }

            // search for macro:
            uint8_t macro;
            for (int i = 0; i < MACRO_NUMBER && !line_type; i++)
                if (!strcmp(token_ptr, macro_strings[i]))
                {
                    line_type = LINE_MACRO;
                    macro = i;
                }

            // search for data declarations
            if (!strcmp(token_ptr, "DW"))
            {
                line_type = LINE_DATA;
                while (current_token < token_num - 1)
                {
                    token_ptr = line[++current_token];
                    memory[current_addr].addr = current_addr;
                    memory[current_addr].type = MEM_TYPE_DATA;
                    memory[current_addr].instr.linenum = linenum;
                    int data = getValue(token_ptr);
                    memory[current_addr].data = data;
                    current_addr++;
                }
            }

            if (!line_type)
            {
                printf("\n\rAt line %d: unknown instruction \"%s\"\n\r", linenum, token_ptr);
                exit(-1);
            }

            else if (line_type == LINE_OPCODE)
            {
                memory[current_addr].instr.opcode = opcode;
                memory[current_addr].instr.linenum = linenum;
                memory[current_addr].type = MEM_TYPE_INST;

                token_ptr = line[++current_token];

                // instr type:
                uint8_t instr_format;

                if ((opcode > 0 && opcode < 7) || opcode == 0xa || opcode == 0xb)
                    instr_format = INST_FORMAT_1;
                else if (opcode == 0)
                    instr_format = INST_HALT;
                else if (opcode == 0xe)
                    instr_format = INST_FORMAT_J;
                else
                    instr_format = INST_FORMAT_2;

                memory[current_addr].instr.format = instr_format;

                // parameter parsing
                if (instr_format == INST_FORMAT_1)
                {
                    int reg;

                    // d
                    reg = getReg(token_ptr, 1);
                    assert_reg(reg, linenum);
                    memory[current_addr].instr.rd = reg;
                    token_ptr = line[++current_token];

                    // s
                    if (opcode != 0xa && opcode != 0xb)
                    {
                        reg = getReg(token_ptr, 1);
                        assert_reg(reg, linenum);
                        memory[current_addr].instr.rs = reg;
                        token_ptr = line[++current_token];
                    }
                    else
                        memory[current_addr].instr.rs = 0;

                    // t
                    reg = getReg(token_ptr, 0);
                    assert_reg(reg, linenum);
                    memory[current_addr].instr.rt = reg;
                    token_ptr = line[++current_token];
                }

                else if (instr_format == INST_FORMAT_2)
                {
                    // d
                    int reg = getReg(token_ptr, 1);
                    assert_reg(reg, linenum);
                    memory[current_addr].instr.rd = reg;
                    token_ptr = line[++current_token];

                    int imm_type, addr;

                    getImm(token_ptr, line[++current_token], &addr, &imm_type);

                    memory[current_addr].instr.imm_type = imm_type;
                    if (addr == -1)
                    {
                        memory[current_addr].instr.imm_labeled = 1;
                        strcpy(memory[current_addr].instr.label_name, token_ptr);
                    }
                    else
                    {
                        memory[current_addr].instr.imm_labeled = 0;
                        memory[current_addr].instr.addr = addr;
                    }
                }

                else if (instr_format == INST_FORMAT_J)
                {
                    // d
                    int reg = getReg(token_ptr, 0);
                    assert_reg(reg, linenum);
                    memory[current_addr].instr.rd = reg;
                    token_ptr = line[++current_token];
                }

                // Next address
                memory[current_addr].addr = current_addr;
                current_addr++;
            }

            else if (line_type == LINE_MACRO)
            {
                token_ptr = line[++current_token];

                if (macro == MACRO_INC || macro == MACRO_DEC)
                {
                    int rd = getReg(token_ptr, 0);
                    assert_reg(rd, linenum);

                    memory[current_addr].type = MEM_TYPE_INST;
                    memory[current_addr].addr = current_addr;
                    macroIncDec(macro, rd, &memory[current_addr].instr);
                    current_addr++;
                }

                else if (macro == MACRO_PUSH)
                {
                    int rd = getReg(token_ptr, 0);
                    assert_reg(rd, linenum);

                    // decrement stack pointer
                    memory[current_addr].type = MEM_TYPE_INST;
                    memory[current_addr].addr = current_addr;
                    macroIncDec(1, 13, &memory[current_addr].instr);
                    current_addr++;

                    // store rd to stack
                    memory[current_addr].type = MEM_TYPE_INST;
                    memory[current_addr].addr = current_addr;
                    format1inst(&memory[current_addr].instr, 0x0B, rd, 0, 13);
                    current_addr++;
                }

                else if (macro == MACRO_POP)
                {
                    int rd = getReg(token_ptr, 0);
                    assert_reg(rd, linenum);

                    // load rd from stack
                    memory[current_addr].type = MEM_TYPE_INST;
                    memory[current_addr].addr = current_addr;
                    format1inst(&memory[current_addr].instr, 0x0A, rd, 0, 13);
                    current_addr++;

                    // increment stack pointer
                    memory[current_addr].type = MEM_TYPE_INST;
                    memory[current_addr].addr = current_addr;
                    macroIncDec(0, 13, &memory[current_addr].instr);
                    current_addr++;
                }
            }
        }
    } while (r != -1);

    fclose(srcfile);

    num_mem_loc = current_addr;
    printf("%d memory locations used\n\n\r", num_mem_loc);

    printf("First pass result:\n\r");
    for (int i = 0; i < num_mem_loc; i++)
        showMemLoc(&memory[i]);

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
                    printf("At line %d: label \"%s\" not declared!\n\r", mem->instr.linenum, mem->instr.label_name);
                    exit(-1);
                }
            }

            int addr = mem->instr.addr;
            int seg = addr / 256;
            int off = addr - seg;

            if (mem->instr.imm_type == IMM_OFFSET)
                mem->instr.addr = off;
            else if (mem->instr.imm_type == IMM_SEGMENT)
                mem->instr.addr = seg;
            mem->instr.imm_type = IMM_DIRECT;
        }
    }

    printf("\n\rSecond pass result:\n\r");
    for (int i = 0; i < num_mem_loc; i++)
    {
        showMemLoc(&memory[i]);
    }

    // Print assembled program to memory file

    FILE *outfile = fopen(argv[2], "w");

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
