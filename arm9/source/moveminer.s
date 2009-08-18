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

	.global moveMiner
	.global minerJump
	.global minerFall
	
@------------------------------
@
@ This contains all the movement code for Willy using default movement scheme (manic movement comes later)
@
@------------------------------
	
moveMiner:

	stmfd sp!, {r0-r10, lr}

	@ First phase is to read direction.
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r10, [r2]								@ r10= key pressed
	mov r9,r10									

	ldr r0,=conveyorDirection
	ldr r1,[r0]
	cmp r1,#0
	beq moveMinerFine

		bl moveOnConveyor
		b moveMinerJump

	moveMinerFine:
	
	ldr r0,=fallDirection
	mov r1,#0
	str r1,[r0]

	ldr r0,=minerAction							@ check current action of miner
	ldr r1,[r0]
	cmp r1,#MINER_NORMAL	
	bne moveFail							@ if not in normal play, skip
	
	@ move l/r return r0 as the new minerDirection
	
	mov r0, #0									@ make the direction 0 first
	
	tst r10,#BUTTON_RIGHT
	bleq moveRight								@ right is pressed
	tst r10,#BUTTON_LEFT
	bleq moveLeft								@ left is pressed
												@ No movement made, miner is stationary
	movementDone:
	
	ldr r4,=minerDirection
	str r0,[r4]									@ store new direction
	
	moveMinerJump:
	
	tst r10,#BUTTON_A
	bleq moveJump
	
	moveFail:
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------- RIGHT MOVEMENT
	
moveRight:

	stmfd sp!, {r1-r10, lr}
	
	ldr r7,=conveyorDirection
	ldr r7,[r7]						@ r7 is used to let us know if we are on a conveyor	
	
	ldr r2,=spriteHFlip
	ldr r3,[r2]
	cmp r3,#0
	moveq r0,#0						@ set dir to 0 if you were facing Left and flip sprite
	beq moveRightDone
	
	cmp r7,#MINER_RIGHT
@	beq moveRightDone

	ldr r2,=spriteX
	ldr r0,[r2]
	add r0,#1
		
	bl checkRight					@ pass r0 as correct coord

	@ if r9 or r10 contain #1, we must stop moving

	cmp r9,#1						@ solid wall
	beq moveRightWall
	cmp r10,#1
	beq moveRightWall

	str r0,[r2]						@ store new X coordinate	
	mov r0,#MINER_RIGHT				@ return 'moving right'
	
	moveRightDone:

	ldr r2,=spriteHFlip
	mov r5,#1						@ flip sprite
	str r5,[r2]

	ldmfd sp!, {r1-r10, pc}
	
	moveRightWall:
	
	sub r0, #1
	str r0,[r2]
	mov r0, #2
	b moveRightDone
	
@------------------------------- LEFT MOVEMENT
	
moveLeft:	

	stmfd sp!, {r1-r10, lr}

	ldr r7,=conveyorDirection
	ldr r7,[r7]						@ r7 is used to let us know if we are on a conveyor	
	
	ldr r2,=spriteHFlip
	ldr r3,[r2]
	cmp r3,#1
	moveq r0,#0						@ set dir to 0 if you were facing right and flip sprite
	beq moveLeftDone

	@ move Left
	
	cmp r7,#MINER_LEFT
@	beq moveLeftDone
	
	ldr r2,=spriteX
	ldr r0,[r2]
	sub r0,#1
		
	bl checkLeft					@ pass r0 as correct coord
	
	@ if r9 or r10 contain #1, we must stop moving
	
	cmp r9,#1						@ solid wall
	beq moveLeftWall
	cmp r10,#1
	beq moveLeftWall

	str r0,[r2]						@ store new X coordinate	
	mov r0,#MINER_LEFT				@ return 'moving right'
	
	moveLeftDone:

	ldr r2,=spriteHFlip
	mov r5,#0						@ flip sprite
	str r5,[r2]

	ldmfd sp!, {r1-r10, pc}

	moveLeftWall:
	
	add r0, #1
	str r0,[r2]
	mov r0, #1
	b moveLeftDone
	
@------------------------------- LEFT MOVEMENT
	
moveJump:

	stmfd sp!, {r0-r10, lr}

	@ here we need to initialise a jump (if one is not already active)
	@ all we need to do is set miners mode to jump and initialise the counter
	@ if cannot be active as the init is skipped if willy is not in mormal phase
	
	@ we need to check above head first to see if a jump is possible
	
	ldr r1,=minerAction
	ldr r2,[r1]
	cmp r2,#MINER_JUMP
	beq moveJumpFail
	
	
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
	mov r1,#MINER_JUMP
	str r1,[r0]					@ make willy in the jump zone
	ldr r0,=jumpCount
	mov r1,#0
	str r1,[r0]					@ set jump count to 0 (start of phase)
	
	@ if falldirection is right
	
	ldr r0,=minerDirection
	ldr r3,[r0]
	
	ldr r0,=conveyorDirection
	ldr r1,[r0]
	cmp r1,#0
	beq nonConveyorJump
		cmp r1,r3				@ is the conveyor direction opposite to yours?
	@	movne r3,#0				@ if so, make the jump vertical
	
	
	nonConveyorJump:
	ldr r0,=jumpDirection
	str r3,[r0]
	
	
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

	ldr r1,=conveyorDirection
	mov r2,#0
	str r2,[r1]
	
	bl playJump

	ldr r3,=jumpCount
	ldr r2,[r3]						@ r2 = the phase of the jump ("keep" r2 and r3 for later)
	
	ldr r1,=willyJumpData
	ldrsb r4,[r1,r2]				@ r4 = y modification value for jump

	ldr r7,=jumpDirection			@ move l/r if needed (this also does checks for collision)
	ldr r7,[r7]
	cmp r7,#MINER_LEFT
		bleq moveLeft
	cmp r7,#MINER_RIGHT
		bleq moveRight

	ldr r5,=spriteY					@ get y coord
	ldr r6,[r5]
	mov r8,r6						@ Save the Y value for a 'headbut' for later
	adds r6,r4
	str r6,[r5]						@ shove it back


	add r2,#1						@ add to the jump phase
	cmp r2,#MINER_JUMPLEN			@ check if we are at the end of a jump
	blt minerJumpContinues
		
		mov r7,#MINER_NORMAL		@ if jump is over, return control (this will check a fall first though)
		ldr r6,=minerAction
		str r7,[r6]
	
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
		
		mov r7,#MINER_NORMAL		@ set us back to normal movement
		ldr r6,=minerAction
		str r7,[r6]
		
		ldr r7,=spriteY				@ make us land correctly on the floor
		ldr r6,[r7]
		lsr r6,#3
		lsl r6,#3
		str r6,[r7]
		
