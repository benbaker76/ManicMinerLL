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
	.global tScrollChar
	.global tScrollSegment
	.global tScrollText

@----------------------------

initTitleScreen:
	stmfd sp!, {r0-r10, lr}

	mov r0,#0							@ set level to 0 for start of game
	ldr r1,=levelNum
	str r0,[r1]
	ldr r1,=tScrollPix
	str r0,[r1]
	ldr r1,=tScrollSegment
	str r0,[r1]
	ldr r1,=tScrollChar
	str r0,[r1]
	ldr r1,=tDemoPos
	str r0,[r1]

	bl initVideoTitle


	mov r1, #GAMEMODE_TITLE_SCREEN
	ldr r2, =gameMode
	str r1,[r2]
	
	bl titleMainScreen					@ draw our title top screen	

	@ now, what for the bottom screen??????
	
	bl titleBottomScreen
	
	ldr r1,=Title_xm
	bl initMusic

	bl initTitleSprites

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

	bl initVideoTitle
	
	bl specialFXStop	
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

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
	ldreq r8,=500
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
		
		bl titleScroller
		
		bl drawTitleSprites
		
		@ check for fire
		
		ldr r2, =REG_KEYINPUT						@ Read key input register
		ldr r3, [r2]								@ Read key value
		tst r3,#BUTTON_START
		beq titleGameStart
		
		
		cmp r8,#19
@		bleq fxFadeBlackLevelInit
@		bleq fxFadeMax
@		bleq fxFadeOut
		

	subs r8,#1
	
	bne titleScreenLoop
	
titleNextScreen:
	

	ldr r0,=levelNum
	ldr r1,[r0]
	add r1,#1
	cmp r1,#23
	moveq r1,#0
	beq skipMissLevels
	cmp r1,#LEVEL_COUNT+1
	moveq r1,#21
skipMissLevels:
	str r1,[r0]

@		ldr r0,=levelNum		@ add to level number
@		ldr r1,[r0]
@		add r1,#1			
@		cmp r1,#22
@		moveq r1,#0				
@		beq skipMissLevels
@		cmp r1,#LEVEL_COUNT
@		movgt r1,#21
@		skipMissLevels:
@		str r1,[r0]

		cmp r1,#0				@ level 0 is used to title screen graphic
		blne titleGameScreen
		bleq titleMainScreen
		
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
	
@-------------------------

titleScroller:
	stmfd sp!, {r0-r10, lr}	

	ldr r6,=tScrollPix
	ldr r7,[r6]
	add r7,#1
	cmp r7,#8
	moveq r7,#0
	str r7,[r6]
	ldr r0, =REG_BG2HOFS
	strh r7,[r0]	
	bleq titleScrollerRefresh
	
	titleScrollerDone:
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------

titleScrollerRefresh:
	@ ok update scroll at Y20 X31 on bg2
	
	ldr r1,=BG_MAP_RAM(BG2_MAP_BASE)
	add r1,#20*64
	@ r1=left portion of screen 
	add r2,r1,#2
	add r3,r1,#64
	add r4,r3,#2
	mov r0,#0
	
	titleScrollerRefreshLoop:
	ldrh r5,[r2],#2
	strh r5,[r1],#2
	ldrh r5,[r4],#2
	strh r5,[r3],#2
	add r0,#1
	cmp r0,#31
	
	bne titleScrollerRefreshLoop

	bl drawTextScroller

b titleScrollerDone

@---------------------------

drawTitleSprites:

	stmfd sp!, {r0-r10, lr}	
	
	@ hmmm (animating arms?)
	
	ldr r0,=tArmsDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#250
	moveq r1,#0
	str r1,[r0]
	beq updateArms

	ldmfd sp!, {r0-r10, pc}	
	
	updateArms:
	
	ldr r0,=tArms
	ldr r1,[r0]
	add r1,#0
	cmp r1,#2
	moveq r1,#0
	str r1,[r0]
	
	beq tArmsOn
	bne tArmsOff
	
	
	armsReturn:
	
	
	ldmfd sp!, {r0-r10, pc}	

