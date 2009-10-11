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

	#define	BitmapPause			400
	#define	LevelPause			125

	.arm
	.align
	.text
	
	.global initTitleScreen
	.global updateTitleScreen
	.global tScrollChar
	.global tScrollSegment
	.global tScrollText
	.global titleScroller
	.global pointerFrame
	.global pointerY
	.global freshTitle
	.global moveTrap

@----------------------------

initTitleScreen:
	stmfd sp!, {r0-r10, lr}

	bl fxOff
	bl fxFadeBlackInit

	ldr r0,=freshTitle
	mov r1,#0
	str r1,[r0]
	ldr r1,=levelNum
	str r0,[r1]
	

	bl initVideoTitle
	bl initCheat
	bl clearOAM

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
	ldr r1,=tCreditFrame2
	str r0,[r1]
	ldr r1,=titleMenu
	str r0,[r1]
	ldr r1,=gameReturn
	str r0,[r1]
	ldr r1,=moveTrap
	str r0,[r1]
	add r0,#1
	ldr r1,=tArms
	str r0,[r1]
	ldr r1,=trapStart
	str r0,[r1]
	ldr r0,=freshTitle
	str r1,[r0]
	
	ldr r1,=tTimer				@ store initial timer
	ldr r0,=BitmapPause
	str r0,[r1]

	mov r1, #GAMEMODE_TITLE_SCREEN
	ldr r2, =gameMode
	str r1,[r2]
	
@	ldr r2, =Title_xm_gz
@	ldr r3, =Title_xm_gz_size
@	bl initMusicForced					@ play title music

	mov r0,#26
	bl levelMusicPlayEasy
	bl initTitleSprites
	
	mov r1, #1
	ldr r2,=tScrollerOn
	str r1,[r2]

	bl titleMainScreenFirst			@ draw our title top screen	
	
	bl titleBottomScreen
	bl drawSprite

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
titleMainScreenFirst:
	stmfd sp!, {r0-r10, lr}
	
	b titleMainScreenJump

titleMainScreen:

	stmfd sp!, {r0-r10, lr}

	bl fxFadeBlackLevelInit

	titleMainScreenJump:

	bl fxFadeMax
	bl specialFXStop	

	bl fxFadeIn
	
	bl initVideoTitle
		

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
	
	bl clearBG0SubPart
	
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
	ldr r0,=CreditPageTopTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=CreditPageTopTilesLen
	bl decompressToVRAM	
	ldr r0, =CreditPageTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)	@ destination
	ldr r2, =CreditPageTopMapLen
	bl dmaCopy


	ldr r0, =CreditPagePal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =CreditPagePalLen
	bl dmaCopy
	
	bl clearSpriteData

	ldmfd sp!, {r0-r10, pc}	

@----------------------------
titleCredit2Screen:

	stmfd sp!, {r0-r10, lr}	
	
	bl initVideoTitle
	
	bl specialFXStop	
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

	@ draw our credits to sub
	
	ldr r0,=CreditPage2Tiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=CreditPage2TilesLen
	bl decompressToVRAM	
	ldr r0, =CreditPage2Map
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =CreditPage2MapLen
	bl dmaCopy
	ldr r0,=CreditPageTop2Tiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=CreditPageTop2TilesLen
	bl decompressToVRAM	
	ldr r0, =CreditPageTop2Map
	ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)	@ destination
	ldr r2, =CreditPageTop2MapLen
	bl dmaCopy
	ldr r0, =CreditPage2Pal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =CreditPage2PalLen
	bl dmaCopy
	
	bl clearSpriteData

	ldmfd sp!, {r0-r10, pc}	
	
