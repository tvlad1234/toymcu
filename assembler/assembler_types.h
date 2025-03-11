#include <stdint.h>

#define SEP_SPACE " "

enum
{
    TYPE_OPCODE,
    TYPE_DATA
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

enum
{
    MACRO_INC,
    MACRO_DEC,
    MACRO_PUSH,
    MACRO_POP,
    MACRO_CALL,
    MACRO_NUMBER
};

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

enum
{
    MEM_TYPE_INST,
    MEM_TYPE_DATA,
    MEM_TYPE_MACRO
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
    char *filename;
    int linenum;
};
typedef struct instr_struct instr_t;

struct mem_loc_struct
{
    int type;
    uint16_t addr;
    uint16_t data;
    instr_t instr;
    int label_id;
};
typedef struct mem_loc_struct mem_loc_t;

struct label_struct
{
    uint16_t addr;
    char name[50];
};
typedef struct label_struct label_t;

enum
{
    REG_INVALID_REG = -3,
    REG_EXPECT_COMMA,
    REG_EXPECT_NAME
};

extern char opcode_strings[][10];
extern char macro_strings[][10];
extern char reg_names[][10];

uint16_t machine_inst(instr_t *inst);
int getReg(char name[], int comma);
void assert_reg(int reg, int linenum, char *filename);
int getValue(char token_ptr[]);
void getImm(char str1[], char str2[], int *imm_p, int *type_p);
void parseLine(char *lineptr, int linenum, char *filename, mem_loc_t *mem, int *ca_ptr);

uint16_t machine_inst(instr_t *inst);
void format1inst(instr_t *instr, int opcode, int rd, int rs, int rt);
void macroIncDec(int macro, int rd, mem_loc_t *mem, int *current_addr);
void showMemLoc(mem_loc_t *mem);

void macroPop(int rd, mem_loc_t *mem, int *current_addr);
void macroPush(int rd, mem_loc_t *mem, int *current_addr);
void macroCall(mem_loc_t *mem, int *current_addr);
