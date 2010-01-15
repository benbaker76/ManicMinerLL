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

#include "math.h"

	.arm
	.align
	.text
	.global div32
	.global sqrt32
	
	@ ---------------------------------------------
	
@ fn  int32 div32(int32 num, int32 den)
@ brief integer divide
@ r0 - param num  numerator
@ r1 - param den  denominator
@ r0 - return returns 32 bit integer result
div32:

	stmfd sp!, {r2-r3, lr}

	@ r0 - num
	@ r1 - den
	
	ldr r2, =REG_DIVCNT					@ Load REG_DIVCNT
	mov r3, #DIV_32_32					@ Load DIV_32_32
	strh r3, [r2]						@ Write it to REG_DIVCNT
	
div32Loop1:
	
	ldrh r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne div32Loop1						@ Yes, so loop
	
	ldr r3, =REG_DIV_NUMER_L			@ Load REG_DIV_NUMER_L
	str r0, [r3]						@ Write the num
	
	ldr r3, =REG_DIV_DENOM_L			@ Load REG_DIV_NUMER_L
	str r1, [r3]						@ Write the den
	
div32Loop2:
	
	ldrh r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne div32Loop2						@ Yes, so loop
	
	ldr r0, =REG_DIV_RESULT_L			@ Get REG_DIV_RESULT_L address
	ldr r0, [r0]						@ Get result and place it in r0
	
	ldmfd sp!, {r2-r3, pc}				@ Return
	
	@ ---------------------------------------------
	
@ fn int32 sqrt32(int a)
@ brief integer sqrt
@ r0 - param a 32 bit integer argument
@ r0 - return returns 32 bit integer result
sqrt32:

	stmfd sp!, {r1-r2, lr}

	@ r0 - a
	
	ldr r1, =REG_SQRTCNT				@ Load REG_SQRTCNT
	mov r2, #SQRT_32					@ Load SQRT_32
	strh r2, [r1]						@ Write it to REG_SQRTCNT
	
sqrt32Loop1:
	
	ldrh r2, [r1]						@ Read REG_SQRTCNT
	tst r2, #SQRT_BUSY					@ Busy?
	bne sqrt32Loop1						@ Yes, so loop
	
	ldr r2, =REG_SQRT_PARAM_L			@ Load REG_SQRT_PARAM_L
	str r0, [r2]						@ Write the num
	
sqrt32Loop2:
	
	ldrh r2, [r1]						@ Read REG_SQRTCNT
	tst r2, #SQRT_BUSY					@ Busy?
	bne sqrt32Loop2						@ Yes, so loop
	
	ldr r0, =REG_SQRT_RESULT			@ Get REG_SQRT_RESULT address
	ldr r0, [r0]						@ Get result and place it in r0
	
	ldmfd sp!, {r1-r2, pc}				@ Return