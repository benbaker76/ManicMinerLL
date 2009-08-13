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
	
	.global getRandom

	@ call and r8 returns value

getRandom:

	stmfd sp!, {r0-r7,r9-r12, lr}
	
	ldr     ip, =seedpointer
	ldmia   ip, {r8, r9}
	tst     r9, r9, lsr #1				@ to bit into carry
	movs    r2, r8, rrx					@ 33-bit rotate right
	adc     r9, r9, r9					@ carry into LSB of r2
	eor     r2, r2, r8, lsl #12		@ concenate the 38 bit value
	eor     r8, r2, r2, lsr #20		@ de-concentate
	stmia   ip, {r8, r9}
	
	ldmfd sp!, {r0-r7,r9-r12, pc}
	
	.data
	.align
	
seedpointer: 
	.long seed  
seed: 
	.long 0x55555555 
	.long 0x55555555

	.end
