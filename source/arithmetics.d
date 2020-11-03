module arithmetics;
import types;

/++ Rotates right a number a number of steps +/
uint32 ror(uint32 operand, uint32 steps)
{
    return (operand << steps) | (operand >> (32 - steps)); 
}


/++ Rotates left a number a number of steps +/
uint32 rol(uint32 operand, uint32 steps)
{
    return (operand >> steps) | (operand << (32 - steps)); 
}
