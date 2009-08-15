	.global initGame

initGame:
stmfd sp!, {r0-r10, lr}

	mov r0,#1				@ set level to 1 for start of game
	ldr r1,=levelNum
	str r0,[r1]
	
	
ldmfd sp!, {r0-r10, pc}