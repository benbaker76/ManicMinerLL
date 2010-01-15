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

#include "mmll.h"

	.arm
	.align
	.text
	
	.global monsterMove
	
monsterMove:

	stmfd sp!, {r0-r10, lr}
	
	@ Move the monsters, sprite data 1-7 (max 7 per screen)
	
	mov r1,#65				@ counter
	
	monsterMoveLoop:

		ldr r2,=spriteActive
		ldr r3,[r2, r1,lsl #2]
		cmp r3,#0
		beq moveMonsterFail
		cmp r3,#MONSTER_ACTIVE
		bne moveMonsterFail

		ldr r2,=spriteSpeed
		ldr r4,[r2,r1,lsl#2]
		mov r8,#1
		cmp r4,#254						@ is this fractional?
		blt monsterMoveNormalSpeed
			cmp r4,#254
			movne r7,#2
			bne notPartial
			@ partial move 2
				ldr r7,=mPhase
				ldr r7,[r7]
				cmp r7,#0
				addeq r8,#1
				mov r7,#1
			notPartial:
			ldr r5,=monsterDelay
			ldr r6,[r5,r1,lsl #2]
			add r6,#1
			cmp r6,r7
			movge r6,#0
			str r6,[r5,r1,lsl #2]
			moveq r4,r8
			movne r4,#0
		monsterMoveNormalSpeed:
		
		ldr r7,=spriteMonsterFlips
		ldr r7,[r7, r1,lsl#2]
		cmp r7,#0
		moveq r7,#1
		movne r7,#0
		
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
		cmp r1,#72
	bne monsterMoveLoop

	ldr r1,=mPhase
	ldr r2,[r1]
	add r2,#1
	cmp r2,#2
	moveq r2,#0
	str r2,[r1]
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------------------	

@ the move code is passed 2 things, 
@ r4 = speed to move
@ r7 = flip direction (if a sprite should not flip, this must be 0)

monsterMoveLR:
	stmfd sp!, {r0-r10, lr}
	
	@ ok, just a straight left right movement
	@ r1 is still our offset
	@ check direction (hflip) and move

	ldr r2,=spriteDir
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
			mov r4,r7
			str r4,[r3,r1,lsl#2]
			ldr r3,=spriteDir
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
		blt monsterLRDone
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
		blt monsterUDDone
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
		add r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMax
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		blt monsterTRBLDone
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
		add r10,r4
		str r10,[r2,r1,lsl#2]
		ldr r2,=spriteMax
		ldr r3,[r2,r1,lsl#2]
		cmp r10,r3
		blt monsterTLBRDone
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
