.global saveGame
.global loadGame

saveGame:

	stmfd sp!, {r0-r8, lr}

	ldr r0,=startOfSaveData
	ldr r1,=saveBuffer
	ldr r3,=endOfSaveData
	sub r2,r3,r0
	bl dmaCopy
	
	ldr r0, =saveDatText
	ldr r1, =saveBuffer
	bl writeFileBuffer
	
	bl DC_FlushAll
	
bl drawPauseWindow
	
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

bl drawPauseWindow

	ldmfd sp!, {r0-r8, pc}
	
	@------------------------------------

	.data
	.align
	
	.align
	
saveBuffer:
	.incbin "../../efsroot/MMLL/Data/Save.dat"

	.align

saveDatText:
	.asciz "/MMLL/Data/Save.dat"

