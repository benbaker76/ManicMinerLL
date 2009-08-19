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

	.global minerControl
	.global minerJump
	.global minerFall
	.global moveMiner
	.global lastAction
	
@------------------------------
@
@ This contains all the movement code for Willy using default movement scheme (manic movement comes later)
@
@------------------------------
	
minerControl:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=minerAction							@ check current action of miner
	ldr r1,[r0]
	cmp r1,#MINER_NORMAL	
	bne moveControlConveyor						@ if not in normal play, skip

	@ First phase is to read direction.
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r10, [r2]								@ r10= key pressed								
	
	@ move l/r return r0 as the new minerDirection
	
	mov r0, #0									@ make the direction 0 first
	
	tst r10,#BUTTON_RIGHT
	bleq moveRight								@ right is pressed
	tst r10,#BUTTON_LEFT
	bleq moveLeft								@ left is pressed
												@ No movement made, miner is stationary
	movementDone:
	
	ldr r1,=minerDirection
	str r0,[r1]									@ store new direction
	
	tst r10,#BUTTON_A
	bleq moveJump

	ldmfd sp!, {r0-r10, pc}

@------------------------------- ON CONVEYOR
	
	moveControlConveyor:
	cmp r1,#MINER_CONVEYOR
	bne moveFail
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r10, [r2]								@ r10= key pressed				
	
	ldr r1,=conveyorDirection
	ldr r1,[r1]
	cmp r1,#MINER_LEFT
	bne moveControlConveyorRight
		@
		@ Conveyor Left
		@
		ldr r3,=minerDirection
		ldr r0,[r3]
		cmp r0,#MINER_RIGHT
		beq keepGoingRight
		cmp r0,#MINER_STILL
		beq keepGoingRight
			mov r0,#MINER_LEFT
			str r0,[r3]
			
			tst r10,#BUTTON_A
			bleq moveJump		
		
		
		
		
			b moveFail
		
		keepGoingRight:						@ we are facing right, if from fall, no move right
			ldr r5,=faller				@ just stay stationary is pushing right
			ldr r5,[r5]
			cmp r5,#1

			movne r6,#MINER_RIGHT
			moveq r6,#MINER_STILL

			mov r0,#MINER_LEFT
			
			tst r10,#BUTTON_RIGHT
			moveq r0,r6								@ right is pressed
			ldrne r1,=spriteHFlip
			movne r2,#0
			strne r2,[r1]
			
			ldr r1,=minerDirection
			str r0,[r1]
	
			tst r10,#BUTTON_A
			bleq moveJump
	
	
	
	
	
	
	
	moveControlConveyorRight:
	
	
	
	
	moveFail:

	ldmfd sp!, {r0-r10, pc}
	
	
	
	

@------------------------------- RIGHT MOVEMENT
	
moveRight:

	stmfd sp!, {r1-r10, lr}
	
	ldr r2,=spriteHFlip
	ldr r3,[r2]
	cmp r3,#0
	moveq r0,#0						@ set dir to 0 if you were facing Left and flip sprite
	beq moveRightDone
	
	mov r0,#MINER_RIGHT				@ return 'moving right'
	
	moveRightDone:

	ldr r2,=spriteHFlip
	mov r1,#1						@ flip sprite
	str r1,[r2]

	ldmfd sp!, {r1-r10, pc}
	
@------------------------------- LEFT MOVEMENT
	
moveLeft:

	stmfd sp!, {r1-r10, lr}
	
	ldr r2,=spriteHFlip
	ldr r3,[r2]
	cmp r3,#1
	moveq r0,#0						@ set dir to 0 if you were facing right and flip sprite
	beq moveLeftDone

	mov r0,#MINER_LEFT				@ return 'moving right'
	
	moveLeftDone:

	ldr r2,=spriteHFlip
	mov r1,#0						@ flip sprite
	str r1,[r2]

	ldmfd sp!, {r1-r10, pc}
	
	
@------------------------------- MOVE MINER
	
