// GBA Does Not Have A MMU 

module memory;
import types;
import std.stdio;
import std.file;

/++ Class that handles the memory of the GBA +/
class Memory
{

    //ram
    uint8[] bios; /++ bios RAM+/
    uint8[] wram2; /++ Work RAM 2 +/
    uint8[] wram1; /++ Work RAM 1 +/
    uint8[] io; /++ Input/Output RAM +/

    //vram
    uint8[] obj_pallete; /++ OBJ pallete VRAM +/
    uint8[] vram; /++ VRAM +/
    uint8[] obj_attr; /++ OBJ attributes +/

    //rom
    uint8[] rom; /++ ROM +/
    uint8[] srom; /++ Special ROM +/

    /++ Initialises the Memory +/
    this()
    {
        bios = new uint8[16_384];
        wram2 = new uint8[262_144];
        wram1 = new uint8[32_768];
        io = new uint8[0x3FE];

        obj_pallete = new uint8[1024];
        vram = new uint8[98_304];
        obj_attr = new uint8[1024];

        rom = new uint8[33_554_432];
        srom = new uint8[65_536];
    }

    /++ Reads a 32bit number from memory +/
    uint32 read32(uint32 address)
    {
        if (address <= 0x3FFF)
            return (bios[address + 3] << 24) | (bios[address + 2] << 16) | (
                    bios[address + 1] << 8) | bios[address];
        if (address >= 0x02000000 && address <= 0x0203FFFF)
            return (wram2[address - 0x02000000 + 3] << 24) | (wram2[address - 0x02000000 + 2] << 16) | (
                    wram2[address - 0x02000000 + 1] << 8) | wram2[address - 0x02000000];
        if (address >= 0x03000000 && address <= 0x03007FFF)
            return (wram1[address - 0x03000000 + 3] << 24) | (wram1[address - 0x03000000 + 2] << 16) | (
                    wram1[address - 0x03000000 + 1] << 8) | wram1[address - 0x03000000];
        if (address >= 0x04000000 && address <= 0x040003FE)
            return (io[address - 0x04000000 + 3] << 24) | (io[address - 0x04000000 + 2] << 16) | (
                    io[address - 0x04000000 + 1] << 8) | io[address - 0x04000000];

        if (address >= 0x05000000 && address <= 0x050003FF)
            return (obj_pallete[address - 0x05000000 + 3] << 24) | (obj_pallete[address - 0x05000000 + 2] << 16) | (
                    obj_pallete[address - 0x05000000 + 1] << 8) | obj_pallete[address - 0x05000000];
        if (address >= 0x06000000 && address <= 0x06017FFF)
            return (vram[address - 0x06000000 + 3] << 24) | (vram[address + 2] - 0x06000000 << 16) | (
                    vram[address - 0x06000000 + 1] << 8) | vram[address - 0x06000000];
        if (address >= 0x07000000 && address <= 0x070003FF)
            return (obj_attr[address - 0x07000000 + 3] << 24) | (obj_attr[address - 0x07000000 + 2] << 16) | (
                    obj_attr[address - 0x07000000 + 1] << 8) | obj_attr[address - 0x07000000];

        if(address >= 0x08000000 && address <= 0x09FFFFFF)   
            return (rom[address - 0x08000000 + 3] << 24) | (rom[address - 0x08000000  + 2] << 16) | (rom[address - 0x08000000 + 1] << 8) | rom[address - 0x08000000];
        /*
        if(address >= 0x0A000000 && address <= 0x0BFFFFFF)
            return rom[address];
        if(address >= 0x0C000000 && address <= 0x0DFFFFFF)
            return rom[address];    
        */
        //if(address >= 0x05000000 && address <= 0x050003FF)    

       
        return 0;

    }

    /++ Reads a 16bit number from memory +/
    uint16 read16(uint32 address)
    {
        return 0;
    }

    /++ Reads a 8bit number from memory +/
    uint8 read8(ulong address)
    {
        if (address <= 0x3FFF)
            return bios[address]; 
        if (address >= 0x02000000 && address <= 0x0203FFFF)
            return wram2[address]; 
        if (address >= 0x03000000 && address <= 0x03007FFF)
            return wram1[address];
        if (address >= 0x04000000 && address <= 0x040003FE)
            return io[address];

        if (address >= 0x05000000 && address <= 0x050003FF)
            return obj_pallete[address];
        if (address >= 0x06000000 && address <= 0x06017FFF)
            return vram[address];
        if (address >= 0x07000000 && address <= 0x070003FF)
            return obj_attr[address];

        // if(address >= 0x08000000 && address <= 0x09FFFFFF)   
        // return rom[address];
        // if(address >= 0x0A000000 && address <= 0x0BFFFFFF)
        // return rom[address];
        //if(address >= 0x0C000000 && address <= 0x0DFFFFFF)
        // return rom[address];    
     
        return 0;
    }

    /++ Writes a 32bit number to memory +/
    void write32(uint32 address, uint32 value)
    {

    }

    /++ Writes a 16bit number to memory +/
    void write16(uint32 address, uint32 value)
    {

    }

    /++ Writes a 8bit number to memory +/
    void write8(uint32 address, uint32 value)
    {

    }

    /++ Reads the game from a file, stores it into ROM +/
    void read_game()
    {
        auto game = File("test.gba", "r");
        rom = cast(uint8[]) game.rawRead(new char[1_000_000]);
    }
}
