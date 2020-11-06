import std.stdio;
import types;
import memory;

import cpu;

void main()
{ 
    CPU cpu = new CPU;
    while(true)
    {
        cpu.emulate_cycle();
    }
    
}
