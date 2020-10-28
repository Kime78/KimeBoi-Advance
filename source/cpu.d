module cpu;

import types;
import std.stdio : writeln;
import memory;

class CPU
{
    uint32[12] regs; //registers
    uint32 sp; //stack pointer
    uint32 lr; //link register
    uint32 pc; //program counter
    uint32 cpsr; //current program status register
    Memory mem;
    this()
    {
        fill_arm();
        fill_thumb();
        mem = new Memory;
        pc = 0x8_000_000;
        mem.read_game();
    }

    int emulate_cycle()
    {
        uint32 opcode = get_arm_opcode(mem.read32(pc));
        arm_table[opcode]();
        writeln(opcode);
        return 0;
    }

    uint32 get_thumb_opcode(uint32 opcode)
    {
        return (opcode >> 8);
    }

    uint32 get_arm_opcode(uint32 opcode)
    {
        return ((opcode >> 16) & 0xFF0) | ((opcode >> 4) & 0xF);
    }

    //this needs to be in another file 

    void delegate()[4096] arm_table;
    void delegate()[1024] thumb_table;

    void undefined_instruction() // I need to define structions in instructions.d
    {
        writeln("Unhandled Behaviour!");
    }

    void fill_arm()
    {
        for(int i = 0; i < 4096; i++)
        {
            arm_table[i] = &undefined_instruction;
        }
    }

    void fill_thumb()
    {
        for(int i = 0; i < 1024; i++)
        {
            thumb_table[i] = &undefined_instruction;
        }
    }
}