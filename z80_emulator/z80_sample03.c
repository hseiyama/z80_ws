#include <stdio.h>
#define CHIPS_IMPL
#define CHIPS_UTIL_IMPL
#include "z80.h"
#include "z80pio.h"
#include "z80dasm.h"

#define DASM_MAX_STRLEN (32)
#define DASM_MAX_BINLEN (16)
#define DASM_ASM_STRLEN (12)

typedef struct {
	uint16_t cur_addr;
	int str_pos;
	char str_buf[DASM_MAX_STRLEN];
	int bin_pos;
	uint8_t bin_buf[DASM_MAX_BINLEN];
} dasm_t;

#define Z80_ACT_PIN(p) ((pins & Z80_##p) == Z80_##p)

// 64 KB memory with test program at address 0x0000
static uint8_t mem[(1<<16)] = {
	0xF3, 0x31, 0x00, 0x00, 0xCD, 0x10, 0x00, 0xDB, 0x1C, 0xD3, 0x1E, 0x32, 0x40, 0x00, 0x18, 0xF7,
	0x21, 0x30, 0x00, 0x06, 0x03, 0x0E, 0x1D, 0xED, 0xB3, 0x21, 0x33, 0x00, 0x06, 0x03, 0x0E, 0x1F,
	0xED, 0xB3, 0xC9, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xCF, 0xFF, 0x07, 0xCF, 0x00, 0x07, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF,
	// 0000:                           ORG     ROM_B
	// 0000:                   START:
	// 0000: F3       [ 4]             DI
	// 0001: 310000   [14]             LD      SP, 0000H
	// 0004: CD1000   [31]             CALL    IOSET
	// 0007:                   LOOP:
	// 0007: DB1C     [11]             IN      A, (PIOA)
	// 0009: D31E     [22]             OUT     (PIOB), A
	// 000B: 324000   [35]             LD      (PIO_WS), A
	// 000E: 18F7     [47]             JR      LOOP
	// 0010:                   IOSET:
	// 0010: 213000   [10]             LD      HL, PIOACD              ;PIOAコマンドセットアップ
	// 0013: 0603     [17]             LD      B, PAEND - PIOACD
	// 0015: 0E1D     [24]             LD      C, PIOA + 1             ;PIOAコマンドアドレス(1DH)
	// 0017: EDB3     [40|21]          OTIR
	// 0019: 213300   [50]             LD      HL, PIOBCD              ;PIOBコマンドセットアップ
	// 001C: 0603     [57]             LD      B, PBEND - PIOBCD
	// 001E: 0E1F     [64]             LD      C, PIOB + 1             ;PIOBコマンドアドレス(1FH)
	// 0020: EDB3     [80|21]          OTIR
	// 0022: C9       [90]             RET
	// 0023: FFFFFFFF                  ORG     ROM_B + 30H
	// 0027: FF...             
	// 0030: CF                PIOACD: DB      0CFH            ;PIOAモードワード                       **001111 (モード3)
	// 0031: FF                        DB      0FFH            ;PIOAデータディレクションワード         (全ビット入力)
	// 0032: 07                        DB      07H             ;PIOAインタラプトコントロールワード     ****0111 (割込み無効)
	// 0033:                   PAEND   EQU     $
	// 0033: CF                PIOBCD: DB      0CFH            ;PIOBモードワード                       **001111 (モード3)
	// 0034: 00                        DB      00H             ;PIOBデータディレクションワード         (全ビット出力)
	// 0035: 07                        DB      07H             ;PIOBインタラプトコントロールワード     ****0111 (割込み無効)
	// 0036:                   PBEND   EQU     $
	// 0036: FFFFFFFF                  ORG     ROM_B + 40H
	// 003A: FF...             
	// 0040: FF                PIO_WS: DEFS    1
};

// opcode address
static const uint16_t op_addr[] = {
	0x0000,
	0x0001,
	0x0004,
	0x0007,
	0x0009,
	0x000B,
	0x000E,
	0x0010,
	0x0013,
	0x0015,
	0x0017,
	0x0019,
	0x001C,
	0x001E,
	0x0020,
	0x0022
};

static dasm_t dasm_info;

static void dasm_init(void);
static uint8_t _dasm_in_cb(void* user_data);
static void _dasm_out_cb(char c, void* user_data);
static void dasm_disasm(uint16_t cur_addr);

