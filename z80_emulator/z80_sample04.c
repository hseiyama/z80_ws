#include <stdio.h>
#define CHIPS_IMPL
#define CHIPS_UTIL_IMPL
#include "z80.h"
#include "z80pio.h"
#include "z80ctc.h"
#include "z80dasm.h"

#define TICK_CYCLE_END		(799)
#define DASM_MAX_STRLEN		(32)
#define DASM_MAX_BINLEN		(16)
#define DASM_ASM_STRLEN		(12)
#define LOG_STRLEN			(140)

// pin kind
enum {
	PIN_Z80_INT = 0,		// Interrupt Request
	PIN_Z80_NMI,			// Non-Maskable Interrupt
	PIN_Z80_WAIT,			// Wait Requested
	PIN_Z80PIO_ARDY,		// Port A Ready
	PIN_Z80PIO_BRDY,		// Port B Ready
	PIN_Z80PIO_ASTB,		// Port A Strobe
	PIN_Z80PIO_BSTB,		// Port B Strobe
	PIN_Z80PIO_PA,			// Port A
	PIN_Z80PIO_PB,			// Port B
	PIN_Z80CTC_CLKTRG0,		// Clock/Timer Trigger 0
	PIN_Z80CTC_CLKTRG1,		// Clock/Timer Trigger 1
	PIN_Z80CTC_CLKTRG2,		// Clock/Timer Trigger 2
	PIN_Z80CTC_CLKTRG3		// Clock/Timer Trigger 3
};

typedef struct {
	uint16_t cur_addr;
	int str_pos;
	char str_buf[DASM_MAX_STRLEN];
	int bin_pos;
	uint8_t bin_buf[DASM_MAX_BINLEN];
} dasm_t;

typedef struct {
	uint16_t inst;
	uint8_t tick;
	uint8_t pin_knd;
	uint8_t pin_val;
} scene_t;

#define Z80_GET_PIN(p) ((pins & Z80_##p) == Z80_##p)
#define Z80_SET_PIN(p,v) {pins = (pins & ~Z80_##p) | (((v) & 1ULL) << Z80_PIN_##p);}
#define GET_OP_ODR(i,t) (((i) << 8) | (t))
#define GET_SC_ODR(idx) ((scene_tbl[idx].inst << 8) | scene_tbl[idx].tick)

// 64 KB memory with test program at address 0x0000
static uint8_t mem[(1<<16)] = {
	0xF3, 0x31, 0x00, 0x00, 0xED, 0x5E, 0xAF, 0xED, 0x47, 0xCD, 0x17, 0x00, 0xAF, 0x32, 0x80, 0x00,
	0xFB, 0xDB, 0x1C, 0xD3, 0x1E, 0x18, 0xFA, 0x21, 0x50, 0x00, 0x06, 0x03, 0x0E, 0x1D, 0xED, 0xB3,
	0x21, 0x53, 0x00, 0x06, 0x03, 0x0E, 0x1F, 0xED, 0xB3, 0x21, 0x56, 0x00, 0x06, 0x03, 0x0E, 0x10,
	0xED, 0xB3, 0xC9, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x69, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0xCF, 0xFF, 0x07, 0xCF, 0x00, 0x07, 0x48, 0x87, 0x08, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xED, 0x45, 0xF5, 0x3A, 0x80, 0x00, 0x3C, 0x32, 0x80,
	0x00, 0xF1, 0xFB, 0xED, 0x4D, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF,
	// 0000:                           ORG     ROM_B
	// 0000:                   START:
	// 0000: F3       [ 4]             DI
	// 0001: 310000   [14]             LD      SP, 0000H
	// 0004: ED5E     [22]             IM      2
	// 0006: AF       [26]             XOR     A
	// 0007: ED47     [35]             LD      I, A
	// 0009: CD1700   [52]             CALL    IOSET
	// 000C: AF       [56]             XOR     A
	// 000D: 328000   [69]             LD      (CT0CNT), A
	// 0010: FB       [73]             EI
	// 0011:                   LOOP:
	// 0011: DB1C     [11]             IN      A, (PIOA)
	// 0013: D31E     [22]             OUT     (PIOB), A
	// 0015: 18FA     [34]             JR      LOOP
	// 0017:                   IOSET:
	// 0017: 215000   [10]             LD      HL, PIOACD              ;PIOAコマンドセットアップ
	// 001A: 0603     [17]             LD      B, PAEND - PIOACD
	// 001C: 0E1D     [24]             LD      C, PIOA + 1             ;PIOAコマンドアドレス(1DH)
	// 001E: EDB3     [40|21]          OTIR
	// 0020: 215300   [50]             LD      HL, PIOBCD              ;PIOBコマンドセットアップ
	// 0023: 0603     [57]             LD      B, PBEND - PIOBCD
	// 0025: 0E1F     [64]             LD      C, PIOB + 1             ;PIOBコマンドアドレス(1FH)
	// 0027: EDB3     [80|21]          OTIR
	// 0029: 215600   [90]             LD      HL, CTC0CD              ;CTC0コマンドセットアップ
	// 002C: 0603     [97]             LD      B, C0END - CTC0CD
	// 002E: 0E10     [104]            LD      C, CTC0
	// 0030: EDB3     [120|21]         OTIR
	// 0032: C9       [130]            RET
	// 0033: FFFFFFFF                  ORG     ENTRY + 04H
	// 0037: FF...             
	// 0044: 0000                      DW      0000H           ; 4: PIOA割り込み
	// 0046: 0000                      DW      0000H           ; 6: PIOB割り込み
	// 0048: 6900                      DW      INTCT0          ; 8: CTC0割り込み
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
	// 0066: 00       [ 4]             NOP
	// 0067: ED45     [18]             RETN
	// 0069:                   INTCT0:
	// 0069: F5       [11]             PUSH    AF
	// 006A: 3A8000   [24]             LD      A, (CT0CNT)
	// 006D: 3C       [28]             INC     A
	// 006E: 328000   [41]             LD      (CT0CNT), A
	// 0071: F1       [51]             POP     AF
	// 0072: FB       [55]             EI
	// 0073: ED4D     [69]             RETI
	// 0075: FFFFFFFF                  ORG     RAM_B
	// 0079: FF...             
	// 0080: FF                CT0CNT: DEFS    1
};

