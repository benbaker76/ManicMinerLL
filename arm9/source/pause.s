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

#define BUF_ATTRIBUTE2_SUB	(0x07000404)

	.global pauseCheck
	.global gamePaused
	.global drawPauseWindow

@---------------------------

pauseCheck:
	stmfd sp!, {r0-r10, lr}
	
	ldr r1,= trapStart
	
	ldr r2, =REG_KEYINPUT
	ldr r10,[r2]
	
	tst r10,#BUTTON_START
	beq pausePressed
	
	mov r0,#0						@ start not pressed, so clear the trap.
	str r0,[r1]

	ldmfd sp!, {r0-r10, pc}	
	
	pausePressed:
	
	ldr r0,[r1]
	cmp r0,#1
	beq pauseCheckFinished
	
	@----------------------- Init pause screen and stop the game
	
	mov r0,#1						@ reset start trap
	str r0,[r1]
	
	ldr r2,=gameMode
	mov r3,#GAMEMODE_PAUSED
	str r3,[r2]
	
	bl drawPauseWindow
	
	pauseCheckFinished:

	ldmfd sp!, {r0-r10, pc}
	
@---------------------------
	
gamePaused:
	stmfd sp!, {r0-r10, lr}

	ldr r1,= trapStart
		
	ldr r2, =REG_KEYINPUT
	ldr r10,[r2]
	
	tst r10,#BUTTON_START
	beq unpausePressed
	
	mov r0,#0						@ start not pressed, so clear the trap.
	str r0,[r1]
	
	@ now check for B and Select
	
	tst r10,#BUTTON_B
	bne pauseNotB
		@ Button B pressed - lose life
		
		bl initDeath
		bl clearBG0SubPartGame
		bl clearBG1SubPartGame

		ldr r2,=gameMode
		mov r3,#GAMEMODE_RUNNING
		str r3,[r2]	
	
	b pauseButtonsDone
	
	pauseNotB:
		
	tst r10,#BUTTON_SELECT
	bne pauseButtonsDone
	
		@ Button SELECT pressed - title screen
		bl fxFadeBlackInit
		bl fxFadeMin
		bl fxFadeOut

		justWaitForIt:
		ldr r1,=fxFadeBusy
		ldr r1,[r1]
		cmp r1,#0
		beq jumpCompLL

		b justWaitForIt

		jumpCompLL:		

		bl clearBG1
		bl clearBG2
		bl clearBG3
		bl clearBG0
		
		bl initTitleScreen
		
	pauseButtonsDone:
	ldmfd sp!, {r0-r10, pc}	
	
	unpausePressed:
	
	ldr r0,[r1]
	cmp r0,#1
	beq unpauseCheckFinished
	
	@----------------------- Init pause screen and stop the game
	
	mov r0,#1						@ reset start trap
	str r0,[r1]
	
	ldr r2,=gameMode
	mov r3,#GAMEMODE_RUNNING
	str r3,[r2]
	
	bl clearBG0SubPartGame
	bl clearBG1SubPartGame
	
	unpauseCheckFinished:

	ldmfd sp!, {r0-r10, pc}
	
@---------------------------
	
drawPauseWindow:
	stmfd sp!, {r0-r10, lr}

	@ first, we need to set the priority of all sprites to 2
	
	mov r10,#127
	
	pauseSpritePri:
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r10, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r10, lsl #2]
		ldr r1,=spritePriority
		ldr r1,[r1,r10, lsl #2]
		cmp r1,#2
		movlt r1,#2
		lsl r1,#10						@ set priority
		orr r1,r3, lsl #3				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back
	subs r10,#1
	bpl pauseSpritePri
	
	@ draw a window on bg1 (24x13) (inner 22x11)
	
	ldr r0,=StatusMap
	add r0,#(32*8)*2
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB) 	@ r3=location of draw area
	add r1,#(32*10)*2							@ down 10 chars
	add r1,#16									@ move across 8 chars
	mov r2,#32									@ chars to draw
	mov r3,#8	
	pauseWindowLoop:
		
		bl dmaCopy

		add r0,#32*2
		add r1,#32*2
		subs r3,#1
	bpl pauseWindowLoop

	ldmfd sp!, {r0-r10, pc}