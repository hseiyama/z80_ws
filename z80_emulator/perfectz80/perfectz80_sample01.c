//------------------------------------------------------------------------------
//  Main source file.
//------------------------------------------------------------------------------
#include <stdio.h> // printf
#include <string.h> // memcpy
#include "perfectz80.h"

typedef struct {
	uint16_t addr;
	char *inst;
} asm_t;

static uint8_t cpu_rom[] = {
	0x31, 0x30, 0x00,		//         ld sp,stack
	0xCD, 0x08, 0x00,		// loop:   call func
	0x18, 0xFB,				//         jr loop
	0x21, 0x0D, 0x00,		// func:   ld hl,data
	0x34,					//         inc (hl)
	0xC9,					//         ret
	0x40					// data:   db 40h
							// stack:  org 30h
};

static asm_t cpu_asm[] = {
	{0x0000, "LD SP,0030h "},
	{0x0003, "CALL 0008h  "},
	{0x0006, "JR 0003h    "},
	{0x0008, "LD HL,000Dh "},
	{0x000B, "INC (HL)    "},
	{0x000C, "RET         "}
};

void main(void) {
	void* cpu_state;
	uint32_t TickCnt;
	uint8_t pin_CLK;
	uint8_t pin_M1;
	uint8_t pin_MREQ;
	uint8_t pin_IORQ;
	uint8_t pin_RFSH;
	uint8_t pin_RD;
	uint8_t pin_WR;
	uint16_t AddressBus;
	uint8_t DataBus;
	uint16_t val_PC;
	uint16_t val_SP;
	uint8_t val_IR;
	uint16_t val_AF;
	uint16_t val_HL;
	char *val_Asm;

	// Initialize
	TickCnt = 0;
	memcpy(cpu_memory, cpu_rom, sizeof(cpu_rom));
	val_Asm = "";

	// print title
	printf("+------+----+------+------+------+----+----+------+----+------+------+----+------+------+----+--------------+\n");
	printf("|   T  | M1 | MREQ | IORQ | RFSH | RD | WR | AB   | DB | PC   | SP   | IR | AF   | HL   |mem | Asm          |\n");
	printf("+------+----+------+------+------+----+----+------+----+------+------+----+------+------+----+--------------+\n");

	// cpu_initAndResetChip
	cpu_state = cpu_initAndResetChip();

	for (int i = 0; i < 176; i++) {
		// cpu_step
		cpu_step(cpu_state);

		// read
		pin_CLK = cpu_readCLK(cpu_state);
		TickCnt += pin_CLK;
		pin_M1 = !cpu_readM1(cpu_state);
		pin_MREQ = !cpu_readMREQ(cpu_state);
		pin_IORQ = !cpu_readIORQ(cpu_state);
		pin_RFSH = !cpu_readRFSH(cpu_state);
		pin_RD = !cpu_readRD(cpu_state);
		pin_WR = !cpu_readWR(cpu_state);
		AddressBus = cpu_readAddressBus(cpu_state);
		DataBus = cpu_readDataBus(cpu_state);
		val_PC = cpu_readPC(cpu_state);
		val_SP = cpu_readSP(cpu_state);
		val_IR = cpu_readIR(cpu_state);
		val_AF = (cpu_readA(cpu_state) << 8) | cpu_readF(cpu_state);
		val_HL = (cpu_readH(cpu_state) << 8) | cpu_readL(cpu_state);
		// set val_Asm
		if (pin_M1 & !pin_MREQ) {
			for (int i = 0; i < (sizeof(cpu_asm) / sizeof(asm_t)); i++) {
				if (cpu_asm[i].addr == AddressBus) {
					val_Asm = cpu_asm[i].inst;
				}
			}
		}

		// print item
		printf("|%3d/%-2d|", TickCnt, pin_CLK);
		pin_M1 ? printf(" M1 |") : printf("    |");
		pin_MREQ ? printf(" MREQ |") : printf("      |");
		pin_IORQ ? printf(" IORQ |") : printf("      |");
		pin_RFSH ? printf(" RFSH |") : printf("      |");
		pin_RD ? printf(" RD |") : printf("    |");
		pin_WR ? printf(" WR |") : printf("    |");
		printf(" %04X |", AddressBus);
		printf(" %02X |", DataBus);
		printf(" %04X |", val_PC);
		printf(" %04X |", val_SP);
		printf(" %02X |", val_IR);
		printf(" %04X |", val_AF);
		printf(" %04X |", val_HL);
		printf(" %02X |", cpu_memory[0x000D]);
		printf(" %s |", val_Asm);
		printf("\n");
	}

	// cpu_destroyChip
	cpu_destroyChip(cpu_state);
}
