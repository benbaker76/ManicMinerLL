@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"),  the rights to use, copy, modify, merge, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software both source and
@ the compiled code.
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

	.arm
	.align
	.text

	#define KILLDROP			#206
	#define KILLSOUND			#230
	#define WILLY_WALKS			284
	#define TOTALANIMS			13

	.global initGameOver
	.global updateGameOverScreen
	.global updateGameOver
	
@---------------------------					@ init the static screen for music

initGameOverScreen:

	stmfd sp!, {r0-r10, lr}
	
	@ first, we need to fade all out
	
	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWaitForIt:
	ldr r1,=fxFadeBusy
	ldr r1,[r1]
	cmp r1,#0
	bne justWaitForIt

	bl resetScrollRegisters

	lcdMainOnBottom
	
	bl fxFadeBlackInit
	bl fxFadeMax
	bl initVideoMain

	bl clearBG1
	bl clearOAM
	bl clearSpriteData

	ldr r1,=gameMode
	mov r0,#GAMEMODE_GAMEOVER_SCREEN			@ this is our "wait and music" screen
	str r0,[r1]

	ldr r0,=EndBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=EndBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =EndBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =EndBottomMapLen
	bl dmaCopy
	ldr r0, =EndBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =EndBottomPalLen
	bl dmaCopy	

	ldr r0,=EndTopTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=EndTopTilesLen
	bl decompressToVRAM	
	ldr r0, =EndTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =EndTopMapLen
	bl dmaCopy
	ldr r0, =EndTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =EndTopPalLen
	bl dmaCopy	
	
	mov r0,#-1
	ldr r1,=skullFrameOver
	str r0,[r1]
	ldr r1,=skullDelayOver
	str r0,[r1]
	mov r0,#1
	ldr r1,=trapStart
	str r0,[r1]

	bl fxFadeIn	
	
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------							update static screen with music

updateGameOverScreen:

	stmfd sp!, {r0-r10, lr}
	
	bl animateGameOverSkull
	
	@ Check for start or A pressed
	
	ldr r2, =REG_KEYINPUT
	ldr r10,[r2]
	
	tst r10,#BUTTON_START
	beq gOverEnd
	tst r10,#BUTTON_A
	beq gOverEnd

	ldmfd sp!, {r0-r10, pc}

	gOverEnd:
	
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

	justWait0:
		bl swiWaitForVBlank		
		bl animateGameOverSkull	
	
		ldr r1,=fxFadeBusy
		ldr r1,[r1]
		cmp r1,#0
	bne justWait0

	bl findHighscore
	
	ldmfd sp!, {r0-r10, pc}

@--------------------------

animateGameOverSkull:	
	
	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=skullDelayOver
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#8
	str r1,[r0]
	bpl animateGameOverSkullDone
	
	ldr r0,=skullFrameOver
	ldr r8,[r0]
	add r8,#1
	cmp r8,#10
	moveq r8,#0
	str r8,[r0]
	
	@ r8=frame

	mov r1,#3
	mul r8,r1						@ banks of 3
	lsl r8,#1

	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)
	add r0, #1536					@ first tile of offscreen tiles (bottom left)
	add r0, r8						@ add 8 chars (8th along is our blank)
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)
	add r1,#(32*4)*2
	add r1,#15*2
	mov r2,#6
	
	mov r8,#2
	overSkullLoop:
	
	bl dmaCopy
	add r0,#64
	add r1,#64
	subs r8,#1
	bpl overSkullLoop
	
	animateGameOverSkullDone:
	ldmfd sp!, {r0-r10, pc}
@---------------------------					@ init the death animatiob 'here'

