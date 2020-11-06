module opcodes;

import cpu;
import arm;
import std.stdio;
import std.functional;

class LUT
{
    void delegate(CPU)[4096] arm_table; /++ LUT for the ARM instruction table +/
    void delegate(CPU)[1024] thumb_table; /++ LUT for the THUMB instruction table +/
    
    void fill_arm()
    {
        for(int i = 0; i < 4096; i++)
        {
            arm_table[i] = toDelegate(&undefined_instruction);

            if((i >> 9) == 0b0101)
                arm_table[i] = toDelegate(&branch_handler);

            
            if(i <= 0x400)  
            {
                arm_table[i] = toDelegate(&dataproc_handler);
            }

            if((((i >> 0) & 1) == 1) && (((i >> 3) & 1) == 1))
            {
                arm_table[i] = toDelegate(&datatransfer_handler);
            }
                
        }
    }
    /++ Fills the THUMB LUT +/
    void fill_thumb()
    {
        for(int i = 0; i < 1024; i++)
        {
            thumb_table[i] = toDelegate(&undefined_instruction);
        }
    }
}