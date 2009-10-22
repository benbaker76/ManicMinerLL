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
	
	#define	 MAX_PAGES_WW	4
	
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

	ldr r0,=BigFont2Tiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=BigFont2TilesLen
	bl decompressToVRAM

	ldr r0, =SpritesPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy
	
	ldr r0, =FXSprinkleTiles
	ldr r2, =FXSprinkleTilesLen
	ldr r1, =SPRITE_GFX_SUB
	bl dmaCopy
	
	mov r0,#32
	bl levelMusicPlayEasy

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
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r10, pc}
@----------------------------------
updateCompletionWillyWood:

	stmfd sp!, {r0-r10, lr}
	
	willyWoodLoop:				@ main loop
	
		bl swiWaitForVBlank	
		
		bl updatePages
	
		bl drawSpriteSub	
	
		@ Check for start or A pressed
	
		ldr r2, =REG_KEYINPUT
		ldr r10,[r2]
	
		tst r10,#BUTTON_START
		beq completionWWEnd

		ldr r1,=trapStart
		mov r0,#0
		str r0,[r1]

		willyWoodReturn:

	b willyWoodLoop
		
	completionWWEnd:
	
	ldr r1,=trapStart
	ldr r0,[r1]
	cmp r0,#0
	bne willyWoodReturn

@-----------------	Return to title
	
	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]

	mov r0,#0
	ldr r1,=spriteScreen
	str r0,[r1]

	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWait:
	ldr r1,=fxFadeBusy
	ldr r1,[r1]
	cmp r1,#0
	beq jumpComp

	b justWait

	jumpComp:

	bl findHighscore
	
	ldmfd sp!, {r0-r10, pc}
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
			mov r1,r7		@ r1=x
			mov r2,r5,lsl#1	@ r2=y
			cmp r0,#32
		@	blne sprinkles	@ ok, using r1,r2 as x,y.. Draw sprinkles
			bl drawTextComp
		pageNotYet:
		add r4,#30				@ chars per line
		add r5,#1				@ down a line
		cmp r5,#11				@ have we done all 11?
	bne pageDrawLoop
	
	ldr r1,=drawDelay
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#1
	str r2,[r1]
	bpl updatePagesDone
		@ update to next char along on each line
		mov r1,#10				@ offset
		mov r5,#-1				@ page delay (for turn page)
		ldr r2,=pageOffs

		fillLoop:		
			ldr r3,[r2,r1,lsl#2]
			adds r3,#1
			cmp r3,#31
			movge r3,#31
			ldrge r5,=725	@ 550 best?
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

			ldr r1,=page	@ turn page
			ldr r3,[r1]
			add r3,#1
			cmp r3,#MAX_PAGES_WW
			beq turnPageDone
		
			str r3,[r1]			@ reset pageoffs!
			ldr r1,=pageOffs
			mov r5,#44
			mul r3,r5
			mov r0,r1	@ ro=dest
			add r1,r3	@ r1=src
			add r1,#44
			mov r2,#10	@ counter
			pageReset:
				ldr r3,[r1,r2,lsl#2]
				str r3,[r0,r2,lsl#2]
				subs r2,#1
			bpl pageReset

			ldr r1,=pageDelay	@ reset page delay
			mov r0,#-1
			str r0,[r1]
	
	turnPageDone:
	
	ldmfd sp!, {r0-r10, pc}	
	
@--------------------------------
@-----------------

	stmfd sp!, {r0-r10, lr}		
	
	
	
	ldmfd sp!, {r0-r10, pc}	
	
	
@-----------------	
	.pool
	.data
	.align
	pageDelayInit:
	.word 0
	pageOffs:						@ load the sets following depending on page (+11)
	.word 0,0,0,0,0,0,0,0,0,0,0

	.word 0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10	
	.word -5,-1,-6,-2,-7,-3,-8,-4,-9,-5,-10
	.word -20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0
	.word -5,-1,-6,-2,-7,-3,-8,-4,-9,-5,-10
	.word 0,0,-4,-4,-8,-8,-12,-12,-16,-16,-20
	drawDelay:
	.word 0
	page:
	.word 0
	pageDelay:
	.word 0
	pages:
	.ascii "WILLY AWOKE WITH A START, AND "
	.ascii "WAS CONFUSED TO FIND HIS FACE "
	.ascii "DRENCHED IN WATER AND A BURLY "
	.ascii "ITALIAN-LOOKING WOMAN STANDING"
	.ascii "OVER HIM, WITH AN EMPTY GLASS "
	.ascii "IN HER HAND AND A FORBIDDING  "
	.ascii "EXPRESSION ON HER FACE.       "
	.ascii "                              "
	.ascii "WIPING HIS FACE WITH A PYJAMA "
	.ascii "SLEEVE, HE MANAGED TO SPLUTTER"
	.ascii "'WHO THE HECK ARE YOU?'       "
@
	.ascii "'MARIA, YOUR NEW HOUSEKEEPER',"
	.ascii "REPLIED THE FIGURE, WHO BECAME"
	.ascii "MORE AND MORE FRIGHTENING THE "
	.ascii "MORE THAT WILLY'S BLEARY EYES "
	.ascii "WERE ABLE TO FOCUS ON HER.    "
	.ascii "                              "
	.ascii "MARIA EXPLAINED HOW SHE'D BEEN"
	.ascii "BEEN SENT BY THE GOVERNMENT TO"
	.ascii "HELP WILLY GET OVER THE TRAUMA"
	.ascii "OF HIS EXPERIENCE, AND TO HELP"
	.ascii "HIM ADJUST TO HIS NEW LIFE.   "
@
	.ascii "AS HIS STRANGE DREAMS DRIFTED "
	.ascii "FROM MEMORY AND REALITY BEGAN "
	.ascii "TO ASSERT ITSELF AGAIN, WILLY "
	.ascii "PONDERED RUEFULLY WHETHER HE'D"
	.ascii "RATHER FACE THIS INTIMIDATING "
	.ascii "WOMAN OR BE BACK ON THE ALIEN "
	.ascii "PLANET WITH THE MONSTERS.     "
	.ascii "                              "
	.ascii "HE DECIDED TO DELAY MAKING HIS"
	.ascii "MIND UP FOR CERTAIN UNTIL HE'D"
	.ascii "EXPLORED HIS NEW MANSION...   "

@
	.ascii "  MANIC MINER IN WILLYWORLD   "
	.ascii "                              "
	.ascii "        CODE - FLASH          "
	.ascii "     SUPPORT - HEADKAZE       "
	.ascii "       VISUALS - LOBO         "
	.ascii "    SOUNDS - SPACEFRACTAL     "
	.ascii "       WORDS - REV.STU        "
	.ascii "                              "
	.ascii "         (C) 2009             "
	.ascii "                              "
	.ascii " MANIC MINER BY MATTHEW SMITH "