//------------------------------------------------------------------------------
//  Main source file.
//------------------------------------------------------------------------------
#include <stdio.h> // printf
#include <conio.h> // kbhit getch
#include <ctype.h> // tolower
#include <stdlib.h> // exit
#define CHIPS_IMPL
#define CHIPS_UTIL_IMPL
#include "z80.h"
#include "z80dasm.h"

#define DASM_MAX_STRLEN		(32)
#define DASM_MAX_BINLEN		(16)
#define DASM_ASM_STRLEN		(12)
#define LOG_STRLEN			(sizeof(title_line) - 3)

// trace kind
enum {
	TRACE_STOP = 0,		// Trace Stop
//	TRACE_HALF,			// Trace Half clock
	TRACE_CLCK,			// Trace one Clock
	TRACE_STEP,			// Trace Step instruction
	TRACE_LOOP			// Trace Loop
};

typedef struct {
	uint16_t cur_addr;
	int str_pos;
	char str_buf[DASM_MAX_STRLEN];
	int bin_pos;
	uint8_t bin_buf[DASM_MAX_BINLEN];
} dasm_t;

#define Z80_GET_PIN(p) ((pins & Z80_##p) == Z80_##p)
#define Z80_SET_PIN(p,v) {pins = (pins & ~Z80_##p) | (((v) & 1ULL) << Z80_PIN_##p);}
#define LOG_MSG(m) { printf("\r"); printf(work_clear); printf(m); }

static const uint8_t cpu_rom[] = {
	0xF3, 0x31, 0x00, 0x00, 0xED, 0x5E, 0xAF, 0xED, 0x47, 0xCD, 0x2B, 0x00, 0xAF, 0x32, 0x80, 0x00,
	0x32, 0x81, 0x00, 0xFB, 0xDB, 0x1C, 0xFE, 0xAA, 0x28, 0x08, 0x07, 0x47, 0x0E, 0x1E, 0xED, 0x41,
	0x18, 0xF2, 0x00, 0x76, 0x3E, 0x55, 0xD3, 0x1C, 0x00, 0x18, 0xE9, 0x21, 0x50, 0x00, 0x06, 0x03,
	0x0E, 0x10, 0xED, 0xB3, 0xC9, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x48, 0x87, 0x08, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xD9, 0x21, 0x81, 0x00, 0x34, 0xD9, 0xED, 0x45, 0xF5, 0x3A,
	0x80, 0x00, 0x3C, 0x32, 0x80, 0x00, 0xF1, 0xFB, 0xED, 0x4D, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF
	// 0000:                           ORG     ROM_B
	// 0000:                   START:
	// 0000: F3       [ 4]             DI
	// 0001: 310000   [14]             LD      SP, 0000H
	// 0004: ED5E     [22]             IM      2
	// 0006: AF       [26]             XOR     A
	// 0007: ED47     [35]             LD      I, A
	// 0009: CD2B00   [52]             CALL    IOSET
	// 000C: AF       [56]             XOR     A
	// 000D: 328000   [69]             LD      (CT0CNT), A
	// 0010: 328100   [82]             LD      (NMICNT), A
	// 0013: FB       [86]             EI
	// 0014:                   LOOP:
	// 0014: DB1C     [11]             IN      A, (PIOA)
	// 0016: FEAA     [18]             CP      0AAH
	// 0018: 2808     [25|30]          JR      Z, BREAK
	// 001A: 07       [29]             RLCA
	// 001B: 47       [33]             LD      B, A
	// 001C: 0E1E     [40]             LD      C, PIOB
	// 001E: ED41     [52]             OUT     (C), B
	// 0020: 18F2     [64]             JR      LOOP
	// 0022:                   BREAK:
	// 0022: 00       [ 4]             NOP
	// 0023: 76       [ 8]             HALT
	// 0024: 3E55     [15]             LD      A, 55H
	// 0026: D31C     [26]             OUT     (PIOA), A
	// 0028: 00       [30]             NOP
	// 0029: 18E9     [42]             JR      LOOP
	// 002B:                   IOSET:
	// 002B: 215000   [10]             LD      HL, CTC0CD              ;CTC0コマンドセットアップ
	// 002E: 0603     [17]             LD      B, C0END - CTC0CD
	// 0030: 0E10     [24]             LD      C, CTC0
	// 0032: EDB3     [40|21]          OTIR
	// 0034: C9       [50]             RET
	// 0035: FFFFFFFF                  ORG     ENTRY + 04H
	// 0039: FF...             
	// 0044: 0000                      DW      0000H           ; 4: PIOA割り込み
	// 0046: 0000                      DW      0000H           ; 6: PIOB割り込み
	// 0048: 6E00                      DW      INTCT0          ; 8: CTC0割り込み
	// 004A: 0000                      DW      0000H           ;10: CTC1割り込み
	// 004C: 0000                      DW      0000H           ;12: CTC2割り込み
	// 004E: 0000                      DW      0000H           ;14: CTC3割り込み
	// 0050:                   CTC0CD:
	// 0050: 48                        DB      ENTRY + 8       ;CTC0インタラプトベクタ                 *****000 (全チャネル用)
	// 0051: 87                        DB      87H             ;CTC0チャンネルコントロールワード       *******1 (タイマモード)
	// 0052: 08                        DB      08H             ;CTC0タイムコンスタントレジスタ         (8)
	// 0053:                   C0END   EQU     $
	// 0053: FFFFFFFF                  ORG     0066H
	// 0057: FF...             
	// 0066:                   NMI:
	// 0066: D9       [ 4]             EXX
	// 0067: 218100   [14]             LD      HL, NMICNT
	// 006A: 34       [25]             INC     (HL)
	// 006B: D9       [29]             EXX
	// 006C: ED45     [43]             RETN
	// 006E:                   INTCT0:
	// 006E: F5       [11]             PUSH    AF
	// 006F: 3A8000   [24]             LD      A, (CT0CNT)
	// 0072: 3C       [28]             INC     A
	// 0073: 328000   [41]             LD      (CT0CNT), A
	// 0076: F1       [51]             POP     AF
	// 0077: FB       [55]             EI
	// 0078: ED4D     [69]             RETI
	// 007A: FFFFFFFF                  ORG     RAM_B
	// 007E: FFFF              
	// 0080: FF                CT0CNT: DS      1
	// 0081: FF                NMICNT: DS      1
};

