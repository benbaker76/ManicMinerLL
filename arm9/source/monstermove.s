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
		cmp r3,#1
		bleq monsterMoveLR
		
		
		
		
		
		
		
		
		
		
		
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
	monsterLRDone:
	@ r10= x coord, use this to set the anim frame (0-7)
	
	and r10,#15
	lsr r10,#1
	ldr r2,=spriteObjBase
	ldr r2,[r2,r1,lsl#2]
	add r2,r10
	ldr r3,=spriteObj
	str r2,[r3,r1,lsl#2]
	
	
	
	ldmfd sp!, {r0-r10, pc}