tArmsOn:

@ arms on
	ldr r0,=OBJ_ATTRIBUTE0(2)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(2)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#7*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(2)
	mov r2,#2
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(3)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(3)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#9*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(3)
	mov r2,#3
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(4)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(4)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#11*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(4)
	mov r2,#4
	lsl r2,#3
	strh r2,[r0]		
@	
	ldr r0,=OBJ_ATTRIBUTE0(5)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(5)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#7*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(5)
	mov r2,#5
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(6)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(6)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#9*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(6)
	mov r2,#6
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(7)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(7)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#11*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(7)
	mov r2,#7
	lsl r2,#3
	strh r2,[r0]			
	
@	
	ldr r0,=OBJ_ATTRIBUTE0(8)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(8)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#7*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(8)
	mov r2,#8
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(9)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(9)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#9*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(9)
	mov r2,#9
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(10)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(10)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#11*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(10)
	mov r2,#10
	lsl r2,#3
	strh r2,[r0]

@ Right

	ldr r0,=OBJ_ATTRIBUTE0(11)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(11)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#18*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(11)
	mov r2,#11
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(12)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(12)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#20*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(12)
	mov r2,#12
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(13)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(13)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#22*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(13)
	mov r2,#13
	lsl r2,#3
	strh r2,[r0]		
@	
	ldr r0,=OBJ_ATTRIBUTE0(14)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(14)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#18*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(14)
	mov r2,#14
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(15)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(15)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#20*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(15)
	mov r2,#15
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(16)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(16)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#22*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(16)
	mov r2,#16
	lsl r2,#3
	strh r2,[r0]			
	
@	
	ldr r0,=OBJ_ATTRIBUTE0(17)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(17)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#18*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(17)
	mov r2,#17
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(18)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(18)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#20*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(18)
	mov r2,#18
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(19)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(19)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#22*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(19)
	mov r2,#19
	lsl r2,#3
	strh r2,[r0]
	
b armsReturn

tArmsOff:
@ arms off

@	mov r1,#ATTR0_DISABLED
@	ldr r0,=OBJ_ATTRIBUTE0(2)
@	strh r1,[r0]


b armsReturn



	.pool
	.data
tDemoSequence:			@ 0=title, 512=credits 1, 1024=credits 3, 4096=loop
	.word 0,1,2,3,4,5,6,7,8,9,10,4096
tDemoPos:
	.word 0
tScrollPix:
	.word 0
tScrollChar:
	.word 0
tScrollSegment:
	.word 0
tArms:
	.word 0
tArmsDelay:
	.word 0
tScrollText:
	.ascii	"    HELLO AND WELCOME TO 'MANIC MINER THE LOST LEVELS'...      THIS IS NOT YOUR USUAL "
	.ascii	"'MANIC MINER' REMAKE AND IS CONSTRUCTED FROM A SELECTION OF THE LEVELS YOU MAY NOT HAVE "
	.ascii	"SEEN. THESE ARE SOURCED FROM THE NON-SPECTUM VERSIONS OF THE GAME, WHERE THE CODER DECIDED "
	.ascii	"TO ADD A FEW LEVELS OF THEIR OWN. THE BOTTOM SCREEN SHOWS WHERE THESE LEVELS CAME FROM AND "
	.ascii	"THE YEAR OF RELEASE.   SEVERAL OF THE LEVELS HAVE HAD TO BE 'SLIGHLY' MODIFIED TO KEEP THEM "
	.ascii	"CORRECTLY USING THE ORIGINAL ZX SPECTRUM GAME MECHANICS (OTHER VERSIONS PLAYED SLIGHTLY "
	.ascii	"DIFFERENTLY). "
	.byte 0