moveMiner:

	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=minerAction
	ldr r0,[r0]
	cmp r0,#MINER_FALL
	beq moveMinerFail
	
	ldr r0,=minerDirection
	ldr r0,[r0]
	cmp r0,#0
	beq moveMinerFail
	
	cmp r0,#MINER_LEFT
	bne moveMinerRight
		ldr r2,=spriteX
		ldr r1,[r2]
		sub r1,#1
		str r1,[r2]
		
		bl checkLeft
	
		cmp r9,#1
		beq moveMinerLeftFail
		cmp r10,#1
		beq moveMinerLeftFail
		
		b moveMinerFail
		
		moveMinerLeftFail:

		ldr r2,=spriteX
		ldr r1,[r2]
		add r1,#1
		str r1,[r2]		
		


		b moveMinerFail


	moveMinerRight:
		ldr r2,=spriteX
		ldr r1,[r2]
		add r1,#1
		str r1,[r2]
		
		bl checkRight
		
		cmp r9,#1
		beq moveMinerRightFail
		cmp r10,#1
		beq moveMinerRightFail
		
		b moveMinerFail
		
		moveMinerRightFail:

		ldr r2,=spriteX
		ldr r1,[r2]
		sub r1,#1
		str r1,[r2]		
		


		b moveMinerFail

	moveMinerFail:
	ldmfd sp!, {r0-r10, pc}	
	
@------------------------------- CHECK FOR JUMP
	
moveJump:

	stmfd sp!, {r0-r10, lr}

	@ here we need to initialise a jump (if one is not already active)
	@ all we need to do is set miners mode to jump and initialise the counter
	@ if cannot be active as the init is skipped if willy is not in mormal phase
	
	@ we need to check above head first to see if a jump is possible
	
	ldr r1,=spriteY
	ldr r2,[r1]
	sub r2,#8				@ go one char above head
	str r2,[r1]
	
	bl checkHead
	
	add r2,#8				@ restore coord
	str r2,[r1]
	cmp r9,#1
	beq moveJumpFail
	cmp r10,#1
	beq moveJumpFail
	
	ldr r0,=minerAction
	ldr r1,[r0]
	cmp r1,#MINER_JUMP
	beq moveJumpFail
	cmp r1,#MINER_FALL
	beq moveJumpFail
	

bl lastAction
	ldr r0,=minerAction
	mov r1,#MINER_JUMP
	str r1,[r0]					@ make willy in the jump zone
	ldr r0,=jumpCount
	mov r1,#0
	str r1,[r0]					@ set jump count to 0 (start of phase)
	
	moveJumpFail:
	
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------- Animate and move Willy through a jump

@ we are using a lookup table for now, but this should really be calculated
@ the original Y value is stored in 'r8' so, keep it clear
	
minerJump:

	stmfd sp!, {r0-r10, lr}
	
	@ here we need to complete a jump (if one is already active)
	
	ldr r0,=minerAction
	ldr r1,[r0]
	cmp r1,#MINER_JUMP				@ If we are not jumping, leave this place
	bne minerJumpFail
	
	bl playJump

	ldr r3,=jumpCount
	ldr r2,[r3]						@ r2 = the phase of the jump ("keep" r2 and r3 for later)
	
	ldr r1,=willyJumpData
	ldrsb r4,[r1,r2]				@ r4 = y modification value for jump	

	ldr r5,=spriteY					@ get y coord
	ldr r6,[r5]
	mov r8,r6						@ Save the Y value for a 'headbut' for later
	adds r6,r4
	str r6,[r5]						@ shove it back

	add r2,#1						@ add to the jump phase
	cmp r2,#MINER_JUMPLEN			@ check if we are at the end of a jump
	blt minerJumpContinues
		
bl lastAction
		mov r7,#MINER_NORMAL		@ if jump is over, return control (this will check a fall first though)
		ldr r6,=minerAction
		str r7,[r6]
		
		ldr r0,=spriteY
		ldr r1,[r0]
		lsr r1,#3
		lsl r1,#3
		str r1,[r0]
		
		bl checkFeet

@b minerLanded

		b minerJumpFail
	
	minerJumpContinues:

	str r2,[r3]						@ store new jump position
	
	cmp r2,#MINER_MID_JUMP			@ if we are past the jump midpoint, check feet
	ble minerJumpUp					@ if not, jump to the head detection
	
	@ Coming down so check feet
	
		bl checkFeet			
		
		cmp r9,#0					@ we are only worrying about any collision for now
		bne minerLanded
		cmp r10,#0
		bne minerLanded 			@ check both sides
		
		b minerJumpFail
		
		minerLanded:
		
		@ check if the floor detected is not part through us already?
		
		ldr r7,=spriteY				@ this is perhaps not the best way???
		ldr r6,[r7]
		and r6,#7
		cmp r6,#5
		bge minerJumpFail

bl lastAction
	
		mov r7,#MINER_NORMAL		@ set us back to normal movement
		ldr r6,=minerAction
		str r7,[r6]
		
		ldr r7,=spriteY				@ make us land correctly on the floor
		ldr r6,[r7]
		lsr r6,#3
		lsl r6,#3
		str r6,[r7]


	
		b minerJumpFail

	minerJumpFail:
	
