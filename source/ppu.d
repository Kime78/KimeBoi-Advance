module ppu;

import types;
import cpu;
import memory;
import std.stdio;
import bindbc.sdl;

int ppu_cycles = 0;
int line_counter = 0;
SDL_Window* window;
SDL_Texture* texture;
SDL_Renderer* renderer;
uint16[] pixels = new uint16[160 * 240];

enum ppu_state
{
    VBlank,
    HBlank,
    HDraw,
};

ppu_state state = ppu_state.HDraw;

void emulate_ppu(CPU cpu)
{
    switch (state)
    {
        case ppu_state.HDraw:
        {
            if(ppu_cycles == 0)
            {
                //enter HDRAW
                cpu.mem.write16(0x4000004, cpu.mem.read16(0x4000004) & 0b1111_1111_1111_1101);//this is not in hblank, so we reset hblank
            }

            if(ppu_cycles == 240)
            {
                //leave HDRAW
                state = ppu_state.HBlank;
                ppu_cycles = -4;
            }

            break;
        }

        case ppu_state.HBlank:
        {
            if(ppu_cycles == 0)
            {
                cpu.mem.write16(0x4000004, cpu.mem.read16(0x4000004) | 0b10);
                put_line(cpu.mem, line_counter);
                line_counter++;
                //put the mf line
                //enter HBLANK
            }

            if(ppu_cycles == 68)
            {
                //leave HBLANK
                if(line_counter == 160)
                    state = ppu_state.VBlank;
                else 
                    state = ppu_state.HDraw;
                ppu_cycles = -4;
            }

            break;
        }

        case ppu_state.VBlank:
        {
            if(ppu_cycles == 0)
            {
                cpu.mem.write16(0x4000004, cpu.mem.read16(0x4000004) | 0b1);
                draw_frame();
                //draw the screen
                //enter VBLANK
            }

            if(ppu_cycles == 308 * 68)
            {
                cpu.mem.write16(0x4000004, cpu.mem.read16(0x4000004) & 0b1111_1111_1111_1110);
                line_counter = 0;
                //leave VBLANK
                state = ppu_state.HDraw;
                ppu_cycles = -4;
            }

            break;
        }

        default:
        {
            //you fucking crashed you fucking moron 
        }
    }

    ppu_cycles++;
}

void put_line(Memory mem, int line)
{
    for(int i = 0; i < 240; i++)
    {
        pixels[line * 240 + i] = mem.read16(0x06000000 + 2 * (line  * 240 + i));
    }
}

void draw_frame()
{    
    SDL_UpdateTexture(texture, null, pixels.ptr, 240 * uint16.sizeof);
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, null, null);
    SDL_RenderPresent(renderer);
}

void init_ppu()
{
    SDLSupport ret = loadSDL();
    for(int i = 0; i < 160; i++)
    {
        for(int j = 0; j < 240; j++)
        {
            pixels[i + j * 160] = 0;
        }
    }
    window = SDL_CreateWindow("KimeBoi Advance", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 480, 320, SDL_WINDOW_SHOWN);
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_BGR555, SDL_TEXTUREACCESS_STREAMING, 240, 160);
}