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

#include "math.h"

	.arm
	.align
	.text
	.global divf32
	.global sqrtf32
	.global div32
	.global mod32
	.global sqrt32

@ fn divf32(int32 num, int32 den)
@ brief Fixed point divide
@ r0 = param num Takes 20.12 numerator and denominator
@ r1 = param den Takes 20.12 numerator and denominator
@ r0 = return returns 20.12 result
divf32:

	stmfd sp!, {r2-r4, lr}

	@ r0 - Number
	@ r1 - Denominator
	
	ldr r2, =REG_DIVCNT					@ Load REG_DIVCNT
	mov r3, #DIV_64_32					@ Load DIV_64_32
	strh r3, [r2]						@ Write it to REG_DIVCNT
	
divf32Loop1:
	
	ldrh r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne divf32Loop1						@ Yes, so loop
	
	ldr r3, =REG_DIV_NUMER				@ Load REG_DIV_NUMER
	mov r4, r0							@ Read the number
	lsl r4, #12							@ Shift left
	str r4, [r3], #4					@ Write the num and add 4 bytes
	mov r4, r0							@ Read the number
	lsr r4, #20							@ Right shift 20
	str r4, [r3]						@ Write remaining 20 bits
	
	ldr r3, =REG_DIV_DENOM_L			@ Load REG_DIV_DENOM_L
	str r1, [r3]						@ Write the den
	
divf32Loop2:
	
	ldrh r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne divf32Loop2						@ Yes, so loop
	
	ldr r0, =REG_DIV_RESULT_L			@ Get REG_DIV_RESULT_L address
	ldr r0, [r0]						@ Get result and place it in r0
	
	ldmfd sp!, {r2-r4, pc}				@ Return
	
	@ ---------------------------------------------
	
@ fn int32 sqrtf32(int32 a)
@ brief Fixed point sqrt
@ r0 - param a Takes 20.12 
@ r0 - return returns 20.12 result
sqrtf32:

	stmfd sp!, {r1-r4, lr}

	@ r0 - a
	
	ldr r1, =REG_SQRTCNT				@ Load REG_SQRTCNT
	mov r2, #SQRT_64					@ Load SQRT_64
	strh r2, [r1]						@ Write it to REG_SQRTCNT
	
sqrtf32Loop1:
	
	ldrh r2, [r1]						@ Read REG_SQRTCNT
	tst r2, #SQRT_BUSY					@ Busy?
	bne sqrtf32Loop1					@ Yes, so loop
	
	ldr r2, =REG_SQRT_PARAM				@ Load REG_SQRT_PARAM
	mov r3, r0							@ Read the number
	lsl r3, #12							@ Shift left
	str r3, [r2], #4					@ Write the num and add 4 bytes
	mov r3, r0							@ Read the number
	lsr r3, #20							@ Right shift 20
	str r3, [r2]						@ Write remaining 20 bits
	
	ldr r1, =REG_SQRTCNT				@ Load REG_SQRTCNT
	
sqrtf32Loop2:
	
	ldrh r2, [r1]						@ Read REG_SQRTCNT
	tst r2, #SQRT_BUSY					@ Busy?
	bne sqrtf32Loop2					@ Yes, so loop
	
	ldr r0, =REG_SQRT_RESULT			@ Get REG_SQRT_RESULT address
	ldr r0, [r0]						@ Get result and place it in r0
	
	ldmfd sp!, {r1-r4, pc}				@ Return
	
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
	
@ fn  int32 mod32(int32 num, int32 den)
@ brief integer modulous
@ r0 - param num  numerator
@ r1 - param den  denominator
@ r0 - return returns 32 bit integer remainder
mod32:

	stmfd sp!, {r2-r3, lr}

	@ r0 - num
	@ r1 - den
	
	ldr r2, =REG_DIVCNT					@ Load REG_DIVCNT
	mov r3, #DIV_32_32					@ Load DIV_32_32
	strh r3, [r2]						@ Write it to REG_DIVCNT
	
mod32Loop1:
	
	ldrh r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne mod32Loop1						@ Yes, so loop
	
	ldr r3, =REG_DIV_NUMER_L			@ Load REG_DIV_NUMER_L
	str r0, [r3]						@ Write the num
	
	ldr r3, =REG_DIV_DENOM_L			@ Load REG_DIV_NUMER_L
	str r1, [r3]						@ Write the den
	
mod32Loop2:
	
	ldrh r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne mod32Loop2						@ Yes, so loop
	
	ldr r0, =REG_DIVREM_RESULT_L		@ Get REG_DIVREM_RESULT_L address
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
	
	@ ---------------------------------------------

	.pool
	.end
