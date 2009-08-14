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

	.global moveMiner
	
moveMiner:

	stmfd sp!, {r0-r10, lr}
	

	@ First phase is to read direction.
	@ If left and select right, only turn, etc.
	@ if move, check colmap for a wall and stop if this is found
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r10, [r2]								@ r10= key pressed
	mov r9,r10									
	
	tst r10,#BUTTON_RIGHT
	bleq moveRight								@ right is pressed
	tst r10,#BUTTON_LEFT
	bleq moveLeft								@ left is pressed

	ldmfd sp!, {r0-r10, pc}

@------------------------------- RIGHT MOVEMENT
	
moveRight:

	stmfd sp!, {r0-r10, lr}
	
	@ First thing to add later is if you we going left, just turn round!
	ldr r0,=spriteHFlip
	ldr r1,[r0]
	cmp r1,#0
	moveq r1,#1
	str r1,[r0]
	beq rightFlipDone
	
		@ Move right
		
@		bl minerPause
@		cmp r9,#0
@		beq rightFlipDone
		
		ldr r2,=spriteX
		ldr r0,[r2]
		add r0,#1
		
		bl checkRight		@ pass r0 as correct coord
		cmp r10,#1			@ solid wall
		beq rightFlipDone

		str r0,[r2]

	
	
	
	
	rightFlipDone:
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------- LEFT MOVEMENT
	
moveLeft:

	stmfd sp!, {r0-r10, lr}
	
	@ First thing to add later is if you we going left, just turn round!
	ldr r0,=spriteHFlip
	ldr r1,[r0]
	cmp r1,#1
	moveq r1,#0
	str r1,[r0]
	beq leftFlipDone

		@ Move left

@		bl minerPause
@		cmp r9,#0
@		beq leftFlipDone

		ldr r2,=spriteX
		ldr r0,[r2]
		sub r0,#1

		bl checkLeft		@ pass r0 as x coord to check
		cmp r10,#1			@ solid wall
		beq leftFlipDone

		str r0,[r2]
		
	
	
	leftFlipDone:
	ldmfd sp!, {r0-r10, pc}	
	
minerPause:
	
	stmfd sp!, {r0-r8,r10, lr}
	
	mov r9,#0
	ldr r0,=minerDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#2
	moveq r1,#0
	moveq r9,#1
	str r1,[r0]
	
	
	ldmfd sp!, {r0-r8,r10, pc}
	
minerXOld:
	.word 0
minerYOld:
	.word 0
	.pool
	.end