// title string
static const char title_upln[] = "+--------+----+------+------+------+----+----+-----+-----+------+------+----+------+------+----+------+------+------+-------+-------+--------------+";
static const char title_item[] = "| Tick   | M1 | MREQ | IORQ | RFSH | RD | WR | INT | NMI | IFF1 | AB   | DB | PC   | SP   | IR | AF   | BC   | HL   | Io    | Mem   | Asm          |";
static const char title_line[] = "+--------+----+------+------+------+----+----+-----+-----+------+-ab---+-db-+-pc---+-sp---+-ir-+-af---+-bc---+-hl---+-io----+-mem---+-asm----------+";
static const char work_clear[] = "|                                                               |";
// F register state
static const char freg_state[] = "SZ.H.PNC";

static uint8_t cpu_memory[0x10000];
static uint8_t cpu_io[0x100];
static uint8_t int_vector = 0xE0;

// dasm informaion
static dasm_t dasm_info;
// trace informaion
static uint8_t trace_op;
static uint16_t break_addr;

static void dasm_init(void);
static uint8_t _dasm_in_cb(void* user_data);
static void _dasm_out_cb(char c, void* user_data);
static void dasm_disasm(uint16_t op_addr);
static bool z80_opdone_wrp(z80_t* cpu_state, uint64_t pins);
static void cpu_setIntVec(uint8_t val);
static uint8_t cpu_getIntVec(void);
static void trace_init(void);
static uint64_t trace_update(z80_t* cpu_state, uint64_t pins);
static int conv_hex(char c);
static void cmd_help(void);
static int get_hex_key(uint8_t size);
static int get_hex_str(char* str_buff, uint8_t size);
static char* conv_freg(uint8_t flag);
static void print_cpu_state(FILE* file, z80_t* cpu_state);
static void print_dump(FILE* file, uint8_t* data, uint32_t size);
static void load_hexfile(FILE* file);