@----------------------------
highScoreScreen:

	stmfd sp!, {r0-r10, lr}	
	
	bl initVideoTitle
	
	bl specialFXStop	
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

	@ draw our Highs to sub
	
	ldr r0,=HighScoreTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=HighScoreTilesLen
	bl decompressToVRAM	
	ldr r0, =HighScoreMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =HighScoreMapLen
	bl dmaCopy
	ldr r0, =HighScorePal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =HighScorePalLen
	bl dmaCopy
	
	bl clearSpriteData

	ldr r0,=BigFontTiles							@ copy the tiles used for large font to main
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=BigFontTilesLen
	bl decompressToVRAM
	
	@ now draw the scores on BG0, using drawHighText draw!
	
	ldr r0,=highScoreName
	mov r8,#5					@ number of lines to draw-1
	mov r1,#6					@ x coord
	mov r2,#7					@ y coord
	mov r3,#HIGH_NAME_LEN		@ length
	mov r9,#0					@ drawing chars
	titleHighNameLoop:
		bl drawHighText
		add r0,#HIGH_NAME_LEN
		add r2,#2
		subs r8,#1
	bpl titleHighNameLoop
	ldr r0,=highScoreScore
	mov r8,#5					@ number of lines to draw-1
	mov r1,#17					@ x coord
	mov r2,#7					@ y coord
	mov r3,#HIGH_SCORE_LEN		@ length
	mov r9,#1					@ drawing digits
	titleHighScoreLoop:
		bl drawHighText
		add r0,#HIGH_SCORE_LEN
		add r2,#2
		subs r8,#1
	bpl titleHighScoreLoop

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
		
		bl titleMenuControl
		
		ldr r2,=titleMenu
		ldr r2,[r2]
		cmp r2,#1
		beq titleStartReturn
		
		@ check for fire
		
		ldr r2, =REG_KEYINPUT						@ Read key input register
		ldr r3, [r2]								@ Read key value
		tst r3,#BUTTON_START
		beq titleGameStart		

		ldr r1,=trapStart
		mov r0,#0
		str r0,[r1]
		
		titleStartReturn:
		
		ldr r1,=gameReturn
		ldr r1,[r1]
		cmp r1,#0
		bne returnToGameLoop

	subs r8,#1
	
	bne titleScreenLoop
	
titleNextScreen:
	ldr r6,=unlockedHW
	ldr r6,[r6]
	cmp r6,#1


	ldrne r0,=tDemoSequence				@ our demo sequence (normal)
	ldreq r0,=tDemoSequenceFull			@ our demo sequence (With Holywood)
	ldr r1,=tDemoPos					@ pos in sequence
	ldr r2,[r1]							@ r2=position
	add r2,#1
	ldr r3,[r0,r2,lsl#2]		@ read next part in sequence
	cmp r3,#4096				@ 4096=end of sequence
	moveq r2,#0					@ if so, reset to 0
	moveq r3,#0					@ and set data to 0 for display
	str r2,[r1]					@ store new pos
	
	@ r3= what to show!!!
	
	bl drawTitleThings			@ jump to the code that initialises the image (r3=image)
	
	b titleScreenTimer

@---------------------------------------

	returnToGameLoop:

	ldmfd sp!, {r0-r10, pc}	
	
@---------------------------------------- Start has been pressed

titleGameStart:

	ldr r1,=trapStart
	ldr r0,[r1]
	cmp r0,#1
	beq titleStartReturn

	@ display menu
	
	ldr r1,=titleMenu		@ if the menu is already shown, do nothing
	ldr r0,[r1]
	cmp r0,#1
	beq titleStartReturn

	mov r0,#1				@ turn on menu
	str r0,[r1]
	
	bl titleMenuDraw
	
	mov r1, #1				@ trap the start key again
	ldr r2, =trapStart
	str r1,[r2]
		
	b titleStartReturn
	
@-------------------------

titleScroller:
	stmfd sp!, {r0-r10, lr}	
	
	ldr r6,=tScrollerOn
	ldr r6,[r6]
	cmp r6,#0
	beq titleScrollerDone

	ldr r6,=tScrollPix
	ldr r7,[r6]
	add r7,#2
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
		ldr r9,=BitmapPause
		b titleThingsDone
	
	titleThings1:
	cmp r3,#128
	bpl titleThings2
		@ display level
	
		bl titleGameScreen
		ldr r9,=LevelPause
		b titleThingsDone
	
	titleThings2:
	cmp r3,#512
	bne titleThings3					@ credit page 1
	
		bl titleCredit1Screen
		ldr r9,=BitmapPause
		ldr r1,=tCreditFrame
		ldr r10,[r1]
		add r10,#1
		cmp r10,#4
		moveq r10,#0
		str r10,[r1]
		bl drawCreditFrame
		b titleThingsDone
	
	titleThings3:
	cmp r3,#1024
	bne titleThings4					@ credit page 2
	
		bl titleCredit2Screen
		ldr r9,=BitmapPause
		ldr r1,=tCreditFrame2
		ldr r10,[r1]
		add r10,#1
		cmp r10,#4
		moveq r10,#0
		str r10,[r1]
		bl drawCreditFrame
		b titleThingsDone
		
	
	titleThings4:						@ highscore
	cmp r3,#2048
	bne titleThings5
	
		bl highScoreScreen
		ldr r9,=BitmapPause
		b titleThingsDone
		
	titleThings5:


	titleThingsDone:
	
	@ r9 should = the timer value for the screen
	
	ldr r1,=tTimer
	str r9,[r1]

	ldmfd sp!, {r0-r10, pc}


@------------------------------------------------------

	titleMenuDraw:

	stmfd sp!, {r0-r10, lr}
	
	@ display the menu for us on bg1 main

	ldr r0,=GameStartTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2,=GameStartTilesLen
	bl decompressToVRAM	
	ldr r0, =GameStartMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)	@ destination
	add r1,#(32*3)*2
	add r1,#(1*2)
	ldr r2, =(30*2)

	mov r10,#14
	
	titleMenuDrawLoop:
	
		bl dmaCopy
		add r1,#(32*2)				@ down 1 line
		add r0,#(30*2)				@ down 1 line in the map
		
	
	subs r10,#1
	bpl titleMenuDrawLoop

	ldr r1,=titleMenu
	mov r0,#1
	str r0,[r1]
	
	bl optionDraw
	
	@ ok, add sprite for the pointer (3rd sprite+8 in titleSprites)
	
	bl initTitlePointer
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------- Draw the option text

