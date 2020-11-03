import std.stdio;
import types;
import memory;

import cpu;

void main()
{ 
    //test.srom[0] = cast(uint8)5;
    CPU cpu = new CPU;
    while(true)
    {
        cpu.emulate_cycle();
    }
    
}
