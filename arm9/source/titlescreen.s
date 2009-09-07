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


	.global initTitleScreen
	.global updateTitleScreen

@----------------------------

initTitleScreen:
	stmfd sp!, {r0-r10, lr}

	mov r0,#0							@ set level to 0 for start of game
	ldr r1,=levelNum
	str r0,[r1]

	bl initVideo

	bl clearBG0
	bl clearBG0
	bl clearBG0
	bl clearBG0

	mov r1, #GAMEMODE_TITLE_SCREEN
	ldr r2, =gameMode
	str r1,[r2]
	
	bl titleMainScreen					@ draw our title top screen	

	@ now, what for the bottom screen??????
	
	bl titleBottomScreen
	
	ldr r1,=Miner_xm
	bl initMusic

	ldmfd sp!, {r0-r10, pc}

@----------------------------
titleBottomScreen:

	stmfd sp!, {r0-r10, lr}

	@ draw our title to sub
	
	ldr r0,=BotMenuTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=BotMenuTilesLen
	bl decompressToVRAM	
	ldr r0, =BotMenuMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =BotMenuMapLen
	bl dmaCopy
	ldr r0, =BotMenuPal
	ldr r1, =BG_PALETTE
	ldr r2, =BotMenuPalLen
	bl dmaCopy
	
	
	ldmfd sp!, {r0-r10, pc}	

@----------------------------
titleMainScreen:

	stmfd sp!, {r0-r10, lr}

	@ draw our title to sub
	
	ldr r0,=TopMenuTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=TopMenuTilesLen
	bl decompressToVRAM	
	ldr r0, =TopMenuMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =TopMenuMapLen
	bl dmaCopy
	ldr r0, =TopMenuPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =TopMenuPalLen
	bl dmaCopy
	
	bl clearSpriteData
	
	ldmfd sp!, {r0-r10, pc}	
	
@----------------------------
titleGameScreen:

	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=StatusTiles							@ copy the tiles used for status and air
	ldr r1,=BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2,=StatusTilesLen
	bl dmaCopy

	ldr r0,=BigFontTiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	add r1,#StatusTilesLen
	ldr r2,=BigFontTilesLen
	bl decompressToVRAM

	bl initSprites

	bl initLevel

	ldmfd sp!, {r0-r10, pc}	

@----------------------------

updateTitleScreen:

	stmfd sp!, {r0-r10, lr}

	titleScreenTimer:

	ldr r10,=levelNum
	ldr r10,[r10]

	cmp r10,#0				@ set timer, 0=title, 1+= ingame
	ldreq r8,=400
	ldrne r8,=100

	titleScreenLoop:
	
		bl swiWaitForVBlank

		ldr r10,=levelNum
		ldr r10,[r10]	
		cmp r10,#0						@ level 0 is out title bitmap
		beq titleIsBitmap
	
		ldr r0,=minerDelay
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
		bne skipTitleFrame
		
			bl monsterMove
		
		skipTitleFrame:

		bl levelAnimate
		bl updateSpecialFX
		
		titleIsBitmap:

		bl drawSprite
		
		@ check for fire
		
		ldr r2, =REG_KEYINPUT						@ Read key input register
		ldr r3, [r2]								@ Read key value
		tst r3,#BUTTON_START
		beq titleGameStart

	subs r8,#1
	
	bne titleScreenLoop
	
titleNextScreen:
	
		ldr r0,=levelNum		@ add to level number
		ldr r1,[r0]
		add r1,#1			
		cmp r1,#22
		moveq r1,#0				
		beq skipMissLevels
		cmp r1,#LEVEL_COUNT
		movgt r1,#21
		skipMissLevels:
		str r1,[r0]

		cmp r1,#0				@ level 0 is used to title screen graphic
		blne titleGameScreen
		bleq titleMainScreen
		bleq initVideoTitle

		
	b titleScreenTimer

titleGameStart:

	mov r1, #GAMEMODE_RUNNING
	ldr r2, =gameMode
	str r1,[r2]
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
@	bl stopMusic				@ WHY does this crash it????????????????????
	
	bl initVideo
	bl initSprites

	bl specialFXStop

	bl initGame
	
	ldmfd sp!, {r0-r10, pc}