// opcode address table
static const uint16_t op_addr_tbl[] = {
	0x0000,
	0x0001,
	0x0004,
	0x0006,
	0x0007,
	0x0009,
	0x000C,
	0x000D,
	0x0010,
	0x0011,
	0x0013,
	0x0015,
	0x0017,
	0x001A,
	0x001C,
	0x001E,
	0x0020,
	0x0023,
	0x0025,
	0x0027,
	0x0029,
	0x002C,
	0x002E,
	0x0030,
	0x0032,
	0x0066,
	0x0067,
	0x0069,
	0x006A,
	0x006D,
	0x006E,
	0x0071,
	0x0072,
	0x0073
};

// scene table
static const scene_t scene_tbl[] = {
	{29,	1,		PIN_Z80PIO_PA,		0xAA},
	{32,	1,		PIN_Z80PIO_PA,		0xBB},
	{35,	1,		PIN_Z80PIO_PA,		0xCC},
	{45,	1,		PIN_Z80PIO_PA,		0xDD},
	{55,	1,		PIN_Z80PIO_PA,		0xEE},
	{58,	1,		PIN_Z80PIO_PA,		0xFF}
};

// dasm informaion
static dasm_t dasm_info;
// scene informaion
static uint16_t scene_idx;
static uint8_t z80pio_pa;
static uint8_t z80pio_pb;

static void dasm_init(void);
static uint8_t _dasm_in_cb(void* user_data);
static void _dasm_out_cb(char c, void* user_data);
static void dasm_disasm(uint16_t op_addr);
static void scene_init(void);
static uint64_t scene_update(uint16_t inst, uint8_t tick, uint64_t pins);

