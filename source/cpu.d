module cpu;

import types;
import std.stdio;
import memory;
import std.format;
import opcodes;

/++++ The ARM7 CPU +/
class CPU
{
    uint32[16] regs; /++ CPU registers +/
    uint32 sp; /++ stack pointer of the CPU +/
    uint32 lr; /++ link register +/
    uint32 pc; /++ program counter +/
    uint32 cpsr = 0x1F; /++ current program status register +/
    Memory mem; /++ memory of the GBA +/
    File output; /++ outputs of the cpu +/
    LUT lut; /++ Look Up Table+/
    
    /++ Returns the signed flag ++/
    bool get_signed_flag()
    {
        return (cpsr >> 31) & 1;
    }

    /++ Returns the zero flag ++/
    bool get_zero_flag()
    {
        return (cpsr >> 30) & 1;
    }

    /++ Returns the carry flag ++/
    bool get_carry_flag()
    {
        return (cpsr >> 29) & 1;
    }

    /++ Returns the overflow flag ++/
    bool get_overflow_flag()
    {
        return (cpsr >> 28) & 1;
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
        output.write("Cond: "); output.writeln((mem.read32(pc) >> 28) & 0b1111);

        bool cond = 0;
        switch (mem.read32(pc) >> 28 & 0b1111)
        {
            case 0x0:
            {
                cond = get_zero_flag() == 1;
                break;
            }
            
            case 0x1:
            {
                cond = get_zero_flag() == 0;
                break;
            }

            case 0x2:
            {
                cond = get_carry_flag() == 1;
                break;
            }

            case 0x3:
            {
                cond = get_carry_flag() == 0;
                break;
            }

            case 0x4:
            {
                cond = get_signed_flag() == 1;
                break;
            }

            case 0x5:
            {
                cond = get_signed_flag() == 0;
                break;
            }

            case 0x6:
            {
                cond = get_overflow_flag() == 1;
                break;
            }

            case 0x7:
            {
                cond = get_overflow_flag() == 0;
                break;
            }

            case 0x8:
            {
                cond = (get_carry_flag() == 1) && (get_zero_flag() == 0);
                break;
            }

            case 0x9:
            {
                cond = (get_carry_flag() == 0) || (get_zero_flag() == 1);
                break;
            }

            case 0xA:
            {
                cond = get_signed_flag() == get_overflow_flag();
                break;
            }

            case 0xB:
            {
                bool a = get_signed_flag();
                bool b = get_overflow_flag();
                cond = get_signed_flag() != get_overflow_flag();    
                break;
            }

            case 0xC:
            {
                cond = (get_zero_flag() == 0) && (get_signed_flag() == get_overflow_flag());
                break;
            }

            case 0xD:
            {
                cond = (get_zero_flag() == 1) && (get_signed_flag() != get_overflow_flag());
                break;
            }
            
            case 0xE:
            {
                cond = 1;
                break;
            }

            default:
            {
                write("UNHANDLED COND ");
                writeln(mem.read32(pc) >> 28 & 0b1111);
                break;
            }
        }
        if(cond)
            lut.arm_table[opcode](this);
        else 
        {
            write('a');
            pc += 4;
        }
            
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

        sp = regs[13];
        lr = regs[14];
        regs[15] = pc;
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