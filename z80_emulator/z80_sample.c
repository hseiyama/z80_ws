#include <stdio.h>
#define CHIPS_IMPL
#include "z80.h"

#define Z80_GET_CTRL(p) ((pins & Z80_##p) >> Z80_PIN_##p)

int main() {
    // 64 KB memory with test program at address 0x0000
    uint8_t mem[(1<<16)] = {
//        0x3E, 0x02,     // LD A,2
//        0x06, 0x03,     // LD B,3
//        0x80,           // ADD A,B
//        0x00,           // NOP...
        0x3E, 0x14,         // LD A,20
        0x32, 0x10, 0x00,   // LD (0010h),A
        0x00,               // NOP...
    };

    // initialize Z80 emu and execute some clock cycles 
    z80_t cpu;
    uint64_t pins = z80_init(&cpu);
    /* 状態表示 */
    printf("< initial state >\n");
    printf("step=%3d, pc=0x%04x, opcode=0x%02x, [M1,MREQ,IORQ,RFSH,RD,WR]=[%d,%d,%d,%d,%d,%d], A=0x%02x, B=0x%02x\n",
        cpu.step, cpu.pc, cpu.opcode, Z80_GET_CTRL(M1), Z80_GET_CTRL(MREQ), Z80_GET_CTRL(IORQ), Z80_GET_CTRL(RFSH), Z80_GET_CTRL(RD), Z80_GET_CTRL(WR), cpu.a, cpu.b);
    for (int i = 0; i < 24; i++) {
        
        // tick the CPU
        pins = z80_tick(&cpu, pins);
        /* 状態表示 */
        if (cpu.step == 0) printf("< start fetch machine cycle >\n");
        if (Z80_GET_CTRL(RFSH) != 0) printf("\x1b[33m");    // 黄
        if (Z80_GET_CTRL(RD)   != 0) printf("\x1b[32m");    // 緑
        if (Z80_GET_CTRL(WR)   != 0) printf("\x1b[36m");    // シアン
        printf("step=%3d, pc=0x%04x, opcode=0x%02x, [M1,MREQ,IORQ,RFSH,RD,WR]=[%d,%d,%d,%d,%d,%d], A=0x%02x, B=0x%02x, addr=0x%04x, data=0x%02x\n",
            cpu.step, cpu.pc, cpu.opcode, Z80_GET_CTRL(M1), Z80_GET_CTRL(MREQ), Z80_GET_CTRL(IORQ), Z80_GET_CTRL(RFSH), Z80_GET_CTRL(RD), Z80_GET_CTRL(WR), cpu.a, cpu.b, Z80_GET_ADDR(pins), Z80_GET_DATA(pins));
        printf("\x1b[0m");  // デフォルト

        // handle memory read or write access
        if (pins & Z80_MREQ) {
            if (pins & Z80_RD) {
                Z80_SET_DATA(pins, mem[Z80_GET_ADDR(pins)]);
            }
            else if (pins & Z80_WR) {
                mem[Z80_GET_ADDR(pins)] = Z80_GET_DATA(pins);
            }
        }
    }

    // register A should now be 5
    printf("Register A: %d", cpu.a);
    return 0;
}
