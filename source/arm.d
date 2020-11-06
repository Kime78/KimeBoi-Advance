module arm;

import std.stdio;
import cpu;
import types;
import std.format;

/++ Handler for undefined instructions +/
void undefined_instruction(CPU cpu) // I need to define structions in instructions.d
{
    //uint32 opcode = get_arm_opcode(mem.read32(pc));
    //output.output.writeln(opcode);
    cpu.output.writeln("Unhandled Behaviour!");
    import core.stdc.stdlib;
    exit(0);
}

/++ Handler for the Branch opcode +/
void branch_handler(CPU cpu)
{
    uint32 debugg = cpu.mem.read32(cpu.pc);
    bool opcode = (debugg >> 24) & 1;
    cpu.output.write(format("%X", cpu.mem.read32(cpu.pc)));
    cpu.output.write("b ");
    
    debugg &= 0xffffff;
    

    cpu.pc += (debugg << 2);
    cpu.pc += 8;
    if(opcode)
    {
        cpu.output.write("blt ");
        cpu.lr = cpu.pc + 4;
    }
    cpu.output.write(format("%X", debugg));
    cpu.output.writeln("");
}

/++ Handler for the Data Proc opcode +/
void dataproc_handler(CPU cpu)
{
    const uint32 alu_opcode = (cpu.mem.read32(cpu.pc) >> 21) & 0b1111;
    const uint32 opcode = cpu.mem.read32(cpu.pc);
    //alu_opcode &= 0x1e;
    switch (alu_opcode)
    {
        case 0x4:
        {
            import arithmetics;
            
            //writeln(mem.read32(pc));
            cpu.output.write("add r");
            //uint16 operand = opcode & 0b111_1111_1111;
            uint8 dest_reg = (opcode >> 12) & 0b1111;
            cpu.output.write(dest_reg);
            
            uint8 operand1 = (opcode >> 16) & 0b1111;
            cpu.output.write(" r");
            cpu.output.write(operand1);
            const bool immediate_mode = (opcode >> 25) & 1;
            if(immediate_mode)
            {
                uint8 immediate = opcode & 0b1111_1111;
                uint8 steps = (opcode >> 8) & 0b1111;
                cpu.regs[dest_reg] += operand1 + ror(immediate, steps * 2);
                cpu.output.write(' ');
                cpu.output.writeln(format("%X", operand1 + ror(immediate, steps * 2)));
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
                        cpu.output.write(" lsl ");
                        cpu.output.write(format("%X", shift_amount));
                        cpu.output.write(" ");
                        cpu.regs[dest_reg] += operand2 << shift_amount;
                        break;
                    }
                    case 1: //lsr
                    {
                        cpu.output.write("lsr");
                        cpu.regs[dest_reg] += operand2 >> shift_amount;
                        break;
                    }
                    case 2: //asr
                    {
                        cpu.output.write("asr");
                        break;
                    }
                    case 3: //ror
                    {
                        cpu.output.write("ror");
                        cpu.regs[dest_reg] += ror(operand2, shift_amount);
                        break;
                    }
                    default:
                    {
                        //crash
                        cpu.output.write("ita");
                        break;
                    }
                }
            }
            cpu.pc += 4;
            break;
        }

        case 0xA:
        {
            import arithmetics;
            
            //writeln(mem.read32(pc));
            cpu.output.write("cmpr r");
            //uint16 operand = opcode & 0b111_1111_1111;
            uint8 dest_reg = (opcode >> 12) & 0b1111;
            cpu.output.write(dest_reg);
    
            uint8 operand1 = (opcode >> 16) & 0b1111;
            cpu.output.write(" r");
            cpu.output.write(operand1);
            const bool immediate_mode = (opcode >> 25) & 1;
            if(immediate_mode)
            {
                uint8 immediate = opcode & 0b1111_1111;
                uint8 steps = (opcode >> 8) & 0b1111;

                uint32 aux = cpu.regs[dest_reg] - operand1 + ror(immediate, steps * 2);
                //set flags here UwU
                cpu.flag_zero(aux == 0);
                cpu.flag_overflow(cpu.regs[dest_reg] - operand1 + ror(immediate, steps * 2) > 0);
                cpu.flag_signed(aux >> 31);
                cpu.flag_carry(cpu.regs[dest_reg] - operand1 + ror(immediate, steps * 2) > 0x80000000);

                cpu.output.write(' ');
                cpu.output.writeln(format("%X", operand1 + ror(immediate, steps * 2)));
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
                        cpu.output.write(" lsl ");
                        cpu.output.write(format("%X", shift_amount));
                        cpu.output.write(" ");

                        uint32 aux = cpu.regs[dest_reg] - operand2 << shift_amount;
                        //set flags UwU
                        cpu.flag_zero(aux == 0);
                        cpu.flag_overflow(cpu.regs[dest_reg] - operand2 << shift_amount > 0);
                        cpu.flag_signed(aux >> 31);
                        cpu.flag_carry(cpu.regs[dest_reg] - operand2 << shift_amount > 0x80000000);


                        break;
                    }
                    case 1: //lsr
                    {
                        cpu.output.write("lsr");

                        uint32 aux = cpu.regs[dest_reg] - operand2 >> shift_amount;
                        //set flags UwU
                        cpu.flag_zero(aux == 0);
                        cpu.flag_overflow(cpu.regs[dest_reg] - operand2 >> shift_amount > 0);
                        cpu.flag_signed(aux >> 31);
                        cpu.flag_carry(cpu.regs[dest_reg] - operand2 >> shift_amount > 0x80000000);
                        break;
                    }
                    case 2: //asr
                    {
                        cpu.output.write("asr");
                        break;
                    }
                    case 3: //ror
                    {
                        cpu.output.write("ror");

                        uint32 aux = cpu.regs[dest_reg] - ror(operand2, shift_amount);
                        //set flags UwU
                        cpu.flag_zero(aux == 0);
                        cpu.flag_overflow(cpu.regs[dest_reg] - ror(operand2, shift_amount) > 0);
                        cpu.flag_signed(aux >> 31);
                        cpu.flag_carry(cpu.regs[dest_reg] - ror(operand2, shift_amount) > 0x80000000);
                        break;
                    }
                    default:
                    {
                        //crash
                        cpu.output.write("ita");
                        break;
                    }
                }
            }
            cpu.pc += 4;
            break;
        }

        case 0xD: 
        {
            import arithmetics;
            
            //writeln(mem.read32(pc));
            cpu.output.write("mov r");
            //uint16 operand = opcode & 0b111_1111_1111;
            uint8 register_id = (opcode & (0b1111 << 12)) >> 12;
            cpu.output.write(register_id);
            
            
            const bool immediate_mode = (opcode >> 25) & 1;
            if(immediate_mode)
            {
                uint8 operand2 = opcode & 0b1111_1111;
                uint8 steps = (opcode >> 8) & 0b1111;
                cpu.regs[register_id] = ror(operand2, steps * 2);
                cpu.output.write(' ');
                cpu.output.writeln(format("%X", ror(operand2, steps * 2)));
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
                            cpu.output.write(" lsl ");
                            cpu.output.write(format("%X", shift_amount));
                            cpu.output.write(" ");
                            cpu.regs[register_id] <<= shift_amount;
                            break;
                        }
                        case 1: //lsr
                        {
                            cpu.output.write("lsr");
                            cpu.regs[register_id] >>= shift_amount;
                            break;
                        }
                        case 2: //asr
                        {
                            cpu.output.write("asr");
                            break;
                        }
                        case 3: //ror
                        {
                            cpu.output.write("ror");
                            ror(cpu.regs[register_id], shift_amount);
                            break;
                        }
                        default:
                        {
                            //crash
                            cpu.output.write("ita");
                            break;
                        }
                    }
            }
            
            cpu.pc += 4;
            break;
        }
        default:
        {
            cpu.output.writeln("Unknown ALU");
            cpu.output.writeln(format("%X", cpu.mem.read32(cpu.pc)));
            import core.stdc.stdlib;
            exit(0);
            break;
        }
    } 
}

/++ Data Transfer Handler +/
void datatransfer_handler(CPU cpu)
{
    uint32 opcode = cpu.mem.read32(cpu.pc);
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
        offset = cpu.regs[opcode & 0b1111];
    }
    if(load_store == 0)
    {
        switch(instr)
        {
            case 1:
            {
                cpu.output.write("strh ");
                uint32 addr = cpu.regs[base_reg];
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

                    cpu.mem.write32(addr, cpu.regs[dest_reg]);
                    if(write_back)
                    {
                        cpu.regs[base_reg] = addr;
                    }
                }
                else
                {
                    cpu.mem.write32(addr, cpu.regs[dest_reg]);

                    if(up_down)
                    {
                        addr += offset;
                    }
                    else
                    {
                        addr -= offset;
                    }

                    cpu.regs[base_reg] = addr;
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

    cpu.pc += 4;
}
