#include <stdio.h>
#define CHIPS_IMPL
#include "z80.h"

#define Z80_ACT_PIN(p) ((pins & Z80_##p) == Z80_##p)

int main() {
	// 64 KB memory with test program at address 0x0000
	uint8_t mem[(1<<16)] = {
		0x3E, 0x02,		// LD A,2
		0x06, 0x03,		// LD B,3
		0x80,			// ADD A,B
		0x32, 0x0A, 0x00,	// LD (000AH),A
		0x00,			// NOP...
	};
	// 256 B io with test program at address 0x00
	uint8_t io[(1<<8)] = {
		0x00,			// 00...
	};

	z80_t cpu;
	int inst;
	int tick;

	// initialize Z80 emu
	uint64_t pins = z80_init(&cpu);
	inst = 0;
	tick = 0;

	// print title
	printf("+-----+----+------+------+------+----+----+------+----+------+------+----+\n");
	printf("|  T  | M1 | MREQ | IORQ | RFSH | RD | WR | AB   | DB | PC   | SP   | IR |\n");
	printf("+-----+----+------+------+------+----+----+------+----+------+------+----+\n");

	// execute some clock cycles
	for (int i = 0; i < 33; i++) {

		// tick the CPU
		pins = z80_tick(&cpu, pins);
		tick++;
		if (Z80_ACT_PIN(M1)) {
			inst++;
			tick = 1;
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
	}

	// register A should now be 5
	printf("\nRegister A: %d\n", cpu.a);
	return 0;
}
