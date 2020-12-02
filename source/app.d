import std.stdio;
import types;
import memory;

import cpu;
import bindbc.sdl;

uint16[] pixels = new uint16[1000 * 480];
void update_screen(CPU cpu)
{
    for(int i = 0; i < 240; i += 2)
    {
        for(int j = 0; j < 160; j += 2)
        {
            pixels[i + 240 * j] = cpu.mem.read16(0x06000000 + 2 * (i + j * 240));
            pixels[i + 240 * j + 1] = cpu.mem.read16(0x06000000 + 2 * (i + j * 240));
            //pixels[i + 240 * j + 240] = cpu.mem.read16(0x06000000 + 2*(i + j*240));
            //pixels[i + 240 * j + 241] = cpu.mem.read16(0x06000000 + 2*(i + j*240));
            //pixels[i + 240 * j + 2] = cpu.mem.read16(0x06000000 + i + j * 240);
            //pixels[i + 240 * j + 3] = cpu.mem.read16(0x06000000 + i + j * 240); 
            //write(cpu.mem.read16(0x06000000 + i + j * 240));
            //write(" ");
            //write(pixels[i * 240 + j]);
        }
    }
}

void main()
{ 
    int fake = 0;
    CPU cpu = new CPU;

    SDLSupport ret = loadSDL();

    SDL_Window* window;
    SDL_Texture* texture;
    SDL_Renderer* renderer;
    window = SDL_CreateWindow("KimeBoi Advance", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 480, 320, SDL_WINDOW_OPENGL);
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_BGR555, SDL_TEXTUREACCESS_TARGET, 240, 160);

    while(true)
    {
        SDL_Event e;
        if (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                break;
            }
        }
        cpu.emulate_cycle();
        fake++;

        if(fake == 2666)
        {
            //SDL_SetRenderTarget(renderer, texture);
            update_screen(cpu);
            SDL_UpdateTexture(texture, null, pixels.ptr, 240 * 4);
            SDL_RenderClear(renderer);
            SDL_RenderCopy(renderer, texture, null, null);
            SDL_RenderPresent(renderer);
            fake = 0;
        }
        
    }
    
}
