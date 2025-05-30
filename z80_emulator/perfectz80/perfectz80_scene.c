//------------------------------------------------------------------------------
//  Main source file.
//------------------------------------------------------------------------------
#include <stdio.h> // printf
#include <string.h> // memcpy
#define CHIPS_IMPL
#include "perfectz80.h"
#include "z80dasm.h"

#define TICK_CYCLE_END		(938)
#define DASM_MAX_STRLEN		(32)
#define DASM_MAX_BINLEN		(16)
#define DASM_ASM_STRLEN		(12)
#define LOG_STRLEN			(sizeof(title_line) - 4)

// pin kind
enum {
	PIN_Z80_WAIT = 0,	// Wait Requested
	PIN_Z80_INT,		// Interrupt Request
	PIN_Z80_NMI,		// Non-Maskable Interrupt
	PIN_Z80_RESET,		// Cpu Reset
	PIN_Z80_BUSRQ,		// Bus Requested
	SET_MEM_VAL,		// Set Memory Value
	SET_IO_VAL			// Set IO Value
};

typedef struct {
	uint16_t cur_addr;
	int str_pos;
	char str_buf[DASM_MAX_STRLEN];
	int bin_pos;
	uint8_t bin_buf[DASM_MAX_BINLEN];
} dasm_t;

typedef struct {
	uint16_t tick;
	uint8_t kind;
	uint16_t addr;
	uint8_t value;
} scene_t;

