format binary as 'gba'

header:
        include 'lib/header.inc'

main:
    mov sp, #0x3000000 ; init SP
    mov r0, #0x4000000 ; set DISPCNT to BG2 + mode 4
    mov r1, #0x400
    add r1, #4
    strh r1, [r0]

    mov r0, #0x6000000 ; clear VRAM
    add r1, r0, #0x18000
    mov r2, #0

.VRAMClearLoop:
    str r2, [r0], #4
    cmp r0, r1
    blt .VRAMClearLoop

    mov r3, #0x5000000 ; set backdrop to black
    mov r1, #0
    strh r1, [r3]

main_loop:
    mov r0, #0x4000000 ; wait for vblank
.wait_for_vblank_without_interrupt:
    ldrh r1, [r0, #4]
    tst r1, #1 ; check if vblank flag in DISPSTAT is on. If not, loop
    beq .wait_for_vblank_without_interrupt

    mov r1, #0x1F ; now that we're in VBlank, set backdrop to red
    strh r1, [r3]

    mov r0, #27 ; line counter
    mov r1, 0 ; loop counter
    mov r2, colors ; points to the array of colors
    add r2, r2, #0x8000000 ; account for the fact the ROM starts at 0x8000000

draw_loop:
    bl wait_for_line_without_interrupt
    add r0, r0, #28 ; increment line counter
    add r1, r1, #1 ; increment loop counter
    ldrh r4, [r2] ; fetch new color
    strh r4, [r3] ; store it as backdrop
    add r2, r2, #2 ; increment color pointer

    cmp r1, #5 ; stop after 5 iterations
    bne draw_loop

    b main_loop


; polls vcount till the PPU gets to a specific line
; params: r0 -> line number
wait_for_line_without_interrupt:
    push {r8, r9}

.loop:
    mov r8, #0x4000000
    ldrb r9, [r8, #6]
    cmp r0, r9
    bne .loop

    pop {r8, r9}
    mov pc, lr ; return

colors:
    dh 0x29F, 0x3FF, 0x1224, 0x7C00, 0x4411