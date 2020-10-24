module mmu;
import types;

class MMU
{

    //ram
    uint8[] bios;
    uint8[] wram2;
    uint8[] wram1;
    uint8[] io;

    //vram
    uint8[] obj_pallete;
    uint8[] vram;
    uint8[] obj_attr;

    //rom
    uint8[] rom; 
    uint8[] srom;
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

    uint32 read32(uint32 address)
    {
        if (address <= 0x3FFF)
            return (bios[address + 3] << 24) | (bios[address + 2] << 16) | (
                    bios[address + 1] << 8) | bios[address];
        if (address >= 0x02000000 && address <= 0x0203FFFF)
            return (wram2[address + 3] << 24) | (wram2[address + 2] << 16) | (
                    wram2[address + 1] << 8) | wram2[address];
        if (address >= 0x03000000 && address <= 0x03007FFF)
            return (wram1[address + 3] << 24) | (wram1[address + 2] << 16) | (
                    wram1[address + 1] << 8) | wram1[address];
        if (address >= 0x04000000 && address <= 0x040003FE)
            return (io[address + 3] << 24) | (io[address + 2] << 16) | (
                    io[address + 1] << 8) | io[address];

        if (address >= 0x05000000 && address <= 0x050003FF)
            return (obj_pallete[address + 3] << 24) | (obj_pallete[address + 2] << 16) | (
                    obj_pallete[address + 1] << 8) | obj_pallete[address];
        if (address >= 0x06000000 && address <= 0x06017FFF)
            return (vram[address + 3] << 24) | (vram[address + 2] << 16) | (
                    vram[address + 1] << 8) | vram[address];
        if (address >= 0x07000000 && address <= 0x070003FF)
            return (obj_attr[address + 3] << 24) | (obj_attr[address + 2] << 16) | (
                    obj_attr[address + 1] << 8) | obj_attr[address];

        //if(address >= 0x08000000 && address <= 0x09FFFFFF)   
        //return (rom[address + 3] << 24) | (rom[address + 2] << 16) | (rom[address + 1] << 8) | rom[address];
        /*
        if(address >= 0x0A000000 && address <= 0x0BFFFFFF)
            return rom[address];
        if(address >= 0x0C000000 && address <= 0x0DFFFFFF)
            return rom[address];    
        */
        //if(address >= 0x05000000 && address <= 0x050003FF)    

       
        return 0;

    }

    uint16 read16(uint32 address)
    {
        return 0;
    }

    uint8 read8(ulong address)
    {
        if (address <= 0x3FFF)
            return bios[address]; //this is a UINT8 !!!!!!
        if (address >= 0x02000000 && address <= 0x0203FFFF)
            return wram2[address]; //this is a UINT8 !!!!!!
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

    void write32(uint32 address, uint32 value)
    {

    }

    void write16(uint32 address, uint32 value)
    {

    }

    void write8(uint32 address, uint32 value)
    {

    }
}