@		ldr r7,=minerDirection
@		ldr r6,[r7]
@		ldr r7,=fallDirection
@		str r6,[r7]
		
		@ we need to see if we have landed on a conveyer and set conveyorDirection
		
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
		
		mov r7,#MINER_NORMAL
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
	
	@ ok, if we are not already falling, check both feet and if empty, FALL
	
	cmp r1,#MINER_FALL
	beq minerIsFalling
	
		bl checkFeet
	
		cmp r9,#0					@ again, we are not doing a strict check, anything will do...
		bne minerFallFail
		cmp r10,#0
		bne minerFallFail

		@ we are falling now!!
		
		mov r1,#MINER_FALL
		str r1,[r0]					@ set to falling
		mov r1,#0
		ldr r0,=fallCount			@ set fall count to 1, we need this so we know if we are DEAD
		str r1,[r0]		
		
		b minerFallFail

	minerIsFalling:

		@ this is simple code to make willy fall
		@ though, we also need to update the direction he is facing (without flipping)

		ldr r1,=conveyorDirection
		mov r2,#0
		str r2,[r1]
		
		ldr r2, =REG_KEYINPUT						@ Read key input register
		ldr r10, [r2]								@ r10= key pressed
		
		mov r0,#MINER_STILL							@ this is needed for if we fall on a conveyor
		tst r10,#BUTTON_RIGHT						@ during jump, direction needs to stay the same
		moveq r0,#MINER_RIGHT						@ as the start of the jump
		tst r10,#BUTTON_LEFT
		moveq r0,#MINER_LEFT
		
		ldr r1,=minerDirection
		str r0,[r1]									@ store new direction
		
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
	
		Ldr r0,=minerAction
		mov r1,#MINER_NORMAL
		str r1,[r0]
		
		ldr r7,=spriteY				@ make sure we are back on level ground and feet are in correct place.
		ldr r6,[r7]
		lsr r6,#3
		lsl r6,#3
		str r6,[r7]
		
		@ if we fall and land on a conveyor, if we were pushing right and the conveyor
		@ if moving left, we should just stand still.. So.. How!!!
		@ store direction in fallDirection
		@ in conveyor test, if fallDirection is the same as the move direction, donot move
		@ but, what if we land on a conveyor from a jump or crumbler???? AAAArrrrggghhh!!!
		
		ldr r0,=minerDirection
		ldr r1,[r0]
		ldr r0,=fallDirection
		str r1,[r0]
	
	
	b minerFallFail

@------------------------------- Move with a conveyor

moveOnConveyor:

	stmfd sp!, {r0-r10, lr}
	
@	ldr r7,=minerAction
@	ldr r7,[r7]
@	cmp r7,#MINER_CONVEYOR
@	bne moveOnConveyorFail
	ldr r7,=conveyorDirection
	ldr r7,[r7]
	cmp r7,#MINER_LEFT					@ conveyor left
	@ if we were moving right, continue to do so until otherwise!
	@ if we are moving left or not moving, move player left (but not twice), and set direction to left
	@ BUT!!! If you fall on conveyor and it is a left, and you press right
	@ you remain stationary and can only jump up! (How do I add that?)

	bne moveOnConveyerRight
	
		ldr r1,=minerDirection
		ldr r0,[r1]
		cmp r0,#MINER_RIGHT
		bne leftConveyorLeft
			@ if flip is right and button pressed is right,
			@ donot move!
			ldr r3,=spriteHFlip
			ldr r3,[r3]
			cmp r3,#1					@ facing Right
			bne leftConveyorNot
				ldr r3,=fallDirection
				ldr r3,[r3]
				cmp r3,#MINER_RIGHT
				bne leftConveyorNot
				tst r10,#BUTTON_RIGHT
				beq moveOnConveyorFail
			leftConveyorNot:
		
			bl moveRight
			tst r10,#BUTTON_RIGHT
			movne r1,#MINER_LEFT
			ldrne r2,=minerDirection
			strne r1,[r2]
			b moveOnConveyorFail
		leftConveyorLeft:
			mov r0,#MINER_LEFT
			str r0,[r1]
			ldr r0,=spriteHFlip
			mov r1,#0
			str r1,[r0]
			bl moveLeft
		b moveOnConveyorFail
	
	moveOnConveyerRight:				@ conveyor Right
	
	moveOnConveyorFail:

	ldmfd sp!, {r0-r10, pc}	
	
@-------------------------------

minerPause:	@ NOT USED!
	
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
	
minerXOld:
	.word 0
minerYOld:
	.word 0
	.pool
	.end