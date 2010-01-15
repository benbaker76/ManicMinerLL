@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"),  the rights to use, copy, modify, merge, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software both source and
@ the compiled code.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "system.h"

	.arm
	.align
	.text
	.global flushCaches
	.global breakPoint
	.global drawDebugString
	.global debugString
	.global debugText
	
flushCaches:

	@ This will flush the caches

	eor r0, r0, r0
	mcr p15, 0, r0, c7, c5, 0
	mcr p15, 0, r0, c7, c6, 0
	bx lr
	
breakPoint:

	@ This will trigger a breakpoint in NO$GBA

	bl flushCaches
	mov r11, r11
	bx lr

drawDebugString:

	@ This subroutine will output text to the NO$GBA debug screen
	@ r0 = pointer to null terminated text
	
	ldr r1, =Data					@ Get the data pointer

textLoop:

	stmfd sp!, {r1-r8, lr}
	
	ldrb r2, [r0], #1				@ Read the data and add one
	strb r2, [r1], #1				@ Write to buffer and add one
	cmp r2, #0						@ Null character?
	beq textDone					@ Yes so were done
	bl textLoop

textDone:
	bl drawDebugNo$
	
	ldmfd sp!, {r1-r8, pc}

drawDebugNo$:
	mov r12, r12					@ First ID 
    b drawDebugNo$Done				@ Skip the text section 

	.hword 0x6464					@ Second ID 
	.hword 0						@ Flags

Data:

	.space 120						@ Data

drawDebugNo$Done:

	bx lr							@ Return
	
	
debugText:

	stmfd sp!, {r1-r8, lr}

	ldr r10,=minerAction
	ldr r10,[r10]						@ Number
	mov r11,#20							@ X Pos
	mov r8,#1							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits
	ldr r10,=minerDirection
	ldr r10,[r10]						@ Number
	mov r11,#23							@ X Pos
	mov r8,#1							@ Y Pos
	mov r9,#1							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits
	ldr r10,=lastMiner
	ldr r10,[r10]						@ Number
	mov r11,#20							@ X Pos
	mov r8,#3							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits
	ldr r10,=faller
	ldr r10,[r10]						@ Number
	mov r11,#20							@ X Pos
	mov r8,#5							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits

	ldr r10,=fallCount
	ldr r10,[r10]						@ Number
	mov r11,#16							@ X Pos
	mov r8,#5							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits

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

	ldr r10,=exitX
	ldr r10,[r10]						@ Number
	mov r11,#1							@ X Pos
	mov r8,#21							@ Y Pos
	mov r9,#3							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits

	ldr r10,=exitY
	ldr r10,[r10]						@ Number
	mov r11,#6							@ X Pos
	mov r8,#21							@ Y Pos
	mov r9,#3							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
	bl drawDigits
	
	ldmfd sp!, {r1-r8, pc}
	
	.pool
	.data

debugString:

	.string "r8 = %r8% ; r9 = %r9% ; r10 = %r10%\0"
