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
	.global decompressToVRAM

getSize:

	@ r0 - source
	@ r1 - dest
	
	ldr	r0, [r0, #0]
	bic	r0, r0, #255
	orr	r0, r0, #16
	bx lr
	
	@ ---------------------------------------------
	
readByte:

	ldrb r0, [r0, #0]
	bx lr
	
	@ ---------------------------------------------
	
decompressToVRAM:

	stmfd sp!, {r0-r3, lr}

	ldr r2, =decStream
	ldr r3, =getSize
	str r3, [r2], #4
	mov r3, #0
	str r3, [r2], #4
	ldr r3, =readByte
	str r3, [r2]
	mov r2, #0
	ldr r3, =decStream
	bl swiDecompressLZSSVram
	
	ldmfd sp!, {r0-r3, pc}
	
	@ ---------------------------------------------

	.data
	.align

decStream:
	.word 0, 0, 0