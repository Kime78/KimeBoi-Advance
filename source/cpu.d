module cpu;

import types;
import std.stdio;
import memory;
import std.format;
/++++ The ARM7 CPU +/
class CPU
{
    uint32[12] regs; /++ CPU registers +/
    uint32 sp; /++ stack pointer of the CPU +/
    uint32 lr; /++ link register +/
    uint32 pc; /++ program counter +/
    uint32 cpsr; /++ current program status register +/
    Memory mem; /++ memory of the GBA +/
    File output; /++ outputs of the cpu +/

    /++ Initialises the CPU  +/
    this()
    {
        fill_arm();
        fill_thumb();
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
        output.write("PC = "); output.writeln(format("%X", pc - 0x8000000));
        output.write("Instruction: "); output.writeln(format("%X", opcode));

        arm_table[opcode]();
        for(int i = 0; i < 12; i++)
        {
            output.write("R");
            output.write(i);
            output.write(": ");
            output.write(format("%X",regs[i]));
            output.write(" ");
        }
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

    //this needs to be in another file 

    void delegate()[4096] arm_table; /++ LUT for the ARM instruction table +/
    void delegate()[1024] thumb_table; /++ LUT for the THUMB instruction table +/

    /++ Handler for undefined instructions +/
    void undefined_instruction() // I need to define structions in instructions.d
    {
        //uint32 opcode = get_arm_opcode(mem.read32(pc));
        //output.output.writeln(opcode);
        output.writeln("Unhandled Behaviour!");
        import core.stdc.stdlib;
        exit(0);
    }

    /++ Handler for the Branch opcode +/
    void branch_handler()
    {
        uint32 debugg = mem.read32(pc);
        output.write("b ");
        debugg &= 0xffffff;
        output.write(debugg);
        output.writeln("");

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
            case 0x4:
            {
                import arithmetics;
                
                //writeln(mem.read32(pc));
                output.write("add r");
                //uint16 operand = opcode & 0b111_1111_1111;
                uint8 dest_reg = (opcode & (0b1111 << 12)) >> 12;
                output.write(dest_reg);
                
                uint8 operand1 = (opcode >> 19) & 0b1111;
                const bool immediate_mode = (opcode >> 25) & 1;
                if(immediate_mode)
                {
                    uint8 immediate = opcode & 0b1111_1111;
                    uint8 steps = (opcode >> 8) & 0b1111;
                    regs[dest_reg] += operand1 + ror(immediate, steps * 2);
                    output.write(' ');
                    output.writeln(format("%X", operand1 + ror(immediate, steps * 2)));
                }
                else
                {
                    const uint8 shift_type = (opcode >> 4) & 0b11;
                    uint8 shift_amount;
                    if(((opcode >> 4) & 1) == 1)
                    {
                        uint8 id = ((opcode >> 8) & 0b1111);
                        //shift_amount = regs[id];
                    }
                    else
                    {
                        shift_amount = (opcode >> 7) & 0b1_1111;
                    }
                    const uint8 operand2 = opcode & 0b1111;
                    switch (shift_type)
                        {
                            case 0: //lsl
                            {
                                output.write(" lsl ");
                                output.write(format("%X", shift_amount));
                                output.write(" ");
                                regs[dest_reg] += operand2 << shift_amount;
                                break;
                            }case 0x4:
            {
                import arithmetics;
                
                //writeln(mem.read32(pc));
                output.write("add r");
                //uint16 operand = opcode & 0b111_1111_1111;
                uint8 dest_reg = (opcode & (0b1111 << 12)) >> 12;
                output.write(dest_reg);
                
                uint8 operand1 = (opcode >> 19) & 0b1111;
                const bool immediate_mode = (opcode >> 25) & 1;
                if(immediate_mode)
                {
                    uint8 immediate = opcode & 0b1111_1111;
                    uint8 steps = (opcode >> 8) & 0b1111;
                    regs[dest_reg] += operand1 + ror(immediate, steps * 2);
                    output.write(' ');
                    output.writeln(format("%X", operand1 + ror(immediate, steps * 2)));
                }
                else
                {
                    const uint8 shift_type = (opcode >> 4) & 0b11;
                    uint8 shift_amount;
                    if(((opcode >> 4) & 1) == 1)
                    {
                        uint8 id = ((opcode >> 8) & 0b1111);
                        //shift_amount = regs[id];
                    }
                    else
                    {
                        shift_amount = (opcode >> 7) & 0b1_1111;
                    }
                            case 1: //lsr
                            {
                                output.write("lsr");
                                regs[dest_reg] += operand2 >> shift_amount;
                                break;
                            }
                            case 2: //asr
                            {
                                output.write("asr");
                                break;
                            }
                            case 3: //ror
                            {
                                output.write("ror");
                                regs[dest_reg] += ror(operand2, shift_amount);
                                break;
                            }
                            default:
                            {
                                //crash
                                output.write("ita");
                                break;
                            }
                        }
                }
                
                pc += 4;
                break;
            }
            case 0xD: 
            {
                import arithmetics;
                
                //writeln(mem.read32(pc));
                output.write("mov r");
                //uint16 operand = opcode & 0b111_1111_1111;
                uint8 register_id = (opcode & (0b1111 << 12)) >> 12;
                output.write(register_id);
                
                
                const bool immediate_mode = (opcode >> 25) & 1;
                if(immediate_mode)
                {
                    uint8 operand2 = opcode & 0b1111_1111;
                    uint8 steps = (opcode >> 8) & 0b1111;
                    regs[register_id] = ror(operand2, steps * 2);
                    output.write(' ');
                    output.writeln(format("%X", ror(operand2, steps * 2)));
                }
                else
                {
                    const uint8 shift_type = (opcode >> 4) & 0b11;
                    uint8 shift_amount;
                    if(((opcode >> 4) & 1) == 1)
                    {
                        uint8 id = ((opcode >> 8) & 0b1111);
                        //shift_amount = regs[id];
                    }
                    else
                    {
                        shift_amount = (opcode >> 7) & 0b1_1111;
                    }

                    switch (shift_type)
                        {
                            case 0: //lsl
                            {
                                output.write(" lsl ");
                                output.write(format("%X", shift_amount));
                                output.write(" ");
                                regs[register_id] <<= shift_amount;
                                break;
                            }
                            case 1: //lsr
                            {
                                output.write("lsr");
                                regs[register_id] >>= shift_amount;
                                break;
                            }
                            case 2: //asr
                            {
                                output.write("asr");
                                break;
                            }
                            case 3: //ror
                            {
                                output.write("ror");
                                ror(regs[register_id], shift_amount);
                                break;
                            }
                            default:
                            {
                                //crash
                                output.write("ita");
                                break;
                            }
                        }
                }
                
                pc += 4;
                break;
            }
            default:
            {
                output.writeln("Unknown ALU");
                output.writeln(format("%X", mem.read32(pc)));
                import core.stdc.stdlib;
                exit(0);
                break;
            }
        } 
    }

    /++ Data Transfer Handler +/
    void datatransfer_handler()
    {
        uint32 opcode = mem.read32(pc);
        bool pre_post = (opcode >> 24) & 1;
        bool up_down = (opcode >> 23) & 1;
        bool immediate_flag = (opcode >> 22) & 1;
        bool write_back = 1;
        if(pre_post == 1 && (((opcode) >> 21) & 1) == 1)
            write_back = 0;
        bool load_store = (opcode >> 20) & 1;
        uint8 base_reg = (opcode >> 16) & 0b1111;
        uint8 dest_reg = (opcode >> 12) & 0b1111;

        uint8 imm_off = (opcode >> 8) & 0b1111;
        uint8 instr = (opcode >> 5) & 0b11;

        uint32 offset;
        if(immediate_flag)
        {
            offset = opcode & 0b1111;
        }
        else
        {
            offset = regs[opcode & 0b1111];
        }
        if(load_store == 0)
        {
            switch(instr)
            {
                case 1:
                {
                    output.write("strh ");
                    uint32 addr = regs[base_reg];
                    if(pre_post)
                    {
                        if(up_down)
                        {
                            addr += offset;
                        }
                        else
                        {
                            addr -= offset;
                        }

                        mem.write32(addr, regs[dest_reg]);
                        if(write_back)
                        {
                            regs[base_reg] = addr;
                        }
                    }
                    else
                    {
                        mem.write32(addr, regs[dest_reg]);

                        if(up_down)
                        {
                            addr += offset;
                        }
                        else
                        {
                            addr -= offset;
                        }

                        regs[base_reg] = addr;
                    }
                    break;
                }
                default:
                {
                    writeln(instr);
                    break;
                }
            }
        }
        else
        {
            writeln("undefined behavior: data transfer2");
        }    

        pc += 4;
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
                arm_table[i] = &dataproc_handler;
            }

            if((((i >> 0) & 1) == 1) && (((i >> 3) & 1) == 1))
            {
                arm_table[i] = &datatransfer_handler;
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