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
	.global initSystem
	.global main
	.global gameStart
	.global gameStop

initSystem:
	stmfd sp!, {r0-r2, lr}
	
	mov r0, #0						@ Clear video display registers
	ldr r1, =0x04000000
	mov r2, #0x56
	bl dmaFillWords
	ldr r1, =0x04001008
	bl dmaFillWords
	
	mov r0, #0						@ Clear IPC
	ldr r1, =IPC
	mov r2, #256
	bl dmaFillWords
	
	ldr r0, =VRAM_CR
	mov r1, #0
	strb r1, [r0]
	ldr r0, =VRAM_E_CR
	strb r1, [r0]
	ldr r0, =VRAM_F_CR
	strb r1, [r0]
	ldr r0, =VRAM_G_CR
	strb r1, [r0]
	ldr r0, =VRAM_H_CR
	strb r1, [r0]
	ldr r0, =VRAM_I_CR
	strb r1, [r0]
	
	ldr r0, =REG_DISPCNT
	mov r1, #0
	str r1, [r0]
	ldr r0, =REG_DISPCNT_SUB
	str r1, [r0]
	
	ldmfd sp!, {r0-r2, pc}

main:
	ldr r0,=cheatMode
	mov r1,#0
	str r1,[r0]

	bl initVideo
	bl initInterruptHandler						@ initialize the interrupt handler

@	bl initGame

@	bl initTitleScreen
	
@	bl showIntro1
	
@	bl initLevelClear

	bl initGameOver
	
	@ ------------------------------------
	
mainLoop:

	bl swiWaitForVBlank							@ Wait for vblank
	
	ldr r0, =gameMode
	ldr r1, [r0]
	cmp r1, #GAMEMODE_RUNNING
	beq gameLoop
	cmp r1, #GAMEMODE_STOPPED
	beq mainLoopDone
	cmp r1, #GAMEMODE_LEVEL_CLEAR_INIT
	bleq initLevelClear
	cmp r1, #GAMEMODE_LEVEL_CLEAR
	bleq levelClear
	cmp r1, #GAMEMODE_INIT_TITLESCREEN
	bleq initTitleScreen
	cmp r1, #GAMEMODE_TITLE_SCREEN
	bleq updateTitleScreen
	cmp r1, #GAMEMODE_INTRO
	bleq updateIntro
	cmp r1, #GAMEMODE_DIES_INIT
	bleq initDeathAnim
	cmp r1, #GAMEMODE_DIES_UPDATE
	bleq updateDeathAnim
	cmp r1, #GAMEMODE_SPOTLIGHT
	beq spotlightLoop
	cmp r1, #GAMEMODE_PAUSED
	bleq gamePaused
	cmp r1, #GAMEMODE_GAMEOVER
	bleq updateGameOver
	cmp r1, #GAMEMODE_AUDIO
	bleq updateAudio
	cmp r1, #GAMEMODE_COMPLETION
	bleq updateCompletion
	cmp r1, #GAMEMODE_COMPLETION_BONUS
	bleq updateCompletionBonus
	cmp r1, #GAMEMODE_COMPLETION_WILLYW
	bleq updateCompletionWillyWood
	cmp r1, #GAMEMODE_GAMEOVER_SCREEN
	bleq updateGameOverScreen
	
	b mainLoop

gameLoop:

	@ This is our main game loop
	ldr r0,=levelNum
	ldr r0,[r0]
	cmp r0,#21
	beq moveFaster
	ldr r0,=minerDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#2
	moveq r1,#0
	str r1,[r0]
	bne skipFrame
	moveFaster:
		@ These are updated every other frame
		
		bl monsterMove
		bl moveMiner	
		bl minerControl
		bl minerJump
		bl minerFall

	skipFrame:
	
	bl collisionMonster

	bl checkHeadDie
	
	bl minerFrame
	bl levelAnimate
		
	bl checkExit

	bl drawScore
	
	bl updateSpecialFX
	
	bl minerChange
	
	bl airDrain
	bl drawAir
	
	bl dieChecker

	bl screenSwapper
	bl levelCheat	

	bl drawSprite
	
	bl switchClear
	
	bl pauseCheck

@	bl debugText
	
mainLoopDone:


	b mainLoop									@ our main loop

@---------------

spotlightLoop:

	ldr r0,=levelNum
	ldr r0,[r0]
	cmp r0,#21
	beq moveSpotFaster
	ldr r0,=minerDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#2
	moveq r1,#0
	str r1,[r0]
	bne skipSpotFrame
	moveSpotFaster:
		@ These are updated every other frame
		
		bl monsterMove

	skipSpotFrame:

	bl levelAnimate
	bl drawScore
	bl updateSpecialFX
	bl drawAir
	bl drawSprite
	
	bl switchClear

@	bl debugText

	b mainLoop									@ our main loop

	.pool
	.end
