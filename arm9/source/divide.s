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

	.arm
	.align
	.text
	.global divideNumber

divideNumber:
	@ R1 to hold number to divide, r2 hold divisor. R0 returns result (hopefully)
	@ Thought this may come in handy - perhaps not?
	
	stmfd sp!, {r4-r6, lr}
	
	mov r0,#0
	mov r3,#1								@ set bit 0 for test in shift
	divl1:
		cmp r2,r1
		movls r2,r2,lsl #1					@ shift r2 till it is same as r1
		movls r3,r3,lsl #1					@ shift r3 (this is our count flag)
	bls divl1
	divl2:
		cmp r1,r2
		subcs r1,r1,r2
		addcs r0,r0,r3
		movs r3,r3,lsr #1
		movcc r2,r2,lsr #1
	bcc divl2
	
	ldmfd sp!, {r4-r6, pc}

	.pool
	.end
