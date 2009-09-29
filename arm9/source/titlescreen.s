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

	#define	BitmapPause			300
	#define	LevelPause			110
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
	ldr r1,=tCreditFrame2
	str r0,[r1]
	ldr r1,=titleMenu
	str r0,[r1]
	ldr r1,=gameReturn
	str r0,[r1]
	add r0,#1
	ldr r1,=tArms
	str r0,[r1]
	ldr r1,=trapStart
	str r0,[r1]
	
	ldr r1,=tTimer				@ store initial timer
	ldr r0,=BitmapPause
	str r0,[r1]

	bl initVideoTitle

	mov r1, #GAMEMODE_TITLE_SCREEN
	ldr r2, =gameMode
	str r1,[r2]
	
	bl titleMainScreen					@ draw our title top screen	
	
	bl titleBottomScreen
	
	ldr r2, =Title_xm_gz
	ldr r3, =Title_xm_gz_size
	bl initMusic						@ play title music

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
	
	@ now draw the scores on BG1?

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
	
	ldr r0,=titleGS
	mov r1,#4
	mov r2,#5
	bl drawTextBigMain
	ldr r0,=titleGM
	mov r2,#7
	bl drawTextBigMain
	ldr r0,=titleSL
	mov r2,#9
	bl drawTextBigMain
	ldr r0,=titleBL
	mov r2,#11
	bl drawTextBigMain
	ldr r0,=titleJB
	mov r2,#13
	bl drawTextBigMain
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

	titleMenuControl:

	stmfd sp!, {r0-r10, lr}

	ldr r1,=titleMenu
	ldr r0,[r1]
	cmp r0,#0
	beq titleStartDone

	ldr r0, =REG_KEYINPUT						@ Read key input register
	ldr r10, [r0]								@ Read key value
	tst r10,#BUTTON_START						@ start=Start game/activate highlight optio
	beq titleStart1		
	tst r10,#BUTTON_B
	beq titleRemoveOptions						@ B=back to normal title
	
		ldr r1,=trapStart	
		mov r0,#0
		str r0,[r1]
		b titleStartDone
	
	titleStart1:
	
		ldr r1,=trapStart
		ldr r0,[r1]
		cmp r0,#1
		beq titleStartDone
	
		@ start has been pressed
		@ call SOMETHING to see what is to be done!! (based on highlighted option)
		@ for now - start game
		
		bl gameStartNormal
		b titleStartDone
	
	titleStartDone:

	ldmfd sp!, {r0-r10, pc}

@-------------------------	Game start!

gameStartNormal:

	stmfd sp!, {r0-r10, lr}

	mov r1, #GAMEMODE_RUNNING
	ldr r2, =gameMode
	str r1,[r2]

	mov r1, #0
	ldr r2,=tScrollerOn
	str r1,[r2]
	
	mov r1, #1				@ trap the start key again
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
	
	ldmfd sp!, {r0-r10, pc}

@--------------------------

	.pool
	.data
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
	.ascii	"SEEN. THESE ARE SOURCED FROM THE NON-SPECTRUM VERSIONS OF THE GAME, AND COLLATED AND DESCRIBED "
	.ascii	"BY STUART CAMPBELL. THE BOTTOM SCREEN SHOWS WHERE THESE LEVELS CAME FROM AND "
	.ascii	"THE YEAR OF RELEASE.   SEVERAL OF THE LEVELS HAVE HAD TO BE 'SLIGHTLY' MODIFIED TO KEEP THEM "
	.ascii	"CORRECT USING THE ORIGINAL ZX SPECTRUM GAME MECHANICS (OTHER VERSIONS PLAYED SLIGHTLY "
	.ascii	"DIFFERENTLY). "
	.byte 0
	.align
titleGS:
	.asciz	"START GAME"
titleGM:
	.asciz	"GAME MODE: THE LOST LEVELS"
titleSL:
	.asciz	"START AT LEVEL: 01"
titleBL:
	.asciz	"PLAY BONUS LEVEL: LOCKED"
titleJB:
	.asciz	"PLAY JUKEBOX"