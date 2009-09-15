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
#include "audio.h"

	.arm
	.align
	.text

	#define 		DIE_ANIM_DELAY		8

	.global dieChecker
	.global initDeathAnim
	.global updateDeathAnim

dieChecker:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=minerDied		@ this will be moved, just for testing
	ldr r1,[r1]
	cmp r1,#1
	bne dieCheckFailed
	
		@ we have already removed a life

		@ Bugger, we have died :(
		
		ldr r0,=minerLives
		ldr r0,[r0]
	@	cmp r0,#0
	@	bleq initTitleScreen
	@	blne initLevel

		@ now we need to set the gamemode to dying and use update die
		
		ldr r1,=gameMode
		mov r2,#GAMEMODE_DIES_INIT	
		str r2,[r1]

b testingit

	dieCheckFailed:
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------
	
initDeathAnim:

	@ init all we need for dying animation and sound!

	stmfd sp!, {r0-r10, lr}

testingit:	
		ldr r1,=gameMode
		mov r2,#GAMEMODE_DIES_UPDATE
		str r2,[r1]	

		bl playDead
		
		@ overlay the sprites needed to the sprite oam..
		
		ldr r3,=levelNum
		ldr r3,[r3]
		sub r3,#1
		mov r2,#2048						@ 8 * 16x16 sprites
		
		ldr r0,=DieFallTiles				@ default death
		cmp r3,#0
		ldreq r0,=DieSkeletonTiles
		cmp r3,#1
		ldreq r0,=DieExplodeTiles
		cmp r3,#2
		ldreq r0,=DieCrumbleTiles
		cmp r3,#6
		ldreq r0,=DieOriginalTiles
		ldr r1, =SPRITE_GFX_SUB				@ copy tiles
		bl dmaCopy

		@ set a few setting for the death

		ldr r2,=120
		ldr r1,=diePause
		str r2,[r1]							@ set length of death
		
		mov r2,#DIE_ANIM_DELAY				@ set animation delay
		ldr r1,=dieAnim
		str r2,[r1]
		
		mov r2,#0							@ set initial frame
		ldr r1,=dieFrame
		str r2,[r1]
		ldr r1,=spriteObj+256
		str r2,[r1]
		
	@	bl fxFadeBlackLevelInit
	@	bl fxFadeMax
	@	bl fxFadeOut
	@	bl fxSpotlightOut
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------------
	
updateDeathAnim:

	@ update the death animation and either return to game or gameover!

	stmfd sp!, {r0-r10, lr}
	
	ldr r12,=diePause						@ read our delay
	ldr r12,[r12]
	
	updateDeathAnimLoop:
	
		bl swiWaitForVBlank	

		ldr r0,=minerDelay
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
		bne skipFrameClearDie
			bl monsterMove
		skipFrameClearDie:	
	
		bl drawSprite
		bl levelAnimate	
		bl updateSpecialFX		

		bl dieAnimationUpdate
	
	subs r12,#1
	bpl updateDeathAnimLoop
	
	@ die anim finished -----------------
	
	ldr r0,=cheatMode
	ldr r0,[r0]
	cmp r0,#1
	beq diedNowStillPlay
	
	ldr r0,=minerLives
	ldr r0,[r0]
	cmp r0,#0
	beq diedNowGameOver
	diedNowStillPlay:
	
		@ return to the level (lives left)
	
		ldr r1,=gameMode
		mov r0,#GAMEMODE_RUNNING
		str r0,[r1]
		bl initLevel
		b updateDeathAnimDone

	@ go to game over (lives all gone)
	diedNowGameOver:

		bl initTitleScreen

	
	updateDeathAnimDone:
	
	ldmfd sp!, {r0-r10, pc}
	

@------------------------------------------------	
	
dieAnimationUpdate:
	stmfd sp!, {r0-r10, lr}
	
		@ ok, animate death
		
		ldr r1,=dieAnim
		ldr r2,[r1]
		subs r2,#1
		movmi r2,#DIE_ANIM_DELAY
		str r2,[r1]
		bpl dieAnimWaits
		
			ldr r1,=dieFrame
			ldr r2,[r1]
			add r2,#1
			cmp r2,#8
			moveq r2,#7
			str r2,[r1]
			bge dieAnimFinished

				cmp r2,#6
			@	bleq fxSpotlightOut

				ldr r3,=spriteObj+256
				str r2,[r3]
				b dieAnimWaits
			
			dieAnimFinished:
				ldr r3,=spriteActive+256
				mov r4,#0
				str r4,[r3]	
				
		
		dieAnimWaits:
	
		
	
	
	ldmfd sp!, {r0-r10, pc}	
	
	
	.pool
	.data
	
	.align
	
	diePause:
		.word 0
	dieFrame:
		.word 0
	dieAnim:
		.word 0