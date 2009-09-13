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

	#define STAR_COUNT					1024
	#define STAR_COLOR_OFFSET			11
	#define STAR_COLOR_TRAIL_OFFSET_1	12
	#define STAR_COLOR_TRAIL_OFFSET_2	13
	#define STAR_COLOR_TRAIL_OFFSET_3	14

	.arm
	.align
	.text

	.global fxStarburstOn
	.global fxStarburstVBlank

fxStarburstOn:

	stmfd sp!, {r0-r2, lr}

	mov r0,#STAR_COUNT
	ldr r1,=starAmount
	str r0,[r1]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARBURST
	str r1, [r0]

	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxStarburstOnLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxStarburstOnLoop

	ldr r1,=0x3fff	
	bl randomStarburst									@ generate em!
	bl moveStarburst									@ draw them
	
	ldmfd sp!, {r0-r2, pc}

	@ ---------------------------------------

fxStarburstVBlank:

	stmfd sp!, {r0, lr}
	
	bl moveStarburst								@ move em, based on x/y speeds and plot

	ldmfd sp!, {r0, pc}

	@ ---------------------------------------

randomStarburst:
	stmfd sp!, {r0-r11, lr}

	@ r1 is passed for the max speed (0x3fff is a good starter)
	ldr r0,=starAmount
	ldr r3,[r0]
	sub r3,#1
	ldr r4, =starXCoord32
	ldr r5, =starYCoord
	ldr r6, =starSpeed
	ldr r10, =starShade
	ldr r11, =starDir
	ldr r7,=0x1ff

	starburstloopMulti:
	
		mov r8,#128
		lsl r8,#12
		str r8, [r4, r3, lsl #2]						@ Store X
		mov r8,#192
		lsl r8,#12
		str r8, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction (we need from a range that only goes up)
		and r8, r7
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		and r8, r1	
		add r8,#1024
		str r8, [r6, r3, lsl #2] 						@ Store Speed
	
		bl getRandom									@ generate colours
		and r8,#0x3
		add r8,#11
		cmp r8,#14
		movpl r8,#13		
		strb r8,[r10, r3]

		subs r3, #1	
	bne starburstloopMulti

	ldmfd sp!, {r0-r11, pc}
	
	@ ---------------------------------------

moveStarburst:
	stmfd sp!, {r0-r12, lr}

	ldr r0,=starAmount
	ldr r10,[r0]
	sub r10,#1
	ldr r4, =starSpeed
	ldr r3, =starYCoord
	ldr r2, =starXCoord32
	ldr r12, =starShade

moveStarburstLoop:
	ldr r0,=starDir
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	adds r0,r9, asr #12								@ add to x

	bmi burstRegenerate
	cmp r0,#0xff000
	bge burstRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	adds r1,r9, asr #12								@ add to Y coord (signed)

	bmi burstRegenerate
	cmp r1,#0x180000
	bge burstRegenerate

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	@ draw sprite here

burstSkip:

	subs r10, #1									@ count down the number of starSpeed
	bne moveStarburstLoop

	ldmfd sp!, {r0-r12, pc}

burstRegenerate:

		mov r8,#128
		lsl r8,#12
		str r8, [r2, r10, lsl #2]						@ Store X
		mov r8,#192
		lsl r8,#12
		str r8, [r3, r10, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		ldr r6,=0x1ff
		and r8, r6
		ldr r0,=starDir
		str r8, [r0, r10, lsl #2]

		bl getRandom									@ generate speed
		ldr r6,=0x3fff
		and r8, r6	
		add r8,#1024
		ldr r0,=starSpeed
		str r8, [r0, r10, lsl #2] 						@ Store Speed
	
	b burstSkip


starMain:
.word 0
starSub:
.word 0

	.data
	.pool
	.align
starAmount:
	.word 0
starDirection:
	.word 0
starShade:
	.space STAR_COUNT
starSpeed:
	.space STAR_COUNT*4	
starYCoord:
	.space STAR_COUNT*4
starXCoord32:
	.space STAR_COUNT*4
starDir:
	.space STAR_COUNT*4
	.end
