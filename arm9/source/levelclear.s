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
	.global initLevelClear
	.global levelClear
	
	
initLevelClear:										@ set up the level clear dat

	stmfd sp!, {r0-r10, lr}	

	@ first, remove willy
	mov r1,#0
	ldr r2,=spriteActive+256
	str r1,[r2]

	ldr r0,=gameMode
	mov r1,#GAMEMODE_LEVEL_CLEAR
	str r1,[r0]
	
	ldr r0,=levelEndTimer
	ldr r1,=350
	str r1,[r0]
	
	ldr r1,=spriteActive		@ Close the door
	mov r0,#63					@ use the 63rd sprite
	mov r2,#EXIT_CLOSED			@ Stop door anim
	str r2,[r1,r0,lsl#2]
	mov r3,#DOOR_FRAME
	ldr r1,=spriteObj
	str r3,[r1,r0,lsl#2]
	

	ldmfd sp!, {r0-r10, pc}	
@-----------------------------------------------

levelClear:											@ do the level clear stuff

	stmfd sp!, {r0-r10, lr}	
	
	
	ldr r0,=levelEndTimer
	ldr r10,[r0]
	
	
	levelClearLoop:
	
		bl swiWaitForVBlank	
		ldr r0,=minerDelay
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
		bne skipFrameClear
			bl monsterMove
			bl scoreAir
		skipFrameClear:	
	
		bl drawSprite
		bl levelAnimate	
		bl drawScore
		bl updateSpecialFX	
		bl drawAir	
	
	
	subs r10,#1
	bpl levelClearLoop
	
	
	
	
	
	
	
	
	
	
	bl levelNext
	
	ldmfd sp!, {r0-r10, pc}		
	
@-----------------------------------------------	
	
scoreAir:											@ reduce Air and score it

	stmfd sp!, {r0-r10, lr}		

	ldr r1,=air
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#0
	str r2,[r1]
	bmi scoreAirDone
	
		mov r4,#3
		ldr r5,=adder+5
		strb r4,[r5]
		bl addScore

		ldr r7,=jumpCount
		mov r4,r2, lsl#1
		str r4,[r7]

		bl playJump
	scoreAirDone:

	ldmfd sp!, {r0-r10, pc}

@-----------------------------------------------	
	
	.pool
	.data
	
	levelEndTimer:
		.word 0