static const uint8_t cpu_rom[] = {
	0xF3, 0x31, 0x00, 0x00, 0xED, 0x5E, 0xAF, 0xED, 0x47, 0xCD, 0x1E, 0x00, 0xAF, 0x32, 0x80, 0x00,
	0x32, 0x81, 0x00, 0xFB, 0x0E, 0x1C, 0xED, 0x40, 0x0E, 0x1E, 0xED, 0x41, 0x18, 0xF6, 0x21, 0x50,
	0x00, 0x06, 0x03, 0x0E, 0x1D, 0xED, 0xB3, 0x21, 0x53, 0x00, 0x06, 0x03, 0x0E, 0x1F, 0xED, 0xB3,
	0x21, 0x56, 0x00, 0x06, 0x03, 0x0E, 0x10, 0xED, 0xB3, 0xC9, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0xCF, 0xFF, 0x07, 0xCF, 0x00, 0x07, 0x48, 0x87, 0x08, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
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
	// 0009: CD1E00   [52]             CALL    IOSET
	// 000C: AF       [56]             XOR     A
	// 000D: 328000   [69]             LD      (CT0CNT), A
	// 0010: 328100   [82]             LD      (NMICNT), A
	// 0013: FB       [86]             EI
	// 0014:                   LOOP:
	// 0014: 0E1C     [ 7]             LD      C, PIOA
	// 0016: ED40     [19]             IN      B, (C)
	// 0018: 0E1E     [26]             LD      C, PIOB
	// 001A: ED41     [38]             OUT     (C), B
	// 001C: 18F6     [50]             JR      LOOP
	// 001E:                   IOSET:
	// 001E: 215000   [10]             LD      HL, PIOACD              ;PIOAコマンドセットアップ
	// 0021: 0603     [17]             LD      B, PAEND - PIOACD
	// 0023: 0E1D     [24]             LD      C, PIOA + 1             ;PIOAコマンドアドレス(1DH)
	// 0025: EDB3     [40|21]          OTIR
	// 0027: 215300   [50]             LD      HL, PIOBCD              ;PIOBコマンドセットアップ
	// 002A: 0603     [57]             LD      B, PBEND - PIOBCD
	// 002C: 0E1F     [64]             LD      C, PIOB + 1             ;PIOBコマンドアドレス(1FH)
	// 002E: EDB3     [80|21]          OTIR
	// 0030: 215600   [90]             LD      HL, CTC0CD              ;CTC0コマンドセットアップ
	// 0033: 0603     [97]             LD      B, C0END - CTC0CD
	// 0035: 0E10     [104]            LD      C, CTC0
	// 0037: EDB3     [120|21]         OTIR
	// 0039: C9       [130]            RET
	// 003A: FFFFFFFF                  ORG     ENTRY + 04H
	// 003E: FF...             
	// 0044: 0000                      DW      0000H           ; 4: PIOA割り込み
	// 0046: 0000                      DW      0000H           ; 6: PIOB割り込み
	// 0048: 6E00                      DW      INTCT0          ; 8: CTC0割り込み
	// 004A: 0000                      DW      0000H           ;10: CTC1割り込み
	// 004C: 0000                      DW      0000H           ;12: CTC2割り込み
	// 004E: 0000                      DW      0000H           ;14: CTC3割り込み
	// 0050: CF                PIOACD: DB      0CFH            ;PIOAモードワード                       **001111 (モード3)
	// 0051: FF                        DB      0FFH            ;PIOAデータディレクションワード         (全ビット入力)
	// 0052: 07                        DB      07H             ;PIOAインタラプトコントロールワード     ****0111 (割込み無効)
	// 0053:                   PAEND   EQU     $
	// 0053: CF                PIOBCD: DB      0CFH            ;PIOBモードワード                       **001111 (モード3)
	// 0054: 00                        DB      00H             ;PIOBデータディレクションワード         (全ビット出力)
	// 0055: 07                        DB      07H             ;PIOBインタラプトコントロールワード     ****0111 (割込み無効)
	// 0056:                   PBEND   EQU     $
	// 0056:                   CTC0CD:
	// 0056: 48                        DB      ENTRY + 8       ;CTC0インタラプトベクタ                 *****000 (全チャネル用)
	// 0057: 87                        DB      87H             ;CTC0チャンネルコントロールワード       *******1 (タイマモード)
	// 0058: 08                        DB      08H             ;CTC0タイムコンスタントレジスタ         (8)
	// 0059:                   C0END   EQU     $
	// 0059: FFFFFFFF                  ORG     0066H
	// 005D: FF...             
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

// scene table
static const scene_t scene_tbl[] = {
	//	tick	kind			addr		value
	{	343,	SET_IO_VAL,		0x001C,		0x12	},
	{	393,	SET_IO_VAL,		0x001C,		0x34	},
	{	398,	PIN_Z80_INT,	0x0000,		0x00	},	// no use value
	{	531,	SET_IO_VAL,		0x001C,		0x56	},
	{	555,	PIN_Z80_NMI,	0x0000,		true	},
	{	557,	PIN_Z80_NMI,	0x0000,		false	},
	{	580,	PIN_Z80_NMI,	0x0000,		true	},
	{	582,	PIN_Z80_NMI,	0x0000,		false	},
	{	689,	SET_IO_VAL,		0x001C,		0x78	},
	{	713,	PIN_Z80_INT,	0x0000,		0x00	},	// no use value
	{	828,	PIN_Z80_WAIT,	0x0000,		true	},
	{	834,	PIN_Z80_WAIT,	0x0000,		false	},
	{	842,	PIN_Z80_BUSRQ,	0x0000,		true	},
	{	848,	PIN_Z80_BUSRQ,	0x0000,		false	},
	{	891,	PIN_Z80_RESET,	0x0000,		true	},
	{	897,	PIN_Z80_RESET,	0x0000,		false	}
};

// title string
static const char title_line[] = "+-------+----+------+------+------+----+----+-----+-----+------+------+----+------+------+----+------+------+------+-------+-------+--------------+\n";
static const char title_item[] = "| Tick  | M1 | MREQ | IORQ | RFSH | RD | WR | INT | NMI | IFF1 | AB   | DB | PC   | SP   | IR | AF   | BC   | HL   | Io    | Mem   | Asm          |\n";

// dasm informaion
static dasm_t dasm_info;
// scene informaion
static uint16_t scene_idx;

static void dasm_init(void);
static uint8_t _dasm_in_cb(void* user_data);
static void _dasm_out_cb(char c, void* user_data);
static void dasm_disasm(uint16_t op_addr);
static bool z80_opdone(void* cpu_state);
static void scene_init(void);
static void scene_update(void* cpu_state, uint16_t tick);
static uint8_t cpu_readIM(void* cpu_state);

void main(void) {
	void* cpu_state;
	uint16_t tick;
	char *val_Asm;

	// initialize dasm
	dasm_init();
	// initialize scene
	scene_init();

	// Initialize
	tick = 0;
	memcpy(cpu_memory, cpu_rom, sizeof(cpu_rom));
	val_Asm = dasm_info.str_buf;	// assembler string

	// print title
	printf(title_line);
	printf(title_item);

	// cpu_initAndResetChip
	cpu_state = cpu_initAndResetChip();

	for (int i = 0; i < (TICK_CYCLE_END * 2); i++) {
		// update scene
		scene_update(cpu_state, tick);
		// cpu_step
		cpu_step(cpu_state);

		// read
		bool pin_CLK = cpu_readCLK(cpu_state);
		tick += pin_CLK;
		bool pin_M1 = !cpu_readM1(cpu_state);
		bool pin_MREQ = !cpu_readMREQ(cpu_state);
		bool pin_IORQ = !cpu_readIORQ(cpu_state);
		bool pin_RFSH = !cpu_readRFSH(cpu_state);
		bool pin_RD = !cpu_readRD(cpu_state);
		bool pin_WR = !cpu_readWR(cpu_state);
		bool pin_INT = !cpu_readINT(cpu_state);
		bool pin_NMI = !cpu_readNMI(cpu_state);
		bool pin_IFF1 = cpu_read_node(cpu_state, 231);
		uint16_t AddressBus = cpu_readAddressBus(cpu_state);
		uint8_t DataBus = cpu_readDataBus(cpu_state);
		uint16_t val_PC = cpu_readPC(cpu_state);
		uint16_t val_SP = cpu_readSP(cpu_state);
		uint8_t val_IR = cpu_readIR(cpu_state);
		uint16_t val_AF = (cpu_readA(cpu_state) << 8) | cpu_readF(cpu_state);
		uint16_t val_BC = (cpu_readB(cpu_state) << 8) | cpu_readC(cpu_state);
		uint16_t val_HL = (cpu_readH(cpu_state) << 8) | cpu_readL(cpu_state);
		// judge opcode fetch machine cycle
		if (z80_opdone(cpu_state)) {
			// disassemble the instruction
			dasm_disasm(AddressBus);
			// print line
			printf(title_line);
		}

		// print item
		printf("|%4d/%-2d|", tick, pin_CLK);
		pin_M1 ? printf(" M1 |") : printf("    |");
		pin_MREQ ? printf(" MREQ |") : printf("      |");
		pin_IORQ ? printf(" IORQ |") : printf("      |");
		pin_RFSH ? printf(" RFSH |") : printf("      |");
		pin_RD ? printf(" RD |") : printf("    |");
		pin_WR ? printf(" WR |") : printf("    |");
		pin_INT ? printf(" INT |") : printf("     |");
		pin_NMI ? printf(" MNI |") : printf("     |");
		pin_IFF1 ? printf(" IFF1 |") : printf("      |");
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
	}

	// cpu_destroyChip
	cpu_destroyChip(cpu_state);
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
static bool z80_opdone(void* cpu_state) {
	static bool prefix_active = false;
	static bool pin_M1_pre = false;
	static bool pin_IORQ_pre = false;
	uint16_t AddressBus = cpu_readAddressBus(cpu_state);
	uint16_t IntVecAddress = (cpu_readI(cpu_state) << 8) | cpu_getIntVec();
	uint16_t IntIsrAddress = *(uint16_t *)&cpu_memory[IntVecAddress];
	bool pin_M1 = !cpu_readM1(cpu_state);
	bool pin_IORQ = !cpu_readIORQ(cpu_state);
	bool pin_RESET = !cpu_readRESET(cpu_state);
	uint8_t val_IM = cpu_readIM(cpu_state);
	bool opdone = false;

	if (pin_M1 && !pin_M1_pre) {
		if (!prefix_active) {
			opdone = true;
		}
		// nmi event
		if (0x0066 == AddressBus) {
			opdone = true;
			printf("|%*s| <- NMI SrvRoutine\r", LOG_STRLEN, "");
		}
		// int event
		if ((IntIsrAddress == AddressBus) && (2 == val_IM)) {
			opdone = true;
			printf("|%*s| <- INT SrvRoutine\r", LOG_STRLEN, "");
		}
		// judge CB/DD/ED/FD prefix
		switch (cpu_memory[AddressBus]) {
		case 0xCB:
		case 0xDD:
		case 0xED:
		case 0xFD:
			prefix_active = true;
			break;
		default:
			prefix_active = false;
			break;
		}
	}
	// int acknowledge
	if (pin_M1 && pin_IORQ && !pin_IORQ_pre) {
		printf("|%*s| <- INT Acknowledge\r", LOG_STRLEN, "");
	}
	// reset event
	if (pin_RESET) {
		prefix_active = false;
		pin_M1_pre = false;
		pin_IORQ_pre = false;
	}
	// previous value
	pin_M1_pre = pin_M1;
	pin_IORQ_pre = pin_IORQ;

	return opdone;
}

// initialize scene
static void scene_init(void) {
	scene_idx = 0;
}

// update scene
static void scene_update(void* cpu_state, uint16_t tick) {
	bool pin_M1 = !cpu_readM1(cpu_state);
	bool pin_IORQ = !cpu_readIORQ(cpu_state);

	while ((scene_idx < (sizeof(scene_tbl) / sizeof(scene_t)))
	&&     (scene_tbl[scene_idx].tick <= tick                )) {
		switch (scene_tbl[scene_idx].kind) {
		case PIN_Z80_WAIT:
			cpu_writeWAIT(cpu_state, !scene_tbl[scene_idx].value);
			printf("|%*s| <- set z80_wait\r", LOG_STRLEN, "");
			break;
		case PIN_Z80_INT:
			cpu_writeINT(cpu_state, !true);
			cpu_setIntVec(0x48);
			printf("|%*s| <- set z80_int\r", LOG_STRLEN, "");
			break;
		case PIN_Z80_NMI:
			cpu_writeNMI(cpu_state, !scene_tbl[scene_idx].value);
			printf("|%*s| <- set z80_nmi\r", LOG_STRLEN, "");
			break;
		case PIN_Z80_RESET:
			cpu_writeRESET(cpu_state, !scene_tbl[scene_idx].value);
			printf("|%*s| <- set z80_reset\r", LOG_STRLEN, "");
			break;
		case PIN_Z80_BUSRQ:
			cpu_writeBUSRQ(cpu_state, !scene_tbl[scene_idx].value);
			printf("|%*s| <- set z80_busrq\r", LOG_STRLEN, "");
			break;
		case SET_MEM_VAL:
			cpu_memory[scene_tbl[scene_idx].addr] = scene_tbl[scene_idx].value;
			printf("|%*s| <- set memory\r", LOG_STRLEN, "");
			break;
		case SET_IO_VAL:
			cpu_io[scene_tbl[scene_idx].addr & 0xFF] = scene_tbl[scene_idx].value;
			printf("|%*s| <- set io\r", LOG_STRLEN, "");
			break;
		}
		scene_idx++;
	}
	if (pin_M1 && pin_IORQ) {
		cpu_writeINT(cpu_state, !false);
	}
}

// read IM
static uint8_t cpu_readIM(void* cpu_state) {
	// see https://github.com/floooh/v6502r/issues/3
	uint8_t im = (cpu_read_node(cpu_state, 205) ? 1 : 0) | (cpu_read_node(cpu_state, 179) ? 2 : 0);
	if (im > 0) {
		im -= 1;
	}
	return im;
}