void main(void) {
	z80_t cpu;
	z80pio_t pio;
	z80ctc_t ctc;
	uint16_t inst;
	uint8_t tick;
	uint8_t z80pio_ieo;
	uint8_t z80ctc_ieo;
	char *str_asm;

	// initialize dasm
	dasm_init();
	// initialize scene
	scene_init();
	// initialize Z80 family emulator
	z80_init(&cpu);
	z80pio_init(&pio);
	z80ctc_init(&ctc);
	// execution starts at 0x0000
	uint64_t pins = z80_prefetch(&cpu, 0x0000);

	inst = 0;
	tick = 0;
	z80pio_ieo = 1;
	z80ctc_ieo = 1;
	str_asm = dasm_info.str_buf;	// assembler string

	// print title
	printf("+------+----+------+------+------+----+----+-----+-----+------+----+------+------+----+------+------+------+----+-----+-------+--------------+\n");
	printf("|ins/t | M1 | MREQ | IORQ | RFSH | RD | WR | INT | IFF | AB   | DB | PC   | SP   | IR | AF   | BC   | HL   |mem | ieo | pio   | asm          |\n");
	printf("+------+----+------+------+------+----+----+-----+-----+------+----+------+------+----+------+------+------+----+-----+-------+--------------+\n");

	// execute some clock cycles
	for (int i = 0; i < TICK_CYCLE_END; i++) {
		// update scene
		pins = scene_update(inst, tick, pins);
		// tick CPU
		pins = z80_tick(&cpu, pins);
		tick++;
		// opcode fetch machine cycle
		if (Z80_GET_PIN(M1)) {
			for (int i = 0; i < (sizeof(op_addr_tbl) / sizeof(uint16_t)); i++) {
				if (op_addr_tbl[i] == Z80_GET_ADDR(pins)) {
					inst++;
					tick = 1;
					// disassemble the instruction
					dasm_disasm(Z80_GET_ADDR(pins));
				}
			}
		}

		// print item
		printf("|%3d/%-2d|", inst, tick);
		Z80_GET_PIN(M1) ? printf(" M1 |") : printf("    |");
		Z80_GET_PIN(MREQ) ? printf(" MREQ |") : printf("      |");
		Z80_GET_PIN(IORQ) ? printf(" IORQ |") : printf("      |");
		Z80_GET_PIN(RFSH) ? printf(" RFSH |") : printf("      |");
		Z80_GET_PIN(RD) ? printf(" RD |") : printf("    |");
		Z80_GET_PIN(WR) ? printf(" WR |") : printf("    |");
		Z80_GET_PIN(INT) ? printf(" INT |") : printf("     |");
		printf(" %d,%d |", cpu.iff1, cpu.iff2);
		printf(" %04X |", Z80_GET_ADDR(pins));
		printf(" %02X |", Z80_GET_DATA(pins));
		printf(" %04X |", cpu.pc);
		printf(" %04X |", cpu.sp);
		printf(" %02X |", cpu.opcode);
		printf(" %04X |", cpu.af);
		printf(" %04X |", cpu.bc);
		printf(" %04X |", cpu.hl);
		printf(" %02X |", mem[0x0080]);
		printf(" %d,%d |", z80ctc_ieo, z80pio_ieo);
		printf(" %02X,%02X |", z80pio_pa, z80pio_pb);
		printf(" %s |", str_asm);
		printf("\n");

		// handle memory read or write access
		if (pins & Z80_MREQ) {
			if (pins & Z80_RD) {
				Z80_SET_DATA(pins, mem[Z80_GET_ADDR(pins)]);
			}
			else if (pins & Z80_WR) {
				mem[Z80_GET_ADDR(pins)] = Z80_GET_DATA(pins);
			}
		}

		// tick CTC first (because it's the highest priority daisychain device)
		{
			pins |= Z80_IEIO;
			if (0x10 == (Z80_GET_ADDR(pins) & 0xFC)) { pins |= Z80CTC_CE; };
			if (pins & Z80_A0) { pins |= Z80CTC_CS0; }
			if (pins & Z80_A1) { pins |= Z80CTC_CS1; }
			pins = z80ctc_tick(&ctc, pins);
			z80ctc_ieo = ((pins & Z80CTC_IEIO) == Z80CTC_IEIO);
			pins &= Z80_PIN_MASK;
		}

		// tick PIO  (next in daisychain priority)
		{
			if (0x1C == (Z80_GET_ADDR(pins) & 0xFC)) { pins |= Z80PIO_CE; }
			if (pins & Z80_A1) { pins |= Z80PIO_BASEL; }
			if (pins & Z80_A0) { pins |= Z80PIO_CDSEL; }
			Z80PIO_SET_PAB(pins, z80pio_pa, 0xFF);
			pins = z80pio_tick(&pio, pins);
			z80pio_pb = Z80PIO_GET_PB(pins);
			z80pio_ieo = ((pins & Z80PIO_IEIO) == Z80PIO_IEIO);
			pins &= Z80_PIN_MASK;
		}
	}
}

// initialize dasm
static void dasm_init(void) {
	memset(&dasm_info, 0, sizeof(dasm_t));
}

// disassembler callback to fetch the next instruction byte
static uint8_t _dasm_in_cb(void* user_data) {
	dasm_t* info = (dasm_t*) user_data;
	uint8_t val = mem[info->cur_addr++];
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

// initialize scene
static void scene_init(void) {
	scene_idx = 0;
	z80pio_pa = 0xFF;		// PA for input
	z80pio_pb = 0xFF;		// PB for output
}

// update scene
static uint64_t scene_update(uint16_t inst, uint8_t tick, uint64_t pins) {
	while ((scene_idx < (sizeof(scene_tbl) / sizeof(scene_t)))
	&&     (GET_SC_ODR(scene_idx) <= GET_OP_ODR(inst, tick))  ) {
		switch (scene_tbl[scene_idx].pin_knd) {
		case PIN_Z80PIO_PA:
			z80pio_pa = scene_tbl[scene_idx].pin_val;
			printf("|%*s| <- set z80pio_pa\r", LOG_STRLEN, "");
			break;
		}
		scene_idx++;
	}
	return pins;
}