void main(void) {
	z80_t cpu_state;
	uint32_t tick;
	char* val_Asm;

	// initialize dasm
	dasm_init();
	// initialize trace
	trace_init();

	// Initialize
	tick = 0;
	memcpy(cpu_memory, cpu_rom, sizeof(cpu_rom));
	memset(cpu_io, 0xFF, sizeof(cpu_io));
	val_Asm = dasm_info.str_buf;	// assembler string

	// command help message
	cmd_help();

	// print title
	printf(title_upln); printf("\n");
	printf(title_item); printf("\n");
	printf(title_upln); printf("\n");

	// z80_init
	uint64_t pins = z80_init(&cpu_state);
	cpu_setIntVec(0x48);

	while (true) {
		// update trace
		pins = trace_update(&cpu_state, pins);
		// z80_tick
		pins = z80_tick(&cpu_state, pins);

		// read
		tick ++;
		bool pin_M1 = Z80_GET_PIN(M1);
		bool pin_MREQ = Z80_GET_PIN(MREQ);
		bool pin_IORQ = Z80_GET_PIN(IORQ);
		bool pin_RFSH = Z80_GET_PIN(RFSH);
		bool pin_RD = Z80_GET_PIN(RD);
		bool pin_WR = Z80_GET_PIN(WR);
		bool pin_INT = Z80_GET_PIN(INT);
		bool pin_NMI = Z80_GET_PIN(NMI);
		bool val_IFF1 = cpu_state.iff1;
		uint16_t AddressBus = Z80_GET_ADDR(pins);
		uint8_t DataBus = Z80_GET_DATA(pins);
		uint16_t val_PC = cpu_state.pc;
		uint16_t val_SP = cpu_state.sp;
		uint8_t val_IR = cpu_state.opcode;
		uint16_t val_AF = cpu_state.af;
		uint16_t val_BC = cpu_state.bc;
		uint16_t val_HL = cpu_state.hl;

		// judge opcode fetch machine cycle
		if (z80_opdone_wrp(&cpu_state, pins)) {
			// disassemble the instruction
			dasm_disasm(AddressBus);
			// print line
			if (tick > 1) {
				printf(title_line); printf("\n");
			}
			// trace operation
			if (TRACE_STEP == trace_op) { trace_op = TRACE_STOP; }
			if (break_addr == AddressBus) { trace_op = TRACE_STOP; }
		}

		// print item
		printf("|%7d |", tick & 0x7FFFFF);
		pin_M1 ? printf(" M1 |") : printf("    |");
		pin_MREQ ? printf(" MREQ |") : printf("      |");
		pin_IORQ ? printf(" IORQ |") : printf("      |");
		pin_RFSH ? printf(" RFSH |") : printf("      |");
		pin_RD ? printf(" RD |") : printf("    |");
		pin_WR ? printf(" WR |") : printf("    |");
		pin_INT ? printf(" INT |") : printf("     |");
		pin_NMI ? printf(" MNI |") : printf("     |");
		val_IFF1 ? printf(" IFF1 |") : printf("      |");
		printf(" %04X |", AddressBus);
		printf(" %02X |", DataBus);
		printf(" %04X |", val_PC);
		printf(" %04X |", val_SP);
		printf(" %02X |", val_IR);
		printf(" %04X |", val_AF);
		printf(" %04X |", val_BC);
		printf(" %04X |", val_HL);
		printf(" %02X %02X |", cpu_io[0x1C], cpu_io[0x1E]);
		printf(" %02X %02X |", cpu_memory[0x0080], cpu_memory[0x0081]);
		printf(" %s |", val_Asm);
		printf("\n");

		// handle memory read or write access
		if (pin_MREQ) {
			if (pin_RD) {
				Z80_SET_DATA(pins, cpu_memory[Z80_GET_ADDR(pins)]);
			}
			else if (pin_WR) {
				cpu_memory[Z80_GET_ADDR(pins)] = Z80_GET_DATA(pins);
			}
		}
		// handle io read or write access
		else if (pin_IORQ) {
			if (pin_RD) {
				Z80_SET_DATA(pins, cpu_io[Z80_GET_ADDR(pins) & 0xFF]);
			}
			else if (pin_WR) {
				cpu_io[Z80_GET_ADDR(pins) & 0xFF] = Z80_GET_DATA(pins);
			}
		}

		// trace operation
//		if (TRACE_HALF == trace_op) { trace_op = TRACE_STOP; }
		if (TRACE_CLCK == trace_op) { trace_op = TRACE_STOP; }
	}
}

