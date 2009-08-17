@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"), to deal in the Software without restriction, including
@ without limitation the rights to use, copy, modify, merge, publish,
@ distribute, sublicense, and/or sell copies of the Software, and to
@ permit persons to whom the Software is furnished to do so, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "mmll.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"
#include "audio.h"

	.arm
	.align
	.text
	.global initSystem
	.global main
	.global gameStart
	.global gameStop

initSystem:
	stmfd sp!, {r0-r2, lr}
	
	mov r0, #0						@ Clear video display registers
	ldr r1, =0x04000000
	mov r2, #0x56
	bl dmaFillWords
	ldr r1, =0x04001008
	bl dmaFillWords
	
	mov r0, #0						@ Clear IPC
	ldr r1, =IPC
	mov r2, #256
	bl dmaFillWords
	
	ldr r0, =VRAM_CR
	mov r1, #0
	strb r1, [r0]
	ldr r0, =VRAM_E_CR
	strb r1, [r0]
	ldr r0, =VRAM_F_CR
	strb r1, [r0]
	ldr r0, =VRAM_G_CR
	strb r1, [r0]
	ldr r0, =VRAM_H_CR
	strb r1, [r0]
	ldr r0, =VRAM_I_CR
	strb r1, [r0]
	
	ldr r0, =REG_DISPCNT
	mov r1, #0
	str r1, [r0]
	ldr r0, =REG_DISPCNT_SUB
	str r1, [r0]
	
	ldmfd sp!, {r0-r2, pc}

main:
	bl initVideo
	bl initSprites
	
	bl initInterruptHandler						@ initialize the interrupt handler
	
	bl initMusic
	
	bl initGame
	
	bl initLevel
	bl drawLevel
@	bl drawSprite
	
	ldr r0, =gameMode							@ set to play time for now!!
	mov r1, #GAMEMODE_RUNNING
	str r1,[r0]

	@ ------------------------------------
	
mainLoop:

	bl swiWaitForVBlank							@ Wait for vblank
	
	ldr r0, =gameMode
	ldr r1, [r0]
	cmp r1, #GAMEMODE_RUNNING
	beq gameLoop
	cmp r1, #GAMEMODE_STOPPED
	beq mainLoopDone
	
	b mainLoop

gameLoop:

	@ This is our main game loop
	
	bl levelAnimate
	
	bl moveMiner
	bl minerFrame
	bl drawSprite

	bl minerJump
	bl minerFall
	
	

	ldr r10,=spriteX
	ldr r10,[r10]						@ Number
	sub r10,#64
	mov r11,#2							@ X Pos
	mov r8,#1							@ Y Pos
	mov r9,#5							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits
	
	ldr r10,=spriteY
	ldr r10,[r10]						@ Number
	sub r10,#384
	mov r11,#2							@ X Pos
	mov r8,#3							@ Y Pos
	mov r9,#5							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits	
	
	ldr r10,=minerDirection
	ldr r10,[r10]						@ Number
	mov r11,#2							@ X Pos
	mov r8,#5							@ Y Pos
	mov r9,#1							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits

	ldr r10,=jumpCount
	ldr r10,[r10]						@ Number
	mov r11,#2							@ X Pos
	mov r8,#7							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits
	
	ldr r0, =hiscoreText				@ Pointer to text
	ldr r1, =0							@ X Pos
	ldr r2, =19							@ Y Pos
	ldr r3, =0							@ 0 = Main, 1 = Sub
	bl drawText
		
	ldr r10, =0							@ Number
	mov r11, #11						@ X Pos
	mov r8, #19							@ Y Pos
	mov r9, #6							@ Digits
	mov r7, #0							@ 0 = Main, 1 = Sub
	bl drawDigits
	
	ldr r0, =scoreText					@ Pointer to text
	ldr r1, =20							@ X Pos
	ldr r2, =19							@ Y Pos
	ldr r3, =0							@ 0 = Main, 1 = Sub
	bl drawText
	
	ldr r10, =0							@ Number
	mov r11, #26						@ X Pos
	mov r8, #19							@ Y Pos
	mov r9, #6							@ Digits
	mov r7, #0							@ 0 = Main, 1 = Sub
	bl drawDigits
	
mainLoopDone:

	b mainLoop									@ our main loop



	.pool
	.end
