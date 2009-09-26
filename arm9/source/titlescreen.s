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
	.global titleScroller

@----------------------------

initTitleScreen:
	stmfd sp!, {r0-r10, lr}
	
	bl fxOff
	
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl initCheat

	mov r0,#0							@ set level to 0 for start of game
	ldr r1,=levelNum
	str r0,[r1]
	ldr r1,=tScrollerOn
	str r0,[r1]
	ldr r1,=tDemoPos
	str r0,[r1]
	ldr r1,=tScrollPix
	str r0,[r1]
	ldr r1,=tScrollSegment
	str r0,[r1]
	ldr r1,=tScrollChar
	str r0,[r1]
	ldr r1,=tDemoPos
	str r0,[r1]
	ldr r1,=tArmsDelay
	str r0,[r1]
	ldr r1,=tPump
	str r0,[r1]
	ldr r1,=tPumpDelay
	str r0,[r1]	
	ldr r1,=tBearF
	str r0,[r1]
	ldr r1,=tBearDelay
	str r0,[r1]
	ldr r1,=tRobotF
	str r0,[r1]
	ldr r1,=tRobotDelay
	str r0,[r1]
	ldr r1,=tGorillaF
	str r0,[r1]
	ldr r1,=tGorillaDelay
	str r0,[r1]
	ldr r1,=tCreditFrame
	str r0,[r1]
	add r0,#1
	ldr r1,=tArms
	str r0,[r1]
	
	ldr r1,=tTimer				@ store initial timer
	ldr r0,=500
	str r0,[r1]

	bl initVideoTitle


	mov r1, #GAMEMODE_TITLE_SCREEN
	ldr r2, =gameMode
	str r1,[r2]
	
	bl titleMainScreen					@ draw our title top screen	

	@ now, what for the bottom screen??????
	
	bl titleBottomScreen
	
	ldr r2, =Title_xm_gz
	ldr r3, =Title_xm_gz_size
	bl initMusic

	bl initTitleSprites
	
	mov r1, #1
	ldr r2,=tScrollerOn
	str r1,[r2]

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
	add r1,#BigFontOffset
	ldr r2,=BigFontTilesLen
	bl decompressToVRAM

	bl initSprites

	bl initLevel

	ldmfd sp!, {r0-r10, pc}	

@----------------------------
titleCredit1Screen:

	stmfd sp!, {r0-r10, lr}	
	
	bl initVideoTitle
	
	bl specialFXStop	
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

	@ draw our credits to sub
	
	ldr r0,=CreditPageTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=CreditPageTilesLen
	bl decompressToVRAM	
	ldr r0, =CreditPageMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =CreditPageMapLen
	bl dmaCopy
	ldr r0, =CreditPagePal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =CreditPagePalLen
	bl dmaCopy
	
	bl clearSpriteData

	ldmfd sp!, {r0-r10, pc}	

@----------------------------

updateTitleScreen:

	stmfd sp!, {r0-r10, lr}

	titleScreenTimer:

	ldr r10,=levelNum
	ldr r10,[r10]

	ldr r1,=tTimer
	ldr r8,[r1]

	titleScreenLoop:
	
		bl swiWaitForVBlank

		ldr r10,=levelNum
		ldr r10,[r10]	
		cmp r10,#0						@ level 0 is out title bitmap
		beq titleIsBitmap
		cmp r10,#128
		bpl titleIsBitmap
	
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

		bl drawTitleSprites
		
		bl updateCheatCheck
		
		@ check for fire
		
		ldr r2, =REG_KEYINPUT						@ Read key input register
		ldr r3, [r2]								@ Read key value
		tst r3,#BUTTON_START
		beq titleGameStart		

	subs r8,#1
	
	bne titleScreenLoop
	
titleNextScreen:
	