// initialize dasm
static void dasm_init(void) {
	memset(&dasm_info, 0, sizeof(dasm_t));
}

// disassembler callback to fetch the next instruction byte
static uint8_t _dasm_in_cb(void* user_data) {
	dasm_t* info = (dasm_t*) user_data;
	uint8_t val = cpu_memory[info->cur_addr++];
	if (info->bin_pos < DASM_MAX_BINLEN) {
		info->bin_buf[info->bin_pos++] = val;
	}
	return val;
}

// disassembler callback to output a character
static void _dasm_out_cb(char c, void* user_data) {
	dasm_t* info = (dasm_t*) user_data;
	if ((info->str_pos + 1) < DASM_MAX_STRLEN) {
		info->str_buf[info->str_pos++] = c;
		info->str_buf[info->str_pos] = 0;
	}
}

// disassemble the instruction
static void dasm_disasm(uint16_t op_addr) {
	dasm_info.str_pos = 0;
	dasm_info.bin_pos = 0;
	dasm_info.cur_addr = op_addr;
	z80dasm_op(op_addr, _dasm_in_cb, _dasm_out_cb, &dasm_info);
	// adjust length of assembler string
	if (dasm_info.str_pos < DASM_ASM_STRLEN) {
		memset(&dasm_info.str_buf[dasm_info.str_pos], ' ', DASM_ASM_STRLEN - dasm_info.str_pos);
		dasm_info.str_buf[DASM_ASM_STRLEN] = 0;
	}
}

// judge opcode fetch machine cycle
static bool z80_opdone_wrp(z80_t* cpu_state, uint64_t pins) {
	uint16_t AddressBus = Z80_GET_ADDR(pins);
	uint16_t IntVecAddress = (cpu_state->i << 8) | cpu_getIntVec();
	uint16_t IntIsrAddress = *(uint16_t*)&cpu_memory[IntVecAddress];
	bool pin_M1 = Z80_GET_PIN(M1);
	bool pin_IORQ = Z80_GET_PIN(IORQ);
	bool pin_HALT = Z80_GET_PIN(HALT);
	uint8_t val_IM = cpu_state->im;
	bool opdone = false;

	if (z80_opdone(cpu_state)) {
		// nmi event
		if (0x0066 == AddressBus) {
			printf("|%*s| <- NMI SrvRoutine\r", LOG_STRLEN, "");
		}
		// int event
		if ((IntIsrAddress == AddressBus) && (2 == val_IM)) {
			printf("|%*s| <- INT SrvRoutine\r", LOG_STRLEN, "");
		}
		opdone = true;
		// halt cycle
		if (pin_HALT) {
			printf(title_line); printf("\n");
			// disassemble the instruction
			dasm_disasm(cpu_state->pc);
			opdone = false;
			// trace operation
			if (TRACE_STEP == trace_op) { trace_op = TRACE_STOP; }
			if (break_addr == cpu_state->pc) { trace_op = TRACE_STOP; }
		}
	}
	// int ack cycle
	if (cpu_state->int_ack) {
		printf(title_line); printf("\n");
		// disassemble the instruction
		dasm_disasm(cpu_state->pc);
		// trace operation
		if (TRACE_STEP == trace_op) { trace_op = TRACE_STOP; }
		if (break_addr == cpu_state->pc) { trace_op = TRACE_STOP; }
	}
	// int acknowledge
	if (pin_M1 && pin_IORQ) {
		printf("|%*s| <- INT Acknowledge\r", LOG_STRLEN, "");
	}

	return opdone;
}

// set interrupt vector
static void cpu_setIntVec(uint8_t val) {
	int_vector = val;
}

// get interrupt vector
static uint8_t cpu_getIntVec(void) {
	return int_vector;
}

// initialize trace
static void trace_init(void) {
	trace_op = TRACE_CLCK;
	break_addr = 0xFFFF;
}

