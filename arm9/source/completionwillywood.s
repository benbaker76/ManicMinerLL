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

	.global initCompletionWillyWood
	.global updateCompletionWillyWood
	
@---------------------------			WILLYWOOD COMPLETION INIT

initCompletionWillyWood:

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
	mov r0,#GAMEMODE_COMPLETION_WILLYW
	str r0,[r1]

	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn	
	
	ldr r0,=VictoryWWBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=VictoryWWBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryWWBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =VictoryWWBottomMapLen
	bl dmaCopy
	ldr r0, =VictoryWWBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =VictoryWWBottomPalLen
	bl dmaCopy	

	ldr r0,=VictoryWWTopTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=VictoryWWTopTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryWWTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =VictoryWWTopMapLen
	bl dmaCopy
	ldr r0, =VictoryWWTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =VictoryWWTopPalLen
	bl dmaCopy	
	
@	ldreq r2, =GameOver_xm_gz
@	ldreq r3, =GameOver_xm_gz_size
@	bl initMusic
	
	ldmfd sp!, {r0-r10, pc}
@----------------------------------
updateCompletionWillyWood:

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
