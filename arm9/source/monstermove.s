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
	
	.global monsterMove
	
monsterMove:

	stmfd sp!, {r0-r10, lr}
	
	@ Move the monsters, sprite data 1-7 (max 7 per screen)
	
	mov r1,#1				@ counter
	
	monsterMoveLoop:
	
		ldr r2,=spriteActive
		ldr r3,[r2, r1,lsl #2]
		cmp r3,#0
		beq moveMonsterFail
		
		@ now find out the movement pattern
		
		ldr r2,=spriteMonsterMove
		ldr r3,[r2, r1,lsl #2]
		cmp r3,#0
		bleq monsterMoveUD
		cmp r3,#1
		bleq monsterMoveLR
		cmp r3,#2
		bleq monsterMoveTRBL
		cmp r3,#3
		bleq monsterMoveTLBR		
		
		
		
		
		
		
		
		
		
		moveMonsterFail:
	add r1,#1
	cmp r1,#8
	bne monsterMoveLoop
	
	
	
	
	
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------------------	
	
monsterMoveLR:
	stmfd sp!, {r0-r10, lr}
	
	@ ok, just a straight left right movement
	@ r1 is still our offset
	@ check direction (hflip) and move
	
	ldr r2,=spriteSpeed
	ldr r4,[r2,r1,lsl#2]
	
	ldr r2,=spriteHFlip
	ldr r3,[r2,r1,lsl#2]
	cmp r3,#0
	bne monsterLRRight
	
		@ move left (r4=speed)
		
		ldr r2,=spriteX
		ldr r10,[r2,r1,lsl#2]
		sub r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMin
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		bgt monsterLRDone
			ldr r3,=spriteHFlip
			mov r4,#1
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
		b monsterLRDone
		@ move Right (r4=speed)
	monsterLRRight:
		ldr r2,=spriteX
		ldr r10,[r2,r1,lsl#2]
		add r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMax
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		ble monsterLRDone
			ldr r3,=spriteHFlip
			mov r4,#0
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
	monsterLRDone:
	@ r10= x coord, use this to set the anim frame (0-7)
	
	and r10,#15
	lsr r10,#1						@ R10=Frame 0-7 (locate image from spritebank)

	bl monsterAnimate
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------------------	
	
monsterMoveUD:
	stmfd sp!, {r0-r10, lr}
	
	ldr r2,=spriteSpeed
	ldr r4,[r2,r1,lsl#2]
	
	ldr r2,=spriteDir
	ldr r3,[r2,r1,lsl#2]
	cmp r3,#0
	bne monsterUDDown
	
		@ move up (r4=speed)
		
		ldr r2,=spriteY
		ldr r10,[r2,r1,lsl#2]
		sub r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMin
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		bgt monsterUDDone
			mov r4,#1
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
		b monsterUDDone
		@ move down (r4=speed)
	monsterUDDown:
		ldr r2,=spriteY
		ldr r10,[r2,r1,lsl#2]
		add r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMax
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		ble monsterUDDone
			mov r4,#0
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
	monsterUDDone:
	@ r10= y coord, use this to set the anim frame (0-7)
	
	and r10,#15
	lsr r10,#1						@ R10=Frame 0-7 (locate image from spritebank)

	bl monsterAnimate

	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------------------	
	
monsterMoveTRBL:
	stmfd sp!, {r0-r10, lr}
	
	@ move diagonal from top right to bottom left
	
	ldr r2,=spriteSpeed
	ldr r4,[r2,r1,lsl#2]
	
	ldr r2,=spriteHFlip
	ldr r3,[r2,r1,lsl#2]
	cmp r3,#0
	bne monsterTRBLRight
	
		@ move down/left (r4=speed) 

		ldr r2,=spriteY
		ldr r9,[r2,r1,lsl#2]
		add r9,r4
		str r9,[r2,r1,lsl#2]		
		ldr r2,=spriteX
		ldr r10,[r2,r1,lsl#2]
		sub r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMin
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		bgt monsterTRBLDone
			ldr r3,=spriteHFlip
			mov r4,#1
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
		b monsterTRBLDone
		@ move Right (r4=speed)
	monsterTRBLRight:
		ldr r2,=spriteY
		ldr r9,[r2,r1,lsl#2]
		sub r9,r4
		str r9,[r2,r1,lsl#2]
		ldr r2,=spriteX
		ldr r10,[r2,r1,lsl#2]
		add r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMax
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		ble monsterTRBLDone
			ldr r3,=spriteHFlip
			mov r4,#0
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
	monsterTRBLDone:
	@ r10= x coord, use this to set the anim frame (0-7)
	
	and r10,#15
	lsr r10,#1						@ R10=Frame 0-7 (locate image from spritebank)

	bl monsterAnimate

	
	ldmfd sp!, {r0-r10, pc}
	
	
@-------------------------------------	
	
monsterMoveTLBR:
	stmfd sp!, {r0-r10, lr}
	
	@ move diagonal from top left to bottom right
	
	ldr r2,=spriteSpeed
	ldr r4,[r2,r1,lsl#2]
	
	ldr r2,=spriteHFlip
	ldr r3,[r2,r1,lsl#2]
	cmp r3,#0
	bne monsterTLBRRight
	
		@ move down/right (r4=speed) 

		ldr r2,=spriteY
		ldr r9,[r2,r1,lsl#2]
		sub r9,r4
		str r9,[r2,r1,lsl#2]		
		ldr r2,=spriteX
		ldr r10,[r2,r1,lsl#2]
		sub r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMin
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		bgt monsterTLBRDone
			ldr r3,=spriteHFlip
			mov r4,#1
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
		b monsterTLBRDone
		@ move Right (r4=speed)
	monsterTLBRRight:
		ldr r2,=spriteY
		ldr r9,[r2,r1,lsl#2]
		add r9,r4
		str r9,[r2,r1,lsl#2]
		ldr r2,=spriteX
		ldr r10,[r2,r1,lsl#2]
		add r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMax
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		ble monsterTLBRDone
			ldr r3,=spriteHFlip
			mov r4,#0
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
			str r4,[r3,r1,lsl#2]
	monsterTLBRDone:
	@ r10= x coord, use this to set the anim frame (0-7)
	
	and r10,#15
	lsr r10,#1						@ R10=Frame 0-7 (locate image from spritebank)

	bl monsterAnimate

	
	ldmfd sp!, {r0-r10, pc}