optionDraw:

	stmfd sp!, {r0-r10, lr}

	ldr r0,=titleGS						@ start game
	mov r1,#4
	mov r2,#5
	bl drawTextBigMain
	
	ldr r0,=titleGM						@ game mode
	ldr r3,=unlockedSelected
	ldr r3,[r3]
	cmp r3,#1
	addeq r0,#27
	mov r2,#7
	bl drawTextBigMain

	@ read unlockedSelected and display digits based on that

	ldr r0,=titleSL						@ level select (add the 2 digits to the end)
	mov r2,#9
	bl drawTextBigMain
	ldr r6,=unlockedSelected
	ldr r6,[r6]
	cmp r6,#0
	ldreq r0,=levelLLSelected
	ldrne r0,=levelHWSelected
	ldr r0,[r0]
	mov r1,#20
	bl drawTextBigDigits
	
	@ display selected bonus level (27 chars for each string)
	
	ldr r3,=unlockedBonusesSelected
	ldr r3,[r3]
	mov r4,#27
	mul r3,r4
	ldr r4,=unlockedBonuses
	ldr r4,[r4]
	cmp r4,#255
	moveq r3,#0
	mov r1,#4
	ldr r0,=titleBL						@ bonus level select
	add r0,r3
	mov r2,#11
	bl drawTextBigMain


	@ draw 'jukebox' text

	ldr r0,=titleJB						@ jukebox
	mov r2,#13
	bl drawTextBigMain
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------				This is for UPDATING the title screen

	titleMenuControl:

	stmfd sp!, {r0-r10, lr}

	ldr r1,=titleMenu
	ldr r0,[r1]
	cmp r0,#0
	beq titleStartSkip

	ldr r0,=REG_KEYINPUT						@ Read key input register
	ldr r10,[r0]								@ Read key value
	tst r10,#BUTTON_START						@ start=Start game/activate highlight optio
	beq titleStart1		
	tst r10,#BUTTON_B
	beq titleRemoveOptions						@ B=back to normal title
	tst r10,#BUTTON_UP
	beq movePointer
	tst r10,#BUTTON_DOWN
	beq movePointer
	tst r10,#BUTTON_LEFT
	beq moveAlter
	tst r10,#BUTTON_RIGHT
	beq moveAlter
	
		ldr r1,=trapStart	
		mov r0,#0
		str r0,[r1]
		ldr r1,=moveTrap	
		mov r0,#0
		str r0,[r1]
		b titleStartDone1
	
	titleStart1:
	
		ldr r1,=trapStart
		ldr r0,[r1]
		cmp r0,#1
		beq titleStartDone
	
		@ start has been pressed
		@ call SOMETHING to see what is to be done!! (based on highlighted option)
		@ for now - start game
		
		ldr r1,=pointerY
		ldr r1,[r1]
		cmp r1,#0			@ normal start
		beq goToStart
		cmp r1,#3
		bne checkForJukebox
			ldr r1,=unlockedBonuses
			ldr r1,[r1]
			cmp r1,#255
			beq titleStartDone
			b goToStart
		
		checkForJukebox:
		cmp r1,#4
		bne titleStartDone

		@ jukebox
		bl startAudio
		b titleStartDone
		
		goToStart:
		@ game start
		bl gameStartNormal
	
	titleStartDone:
	
		bl moveTimer
	
	titleStartDone1:
	
	@ update and animate the pointer
	
	bl	initTitlePointer
	
	ldr r1,=pointerDelay
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#8
	str r0,[r1]
	ldrmi r1,=pointerFrame
	ldrmi r2,[r1]
	addmi r2,#1
	andmi r2,#7
	strmi r2,[r1]
	
	titleStartSkip:

	ldmfd sp!, {r0-r10, pc}

