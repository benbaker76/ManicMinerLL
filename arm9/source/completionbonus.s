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

	.global initCompletionBonus
	.global updateCompletionBonus
	
@---------------------------				BONUS LEVEL COMPLETION INIT

initCompletionBonus:

	stmfd sp!, {r0-r10, lr}

	lcdMainOnBottom
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	bl clearOAM
	bl clearSpriteData
	bl stopMusic					@ remove when we have completion music

	ldr r1,=gameMode
	mov r0,#GAMEMODE_COMPLETION_BONUS
	str r0,[r1]

	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn	
	
	ldr r0,=VictoryBonusBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=VictoryBonusBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryBonusBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =VictoryBonusBottomMapLen
	bl dmaCopy
	ldr r0, =VictoryBonusBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =VictoryBonusBottomPalLen
	bl dmaCopy	

	ldr r0,=VictoryBonusTopTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=VictoryBonusTopTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryBonusTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =VictoryBonusTopMapLen
	bl dmaCopy
	ldr r0, =VictoryBonusTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =VictoryBonusTopPalLen
	bl dmaCopy	
	
@	mov r0,#?
@	bl levelMusicPlayEasy
	
	ldmfd sp!, {r0-r10, pc}
	
@--------------------------- 			BONUS COMPLETION

updateCompletionBonus:

	stmfd sp!, {r0-r10, lr}
	
	@ Check for start or A pressed
	
	ldr r2, =REG_KEYINPUT
	ldr r10,[r2]
	
	tst r10,#BUTTON_START
	beq completionBonusEnd
	tst r10,#BUTTON_A
	beq completionBonusEnd

	ldmfd sp!, {r0-r10, pc}

	completionBonusEnd:
	
	@ return to title screen (or highscore at some point)
	
	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]
	
	bl initTitleScreen
	
	ldmfd sp!, {r0-r10, pc}	
