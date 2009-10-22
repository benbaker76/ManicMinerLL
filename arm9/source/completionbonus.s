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

	bl fxFadeBlackInit
	bl fxFadeMax
	
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

	ldr r0,=BigFont2Tiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=BigFont2TilesLen
	bl decompressToVRAM

	
	mov r0,#0
	bl levelMusicPlayEasy

	@ draw the text!
	
	ldr r0,=line1								@ CONGRATS
	mov r1,#1
	mov r2,#0
	bl drawTextBigNormal
	ldr r0,=line2
	mov r2,#2
	bl drawTextBigNormal
	
	ldr r6,=unlockedBonuses
	ldr r6,[r6]									@ are there still any to find?
	cmp r6,#20
	ldreq r0,=line3all
	ldrne r0,=line3more
	mov r2,#6
	bl drawTextBigNormal
	
	@ now, have we beaten a record
	
	ldr r6,=gotRecord
	ldr r6,[r6]
	cmp r6,#1
	ldreq r0,=recordYes
	ldrne r0,=recordNo
	mov r2,#9
	bl drawTextBigNormal
	
	ldr r0,=fact
	mov r2,#13
	bl drawTextBigNormal
		
	@ draw fact (4*30 chars)
	
	bl getRandom
	and r8,#3
	
	mov r3,#120 		@ 4 lines
	mul r8,r3
	ldr r0,=facts
	add r0,r8			@ r8=first line
	
	add r2,#2
	bl drawTextBigNormal
	add r2,#2
	bl drawTextBigNormal
	add r2,#2
	bl drawTextBigNormal
	add r2,#2
	bl drawTextBigNormal
	
	bl fxFadeIn	

	@ if gotRecord=1, then a bonus time has been beaten
	
	ldmfd sp!, {r0-r10, pc}
	
@--------------------------- 			BONUS COMPLETION

updateCompletionBonus:

	stmfd sp!, {r0-r10, lr}
	
	@ Check for start or A pressed
	
	ldr r2, =REG_KEYINPUT
	ldr r10,[r2]
	
	tst r10,#BUTTON_START
	beq completionBonusEnd

	ldmfd sp!, {r0-r10, pc}

	completionBonusEnd:
	
	@ return to title screen (or highscore at some point)
	
	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]

	mov r0,#0
	ldr r1,=spriteScreen
	str r0,[r1]

	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWait4:
	ldr r1,=fxFadeBusy
	ldr r1,[r1]
	cmp r1,#0
	beq jumpCompLL

	b justWait4

	jumpCompLL:
	
	bl initTitleScreen
	
	ldmfd sp!, {r0-r10, pc}	

@-------------------
	
	.pool
	.align
	.data
line1:
	.ascii "       CONGRATULATIONS!       "
line2:
	.ascii "    BONUS LEVEL COMPLETED!    "
line3all:	@ ARE THEY ALL UNLOCKED
	.ascii "YOU HAVE FOUND ALL THE BONUS'S"
line3more:
	.ascii "CAN YOU FIND THE REST OF THEM?"
recordYes:	@ HAVE YOU GOT A RECORD?
	.ascii "WELL DONE FOR SETTING A RECORD"
recordNo:
	.ascii "CAN YOU BEAT THE RECORD SPEED?"
fact:
	.ascii "     - INTERESTING FACT -     "
	
facts:
	.ascii "THE BBC VERSION OF MANIC MINER"
	.ascii "  DOES NOT CONTAIN THE SOLAR  "
	.ascii " POWER GENERATOR, AND INSTEAD "
	.ascii "    HAS 'THE METEOR STORM'    "

	.ascii " THE ORIC VERSION OF THE GAME "
	.ascii "  WAS CONSTRUCTED FROM TILES  "
	.ascii " THAT WERE JUST 6 PIXELS WIDE "
	.ascii " OTHER VERSIONS WERE 8 PIXELS "

	.ascii "  FOR SOME REASON, THE LEVEL  "
	.ascii "'EUGENE'S LAIR IN THE CPC GAME"
	.ascii "  WAS RENAMED TO 'EUGENE WAS  "
	.ascii " HERE'. THE REASON'S UNKNOWN! "	
	
	.ascii "MANIC MINER HAS BEEN RELEASED "
	.ascii "ON NUMEROUS SYSTEMS. EVEN THE "
	.ascii "  ZX81 HAD A VERY IMPRESSIVE  "
	.ascii "VERSION WITH HIGH RES GRAPHICS"		
	
	