initGameOver:

	stmfd sp!, {r0-r10, lr}

	bl fxFadeBlackInit
	bl fxFadeMax
	
	lcdMainOnBottom

	bl clearOAM
	bl clearSpriteData
	bl initVideoGameOver	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3

	mov r8,#192
	ldr r6,=killPixelH
	str r8,[r6]
	ldr r6,=killPixelH2
	str r8,[r6]

	ldr r5, =REG_BG1VOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	strh r8, [r5]					@ Write our offset value to REG_BG2HOFS_SUB
	ldr r5, =REG_BG1VOFS			@ Load our horizontal scroll register for BG2 on the sub screen
	strh r8, [r5]					@ Write our offset value to REG_BG2HOFS_SUB

	ldr r1,=gameMode
	mov r0,#GAMEMODE_GAMEOVER					@ this is our Animation
	str r0,[r1]
	
	@ use these 2 screens for now
	
	ldr r0,=EndBotSplatTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=EndBotSplatTilesLen
	bl decompressToVRAM	
	ldr r0, =EndBotSplatMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =EndBotSplatMapLen
	bl dmaCopy
	ldr r0, =EndBotSplatPal
	ldr r1, =BG_PALETTE
	ldr r2, =EndBotSplatPalLen
	bl dmaCopy	

	ldr r0,=EndTopSplatTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=EndTopSplatTilesLen
	bl decompressToVRAM	
	ldr r0, =EndTopSplatMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =EndTopSplatMapLen
	bl dmaCopy
	ldr r0, =EndTopSplatPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =EndTopSplatPalLen
	bl dmaCopy	
	
	@ cycle through anims

	ldr r0,=deathAnimation
	ldr r8,[r0]
	add r8,#1
	cmp r8,#TOTALANIMS+1
	moveq r8,#0
	str r8,[r0]

	cmp r8,#0
	ldreq r0,=EndBootTiles
	ldreq r2,=EndBootTilesLen
	ldreq r3,=EndBootMap
	cmp r8,#1
	ldreq r0,=EndFridgeTiles
	ldreq r2,=EndFridgeTilesLen
	ldreq r3,=EndFridgeMap
	cmp r8,#2
	ldreq r0,=EndPooTiles
	ldreq r2,=EndPooTilesLen
	ldreq r3,=EndPooMap
	cmp r8,#3
	ldreq r0,=EndPianoTiles
	ldreq r2,=EndPianoTilesLen
	ldreq r3,=EndPianoMap	
	cmp r8,#4
	ldreq r0,=EndCaseTiles
	ldreq r2,=EndCaseTilesLen
	ldreq r3,=EndCaseMap
	cmp r8,#5
	ldreq r0,=EndAnvilTiles
	ldreq r2,=EndAnvilTilesLen
	ldreq r3,=EndAnvilMap	
	cmp r8,#6
	ldreq r0,=EndMorrisseyTiles
	ldreq r2,=EndMorrisseyTilesLen
	ldreq r3,=EndMorrisseyMap	
	cmp r8,#7
	ldreq r0,=EndLooTiles
	ldreq r2,=EndLooTilesLen
	ldreq r3,=EndLooMap	
	cmp r8,#8
	ldreq r0,=EndMaidTiles
	ldreq r2,=EndMaidTilesLen
	ldreq r3,=EndMaidMap	
	cmp r8,#9
	ldreq r0,=EndEasterTiles
	ldreq r2,=EndEasterTilesLen
	ldreq r3,=EndEasterMap	
	cmp r8,#10
	ldreq r0,=EndStarTrekTiles
	ldreq r2,=EndStarTrekTilesLen
	ldreq r3,=EndStarTrekMap	
	cmp r8,#11
	ldreq r0,=EndMaxTiles
	ldreq r2,=EndMaxTilesLen
	ldreq r3,=EndMaxMap	
	cmp r8,#12
	ldreq r0,=EndTardisTiles
	ldreq r2,=EndTardisTilesLen
	ldreq r3,=EndTardisMap	
	cmp r8,#13
	ldreq r0,=EndBusTiles
	ldreq r2,=EndBusTilesLen
	ldreq r3,=EndBusMap		
	
	ldr r1,=BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	bl decompressToVRAM
	ldr r1,=BG_TILE_RAM(BG1_TILE_BASE)
	bl decompressToVRAM

	mov r0,r3
	ldr r2,=EndBootMapLen
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	bl dmaCopy		
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)
	bl dmaCopy
	
	mov r0,#0
	ldr r1,=killMotion
	str r0,[r1]
	ldr r0,=500
	ldr r1,=killDelay
	str r0,[r1]
	mov r0,#1
	ldr r1,=trapStart
	str r0,[r1]
	mov r0,#0
	ldr r1,=killMinerX
	str r0,[r1]
	ldr r1,=kneeDelay
	str r0,[r1]
	mov r0,#12
	ldr r1,=kneeFrame
	str r0,[r1]	
	mov r0,#1
	ldr r1,=killMinerMotion
	str r0,[r1]
	ldr r1,=spriteScreen
	str r0,[r1]	
	
	@ ok, init willys sprite
	
	mov r10,#0
	
	ldr r0,=spriteActive
	mov r1,#1
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteX
	mov r1,#0
	str r1,[r0,r10,lsl#2]	
	ldr r0,=spriteY
	mov r1,#144+384
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteObj
	mov r1,#0
	str r1,[r0,r10,lsl#2]
	ldr r0,=spritePriority
	mov r1,#2
	str r1,[r0,r10,lsl#2]	
	
	add r10,#1
	
	ldr r0,=spriteActive
	mov r1,#1
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteX
	mov r1,#0
	str r1,[r0,r10,lsl#2]	
	ldr r0,=spriteY
	mov r1,#160+384
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteObj
	mov r1,#2
	str r1,[r0,r10,lsl#2]
	ldr r0,=spritePriority
	mov r1,#2
	str r1,[r0,r10,lsl#2]
	
	@ now load the sprite data for willy
	
	ldr r0,=DieGameOverTiles
	ldr r1,=SPRITE_GFX
	ldr r2,=11*256							@ first 11 sprites for anim
	bl dmaCopy	
	ldr r0, =DieGameOverPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE
	bl dmaCopy	

	ldr r0,=DieGameOverTiles				@ copy blood splats
	add r0,#11*256							@ 12th tile
	ldr r1,=SPRITE_GFX
	add r1,#40*256							@ dump at 40th sprite onwards
	ldr r2,=8*256
	bl dmaCopy

	ldr r0,=DieGameOverTiles
	add r0,#20*256
	ldr r1,=SPRITE_GFX
	add r1,#12*256							@ dump at sprite 12 -19
	ldr r2,=8*256							@ 8 sprites for anim
	bl dmaCopy
	
	mov r0,#128+56+8
	ldr r1,=exitX
	str r0,[r1]
	mov r0,#384+160+8
	add r0,#4
	ldr r1,=exitY
	str r0,[r1]
	
	mov r0,#27						@ play gameover musi
	bl levelMusicPlayEasy
	
	mov r1,#192
	ldr r5, =REG_BG3VOFS_SUB		@ Load our horizontal scroll register for BG3 on the sub screen
	strh r1, [r5]					@ Write our offset value to REG_BG3HOFS_SUB			

	ldr r5, =REG_BG3VOFS			@ Load our horizontal scroll register for BG3 on the sub screen
	strh r1, [r5]

	bl fxFadeIn	

	ldmfd sp!, {r0-r10, pc}
@--------------------------						@ do the death animation

updateGameOver:	
	
	stmfd sp!, {r0-r10, lr}

	ldr r10,=350
	
	updateGameOverLoop:
	
		cmp r10,KILLDROP					@ timer to drop something
		ldreq r1,=killMotion
		moveq r2,#1
		streq r2,[r1]
		cmp r10,KILLSOUND
		bleq playFallThing
	
		bl swiWaitForVBlank	

		bl moveKiller
		bl moveKillerMiner
		bl drawSprite
		bl fxMoveBloodburst
		bl dropWobbler
	
		@ check if start is press and if so, return to title (well, highscore when done)

		ldr r2, =REG_KEYINPUT
		ldr r2,[r2]
		tst r2,#BUTTON_START
		bne updateGO
		
		ldr r2, =trapStart
		ldr r1, [r2]
		mov r3, #0
		cmp r1, #1
		streq r3, [r2]
		beq updateGO
		
		b gOverUpdateEnd
		
		updateGO:

		subs r10,#1
		cmp r10,#-70
		
	bpl updateGameOverLoop
		
	@------------------------- ok, jump to gameover screens

	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]

	mov r0,#0
	ldr r1,=spriteScreen
	str r0,[r1]

	bl initGameOverScreen

	ldmfd sp!, {r0-r10, pc}
	
	@------------------------- ok, straight jump to title

	gOverUpdateEnd:
	
	@ return to title screen (via highscore)

	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWait:
		bl swiWaitForVBlank	
		bl drawSprite
		bl fxMoveBloodburst
	
		ldr r1,=fxFadeBusy
		ldr r1,[r1]
		cmp r1,#0
	bne justWait

	mov r0,#0
	ldr r1,=spriteScreen
	str r0,[r1]

	bl findHighscore
	
	ldmfd sp!, {r0-r10, pc}
	
@--------------------------						@ drop the killer Object

moveKiller:	
	
	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=killMotion
	ldr r0,[r0]
	cmp r0,#0
	beq moveKillerDone
	
		ldr r0,=killPixelH			@ top
		ldr r1,[r0]
		sub r1,#8
		cmp r1,#-192
		movle r1,#-192
		str r1,[r0]
		ldr r5, =REG_BG1VOFS_SUB		
		strh r1, [r5]				

		cmp r1,#-32
		ldr r0,=killPixelH2			@ bottom
		ldr r1,[r0]
		suble r1,#8
		cmp r1,#14
		movle r1,#14
		str r1,[r0]
		ldr r5, =REG_BG1VOFS		
		strh r1, [r5]			
	
		cmp r1,#14
		bne moveKillerDone
			bl playSplat	
			ldr r0,=killMotion
			mov r1,#0
			str r1,[r0]
			
			ldr r0,=spriteActive
			str r1,[r0]
			ldr r0,=spriteActive+4
			str r1,[r0]
	
			@ initialise a rumble on both bg1 and bg3 (sub and main)
			
			ldr r1,=dropWobble
			mov r0,#512
			sub r0,#9
			str r0,[r1]
			
			@ initialise blood splats
			
			mov r0,#127
			mov r1,#0
			ldr r2,=spriteActive
			clearSplats:
			str r1,[r2,r0,lsl#2]
			subs r0,#1
			bpl clearSplats
			
			bl fxBloodburstInit
			
			@ play a splat sound
			
			bl playSplat
	
	moveKillerDone:
	
	ldmfd sp!, {r0-r10, pc}	

@--------------------------						@ move and animate willy onto the screen

moveKillerMiner:	
	
	stmfd sp!, {r0-r10, lr}	
	ldr r0,=spriteActive
	ldr r0,[r0]
	cmp r0,#1
	bne moveMinerDone
	
	ldr r0,=killMinerMotion
	ldr r0,[r0]
	cmp r0,#0
	beq moveMinerDone
	cmp r10,#WILLY_WALKS
	bpl moveMinerDone
	
		ldr r0,=killMinerX
		ldr r1,[r0]
		add r1,#2
		cmp r1,#128+56
		movpl r1,#128+56
		str r1,[r0]
		
		cmp r1,#120
		
			ldreq r0,=spriteObj
			moveq r3,#1
			streq r3,[r0]

		cmp r1,#128+16
		
			ldreq r0,=spriteObj
			moveq r3,#2
			streq r3,[r0]
			
		cmp r1,#128+56
		bne notKnockingKnees
		
			@ ok, animate the knees knocking. kneeFrame, and kneeDelay (19-26)
			ldr r0,=kneeFrame
			ldr r1,[r0]
			ldr r2,=spriteObj+4
			str r1,[r2]
			ldr r3,=kneeDelay
			ldr r4,[r3]
			subs r4,#1
			movmi r4,#1
			str r4,[r3]
			bpl moveMinerDone
		
			add r1,#1
			cmp r1,#19
			movpl r1,#12
			str r1,[r0]
			
			b moveMinerDone
			
		notKnockingKnees:
		ldr r2,=spriteX
		str r1,[r2]
		ldr r2,=spriteX+4
		str r1,[r2]	

		@ animate legs (sprites 2-9 on sprite 2)

		ldr r0,=spriteX+4
		ldr r0,[r0]
		
		and r0,#63
		lsr r0,#3

		ldr r2,=spriteObj+4
		add r0,#3
		str r0,[r2]	

		cmp r1,#128+56
		bne moveMinerDone
			ldr r0,=killMinerMotion
			mov r1,#0
			str r1,[r0]
			ldr r0,=spriteObj
			mov r3,#2
			str r3,[r0]
	moveMinerDone:
	
	ldmfd sp!, {r0-r10, pc}	

@--------------------------	

dropWobbler:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=dropWobble
	ldr r0,[r1]
	cmp r0,#0
	beq dropWobblerDone

		add r0,#1
		cmp r0,#512
		moveq r0,#0
		str r0,[r1]
		mov r2,r0
		add r2,#512+16		
		ldr r5, =REG_BG1VOFS			@ splatThing
		strh r2, [r5]				
		add r0,#192
		ldr r5, =REG_BG3VOFS_SUB   		@ Background
		strh r0, [r5]					@ Write our offset value to REG_BG2HOFS_SUB	
		ldr r5, =REG_BG3VOFS    		@ Background
		strh r0, [r5]					@ Write our offset value to REG_BG2HOFS_SUB	
	
	dropWobblerDone:
	
	ldmfd sp!, {r0-r10, pc}	

.data

skullFrameOver:
.word 0
skullDelayOver:
.word 0
killPixelH:
.word 0
killPixelH2:
.word 0
killDelay:
.word 0
killMotion:
.word 0
killMinerX:
.word 0
killMinerMotion:
.word 0
dropWobble:
.word 0
kneeFrame:
.word 0
kneeDelay:
.word 0