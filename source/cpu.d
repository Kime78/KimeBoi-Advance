module cpu;

import types;
import std.stdio;
import memory;

/++++ The ARM7 CPU +/
class CPU
{
    uint32[12] regs; /++ CPU registers +/
    uint32 sp; /++ stack pointer of the CPU +/
    uint32 lr; /++ link register +/
    uint32 pc; /++ program counter +/
    uint32 cpsr; /++ current program status register +/
    Memory mem; /++ memory of the GBA +/
    /++ Initialises the CPU  +/
    this()
    {
        fill_arm();
        fill_thumb();
        mem = new Memory;
        pc = 0x8_000_000;
        mem.read_game();
    }
    /++ Emulates a single CPU cycle, returns the number of cycles taken +/
    int emulate_cycle()
    {
        uint32 opcode = get_arm_opcode(mem.read32(pc));
        writeln("");
        write("PC = "); writeln(pc - 0x8000000);
        write("Instruction: "); writeln(opcode);

        arm_table[opcode]();
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

    void delegate()[4096] arm_table; /++ LUT for the ARM instruction table +/
    void delegate()[1024] thumb_table; /++ LUT for the THUMB instruction table +/

    /++ Handler for undefined instructions +/
    void undefined_instruction() // I need to define structions in instructions.d
    {
        //uint32 opcode = get_arm_opcode(mem.read32(pc));
        //writeln(opcode);
        writeln("Unhandled Behaviour!");
        import core.stdc.stdlib;
        exit(0);
    }

    /++ Handler for the Branch opcode +/
    void branch_handler()
    {
        uint32 debugg = mem.read32(pc);
        write("b ");
        debugg &= 0xffffff;
        write(debugg);
        writeln("");

        pc += (debugg << 2);
        pc += 8;
    }

    /++ Handler for the Data Proc opcode +/
    void dataproc_handler()
    {
        const uint32 alu_opcode = (mem.read32(pc) >> 21) & 0b1111;
        const uint32 opcode = mem.read32(pc);
        //alu_opcode &= 0x1e;
        switch (alu_opcode)
        {
            case 0xD: 
            {
                import arithmetics;
                
                writeln(mem.read32(pc));
                write("mov r");
                uint16 operand = opcode & 0b111_1111_1111;
                uint8 register_id = (opcode & (0b1111 << 11)) >> 11;
                write(register_id);
                write(' ');
                writeln(operand);
                
                const bool immediate_mode = (opcode >> 25) & 1;
                if(immediate_mode)
                {
                    uint8 operand2 = opcode & 0b1111_1111;
                    uint8 steps = (opcode >> 8) & 0b1111;
                    regs[register_id] = ror(operand2, steps);
                }
                else
                {
                    if(((opcode >> 3) & 1) == 1)
                    {
                        const uint8 shift_type = (opcode >> 4) & 0b11;
                        const uint16 immediate = (opcode >> 6) & 0b11111; 
                        switch (shift_type)
                        {
                            case 0: //lsl
                            {

                            }
                            case 1: //lsr
                            {

                            }
                            case 2: //asr
                            {

                            }
                            case 3: //ror
                            {

                            }
                            default:
                            {
                                //crash
                            }
                        }
                    }
                    else
                    {
                        //shift by reg
                    }
                }
                
                pc += 4;
                break;
            }
            default:
            {
                writeln("ita");
                writeln(mem.read32(pc));
                import core.stdc.stdlib;
                exit(0);
                break;
            }
        } 
    }

    /++ Fills the ARM LUT +/
    void fill_arm()
    {
        for(int i = 0; i < 4096; i++)
        {
            arm_table[i] = &undefined_instruction;

            if((i >> 9) == 0b0101)
                arm_table[i] = &branch_handler;

            if(i <= 0x400)  
            {
                arm_table[i] = & dataproc_handler;
            }
        }
    }
    /++ Fills the THUMB LUT +/
    void fill_thumb()
    {
        for(int i = 0; i < 1024; i++)
        {
            thumb_table[i] = &undefined_instruction;
        }
    }
}