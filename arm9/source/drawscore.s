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

#include "mmll.h"
#include "video.h"
#include "background.h"

	.global drawScore
	.global addScore

drawScore:
	@ levelNum holds the number of the level needed

	stmfd sp!, {r0-r10, lr}
	
	ldr r0, =hiscoreText				@ Pointer to text
	ldr r1, =0							@ X Pos
	ldr r2, =22							@ Y Pos
	ldr r3, =0							@ 0 = Main, 1 = Sub
	bl drawText
	
	ldr r0, =scoreText					@ Pointer to text
	ldr r1, =20							@ X Pos
	ldr r2, =22							@ Y Pos
	ldr r3, =0							@ 0 = Main, 1 = Sub
	bl drawText

	ldr r4, =BG_MAP_RAM(BG0_MAP_BASE)
	add r4,#22*32*2
	add r4,#50+(6*2)
	mov r0, #5
	ldr r5, =score
	drawScoreSubLoop:
		ldrb r1,[r5,r0]
		add r1,#16
		strh r1,[r4]
		subs r0,#1
		sub r4,#2
	bpl drawScoreSubLoop	

	ldr r4, =BG_MAP_RAM(BG0_MAP_BASE)
	add r4,#22*32*2
	add r4,#20+(6*2)
	mov r0, #5
	ldr r5, =highScoreScore
	drawHighSubLoop:
		ldrb r1,[r5,r0]
		add r1,#16
		strh r1,[r4]
		subs r0,#1
		sub r4,#2
	bpl drawHighSubLoop		

	ldmfd sp!, {r0-r10, pc}
	
addScore:
	stmfd sp!, {r0-r6, lr}
	
	@ To use the score adder, just store the digits in 'adder' a byte for each and call this.
	@ the adder is cleared on exit to stop in keep counting digits.

	mov r0,#5			@ r0 = start digit offset in score and adder
	ldr r3,=score
	ldr r4,=adder
	addLoop:
		ldrb r1,[r3,r0]
		ldrb r2,[r4,r0]
		add r5,r1,r2
		cmp r5,#10
		bmi addPassed
			sub r5,#10		
			sub r0,#1
			ldrb r6,[r3,r0]
			add r6,#1
			strb r6,[r3,r0]
			add r0,#1
		addPassed:
		strb r5,[r3,r0]
		mov r5,#0
		strb r5,[r4,r0]
		
		subs r0,#1
		bne addLoop
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
drawDigit:
	@ r0 - digit
	@ r1 - number
	@ r2 - screen 0 = main 1 = sub
	@ r3 - offset
	stmfd sp!, {r2-r6, lr} 

	ldr r4, =BG_MAP_RAM(BG0_MAP_BASE)
	ldr r5, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)
	cmp r2, #0
	moveq r2, r4
	movne r2, r5
	
	add r2, r3
	mov r3, #4
	mov r4, #0
	mla r2, r0, r3, r2
	mov r3, #4
	mov r4, #2
	mla r3, r1, r3, r4
	strh r3, [r2]
	add r2, #2
	add r3, #1
	strh r3, [r2]
	add r2, #63
	add r3, #1
	strh r3, [r2]
	add r2, #1
	add r3, #1
	strh r3, [r2]

	ldmfd sp!, {r2-r6, pc}
	
	@ ---------------------------------------