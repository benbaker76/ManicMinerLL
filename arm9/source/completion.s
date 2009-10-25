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
	bl clearBG3
	bl clearOAM
	bl clearSpriteData
	bl stopMusic					@ remove when we have completion music

	ldr r1,=gameMode
	mov r0,#GAMEMODE_COMPLETION
	str r0,[r1]

	bl fxFadeBlackInit
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
	
	mov r0,#34
	bl levelMusicPlayEasy

	ldr r0,=BigFont2Tiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=BigFont2TilesLen
	bl decompressToVRAM

	ldr r0, =SpritesPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =FXSprinkleTiles
	ldr r2, =FXSprinkleTilesLen
	ldr r1, =SPRITE_GFX_SUB
	bl dmaCopy

	
	bl fxFadeIn	
	
	@ init the text
	mov r0,#0
	ldr r1,=page
	str r0,[r1]
	mov r0,#-1
	ldr r1,=pageDelay
	str r0,[r1]
	mov r0,#250
	ldr r1,=pageDelayInit
	str r0,[r1]
	
	ldr r1,=pageOffs
	mov r0,r1
	add r0,#44
	mov r2,#11*4
	bl dmaCopy
	
	
	ldr r1,=unlockedHW
	mov r2,#1
	str r2,[r1]						@ unlock WillyWood
	
	bl saveGame
	
	ldmfd sp!, {r0-r10, pc}

@---------------------------			LOST LEVEL COMPLETION

updateCompletion:

	stmfd sp!, {r0-r10, lr}
	
	completionLLLoop:
	
		bl swiWaitForVBlank

		bl goldGlintInit
		
		bl drawSprite
		bl drawSpriteSub
		
		bl updatePages
	
		@ Check for start or A pressed
	
		ldr r2, =REG_KEYINPUT
		ldr r10,[r2]
	
		tst r10,#BUTTON_START
		beq completionEnd


		tst r10,#BUTTON_L
		beq skipBack
		tst r10,#BUTTON_LEFT
		beq skipBack
		tst r10,#BUTTON_R
		beq skipForward
		tst r10,#BUTTON_RIGHT
		beq skipForward		
		b skipNone
		
		skipBack:
			@ back a page
			ldr r2,=pageDelay
			ldr r1,[r2]
			cmp r1,#-1
			beq skipNone
			cmp r1,#880
			bpl skipNone
			ldr r1,=page
			ldr r3,[r1]
			subs r3,#1
			bmi skipNone
			str r3,[r1]
			bl changePage			
		skipForward:
			@ forward a page
			ldr r2,=pageDelay
			ldr r1,[r2]
			cmp r1,#-1
			beq skipNone
			cmp r1,#880
			bpl skipNone
			ldr r1,=page
			ldr r3,[r1]
			add r3,#1
			cmp r3,#MAX_PAGES
			beq skipNone
			str r3,[r1]
			bl changePage
		
		skipNone:
	
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
	
@---------------------- return to title screen & Highscore
	
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
		bl swiWaitForVBlank
		bl goldGlintInit	
		bl drawSprite
		bl drawSpriteSub
		bl updatePages	
		ldr r1,=fxFadeBusy
		ldr r1,[r1]
		cmp r1,#0
	bne justWait4

	bl findHighscore
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------
changePage:
	
	stmfd sp!, {r0-r10, lr}	

	b pageTurner

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
			mov r1,r7		@ r1=x
			mov r2,r5,lsl#1	@ r2=y
			cmp r0,#32
			blne sprinkles	@ ok, using r1,r2 as x,y.. Draw sprinkles
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
			ldrge r5,=925	@ 550 best?
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
			cmp r3,#MAX_PAGES
			bge turnPageDone
		
			str r3,[r1]			@ reset pageoffs!

		pageTurner:

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