// update trace
static uint64_t trace_update(z80_t* cpu_state, uint64_t pins) {
	bool pin_M1 = Z80_GET_PIN(M1);
	bool pin_IORQ = Z80_GET_PIN(IORQ);
	uint8_t val_A = cpu_state->a;
	uint8_t val_F = cpu_state->f;
	uint16_t val_BC = cpu_state->bc;
	uint16_t val_DE = cpu_state->de;
	uint16_t val_HL = cpu_state->hl;
	uint16_t val_IX = cpu_state->ix;
	uint16_t val_IY = cpu_state->iy;
	FILE* file;
	int value;

	// check any key
	if (kbhit()) {
		trace_op = TRACE_STOP;
	}
	// trace operation
	while (TRACE_STOP == trace_op) {
		// print cpu state
		printf(work_clear); printf("\r");
		printf("]");
		if (Z80_GET_PIN(HALT)) { printf(" HALT"); }
//		if (Z80_GET_PIN(BUSAK)) { printf(" BUSAK"); }
		if (Z80_GET_PIN(WAIT)) { printf(" WAIT"); }
		if (Z80_GET_PIN(INT)) { printf(" INT"); }
		if (Z80_GET_PIN(NMI)) { printf(" NMI"); }
//		if (Z80_GET_PIN(RESET)) { printf(" RESET"); }
//		if (Z80_GET_PIN(BUSRQ)) { printf(" BUSRQ"); }
		printf("\r");

		// wait input key
		switch (tolower(getch())) {
		case '?':
			printf("|%*s|\r", LOG_STRLEN, "");
			// print help
			LOG_MSG(" traceC/S/L Wait Int Nmi Reset Edit Freg breaK Vect Print heX Quit\r");
			break;
//		case 'h':
//			trace_op = TRACE_HALF;
//			break;
		case 'c':
			trace_op = TRACE_CLCK;
			break;
		case 's':
			trace_op = TRACE_STEP;
			break;
		case 'l':
			trace_op = TRACE_LOOP;
			break;
		case 'w':
			Z80_SET_PIN(WAIT, !Z80_GET_PIN(WAIT));
			printf("|%*s| <- set z80_wait \r", LOG_STRLEN, "");
			break;
		case 'i':
			Z80_SET_PIN(INT, !Z80_GET_PIN(INT));
			printf("|%*s| <- set z80_int  \r", LOG_STRLEN, "");
			break;
		case 'n':
			Z80_SET_PIN(NMI, !Z80_GET_PIN(NMI));
			printf("|%*s| <- set z80_nmi  \r", LOG_STRLEN, "");
			break;
		case 'r':
			printf("|%*s| <- set z80_reset\r", LOG_STRLEN, "");
			printf("] Reset?(y/n)=");
			if ('y' == tolower(getche())) {
				pins = z80_reset(cpu_state);
				LOG_MSG(" Reset OK\r");
			}
			else {
				LOG_MSG(" Cancel\r");
			}
			break;
//		case 'b':
//			Z80_SET_PIN(BUSRQ, !Z80_GET_PIN(BUSRQ));
//			printf("|%*s| <- set z80_busrq\r", LOG_STRLEN, "");
//			break;
		case 'e':
			printf("|%*s| <- set io       \r", LOG_STRLEN, "");
			printf("] cpu_io[0x1C]=0x");
			if ((value = get_hex_key(2)) >= 0) {
				cpu_io[0x1C] = value;
				printf("\r");
				printf(work_clear);
				printf(" cpu_io[0x1C]=0x%02X OK\r", cpu_io[0x1C]);
			}
			else {
					LOG_MSG(" Error\r");
			}
			break;
		case 'f':
			printf("|%*s|\r", LOG_STRLEN, "");
			printf(work_clear);
			printf(" A=%02X", val_A);
			printf(" F=%s", conv_freg(val_F));
			printf(" BC=%04X", val_BC);
			printf(" DE=%04X", val_DE);
			printf(" HL=%04X", val_HL);
			printf(" IX=%04X", val_IX);
			printf(" IY=%04X", val_IY);
			printf("\r");
			break;
		case 'k':
			printf("|%*s|\r", LOG_STRLEN, "");
			printf("] break_addr=0x%04X edit?(y/n)=", break_addr);
			if ('y' == tolower(getche())) {
				printf("\r");
				printf(work_clear); printf("\r");
				printf("] break_addr=0x");
				if ((value = get_hex_key(4)) >= 0) {
					break_addr = value;
					printf("\r");
					printf(work_clear);
					printf(" break_addr=0x%04X OK\r", break_addr);
				}
				else {
					LOG_MSG(" Error\r");
				}
			}
			else {
				printf("\r");
				printf(work_clear);
				printf(" break_addr=0x%04X\r", break_addr);
			}
			break;
		case 'v':
			printf("|%*s|\r", LOG_STRLEN, "");
			printf("] int_vector=0x%02X edit?(y/n)=", cpu_getIntVec());
			if ('y' == tolower(getche())) {
				printf("\r");
				printf(work_clear); printf("\r");
				printf("] int_vector=0x");
				if ((value = get_hex_key(2)) >= 0) {
					cpu_setIntVec(value);
					printf("\r");
					printf(work_clear);
					printf(" int_vector=0x%02X OK\r", cpu_getIntVec());
				}
				else {
					LOG_MSG(" Error\r");
				}
			}
			else {
				printf("\r");
				printf(work_clear);
				printf(" int_vector=0x%04X\r", cpu_getIntVec());
			}
			break;
		case 'p':
			printf("|%*s|\r", LOG_STRLEN, "");
			// z80_cpu_trace.cpu
			if ((file = fopen("z80_cpu_trace.cpu","w")) == NULL) {
				LOG_MSG(" Error write z80_cpu_trace.cpu\r");
				break;
			}
			print_cpu_state(file, cpu_state);
			fclose(file);
			// z80_cpu_trace.mem
			if ((file = fopen("z80_cpu_trace.mem","w")) == NULL) {
				LOG_MSG(" Error write z80_cpu_trace.mem\r");
				break;
			}
			print_dump(file, cpu_memory, sizeof(cpu_memory));
			fclose(file);
			// z80_cpu_trace.io
			if ((file = fopen("z80_cpu_trace.io","w")) == NULL) {
				LOG_MSG(" Error write z80_cpu_trace.io\r");
				break;
			}
			print_dump(file, cpu_io, sizeof(cpu_io));
			fclose(file);
			LOG_MSG(" Print cpu state OK\r");
			break;
		case 'x':
			printf("|%*s|\r", LOG_STRLEN, "");
			printf("] load z80_cpu_trace.hex?(y/n)=");
			if ('y' == tolower(getche())) {
				// z80_cpu_trace.hex
				if ((file = fopen("z80_cpu_trace.hex","r")) == NULL) {
					LOG_MSG(" Error read z80_cpu_trace.hex\r");
					break;
				}
				load_hexfile(file);
				fclose(file);
				LOG_MSG(" Load hex file OK\r");
			}
			else {
				LOG_MSG(" Cancel load\r");
			}
			break;
		case 'q':
			exit(0);
			break;
		default:
			printf("|%*s|\r", LOG_STRLEN, "");
			LOG_MSG(" Error\r");
			break;
		}
	}
	// interrupt acknowledge
	if (pin_M1 && pin_IORQ) {
		Z80_SET_PIN(INT, false);
		Z80_SET_DATA(pins, cpu_getIntVec());
	}

	return pins;
}

