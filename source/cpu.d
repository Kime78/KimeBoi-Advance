module cpu;

import types;
import std.stdio;
import memory;
import std.format;
import opcodes;

/++++ The ARM7 CPU +/
class CPU
{
    uint32[12] regs; /++ CPU registers +/
    uint32 sp; /++ stack pointer of the CPU +/
    uint32 lr; /++ link register +/
    uint32 pc; /++ program counter +/
    uint32 cpsr = 0x1F; /++ current program status register +/
    Memory mem; /++ memory of the GBA +/
    File output; /++ outputs of the cpu +/
    LUT lut; /++ Look Up Table+/
    

    /++ Modifies The Zero conditonal flag +/
    void flag_zero(bool bit) 
    {
        if(bit)
        {
            cpsr |= 1UL << 30;
        }
        else
        {
            cpsr &= ~(1UL << 30);
        }
    }

    /++ Modifies The Signed Overflow flag +/
    void flag_signed(bool bit)
    {
        if(bit)
        {
            cpsr |= 1UL << 31;
        }
        else
        {
            cpsr &= ~(1UL << 31);
        }
    } 

    /++ Modifies The Overflow flag +/
    void flag_overflow(bool bit)
    {
        if(bit)
        {
            cpsr |= 1UL << 28;
        }
        else
        {
            cpsr &= ~(1UL << 28);
        }
    }

    /++ Modifies The Carry flag +/
    void flag_carry(bool bit) 
    {
        if(bit)
        {
            cpsr |= 1UL << 29;
        }
        else
        {
            cpsr &= ~(1UL << 29);
        }
    }

    /++ Initialises the CPU  +/
    this()
    {
        lut = new LUT;
        lut.fill_arm();
        lut.fill_thumb();
        mem = new Memory;
        pc = 0x8_000_000;
        mem.read_game();
        output = File("output.out", "w");
    }
    /++ Emulates a single CPU cycle, returns the number of cycles taken +/
    int emulate_cycle()
    {
        uint32 opcode = get_arm_opcode(mem.read32(pc));
        output.writeln("");
        output.write("PC = "); output.writeln(format("%X", pc));
        output.write("Instruction: "); output.writeln(format("%X", opcode));

        lut.arm_table[opcode](this);
        for(int i = 0; i < 12; i++)
        {
            output.write("R");
            output.write(i);
            output.write(": ");
            output.write(format("%X",regs[i]));
            output.write(" ");
        }
        output.write("CPRS: ");
        output.write(format("%X", cpsr));
        output.writeln("");
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

}