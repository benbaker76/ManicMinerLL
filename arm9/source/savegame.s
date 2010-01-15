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

	.arm
	.align
	.text

	.global saveGame
	.global loadGame

saveGame:

	stmfd sp!, {r0-r8, lr}

	bl DC_FlushAll

	ldr r0,=startOfSaveData
	ldr r1,=saveBuffer
	ldr r3,=endOfSaveData
	sub r2,r3,r0
	bl dmaCopy
	
	ldr r0, =saveDatText
	ldr r1, =saveBuffer
	bl writeFileBuffer

	bl DC_FlushAll
	
	ldmfd sp!, {r0-r8, pc}
	
loadGame:

	stmfd sp!, {r0-r8, lr}
	
	ldr r0, =saveDatText
	ldr r1, =saveBuffer
	bl readFileBuffer
	
	bl DC_FlushAll

	ldr r1,=saveBuffer
	ldr r3,=id
	mov r5,#6
	checkID:
		ldrb r0,[r1],#1
		ldrb r4,[r3],#1
		cmp r0,r4
		bne loadGameFail
	subs r5,#1
	bpl checkID

	ldr r0,=saveBuffer
	ldr r1,=startOfSaveData
	ldr r3,=endOfSaveData
	sub r2,r3,r1
	bl dmaCopy

	ldmfd sp!, {r0-r8, pc}

loadGameFail:

	ldmfd sp!, {r0-r8, pc}
	
	@------------------------------------

	.data
	.pool
	.align

saveDatText:
	.asciz "/Data/MMLL/Data/Save.dat"
	.byte 0
	
	.align
	
saveBuffer:
	.incbin "../../efsroot/Data/MMLL/Data/Save.dat"