// convert char to hex
static int conv_hex(char c) {
	int value = 0;

	char code = tolower(c);
	if (('0' <= code) && (code <= '9')) {
		value = code - '0';
	}
	else if (('a' <= code) && (code <= 'f')) {
		value = code - 'a' + 10;
	}
	else {
		value = -1;
	}

	return value;
}

// command help message
static void cmd_help(void) {
	printf("? :command help\n");
//	printf("H :trace Half clock\n");
	printf("C :trace one Clock\n");
	printf("S :trace Step instruction\n");
	printf("L :trace Loop\n");
	printf("W :toggle WAIT\n");
	printf("I :toggle INT\n");
	printf("N :toggle NMI\n");
	printf("R :toggle RESET\n");
//	printf("B :toggle BUSRQ\n");
	printf("E :Edit io value\n");
	printf("F :F register\n");
	printf("K :breaK address\n");
	printf("V :interrupt Vector\n");
	printf("P :Print cpu state\n");
	printf("X :heX file load\n");
	printf("Q :Quit\n");
}

// get hex by key input (upper limit 16 bits)
static int get_hex_key(uint8_t size) {
	int value;
	int rte_value = 0;

	for (int i = 0; i < size; i++) {
		if ((value = conv_hex(getche())) >= 0) {
			rte_value = (rte_value << 4) + value;
		}
		else {
			rte_value = -1;
			break;
		}
	}

	return rte_value;
}

