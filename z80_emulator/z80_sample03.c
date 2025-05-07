#include <stdio.h>
#define CHIPS_IMPL
#include "z80.h"
#include "z80pio.h"

typedef struct {
	uint16_t addr;
	char *inst;
} asm_t;

#define Z80_ACT_PIN(p) ((pins & Z80_##p) == Z80_##p)

void main(void) {
	// 64 KB memory with test program at address 0x0000
	uint8_t mem[(1<<16)] = {
		0xF3, 0x31, 0x00, 0x00, 0xCD, 0x10, 0x00, 0xDB, 0x1C, 0xD3, 0x1E, 0x32, 0x40, 0x00, 0x18, 0xF7,
		0x21, 0x30, 0x00, 0x06, 0x03, 0x0E, 0x1D, 0xED, 0xB3, 0x21, 0x33, 0x00, 0x06, 0x03, 0x0E, 0x1F,
		0xED, 0xB3, 0xC9, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xCF, 0xFF, 0x07, 0xCF, 0x00, 0x07, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF,
	};
	// 256 Byte io with test program at address 0x00
	uint8_t io[(1<<8)] = {
		0x00,				// 00...
	};
	// Assembler string
	asm_t cpu_asm[] = {
		{0x0000, "DI          "},	// 0000: F3       [ 4]             DI
		{0x0001, "LD SP,0000h "},	// 0001: 310000   [14]             LD      SP, 0000H
		{0x0004, "CALL 0010h  "},	// 0004: CD1000   [31]             CALL    IOSET
									// 0007:                   LOOP:
		{0x0007, "IN A,(1Ch)  "},	// 0007: DB1C     [11]             IN      A, (PIOA)
		{0x0009, "OUT (1Eh),A "},	// 0009: D31E     [22]             OUT     (PIOB), A
		{0x000B, "LD (0040h),A"},	// 000B: 324000   [35]             LD      (PIO_WS), A
		{0x000E, "JR 0007h    "},	// 000E: 18F7     [47]             JR      LOOP
									// 0010:                   IOSET:
		{0x0010, "LD HL,0030h "},	// 0010: 213000   [10]             LD      HL, PIOACD
		{0x0013, "LD B,03h    "},	// 0013: 0603     [17]             LD      B, PAEND - PIOACD
		{0x0015, "LD C,1Dh    "},	// 0015: 0E1D     [24]             LD      C, PIOA + 1
		{0x0017, "OTIR        "},	// 0017: EDB3     [40|21]          OTIR
		{0x0019, "LD HL,0033h "},	// 0019: 213300   [50]             LD      HL, PIOBCD
		{0x001C, "LD B,03h    "},	// 001C: 0603     [57]             LD      B, PBEND - PIOBCD
		{0x001E, "LD C,1Fh    "},	// 001E: 0E1F     [64]             LD      C, PIOB + 1
		{0x0020, "OTIR        "},	// 0020: EDB3     [80|21]          OTIR
		{0x0022, "RET         "}	// 0022: C9       [90]             RET
									// 0023: FFFFFFFF                  ORG     ROM_B + 30H
									// 0027: FF...             
									// 0030: CF                PIOACD: DB      0CFH
									// 0031: FF                        DB      0FFH
									// 0032: 07                        DB      07H
									// 0033:                   PAEND   EQU     $
									// 0033: CF                PIOBCD: DB      0CFH
									// 0034: 00                        DB      00H
									// 0035: 07                        DB      07H
									// 0036:                   PBEND   EQU     $
									// 0036: FFFFFFFF                  ORG     ROM_B + 40H
									// 003A: FF...             
									// 0040: FF                PIO_WS: DEFS    1
	};

	z80_t cpu;
	z80pio_t pio;
	uint8_t pio_a;
	uint8_t pio_b;
	uint8_t inst;
	uint8_t tick;
	char *val_Asm;

	// initialize Z80 emu
	z80_init(&cpu);
	z80pio_init(&pio);
	// execution starts at 0x0000
	uint64_t pins = z80_prefetch(&cpu, 0x0000);

	pio_a = 0xAA;		// PA for input
	pio_b = 0xFF;		// PB for output
	inst = 0;
	tick = 0;
	val_Asm = "";

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
			for (int i = 0; i < (sizeof(cpu_asm) / sizeof(asm_t)); i++) {
				if (cpu_asm[i].addr == Z80_GET_ADDR(pins)) {
					val_Asm = cpu_asm[i].inst;
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
		// handle io read or write access
		else if (pins & Z80_IORQ) {
			if (pins & Z80_RD) {
				Z80_SET_DATA(pins, io[Z80_GET_ADDR(pins) & 0xFF]);
			}
			else if (pins & Z80_WR) {
				io[Z80_GET_ADDR(pins) & 0xFF] = Z80_GET_DATA(pins);
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
