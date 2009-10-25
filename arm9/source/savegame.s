.global saveGame
.global loadGame

#define SRAM_SIZE		32760
#define SRAM			0x0A000000

saveGame:

	stmfd sp!, {r0-r8, lr}

	ldr r0,=startOfSaveData
	ldr r1,=SRAM
	ldr r3,=endOfSaveData
	sub r2,r3,r0
	bl dmaCopy
	
	ldmfd sp!, {r0-r8, pc}
	
loadGame:

	stmfd sp!, {r0-r8, lr}

	ldr r1,=SRAM
	ldr r3,=id
	mov r5,#6
	checkID:
		ldrb r0,[r1],#1
		ldrb r4,[r3],#1
		cmp r0,r4
		bne loadGameFail
	subs r5,#1
	bpl checkID

	ldr r0,=SRAM
	ldr r1,=startOfSaveData
	ldr r3,=endOfSaveData
	sub r2,r3,r1
	bl dmaCopy


		loadGameFail:
	ldmfd sp!, {r0-r8, pc}