void main(void) {
	z80_t cpu;
	z80pio_t pio;
	uint8_t pio_a;
	uint8_t pio_b;
	uint8_t inst;
	uint8_t tick;
	char *val_Asm;

	// initialize dasm_info
	dasm_init();
	// initialize Z80 emu
	z80_init(&cpu);
	z80pio_init(&pio);
	// execution starts at 0x0000
	uint64_t pins = z80_prefetch(&cpu, 0x0000);

	pio_a = 0xAA;					// PA for input
	pio_b = 0xFF;					// PB for output
	inst = 0;
	tick = 0;
	val_Asm = dasm_info.str_buf;	// assembler string

	// print title
	printf("+-----+----+------+------+------+----+----+------+----+------+------+----+------+------+------+----+-------+--------------+\n");
	printf("|  T  | M1 | MREQ | IORQ | RFSH | RD | WR | AB   | DB | PC   | SP   | IR | AF   | BC   | HL   |mem | PIO   | Asm          |\n");
	printf("+-----+----+------+------+------+----+----+------+----+------+------+----+------+------+------+----+-------+--------------+\n");

	// execute some clock cycles
	for (int i = 0; i < 254; i++) {

		// tick the CPU
		pins = z80_tick(&cpu, pins);
		tick++;
		if (Z80_ACT_PIN(M1)) {
			inst++;
			tick = 1;
		}
		// set val_Asm
		if (Z80_ACT_PIN(M1)) {
			for (int i = 0; i < (sizeof(op_addr) / sizeof(uint16_t)); i++) {
				if (op_addr[i] == Z80_GET_ADDR(pins)) {
					// disassemble instruction
					dasm_disasm(Z80_GET_ADDR(pins));
				}
			}
		}

		// print item
		printf("|%2d/%-2d|", inst, tick);
		Z80_ACT_PIN(M1) ? printf(" M1 |") : printf("    |");
		Z80_ACT_PIN(MREQ) ? printf(" MREQ |") : printf("      |");
		Z80_ACT_PIN(IORQ) ? printf(" IORQ |") : printf("      |");
		Z80_ACT_PIN(RFSH) ? printf(" RFSH |") : printf("      |");
		Z80_ACT_PIN(RD) ? printf(" RD |") : printf("    |");
		Z80_ACT_PIN(WR) ? printf(" WR |") : printf("    |");
		printf(" %04X |", Z80_GET_ADDR(pins));
		printf(" %02X |", Z80_GET_DATA(pins));
		printf(" %04X |", cpu.pc);
		printf(" %04X |", cpu.sp);
		printf(" %02X |", cpu.opcode);
		printf(" %04X |", cpu.af);
		printf(" %04X |", cpu.bc);
		printf(" %04X |", cpu.hl);
		printf(" %02X |", mem[0x0040]);
		printf(" %02X,%02X |", pio_a, pio_b);
		printf(" %s |", val_Asm);
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

		// tick PIO first (because it's the highest priority daisychain device)
		{
			pins |= Z80_IEIO;
			if (0x1C == (Z80_GET_ADDR(pins) & 0xFC)) { pins |= Z80PIO_CE; }
			if (pins & Z80_A1) { pins |= Z80PIO_BASEL; }
			if (pins & Z80_A0) { pins |= Z80PIO_CDSEL; }
			Z80PIO_SET_PAB(pins, pio_a, 0xFF);
			pins = z80pio_tick(&pio, pins);
			pio_b = Z80PIO_GET_PB(pins);
			pins &= Z80_PIN_MASK;
		}
	}
}

static void dasm_init(void) {
	memset(&dasm_info, 0, sizeof(dasm_t));
}

/* disassembler callback to fetch the next instruction byte */
static uint8_t _dasm_in_cb(void* user_data) {
	dasm_t* info = (dasm_t*) user_data;
	uint8_t val = mem[info->cur_addr++];
	if (info->bin_pos < DASM_MAX_BINLEN) {
		info->bin_buf[info->bin_pos++] = val;
	}
	return val;
}

/* disassembler callback to output a character */
static void _dasm_out_cb(char c, void* user_data) {
	dasm_t* info = (dasm_t*) user_data;
	if ((info->str_pos + 1) < DASM_MAX_STRLEN) {
		info->str_buf[info->str_pos++] = c;
		info->str_buf[info->str_pos] = 0;
	}
}

/* disassemble the next instruction */
static void dasm_disasm(uint16_t cur_addr) {
	dasm_info.str_pos = 0;
	dasm_info.bin_pos = 0;
	dasm_info.cur_addr = cur_addr;
	z80dasm_op(dasm_info.cur_addr, _dasm_in_cb, _dasm_out_cb, &dasm_info);
	// adjust length of assembler string
	for (int i = dasm_info.str_pos; i < DASM_ASM_STRLEN; i++) {
		dasm_info.str_buf[i] = ' ';
	}
	dasm_info.str_buf[DASM_ASM_STRLEN] = 0;
}
