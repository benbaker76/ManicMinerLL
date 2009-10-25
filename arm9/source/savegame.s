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

	ldr r0,=SRAM
	ldr r1,=startOfSaveData
	ldr r3,=endOfSaveData
	sub r2,r3,r1
	bl dmaCopy
	
	ldmfd sp!, {r0-r8, pc}