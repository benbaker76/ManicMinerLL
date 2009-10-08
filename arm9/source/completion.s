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

	.global initCompletion
	.global updateCompletion
	
@---------------------------			LOST LEVEL COMPLETION INIT

initCompletion:

	stmfd sp!, {r0-r10, lr}

	lcdMainOnBottom
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
@	bl clearBG3
	bl clearOAM
	bl clearSpriteData
	bl stopMusic					@ remove when we have completion music

	ldr r1,=gameMode
	mov r0,#GAMEMODE_COMPLETION
	str r0,[r1]

	bl fxFadeBlackLevelInit
	bl fxFadeMax
	
	ldr r0,=VictoryBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=VictoryBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =VictoryBottomMapLen
	bl dmaCopy
	ldr r0, =VictoryBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =VictoryBottomPalLen
	bl dmaCopy	

	ldr r0,=VictoryTopTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=VictoryTopTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =VictoryTopMapLen
	bl dmaCopy
	ldr r0, =VictoryTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =VictoryTopPalLen
	bl dmaCopy	
	
	@ load the glint sprites
	
	ldr r0, =VictoryStarsPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE
	bl dmaCopy

	ldr r0, =VictoryStarsTiles
	ldr r2, =VictoryStarsTilesLen
	ldr r1, =SPRITE_GFX
	bl dmaCopy		

	mov r0,#1
	ldr r1,=spriteScreen
	str r0,[r1]
	
@	ldreq r2, =GameOver_xm_gz
@	ldreq r3, =GameOver_xm_gz_size
@	bl initMusic

	bl fxFadeIn	
	
	ldmfd sp!, {r0-r10, pc}

@---------------------------			LOST LEVEL COMPLETION

updateCompletion:

	stmfd sp!, {r0-r10, lr}
	
	completionLLLoop:
	
		bl swiWaitForVBlank

		@ update goldGlints
		
		bl goldGlintInit
		
		bl drawSprite
	
		@ Check for start or A pressed
	
		ldr r2, =REG_KEYINPUT
		ldr r10,[r2]
	
		tst r10,#BUTTON_START
		beq completionEnd
		tst r10,#BUTTON_A
		beq completionEnd
	
		ldr r1,=trapStart
		mov r0,#0
		str r0,[r1]
	
		completionLLNo:

	b completionLLLoop

	completionEnd:
	
	ldr r1,=trapStart
	ldr r0,[r1]
	cmp r0,#0
	bne completionLLNo
	
@---------------------- return to title screen (or highscore at some point)
	
	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]

	ldr r1,=fadeCheck
	mov r0,#0
	str r0,[r1]
	
	mov r0,#0
	ldr r1,=spriteScreen
	str r0,[r1]

	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWait4:
	ldr r1,=fadeCheck
	ldr r1,[r1]
	cmp r1,#16
	beq jumpCompLL

	b justWait4

	jumpCompLL:

	bl findHighscore
	
	ldmfd sp!, {r0-r10, pc}
