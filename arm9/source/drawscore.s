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


	.global drawScore

drawScore:
	@ levelNum holds the number of the level needed

	stmfd sp!, {r0-r10, lr}
	
	ldr r0, =hiscoreText				@ Pointer to text
	ldr r1, =0							@ X Pos
	ldr r2, =22							@ Y Pos
	ldr r3, =0							@ 0 = Main, 1 = Sub
	bl drawText
		
	ldr r10, =0							@ Number
	mov r11, #11						@ X Pos
	mov r8, #22							@ Y Pos
	mov r9, #6							@ Digits
	mov r7, #0							@ 0 = Main, 1 = Sub
	bl drawDigits
	
	ldr r0, =scoreText					@ Pointer to text
	ldr r1, =20							@ X Pos
	ldr r2, =22							@ Y Pos
	ldr r3, =0							@ 0 = Main, 1 = Sub
	bl drawText
	
	ldr r10, =0							@ Number
	mov r11, #26						@ X Pos
	mov r8, #22							@ Y Pos
	mov r9, #6							@ Digits
	mov r7, #0							@ 0 = Main, 1 = Sub
	bl drawDigits
	
	ldmfd sp!, {r0-r10, pc}