ldmfd sp!, {r0-r10, pc}
	
	minerJumpUp:
	
	@ we are going up, so check head
	
		bl checkHead			
		
		cmp r9,#1					@ we are only worrying about any wall collision for now
		beq minerHeadHit
		cmp r10,#1
		beq minerHeadHit 			@ check both sides
		
		b minerJumpFail
		
		minerHeadHit:
		
		@ we will need to add a check in here for feet also so that if you jump in a 16 pixel
		@ gap, you wont jump but carry on walking!
	
bl lastAction
	
		mov r7,#MINER_FALL
		ldr r6,=minerAction
		str r7,[r6]					@ we have hit our head, so, stop jumping, and fall
		
		ldr r7,=spriteY				@ restore the coord before the jump
		str r8,[r7]
	
	b minerJumpFail

@------------------------------- This just keeps a check under willies feet	

minerFall:
	stmfd sp!, {r0-r10, lr}



	ldr r0,=minerAction
	ldr r1,[r0]
	cmp r1,#MINER_JUMP				@ If we are jumping, leave this place
	beq minerFallFail
	
	@ ok, if we are not alread falling, check both feet and if empty, FALL
	
	cmp r1,#MINER_FALL
	beq minerIsFalling
	
		bl checkFeet
	
		cmp r9,#0					@ again, we are not doing a strict check, anything will do...
		bne minerFallFail
		cmp r10,#0
		bne minerFallFail

		@ we are falling now!!
	
bl lastAction
	
		mov r1,#MINER_FALL
		str r1,[r0]					@ set to falling
		mov r1,#0
		ldr r0,=fallCount			@ set fall count to 1, we need this so we know if we are DEAD
		str r1,[r0]		
		mov r1,#0
		ldr r0,=minerDirection
	@	str r1,[r0]
	
ldr r0,=faller
mov r1,#1
str r1,[r0]
	
		b minerFallFail

	minerIsFalling:

		@ this is simple code to make willy fall
		@ though, we also need to update the direction he is facing (without flipping)
		
		ldr r2, =REG_KEYINPUT						@ Read key input register
		ldr r10, [r2]								@ r10= key pressed
		
		mov r0,#MINER_STILL							@ this is needed for if we fall on a conveyor
		tst r10,#BUTTON_RIGHT						@ during jump, direction needs to stay the same
		moveq r0,#MINER_RIGHT						@ as the start of the jump
		tst r10,#BUTTON_LEFT
		moveq r0,#MINER_LEFT
		
@		ldr r1,=minerDirection
@		str r0,[r1]									@ store new direction
		
		bl playFall

		ldr r1,=spriteY
		ldr r2,[r1]
		add r2,#2					@ add 2 to y coord (should we accelerate?)
		str r2,[r1]

		bl checkFeet				@ lets have a look below us
		
		cmp r9,#0
		bne minerFallOver
		cmp r10,#0
		bne minerFallOver			@ if we have found anything, lets stop falling
		
		@ we are still falling, so add to fall count
		
		ldr r1,=fallCount
		ldr r2,[r1]
		add r2,#1
		str r2,[r1]

	minerFallFail:

	ldmfd sp!, {r0-r10, pc}

@-------------------------------

	@ stop the falling now please
	
	minerFallOver:
	
		@ later, check minerFall and see if it was too far, and kill us!
	
bl lastAction
	
		Ldr r0,=minerAction
		mov r1,#MINER_NORMAL
		str r1,[r0]
		
		ldr r7,=spriteY				@ make sure we are back on level ground and feet are in correct place.
		ldr r6,[r7]
		lsr r6,#3
		lsl r6,#3
		str r6,[r7]
	
	
	b minerFallFail
	
@-------------------------------

minerPause:
	
	stmfd sp!, {r0-r8,r10, lr}
	
	mov r9,#0
	ldr r0,=minerDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#2
	moveq r1,#0
	moveq r9,#1
	str r1,[r0]
	
	
	ldmfd sp!, {r0-r8,r10, pc}

lastAction:	
	
	stmfd sp!, {r0-r2, lr}
	
	ldr r1,=minerAction
	ldr r2,[r1]
	ldr r1,=lastMiner
	str r2,[r1]
	
	
	ldmfd sp!, {r0-r2, pc}
	
minerXOld:
	.word 0
minerYOld:
	.word 0
	.pool
	.end