module cpu;

import types;

class CPU
{
    uint32[12] regs; //registers
    uint32 sp; //stack pointer
    uint32 lr; //link register
    uint32 pc; //program counter
    uint32 cpsr; //current program status register

    int emulate_cycle()
    {
        return 0;
    }
}