// get hex by string (upper limit 16 bits)
static int get_hex_str(char* str_buff, uint8_t size) {
	int value;
	int rte_value = 0;

	for (int i = 0; i < size; i++) {
		if ((value = conv_hex(str_buff[i])) >= 0) {
			rte_value = (rte_value << 4) + value;
		}
		else {
			rte_value = -1;
			break;
		}
	}

	return rte_value;
}

// convert freg to string
static char* conv_freg(uint8_t flag) {
	static char str_buff[0x10];

	for (int i = 0; i < 8; i++) {
		if (((flag >> (7 - i)) & 0x01) == 0x01) {
			str_buff[i] = freg_state[i];
		}
		else {
			str_buff[i] = '.';
		}
	}
	str_buff[8] = 0;

	return str_buff;
}

// print cpu state
static void print_cpu_state(FILE* file, z80_t* cpu_state) {
	uint8_t val_A = cpu_state->a;
	uint8_t val_F = cpu_state->f;
	uint16_t val_BC = cpu_state->bc;
	uint16_t val_DE = cpu_state->de;
	uint16_t val_HL = cpu_state->hl;
	uint16_t val_IX = cpu_state->ix;
	uint16_t val_IY = cpu_state->iy;
	uint16_t val_SP = cpu_state->sp;
	uint16_t val_PC = cpu_state->pc;
	uint8_t val_I = cpu_state->i;
	uint8_t val_R = cpu_state->r;
	uint8_t val_A2 = cpu_state->af2 & 0xFF;
	uint8_t val_F2 = (cpu_state->af2 >> 8) & 0xFF;
	uint16_t val_BC2 = cpu_state->bc2;
	uint16_t val_DE2 = cpu_state->de2;
	uint16_t val_HL2 = cpu_state->hl2;
	uint8_t val_IM = cpu_state->im;
	bool val_IFF1 = cpu_state->iff1;
	bool val_IFF2 = cpu_state->iff2;

	fprintf(file, "A =%02X BC =%04X DE =%04X HL =%04X", val_A, val_BC, val_DE, val_HL);
	fprintf(file, " F =%s", conv_freg(val_F));
	fprintf(file, " IX=%04X IY=%04X\n", val_IX, val_IY);
	fprintf(file, "A'=%02X BC'=%04X DE'=%04X HL'=%04X", val_A2, val_BC2, val_DE2, val_HL2);
	fprintf(file, " F'=%s", conv_freg(val_F2));
	fprintf(file, " SP=%04X PC=%04X\n", val_SP, val_PC);
	fprintf(file, "I=%02X R=%02X IM=%01X IFF1=%01X IFF2=%01X\n", val_I, val_R, val_IM, val_IFF1, val_IFF2);
}

// print dump
static void print_dump(FILE* file, uint8_t* data, uint32_t size) {
	for (int i = 0; i < (size / 0x10); i++) {
		fprintf(file, "%04X : ", i * 0x10);
		for (int j = 0; j < 0x10; j++) {
			fprintf(file, "%02X ", data[(i * 0x10) + j]);
		}
		fprintf(file, "| ");
		for (int j = 0; j < 0x10; j++) {
			char c = data[(i * 0x10) + j];
			if ((c >= 0x20) && (c <= 0x7E)) {
				fprintf(file, "%c", c);
			}
			else {
				fprintf(file, ".");
			}
		}
		fprintf(file, "\n");
	}
}

// load hex file
static void load_hexfile(FILE* file) {
	char str_buff[0x100];

	// clear cpu_memory
	memset(cpu_memory, 0x00, sizeof(cpu_memory));
	// set cpu_memory
	while ((fgets(str_buff, sizeof(str_buff), file)) != NULL) {
		if ((str_buff[0] == ':') && (memcmp(&str_buff[7], "00", 2) == 0)) {
			int num = get_hex_str(&str_buff[1], 2);
			int addr = get_hex_str(&str_buff[3], 4);
			for (int i = 0; i < num; i++) {
				cpu_memory[addr + i] = get_hex_str(&str_buff[9 + (i * 2)], 2);
			}
		}
	}
}