sprinkles:

	stmfd sp!, {r0-r10, lr}	
	
	@ activate sprinkles at r1,r2 on sub screen (10 per line?)
	cmp r1,#30
	bge noSprinkle
	bl getRandom
	and r8,#1
	cmp r8,#1
	bge noSprinkle	
	
	
	bl spareSpriteSub
	
	ldr r3,=spriteActiveSub
	mov r4,#1
	str r4,[r3,r10,lsl#2]
	
	lsl r1,#3
	add r1,#64-4
	bl getRandom
	and r8,#7
	add r1,r8
lsl r1,#12
	ldr r3,=spriteXSub
	str r1,[r3,r10,lsl#2]
	
	lsl r2,#3
	add r2,#384
	add r2,#4
	bl getRandom
	and r8,#7
	add r2,r8
lsl r2,#12
	ldr r3,=spriteYSub
	str r2,[r3,r10,lsl#2]	
	
	mov r4,#0
	ldr r3,=spriteObjSub
	str r4,[r3,r10,lsl#2]
	
	mov r4,#4
	bl getRandom
	and r8,#3
	add r4,r8
	ldr r3,=spriteAnimDelaySub
	str r4,[r3,r10,lsl#2]
	ldr r3,=spriteMaxSub
	str r4,[r3,r10,lsl#2]	
	
	bl getRandom
	ldr r7,=0xfff
	and r8,r7
	add r8,#2048
	ldr r3,=spriteMinSub
	str r8,[r3,r10,lsl#2]
	
	noSprinkle:
	ldmfd sp!, {r0-r10, pc}	

	
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
	.ascii "       CONGRATULATIONS!       "
	.ascii "                              "
	.ascii "WILLY HURTLED THROUGH THE WARP"
	.ascii "PORTAL AND BACK TO EARTH. UPON"
	.ascii "ARRIVAL HE IMMEDIATELY ALERTED"
	.ascii "THE AUTHORITIES, WHEREUPON THE"
	.ascii "ARMY BLEW UP HIS HOUSE TO SEAL"
	.ascii "THE GATEWAY CLOSED FOREVER.   "
	.ascii "                              "
	.ascii "WILLY WAS UNDERSTANDABLY A BIT"
	.ascii "UPSET AT THIS TURN OF EVENTS. "
@
	.ascii "HIS ATTITUDE IMPROVED QUICKLY,"
	.ascii "HOWEVER, ON SEEING THE MANSION"
	.ascii "A GRATEFUL NATION HAD DECIDED "
	.ascii "TO BESTOW ON HIM AS REWARD FOR"
	.ascii "HIS HEROIC DEEDS.             "
	.ascii "                              "
	.ascii "(INDEED, WILLY WAS SO PLEASED "
	.ascii "THAT HE BARELY EVEN HEARD THE "
	.ascii "GENERAL MENTION THE TELEPORTER"
	.ascii "IN THE UPPER EAVES, LEADING TO"
	.ascii "A SECRET LUNAR DEFENCE BASE.) "

@
	.ascii "AS THE GOVERNMENT CARS AT LAST"
	.ascii "DROVE AWAY, WILLY CLIMBED INTO"
	.ascii "HIS LUXURIOUS NEW FOUR-POSTER "
	.ascii "BED. HE WAS EXHAUSTED FROM HIS"
	.ascii "EXERTIONS, AND HIS MIND RACED "
	.ascii "AS HE RECALLED HIS INCREDIBLE,"
	.ascii "IMPOSSIBLE EXPLOITS.          "
	.ascii "                              "
	.ascii "HIS THOUGHTS TURNED TO SOME OF"
	.ascii "HUMANITY'S OTHER GREAT DRAMAS "
	.ascii "AS HE DRIFTED OFF TO SLEEP... "

@
	.ascii "MANIC MINER IN THE LOST LEVELS"
	.ascii "                              "
	.ascii "         CODE - FLASH         "
	.ascii "      SUPPORT - HEADKAZE      "
	.ascii "        VISUALS - LOBO        "
	.ascii "     MUSIC - SPACEFRACTAL     "
	.ascii "   CONCEPT, WORDS - REV.STU   "
	.ascii "                              "
	.ascii "            # 2009            "
	.ascii "                              "
	.ascii " MANIC MINER BY MATTHEW SMITH "