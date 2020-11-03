module arithmetics;
import types;

/++ Rotates right a number a number of steps +/
uint32 ror(uint32 operand, uint32 steps)
{    
    uint32 a = operand >> steps;
    uint32 b = operand << (32 - steps);
   
    return a | b; 
}


/++ Rotates left a number a number of steps +/
uint32 rol(uint32 operand, uint32 steps)
{
    return (operand >> steps) | (operand << (32 - steps)); 
}
