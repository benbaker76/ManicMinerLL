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

#include "MMLL.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "windows.h"

	#define burstFrameStart		40
	#define burstFrameEnd		47
	#define burstAnimDelay		4
	
	.arm
	.align
	.text

	.global fxStarburstInit
	.global fxMoveStarburst

fxStarburstInit:

	stmfd sp!, {r0-r11, lr}

	ldr r1,=burstLength
	ldr r0,=220
	str r0,[r1]

	ldr r4, =spriteX+324
	ldr r5, =spriteY+324
	ldr r6, =spriteSpeed+324
	ldr r11, =spriteDir+324
	ldr r9,=spriteActive+324
	ldr r10,=spriteObj+324
	ldr r12,=spritePriority+324
	ldr r7,=0x1ff
	ldr r1,=0x8ff

	mov r3,#46							@ amount of stars
	starburstloopMulti:
	
		ldr r8,=exitX
		ldr r8,[r8]

		lsl r8,#12
		str r8, [r4, r3, lsl #2]						@ Store X
		ldr r8,=exitY
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction (we need from a range that only goes up)
		and r8, #127										@ 0-511
		add r8,#320
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		ldr r1,=0x7ff
		and r8, r1	
		add r8,#2048
		str r8, [r6, r3, lsl #2] 						@ Store Speed
		
		mov r8,#1										@ sprite active
		str r8, [r9, r3, lsl #2]
		
		bl getRandom
		and r8,#0x7
		add r8,#burstFrameStart							@ obj
		str r8, [r10,r3, lsl #2]
		
		mov r8,#2										@ priority
		str r8, [r12,r3, lsl #2]
		
		ldr r1,=spriteMax+324							@ time to live!
		bl getRandom
		lsr r8,#12
		add r8,#0x20000
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteMin+324							@ time to live!
		bl getRandom
		and r8,#127
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteAnimDelay+324
		mov r8,#burstAnimDelay
		str r8,[r1, r3, lsl #2]

		subs r3, #1	
	bpl starburstloopMulti

	ldmfd sp!, {r0-r11, pc}
	
	@ ---------------------------------------

fxMoveStarburst:
	stmfd sp!, {r0-r12, lr}


	ldr r4, =spriteSpeed+324
	ldr r2, =spriteX+324
	ldr r3, =spriteY+324
	
	mov r10,#46
	
moveStarburstLoop:
	ldr r0,=spriteDir+324
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	add r0,r9, asr #12								@ add to x

	cmp r0,#(32<<12)
	blt burstRegenerate
	cmp r0,#(320<<12)
	bge burstRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	add r1,r9, asr #12								@ add to Y coord (signed)
	
	@ now add gravity to y
	
	ldr r7,=spriteMin+324							@ add to gravity
	ldr r5,[r7, r10, lsl #2]
@	ldr r8,=512
@	sub r8,r6
@	lsr r8,#7
@	add r5,r8
	add r5,#32

	str r5,[r7, r10, lsl #2]
	add r1,r5
	

	cmp r1,#(400<<12)
	blt burstRegenerate
	cmp r1,#(576<<12)
	movge r1,#(576<<12)

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	ldr r7,=spriteMax+324
	ldr r1,[r7, r10, lsl #2]
	subs r1,r6
	subs r1,r5
	str r1,[r7, r10, lsl #2]
	bmi burstRegenerate
	
	burstOver:
	
	@ animate
	ldr r7,=spriteAnimDelay+324
	ldr r6,[r7, r10, lsl #2]
	subs r6,#1
	movmi r6,#burstAnimDelay
	str r6,[r7, r10, lsl #2]
	bpl burstSkip
	
		ldr r7,=spriteObj+324
		ldr r6,[r7,r10,lsl#2]
		add r6,#1
		cmp r6,#burstFrameEnd+1
		moveq r6,#burstFrameStart
		str r6,[r7,r10,lsl#2]
	
	burstSkip:

	subs r10, #1									@ count down the number of starSpeed
	bpl moveStarburstLoop
	
	ldr r1,=burstLength
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#0
	str r0,[r1]

	ldmfd sp!, {r0-r12, pc}

burstRegenerate:

		ldr r8,=burstLength
		ldr r8,[r8]
		cmp r8,#0
		ldreq r8,=spriteActive+324
		moveq r7,#0
		streq r7,[r8,r10,lsl#2]
		beq burstOver

		ldr r8,=exitX
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r2, r10, lsl #2]						@ Store X
		ldr r8,=exitY
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r3, r10, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		and r8, #127
		add r8, #320
		ldr r0,=spriteDir+324
		str r8, [r0, r10, lsl #2]

		bl getRandom									@ generate speed
		ldr r6,=0x7ff
		and r8, r6	
		add r8,#2048
		ldr r0,=spriteSpeed+324
		str r8, [r0, r10, lsl #2] 						@ Store Speed

		ldr r0,=spriteMax+324							@ time to live!
		bl getRandom
		lsr r8,#12
		add r8,#0x60000
		str r8,[r0, r10, lsl #2]

		ldr r0,=spriteMin+324							@ gravity
		bl getRandom
		and r8,#127
		str r8,[r0, r10, lsl #2]
	
	b burstSkip



	.data
	.pool
	.align

	burstLength:
	.word 0