@	ldr r0,=levelNum
@	ldr r1,[r0]
@	add r1,#1
@	cmp r1,#LEVEL_COUNT+1
@	moveq r1,#0
@	str r1,[r0]
@
@		cmp r1,#0				@ level 0 is used to title screen graphic
@		blne titleGameScreen
@		bleq titleMainScreen


	ldr r0,=tDemoSequence		@ our demo sequence
	ldr r1,=tDemoPos			@ pos in sequence
	ldr r2,[r1]					@ r2=position
	add r2,#1
	ldr r3,[r0,r2,lsl#2]		@ read next part in sequence
	cmp r3,#4096				@ 4096=end of sequence
	moveq r2,#0					@ if so, reset to 0
	moveq r3,#0					@ and set data to 0 for display
	str r2,[r1]					@ store new pos
	
	@ r3= what to show!!!
	
	bl drawTitleThings			@ jump to the code that initialises the image (r3=image)
	
	b titleScreenTimer

titleGameStart:

	mov r1, #GAMEMODE_RUNNING
	ldr r2, =gameMode
	str r1,[r2]
	mov r1, #0
	ldr r2,=tScrollerOn
	str r1,[r2]
	
@	bl stopMusic
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3

	bl initVideo
	bl initSprites

	bl specialFXStop

	bl initGame
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------

titleScroller:
	stmfd sp!, {r0-r10, lr}	
	
	ldr r6,=tScrollerOn
	ldr r6,[r6]
	cmp r6,#0
	beq titleScrollerDone

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

@---------------------------			@ animation for base screen

drawTitleSprites:

	stmfd sp!, {r0-r10, lr}	
	
	@ Arms
	
	ldr r0,=tArmsDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#50
	moveq r1,#0
	str r1,[r0]
	beq updateArms

		b armsReturn
	
	updateArms:
	
		ldr r0,=tArms
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
	
		beq tArmsOn
		bne tArmsOff
	
	armsReturn:
	
	@ Pumpkin
	
		b tPumpkin

	pumpkinReturn:
	
	@ Bears eye
	
		b tBear

	bearReturn:

	@ Robots eye
	
		b tRobot

	robotReturn:

	@ Gorilla
	
		b tGorilla

	gorillaReturn:
	
	ldmfd sp!, {r0-r10, pc}	

@------------------------------

tArmsOn:

@ arms on

	@ ok, we have the tiles below the screen 32*5 and we need to copy them to the screen..
	
	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		@ src
	add r0, #(32*24*2) 						@ start of offscreen
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r2, =(7+7*32)*2
	add r1, r2
	mov r2, #(17*2)							@ tile count
	mov r3, #(32*2)							@ tile skip
	mov r4, #4

tArmsOnLoop:

	bl dmaCopy

	add r0, r3
	add r1, r3
	
	subs r4, #1
	bpl tArmsOnLoop
	
b armsReturn

tArmsOff:
	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		@ src
	add r0, #(32*24*2)+(5*32*2) 			@ start of offscreen
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r2, =(7+7*32)*2
	add r1, r2
	mov r2, #(17*2)							@ tile count
	mov r3, #(32*2)							@ tile skip
	mov r4, #4

tArmsOffLoop:

	bl dmaCopy

	add r0, r3
	add r1, r3
	
	subs r4, #1
	bpl tArmsOffLoop

b armsReturn

@---------------------------------------------

tPumpkin:

	@ read tPump as the frame to use
	
	ldr r0,=tPumpDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#8
	moveq r1,#0
	str r1,[r0]
	bne pumpkinReturn

	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		@ src
	add r0, #(32*24*2) 						@ start of offscreen
	add r0,#17*2
	mov r5,#5
	ldr r7,=tPump			@ frame 0-11
	ldr r6,[r7]
	add r6,#1
	cmp r6,#16
	moveq r6,#0
	str r6,[r7]
	ldr r7,=tPumpFrames
	ldrb r7,[r7,r6]
	mul r7,r5
	add r0,r7,lsl #1

	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r2, =(2+8*32)*2
	add r1, r2
	mov r2, #(5*2)							@ tile count
	mov r3, #(32*2)							@ tile skip
	mov r4, #3								

tPumpkinLoop:

	bl dmaCopy

	add r0, r3
	add r1, r3
	
	subs r4, #1
	bpl tPumpkinLoop
	
b pumpkinReturn

@---------------------------------------------------

tBear:

	@ read tPump as the frame to use
	
	ldr r0,=tBearDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#4
	moveq r1,#0
	str r1,[r0]
	bne bearReturn

	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		@ src
	add r0, #(32*28*2) 						@ start of offscreen
	add r0,#17*2							@ initial frame location
	mov r5,#2								@ width of frame
	ldr r7,=tBearF							@ frame 0-11
	ldr r6,[r7]
	add r6,#1
	cmp r6,#32
	moveq r6,#0
	str r6,[r7]
	ldr r7,=tBearFrames
	ldrb r7,[r7,r6]
	mul r7,r5
	add r0,r7,lsl #1						@ r0=source

	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r2, =(10+12*32)*2
	add r1, r2
	mov r2, #(2*2)							@ tile count (x)
	mov r3, #(32*2)							@ tile skip
	mov r4, #1								@ rows

tBearLoop:

	bl dmaCopy

	add r0, r3
	add r1, r3
	
	subs r4, #1
	bpl tBearLoop
	
b bearReturn


@---------------------------------------------------

tRobot:

	@ read tPump as the frame to use
	
	ldr r0,=tRobotDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#8
	moveq r1,#0
	str r1,[r0]
	bne robotReturn

	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		@ src
	add r0, #(32*34*2) 						@ start of offscreen
@	add r0,#17*2							@ initial frame location
	mov r5,#5								@ width of frame
	ldr r7,=tRobotF							@ frame 0-11
	ldr r6,[r7]
	add r6,#1
	cmp r6,#4
	moveq r6,#0
	str r6,[r7]
	mul r6,r5
	add r0,r6,lsl #1						@ r0=source

	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r2, =(26+14*32)*2
	add r1, r2
	mov r2, #(5*2)							@ tile count (x)
	mov r3, #(32*2)							@ tile skip
	mov r4, #2								@ rows

tRobotLoop:

	bl dmaCopy

	add r0, r3
	add r1, r3
	
	subs r4, #1
	bpl tRobotLoop
	
b robotReturn


@---------------------------------------------------

tGorilla:

	@ read tPump as the frame to use
	
	ldr r0,=tGorillaDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#12
	moveq r1,#0
	str r1,[r0]
	bne gorillaReturn

	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		@ src
	add r0, #(32*30*2) 						@ start of offscreen
	add r0,#20*2							@ initial frame location
	mov r5,#4								@ width of frame
	ldr r7,=tGorillaF							@ frame 0-11
	ldr r6,[r7]
	add r6,#1
	cmp r6,#18
	moveq r6,#0
	str r6,[r7]
	ldr r7,=tGorillaFrames
	ldrb r7,[r7,r6]
	mul r7,r5
	add r0,r7,lsl #1						@ r0=source

	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)		@ dest
	ldr r2, =(24+5*32)*2
	add r1, r2
	mov r2, #(4*2)							@ tile count (x)
	mov r3, #(32*2)							@ tile skip
	mov r4, #5								@ rows

