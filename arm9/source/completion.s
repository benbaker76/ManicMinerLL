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
	
	#define MAX_PAGES	4

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
	
	mov r0,#32
	bl levelMusicPlayEasy

	ldr r0,=BigFont2Tiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	add r1,#BigFontOffset
	ldr r2,=BigFont2TilesLen
	bl decompressToVRAM
	
	bl fxFadeIn	
	
	@ init the text
	mov r0,#0
	ldr r1,=page
	str r0,[r1]
	mov r0,#-1
	ldr r1,=pageDelay
	str r0,[r1]
	mov r0,#100
	ldr r1,=pageDelayInit
	str r0,[r1]
	
	ldr r1,=pageOffs
	mov r0,r1
	add r0,#44
	mov r2,#11*4
	bl dmaCopy
	
	ldmfd sp!, {r0-r10, pc}

@---------------------------			LOST LEVEL COMPLETION

updateCompletion:

	stmfd sp!, {r0-r10, lr}
	
	completionLLLoop:
	
		bl swiWaitForVBlank

		@ update goldGlints
		
		bl goldGlintInit
		
		bl drawSprite
		
		bl updatePages
	
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
	.pool
@-------------------------------
updatePages:	
	stmfd sp!, {r0-r10, lr}	
	
	ldr r1,=pageDelayInit
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#0
	str r2,[r1]
	bpl turnPageDone
	
	ldr r3,=page
	ldr r3,[r3]
	ldr r4,=330
	mul r3,r4
	ldr r4,=pages
	add r4,r3				@ r4=offset to first char of page
	
	mov r5,#0				@ counter for line
	mov r10,#0				@ line (add by 15 each loop)

	pageDrawLoop:
	
		ldr r6,=pageOffs
		ldr r7,[r6,r5,lsl#2]	@ r7=char across screen to draw and char in pages to grab
		cmp r7,#2
		blt pageNotYet		@ if char pos is <2, do not draw
			sub r7,#2
			ldrb r0,[r4,r7]	@ r0=char
			add r7,#1
			mov r1,r7
			mov r2,r5,lsl#1
			bl drawTextComp
		pageNotYet:
	
	add r4,#30
	add r5,#1
	cmp r5,#11
	bne pageDrawLoop
	
	ldr r1,=drawDelay
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#1
	str r2,[r1]
	bpl updatePagesDone
	
		mov r1,#10				@ offset
		mov r5,#-1				@ page delay
		ldr r2,=pageOffs
		fillLoop:
		
			ldr r3,[r2,r1,lsl#2]
			add r3,#1
			cmp r3,#31
			movge r3,#31
			ldrge r5,=600
			str r3,[r2,r1,lsl#2]
			
			subs r1,#1
		bpl fillLoop
	
		ldr r1,=pageDelay
		ldr r2,[r1]
		cmp r2,#-1
		bne updatePagesDone
		cmp r5,#-1
		beq updatePagesDone
		str r5,[r1]
	
	updatePagesDone:
	
	ldr r1,=pageDelay
	ldr r2,[r1]
	cmp r2,#-1
	beq turnPageDone
		sub r2,#1
		str r2,[r1]
		cmp r2,#0
		bne turnPageDone

		@ turn page
		
		ldr r1,=page
		ldr r3,[r1]
		add r3,#1
		cmp r3,#MAX_PAGES
		beq turnPageDone
		
		str r3,[r1]
		ldr r1,=pageOffs
		mov r0,r1
		mov r5,#44
		mul r5,r3
		add r0,r5
		add r0,#44
		mov r2,#11*4
		bl dmaCopy
		
		ldr r1,=pageDelay
		mov r0,#-1
		str r0,[r1]
	
	turnPageDone:
	
	ldmfd sp!, {r0-r10, pc}	
	.pool
	.data
	.align
	pageDelayInit:
	.word 0
	pageOffs:						@ load the sets following depending on page (+11)
	.word 0,0,0,0,0,0,0,0,0,0,0

	.word 0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10	
	.word 0,-2,-4,-6,-8,-10,-8,-6,-4,-2,0
	.word -20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0
	.word -5,-1,-6,-2,-7,-3,-8,-4,-9,-5,-10
	drawDelay:
	.word 0
	page:
	.word 0
	pageDelay:
	.word 0
	pages:
	.ascii "CONGRATULATIONS               "
	.ascii "                              "
	.ascii " YOUVE CLEARED ALL OF THE LOST"
	.ascii "ALL OF THE LOST COCK JOCKEY   "
	.ascii "A HAMSTER ONION FLAKE FELL IN "
	.ascii "MY EYE..                      "
	.ascii "       SDFSDF                 "
	.ascii "     WERWERWER                "
	.ascii "   WERWERWER                  "
	.ascii "         WCVBC                "
	.ascii "  CXCXCBXBBXXBB        PICKLES"
@
	.ascii "SO, WELL THIS IS THE THING,   "
	.ascii "IS THIS OK FOR THE COMPLETION "
	.ascii "TEXT, OR IS IT A BIT POO?     "
	.ascii "I REALLY AM NOT SURE? BUT AT  "
	.ascii "LEAST WE CAN HAVE SOME WIPES  "
	.ascii "THAT CHANGE PER PAGE I SPOSE  "
	.ascii "AND IT SHOULD GIVE PLENTY OF  "
	.ascii "ROOM FOR STUFF TO BE SAID     "
	.ascii "A BIT LIKE THIS DRIVEL THAT I "
	.ascii "AM SAYING I SUPPOSE.....      "
	.ascii "        FLASH 2009            "
@	
	.ascii "CONGRATULATIONS               "
	.ascii "                              "
	.ascii " YOUVE CLEARED ALL OF THE LOST"
	.ascii "ALL OF THE LOST COCK JOCKEY   "
	.ascii "A HAMSTER ONION FLAKE FELL IN "
	.ascii "MY EYE..                      "
	.ascii "       SDFSDF                 "
	.ascii "     WERWERWER                "
	.ascii "   WERWERWER                  "
	.ascii "         WCVBC                "
	.ascii "  CXCXCBXBBXXBB        PICKLES"
@
	.ascii "SO, WELL THIS IS THE THING,   "
	.ascii "IS THIS OK FOR THE COMPLETION "
	.ascii "TEXT, OR IS IT A BIT POO?     "
	.ascii "I REALLY AM NOT SURE? BUT AT  "
	.ascii "LEAST WE CAN HAVE SOME WIPES  "
	.ascii "THAT CHANGE PER PAGE I SPOSE  "
	.ascii "AND IT SHOULD GIVE PLENTY OF  "
	.ascii "ROOM FOR STUFF TO BE SAID     "
	.ascii "A BIT LIKE THIS DRIVEL THAT I "
	.ascii "AM SAYING I SUPPOSE.....      "
	.ascii "        FLASH 2009            "