@-------------------------	Audio Init
startAudio:

	mov r1, #1						@ trap the start key again
	ldr r2, =trapStart
	str r1,[r2]
	ldr r2, =gameReturn
	str r1,[r2]
	mov r1, #0
	ldr r2,=tScrollerOn
	str r1,[r2]
	
	bl initAudio

	ldmfd sp!, {r0-r10, pc}
	
@-------------------------	Game start!

gameStartNormal:

	@ check pointerY to set the starting level (amd the gamemode/level selected)

	stmfd sp!, {r0-r10, lr}

	mov r1, #GAMEMODE_RUNNING
	ldr r2, =gameMode
	str r1,[r2]

	mov r1, #ATTR0_DISABLED			@ this should destroy the willy pointer
	ldr r0,=OBJ_ATTRIBUTE0(2)
	strh r1,[r0]

	mov r1, #0
	ldr r2,=tScrollerOn
	str r1,[r2]
	
	mov r1, #1						@ trap the start key again
	ldr r2, =trapStart
	str r1,[r2]
	ldr r2, =gameReturn
	str r1,[r2]
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3

	bl initVideo
	bl initSprites
	bl specialFXStop
	
	@ we need to pass initGame the level to play!!
	@ we pass that in "R12"
	
	ldr r0,=unlockedSelected
	ldr r0,[r0]
	ldr r1,=pointerY
	ldr r1,[r1]
	cmp r1,#2						@ 'Start game'
	bgt notSelectedStart		
		cmp r0,#0
		ldreq r12,=levelLLSelected
		ldrne r12,=levelHWSelected
		ldr r12,[r12]
		cmp r0,#1
		addeq r12,#22
		b timeToPlay
	
	notSelectedStart:
	@ option can only be 			'bonus level start'
	@ so, we need to set r12 based on unlockedBonusesSelected
		ldr r1,=unlockedBonusesSelected
		ldr r1,[r1]
		ldr r2,=bonusLevelsAre
		ldr r12,[r2,r1,lsl#2]
	
	timeToPlay:						@ 'activate game start'
	
	bl stopMusic

	bl initGame

	ldmfd sp!, {r0-r10, pc}
	
@--------------------------	Return to normal title screen

titleRemoveOptions:

	ldr r1,=trapStart	
	mov r0,#0
	str r0,[r1]

	ldr r1,=titleMenu
	mov r0,#0
	str r0,[r1]
	
	@ now clear the bg0 and bg1 on main

	bl clearBGTitle
	
	@ now remover the sprite
	
	mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
	ldr r0,=OBJ_ATTRIBUTE0(2)
	strh r1,[r0]
	
	ldmfd sp!, {r0-r10, pc}

@--------------------------	update Move Timer

moveTimer:

	stmfd sp!, {r0-r10, lr}

	ldr r1,=moveTrap	
	ldr r0,[r1]
	add r0,#1
	cmp r0,#POINTER_DELAY
	moveq r0,#0
	str r0,[r1]

	ldmfd sp!, {r0-r10, pc}
	
@--------------------------	Move pointer up or down

movePointer:

	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne movePointerDone
	
		mov r1,#1
		str r1,[r0]
		
		ldr r0,=pointerY
		ldr r1,[r0]
		
		tst r10,#BUTTON_UP
		bne pointerDown
		
			subs r1,#1
			movmi r1,#0
			b pointerMoveStore
		
		pointerDown:
	
			add r1,#1
			cmp r1,#4
			movpl r1,#4
	
		pointerMoveStore:
		
		str r1,[r0]

	movePointerDone:
	
	b titleStartDone
	
@--------------------------	Alter selected area

moveAlter:
	ldr r0,=pointerY				@ first and last cannot be altered
	ldr r8,[r0]
	cmp r8,#0
	beq moveAlterDone
	cmp r8,#4
	beq moveAlterDone	

	ldr r0,=moveTrap				@ check trap
	ldr r1,[r0]
	cmp r1,#0
	bne moveAlterDone
	
		mov r1,#1
		str r1,[r0]					@ set trap
		
		tst r10,#BUTTON_LEFT
		bne pointerRight
		
			cmp r8,#1				@ left on mode
			bne notLeftMode
				ldr r4,=unlockedHW
				ldr r4,[r4]
				cmp r4,#1
				bne moveAlterDone			
				ldr r4,=unlockedSelected
				ldr r5,[r4]
				subs r5,#1
				movmi r5,#0
				str r5,[r4]
				bl optionDraw

				b moveAlterDone
		
			notLeftMode:
			cmp r8,#2				@ are we on the level select
			bne notLeftLevel
				ldr r4,=unlockedSelected
				ldr r4,[r4]
				cmp r4,#0
				ldreq r6,=levelLLSelected		@ current value
				ldrne r6,=levelHWSelected		

				ldr r4,[r6]
				sub r4,#1
				cmp r4,#0
				moveq r4,#1
				str r4,[r6]
				bl optionDraw	
		
				b moveAlterDone
			notLeftLevel:
			cmp r8,#3				@ are we on the level select
			bne notLeftBonus
				ldr r4,=unlockedBonuses
				ldr r4,[r4]
				cmp r4,#255
				beq moveAlterDone
				ldr r5,=unlockedBonusesSelected
				ldr r6,[r5]
				sub r6,#1
				cmp r6,#0
				moveq r6,#1
				str r6,[r5]
				bl optionDraw	
				b moveAlterDone
			
			notLeftBonus:			
			b moveAlterDone
		
		pointerRight:
	
			cmp r8,#1				@ Right on mode
			bne notRightMode
				ldr r4,=unlockedHW
				ldr r4,[r4]
				cmp r4,#1
				bne moveAlterDone
				ldr r4,=unlockedSelected
				ldr r5,[r4]
				add r5,#1
				cmp r5,#2
				moveq r5,#1
				str r5,[r4]
				bl optionDraw
				b moveAlterDone
				
			notRightMode:
			cmp r8,#2				@ are we on the level select
			bne notRightLevel
				ldr r4,=unlockedSelected
				ldr r4,[r4]
				cmp r4,#0
				ldreq r5,=levelLLReached		@ max value
				ldrne r5,=levelHWReached
				ldreq r6,=levelLLSelected		@ current value
				ldrne r6,=levelHWSelected		

				ldr r4,[r6]
				add r4,#1
				ldr r7,[r5]
				cmp r4,r7
				movgt r4,r7
				str r4,[r6]
				bl optionDraw	
		
				b moveAlterDone
		
			notRightLevel:
			cmp r8,#3				@ are we on the level select
			bne notRightBonus
				ldr r4,=unlockedBonuses
				ldr r4,[r4]
				cmp r4,#255
				beq moveAlterDone
				ldr r5,=unlockedBonusesSelected
				ldr r6,[r5]
				add r6,#1
				cmp r6,r4
				movpl r6,r4
				str r6,[r5]
				bl optionDraw	
				b moveAlterDone
			
			notRightBonus:
			
			b moveAlterDone
	

	moveAlterDone:
	
	b titleStartDone

@--------------------------

	.pool
	.data
	.align
freshTitle:
	.word 0
pointerY:
	.word 0
pointerFrame:
	.word 0
pointerDelay:
	.word 0
moveTrap:
	.word 0
titleMenu:
	.word 0
gameReturn:
	.word 0
tCreditFrame:
	.word 0
tCreditFrame2:
	.word 0
tTimer:
	.word 0
tScrollerOn:
	.word 0
tDemoSequence:			@ 0=title, 512=credits 1, 1024=credits 2, 2048=hi scores, 4096=loop (others display the level)
	.word 0,1,2,3,4,512,5,6,7,8,2048,9,10,11,12,1024,13,14,15,16,2048,17,18,19,20,4096
tDemoSequenceFull:		@ 0=title, 512=credits 1, 1024=credits 2, 2048=hi scores, 4096=loop (others display the level)
	.word 0,1,2,3,4,512,5,6,7,8,2048,9,10,11,12,1024,13,14,15,16,2048,17,18,19,20,0,23,24,25,26,27,2048,28,29,30,31,32,4096	
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
	.align
bonusLevelsAre:					@ these are the bonus level indexes
	.word 0,21,22,41,33,34,35,36,37,38,39,40,42
tScrollText:
	.ascii	"    HELLO AND WELCOME TO 'MANIC MINER THE LOST LEVELS'...      THIS IS NOT YOUR USUAL "
	.ascii	"'MANIC MINER' REMAKE AND IS CONSTRUCTED FROM A SELECTION OF THE LEVELS YOU MAY NOT HAVE "
	.ascii	"SEEN. THESE ARE SOURCED FROM THE NON-SPECTRUM VERSIONS OF THE GAME, AND COLLATED AND DESCRIBED "
	.ascii	"BY STUART CAMPBELL. THE BOTTOM SCREEN SHOWS WHERE THESE LEVELS CAME FROM AND "
	.ascii	"THE YEAR OF RELEASE.   SEVERAL OF THE LEVELS HAVE HAD TO BE 'SLIGHTLY' MODIFIED TO KEEP THEM "
	.ascii	"CORRECT USING THE ORIGINAL ZX SPECTRUM GAME MECHANICS (OTHER VERSIONS PLAYED SLIGHTLY "
	.ascii	"DIFFERENTLY). "
	.byte 0
	.align	
titleGS:
	.asciz	"PLAY GAME"
titleGM:
	.asciz	"GAME MODE: THE LOST LEVELS"
	.asciz	"GAME MODE: WILLYWOOD      "
titleSL:
	.asciz	"START AT LEVEL:"
titleBL:			@ 26 chars each
	.asciz	"PLAY SPECIAL: LOCKED      "
	.asciz	"PLAY SPECIAL: HORACE      "	@ 21	1
	.asciz	"PLAY SPECIAL: BLAGGER     "	@ 22	2
	.asciz	"PLAY SPECIAL: REAL CENTRAL"	@ 41	3
	.asciz	"PLAY SPECIAL: CHEESE      "	@ 33	4
	.asciz	"PLAY SPECIAL: MY SHAFT!   "	@ 34	5
	.asciz	"PLAY SPECIAL: BIG DROPPER "	@ 35	6
	.asciz	"PLAY SPECIAL: BOUNCY THING"	@ 36	7
	.asciz	"PLAY SPECIAL: ROCKY THING "	@ 37	8
	.asciz	"PLAY SPECIAL: MY BOTTOM!  "	@ 38	9
	.asciz	"PLAY SPECIAL: COSMIC MAN! "	@ 39	10
	.asciz	"PLAY SPECIAL: THAT LOGO   "	@ 40	11
	.asciz	"PLAY SPECIAL: CONFLICTION "	@ 42	12
titleJB:
	.asciz	"AUDIO OPTIONS"