tGorillaLoop:

	bl dmaCopy

	add r0, r3
	add r1, r3
	
	subs r4, #1
	bpl tGorillaLoop
	
b gorillaReturn

@---------------------------------------------

drawTitleThings:

	stmfd sp!, {r0-r10, lr}
	
	@ r3= what to show!!
	@ 0=title
	@ 1-128 = level
	@ 512= credit 1
	@ 1024=credit 2
	@ 2048=highscores
	
	ldr r1,=levelNum
	str r3,[r1]

	cmp r3,#0
	bne titleThings1
		@ draw title
	
		bl titleMainScreen
		ldr r9,=400
		b titleThingsDone
	
	titleThings1:
	cmp r3,#128
	bpl titleThings2
		@ display level
	
		bl titleGameScreen
		ldr r9,=150
		b titleThingsDone
	
	titleThings2:
	cmp r3,#512
	bne titleThings3
	
		bl titleCredit1Screen
		ldr r9,=400
		ldr r1,=tCreditFrame
		ldr r10,[r1]
		add r10,#1
		cmp r10,#4
		moveq r10,#0
		str r10,[r1]
		bl drawCreditFrame
		b titleThingsDone
	
	
	titleThings3:


	titleThingsDone:
	
	@ r9 should = the timer value for the screen
	
	ldr r1,=tTimer
	str r9,[r1]

	ldmfd sp!, {r0-r10, pc}



	.pool
	.data
tCreditFrame:
	.word 0
tTimer:
	.word 0
tScrollerOn:
	.word 0
tDemoSequence:			@ 0=title, 512=credits 1, 1024=credits 2, 2048=hi scores, 4096=loop (others display the level)
	.word 0,1,2,3,4,512,5,6,7,8,512,9,10,11,12,512,13,14,15,16,512,17,18,19,20,4096
tDemoPos:
	.word 0
tScrollPix:
	.word 0
tScrollChar:
	.word 0
tScrollSegment:
	.word 0
tArms:
	.word 1
tArmsDelay:
	.word 0
tPump:
	.word 0
tPumpDelay:
	.word 0
tPumpFrames:
	.byte 0,0,0,0,0,0,0,0,1,2,2,1,0,0,0,0
tBearF:
	.word 0
tBearDelay:
	.word 0
tBearFrames:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,0
tRobotF:
	.word 0
tRobotDelay:
	.word 0
tGorillaF:
	.word 0
tGorillaDelay:
	.word 0
tGorillaFrames:
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,1,2
tScrollText:
	.ascii	"    HELLO AND WELCOME TO 'MANIC MINER THE LOST LEVELS'...      THIS IS NOT YOUR USUAL "
	.ascii	"'MANIC MINER' REMAKE AND IS CONSTRUCTED FROM A SELECTION OF THE LEVELS YOU MAY NOT HAVE "
	.ascii	"SEEN. THESE ARE SOURCED FROM THE NON-SPECTUM VERSIONS OF THE GAME, AND COLLATED AND DESCRIBED "
	.ascii	"BY STUART CAMPBELL. THE BOTTOM SCREEN SHOWS WHERE THESE LEVELS CAME FROM AND "
	.ascii	"THE YEAR OF RELEASE.   SEVERAL OF THE LEVELS HAVE HAD TO BE 'SLIGHTLY' MODIFIED TO KEEP THEM "
	.ascii	"CORRECT USING THE ORIGINAL ZX SPECTRUM GAME MECHANICS (OTHER VERSIONS PLAYED SLIGHTLY "
	.ascii	"DIFFERENTLY). "
	.byte 0