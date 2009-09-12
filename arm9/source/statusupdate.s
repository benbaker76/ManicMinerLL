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

	.arm
	.align
	.text
	.global	drawAir
	.global airDrain
	.global drawLives

drawAir:

	stmfd sp!, {r0-r11, lr}
	
	ldr r1,=air
	ldr r0,[r1]
	
	cmp r0,#48
	movle r8,#30
	movgt r8,#0
	
	ldr r3, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB) 	@ r3=location of draw area
	add r3,#(32*4)*2
	add r3,#8									@ move across 5 chars

	mov r1,#1									@ r1=x coord to plot bar

	drawAirLoop:
		cmp r0,#8
		blt airEmpty
			@ ok, draw a full bar at X
			sub r0,#8
			ldr r5,=StatusMap
			add r5,#(32*6)*2
			add r5,r8
			ldrh r5,[r5]
			strh r5, [r3]
			ldr r5,=StatusMap
			add r5,#(32*7)*2
			add r5,r8
			ldrh r5,[r5]
			add r4,r3,#64
			strh r5, [r4]
			b airNext
			
		airEmpty:
		cmp r0,#0
		bne airLittle
			@ draw empty bar
			ldr r5,=StatusMap
			add r5,#(32*6)*2
			add r5,#16
			ldrh r4,[r5]
			strh r4, [r3]
			add r4,r3,#64
			add r5,#64
			ldrh r5,[r5]
			strh r5, [r4]
			b airNext
			
		airLittle:
		
		xxx:
		cmp r0,#7
		bgt xxx
			@ draw partial bar
			ldr r5,=StatusMap
			add r5,#(32*6)*2
			add r5,r0,lsl#1
			add r5,r8
			ldrh r5,[r5]
			strh r5, [r3]
			ldr r5,=StatusMap
			add r5,#(32*7)*2
			add r5,r0,lsl#1
			add r5,r8
			ldrh r5,[r5]
			add r4,r3,#64
			strh r5, [r4]

			mov r0,#0
			
		airNext:
		add r3,#2
		add r1,#1
		cmp r1,#21
	bne drawAirLoop
	
	ldmfd sp!, {r0-r11, pc}
	
@----------------------------------------------

airDrain:
	
	stmfd sp!, {r0-r11, lr}
	
	ldr r1,=airDelay
	ldr r2,[r1]
	add r2,#1
	cmp r2,#25
	moveq r2,#0
	str r2,[r1]
	beq airDrainYes
	
	ldmfd sp!, {r0-r11, pc}
	
	airDrainYes:

	ldr r1,=air
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#0
	str r2,[r1]
	bmi airGoneUlp
	
	ldmfd sp!, {r0-r11, pc}
	
	airGoneUlp:
	
	@ time to die!!!
	
	bl initDeath


	ldmfd sp!, {r0-r11, pc}

@----------------------------------------------

drawLives:
	
	stmfd sp!, {r0-r11, lr}
	
	ldr r0,=minerLives
	ldr r0,[r0]
	cmp r0,#3
	bge drawLivesDone


	ldr r1,=StatusMap	
	add r1,#(6*32)*2
	add r1,#18				@ src for empty unit
	ldr r2, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)		@ r2=dest
	add r2,#((4*32)*2)
	add r2,#50
	add r2,#8
	@ r1=src, r2=dest
	
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#2
	add r2,#2
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#62
	add r2,#62
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#2
	add r2,#2
	ldrh r3,[r1]
	strh r3,[r2]
	
	cmp r0,#1
	bgt drawLivesDone
	
	ldr r1,=StatusMap	
	add r1,#(6*32)*2
	add r1,#18				@ src for empty unit
	ldr r2, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)		@ r2=dest
	add r2,#((4*32)*2)
	add r2,#50
	add r2,#4
	@ r1=src, r2=dest
	
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#2
	add r2,#2
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#62
	add r2,#62
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#2
	add r2,#2
	ldrh r3,[r1]
	strh r3,[r2]

	cmp r0,#0
	bne drawLivesDone
	
	ldr r1,=StatusMap	
	add r1,#(6*32)*2
	add r1,#18				@ src for empty unit
	ldr r2, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)		@ r2=dest
	add r2,#((4*32)*2)
	add r2,#50
	@ r1=src, r2=dest
	
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#2
	add r2,#2
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#62
	add r2,#62
	ldrh r3,[r1]
	strh r3,[r2]
	add r1,#2
	add r2,#2
	ldrh r3,[r1]
	strh r3,[r2]

	drawLivesDone:

	ldmfd sp!, {r0-r11, pc}
	
	.pool
	.end