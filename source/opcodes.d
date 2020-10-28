module opcodes;

import cpu;
import instructions;
import std.stdio;
class CPU
{
    void delegate()[4096] arm_table;
    void delegate()[1024] thumb_table;

    void undefined_instruction() // I need to define structions in instructions.d
    {
        writeln("Undefined Behaviour!");
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