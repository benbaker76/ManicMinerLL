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

	.global findHighscore
	.global enterHighscore
	
findHighscore:
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=cheatMode; ldr r0,[r0]; cmp r0,#1; beq highscoreReturn		@ if CHEATING - no highscore!! HA HA
	
	mov r0,#5						@ highscore position
	mov r1,#0						@ digit to check
	mov r10,#HIGH_SCORE_LEN			@ multiplier (6 digits per score)
	ldr r2,=score					@ score mem
	ldr r3,=highScoreScore			@ highscore mem
	
	highLoop:
		
		ldrb r4,[r2,r1]				@ r4=score digit (left to right)
		mul r5,r0,r10;	add r5,r1
		ldrb r5,[r3,r5]				@ r5=highscore digit
		cmp r4,r5					@ if score digit is < high, all done
		blt findHighscoreDone		
		beq findHighNextDigit		@ if score=high, move to next digit
									@ else, move up to next entry
			mov r1,#0
			subs r0,#1;	movmi r0,#-1
			bmi findHighscoreDone	@ if we are already at pos 0, we are top
			b findHighscoreNext
		findHighNextDigit:
			@ move to next digit
			add r1,#1;	cmp r1,#6;	beq findHighscoreDone
		findHighscoreNext:
	b highLoop
	
	findHighscoreDone:
	
	@ if r0+1=6, no score (0-5 = entry point)

	cmp r0,#5
	blt enterHighScore
	
	@ Clear up and return to title...

	highscoreReturn:

	bl resetScrollRegisters

	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]

	ldr r1,=spriteScreen					@ put it back to the top screen for Drawsprite
	str r0,[r1]

	bl fxFadeBlackInit
	bl fxFadeOut

	justWait:
	ldr r1,=fxFadeBusy
	ldr r1,[r1]
	cmp r1,#0
	beq jumpGameOver

	b justWait

	jumpGameOver:
	
	bl initTitleScreen
	
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------------------------

enterHighScore:
	@ draw screen and enter highscore

	add r10,r0,#1			@	R10 = position in table from 0-5

@	ldr r2,=levelNum
@	mov r1,#0
@	str r1,[r2]

	bl initVideoTitle
@	bl initVideoHigh
	bl clearSpriteData
@	bl clearBG0
	bl clearBG1
@	bl clearBG2
	bl resetScrollRegisters

	bl fxFadeBlackInit
	bl fxFadeMax

	@ first thing to do is make space.. If pos = 5, overwrite

		mov r0,#4					@ counter (till same as r10)
		mov r1,#HIGH_SCORE_LEN		@ len of score digits
		mov r2,#HIGH_NAME_LEN		@ len of score text
		ldr r3,=highScoreScore		@ score pointer
		ldr r4,=highScoreName		@ name pointer
	
		spacemakerLoop:
			@ do score first
			mov r5,#0					@ digit
			mul r7,r0,r1				@ r7=offset source
			add r7,r3					@ r7=actual data position
			cmp r10,#5
			addeq r7,r1
			add r8,r7,r1				@ r8=destination
			spacemakerScore:
				cmp r10,#5
				beq hm1
				ldrb r9,[r7,r5];	strb r9,[r8,r5]	
				cmp r10,r0
				bne spacemakerScoreNoClear
				hm1:
				ldr r11,=score
				ldrb r9,[r11,r5];	strb r9,[r7,r5]
				spacemakerScoreNoClear:
				add r5,#1
				cmp r5,#HIGH_SCORE_LEN
			bne spacemakerScore
			@ now name
			mov r5,#0					@ letter
			mul r7,r0,r2				@ r7=offset source
			add r7,r4					@ r7=actual data position
			cmp r10,#5
			addeq r7,r2
			add r8,r7,r2				@ r8=destination
			spacemakerName:
				cmp r10,#5
				beq hm2
				ldrb r9,[r7,r5];	strb r9,[r8,r5]	
				cmp r10,r0
				bne spacemakerNameNoClear
				hm2:
				ldr r11,=highNameBlank
				ldrb r9,[r11,r5];	strb r9,[r7,r5]
				spacemakerNameNoClear:				
				add r5,#1
				cmp r5,#HIGH_NAME_LEN
			bne spacemakerName
		cmp r10,#5
		beq noNeedForSpace
		sub r0,#1
		cmp r0,r10
		bge spacemakerLoop
	
	noNeedForSpace:
	
	@ ok, Set up the display and allow name entry at pos r10
	
	ldr r0,=BigFontTiles							@ copy the tiles used for large font to main
	ldr r1,=BG_TILE_RAM(BG0_TILE_BASE)
	ldr r2,=BigFontTilesLen
	bl decompressToVRAM
	ldr r0,=BigFontPal
	ldr r1, =BG_PALETTE
	ldr r2, =512
	bl dmaCopy
	
	@ load sprites
	
	ldr r0, =HighSpritesPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE
	bl dmaCopy

	ldr r0, =HighSpritesTiles
	ldr r2, =HighSpritesTilesLen
	ldr r1, =SPRITE_GFX
	bl dmaCopy	
	
	mov r0,#1
	ldr r1,=spriteScreen							@ set drawsprite to use main
	str r0,[r1]	
	ldr r1,=trapStart								@ trap start button
	str r0,[r1]
	ldr r1,=moveTrap
	str r0,[r1]
	
	mov r0,#0
	ldr r1,=exitHigh
	str r0,[r1]
	
	@ draw 2 screens
	
	ldr r0,=HighTopTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=HighTopTilesLen
	bl decompressToVRAM	
	ldr r0, =HighTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =HighTopMapLen
	bl dmaCopy
	ldr r0, =HighTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =HighTopPalLen
	bl dmaCopy
	@ we now need to grab the "face expression" from the bottom map based on r10
	ldr r0, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)
	add r0, #1536					@ first tile of offscreen tiles
	mov r1,#5
	mov r2,#5
	sub r2,r10
	mul r2,r1
	add r0,r2,lsl#1					@ r0=source
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)
	add r1,#(18*32)*2
	add r1,#13*2					@ r1=dest
	mov r2,#5*2						@ length
	mov r3,#3
	mouthLoop:
		bl dmaCopy
		add r0,#64
		add r1,#64
		subs r3,#1
	bpl mouthLoop
	
	ldr r0,=HighBotTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=HighBotTilesLen
	bl decompressToVRAM	
	ldr r0, =HighBotMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =HighBotMapLen
	bl dmaCopy
	ldr r0, =HighBotPal
	ldr r1, =BG_PALETTE
	ldr r2, =HighBotPalLen
	bl dmaCopy
	
	mov r1,#0
	ldr r0,=entryFrame
	str r1,[r0]
	ldr r0,=entryDelay
	str r1,[r0]

	bl fxFadeIn	
	
	@ play music
	
	mov r0,#28
	bl levelMusicPlayEasy
	
	bl displayHighscores

	@ ok, now we need to jump to the bit that allow us to alter the entry
	
	bl enterName

	b highscoreReturn

@---------------------------------------------	
	
displayHighscores:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=highScoreName
	mov r8,#5					@ number of lines to draw-1
	mov r1,#8					@ x coord
	mov r2,#9					@ y coord
	mov r3,#HIGH_NAME_LEN		@ length
	mov r9,#0					@ drawing chars
	dHighNameLoop:
		bl drawHighTextMain
		add r0,#HIGH_NAME_LEN
		add r2,#2
		subs r8,#1
	bpl dHighNameLoop
	ldr r0,=highScoreScore
	mov r8,#5					@ number of lines to draw-1
	mov r1,#18					@ x coord
	mov r2,#9					@ y coord
	mov r3,#HIGH_SCORE_LEN		@ length
	mov r9,#1					@ drawing digits
	dHighScoreLoop:
		bl drawHighTextMain
		add r0,#HIGH_SCORE_LEN
		add r2,#2
		subs r8,#1
	bpl dHighScoreLoop
	
	ldmfd sp!, {r0-r10, pc}

@---------------------------------------------	
	
drawHighCursor:

	stmfd sp!, {r0-r10, lr}
	
	@ r9= x position of cursor
	
	ldr r0,=spriteX
	mov r1,r9
	lsl r1,#3
	add r1,#64+62
	str r1,[r0]
	
	ldr r0,=spriteY
	mov r1,r10
	lsl r1,#4
	add r1,#384
	add r1,#64+9
	str r1,[r0]
	
	ldmfd sp!, {r0-r10, pc}

@---------------------------------------------	
	
enterName:

	stmfd sp!, {r0-r10, lr}
	
	mov r9,#0					@ current char to edit (0-7)
	
	@ init Cursor
	ldr r1,=spriteActive
	mov r0,#1
	str r0,[r1]
	ldr r1,=spriteObj
	mov r0,#0
	str r0,[r1]
	
	@ l/r char select, u/d char modify, fire/start =done
	
	enterNameLoop:

		bl swiWaitForVBlank
		
		bl moveHighCursor
		bl drawHighCursor
		bl fxSparkleInit
		bl drawSprite
		bl entryCursorAnim
		
	ldr r1,=exitHigh
	ldr r1,[r1]
	cmp r1,#0
	beq enterNameLoop
	
	ldmfd sp!, {r0-r10, pc}	
@---------------------------------------------	
	
entryCursorAnim:

	stmfd sp!, {r0-r8, lr}	

	ldr r1,=entryDelay
	ldr r0,[r1]; subs r0,#1; movmi r0,#4; str r0,[r1]
	bpl entryCursorAnimDone
		ldr r1,=entryFrame
		ldr r0,[r1]; add r0,#1; cmp r0,#4; moveq r0,#0; str r0,[r1]
		ldr r1,=spriteObj; str r0,[r1]
	
	entryCursorAnimDone:

	ldmfd sp!, {r0-r8, pc}	

@---------------------------------------------	
	
moveHighCursor:

	stmfd sp!, {r0-r8, lr}	
	
	ldr r0,=REG_KEYINPUT						@ Read key input register
	ldr r8,[r0]									@ Read key value
	tst r8,#BUTTON_START						@ start=Start game/activate highlight optio
	beq quitHigh		
	tst r8,#BUTTON_A
	beq quitHigh								@ B=back to normal title
	tst r8,#BUTTON_UP
	beq moveVPos
	tst r8,#BUTTON_DOWN
	beq moveVPos
	tst r8,#BUTTON_LEFT
	beq moveHPos
	tst r8,#BUTTON_RIGHT
	beq moveHPos

	ldr r0,=moveTrap
	mov r1,#0
	str r1,[r0]
	ldr r0,=trapStart
	str r1,[r0]
	ldr r0,=cursorAction
	str r1,[r0]
	
	b moveHighCursorReturn
	
	moveHighCursorReturnAdder:	
	
		ldr r0,=moveTrap
		ldr r1,[r0]
		add r1,#1
		cmp r1,#8
		moveq r1,#0
		str r1,[r0]
	
	
	moveHighCursorReturn:
	
	ldmfd sp!, {r0-r8, pc}	

@----------------------------------------

quitHigh:

	ldr r1,=trapStart
	ldr r0,[r1]
	cmp r0,#0
	bne moveHighCursorReturn
	
	mov r0,#1;	str r0,[r1]

	ldr r1,=exitHigh;	mov r0,#1;	str r0,[r1]
	
	@ now copy the typed text to the buffer, so it appears next time..
	
	mov r0,#0
	quitHighLoop:
	
		ldr r1,=highScoreName
		mov r2,r10;	lsl r2,#3;	add r1,r2; 	add r1,r0		@ r1=source
		ldr r2,=highNameBlank
		ldrb r3,[r1]
		strb r3,[r2,r0]
		add r0,#1
		cmp r0,#8
	bne quitHighLoop
	
	b moveHighCursorReturn

@----------------------------------------

moveHPos:	
	
	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne moveHPosDone
	
	tst r8,#BUTTON_LEFT
	bne moveHPosRight
	
	@ cursor left
	
		subs r9,#1;	movmi r9,#0	
		mov r1,#1
		str r1,[r0]
		b moveHighCursorReturn
	
	moveHPosRight:

		add r9,#1
		cmp r9,#HIGH_NAME_LEN;	movge r9,#HIGH_NAME_LEN-1
		mov r1,#1
		str r1,[r0]
		b moveHighCursorReturn
	
		moveHPosDone:
	b moveHighCursorReturnAdder

@-----------------------------

moveVPos:
	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne moveVPosDone
	
	tst r8,#BUTTON_DOWN
	bne moveVPosDown
	
	@ cursor up
		mov r1,#1
		str r1,[r0]

		ldr r1,=highScoreName
		
		mov r2,r10;	lsl r2,#3;	add r1,r2; 	add r1,r9
		ldrb r2,[r1]
		sub r2,#1
		cmp r2,#31;		moveq r2,#57
		cmp r2,#32;		moveq r2,#65+25
		cmp r2,#64;		moveq r2,#32
		strb r2,[r1]

		ldr r1,=cursorAction
		mov r2,#2
		str r2,[r1]
	
		bl displayHighscores
		b moveHighCursorReturn	

	moveVPosDown:

	@ cursor down
		@ use r10 to find the row and r9 to find the char
		mov r1,#1
		str r1,[r0]

		ldr r1,=highScoreName
		
		mov r2,r10;	lsl r2,#3;	add r1,r2;	add r1,r9
		ldrb r2,[r1]
		add r2,#1
		cmp r2,#33; 	moveq r2,#65
		cmp r2,#65+26;	moveq r2,#33
		cmp r2,#58;		moveq r2,#32
		strb r2,[r1]

		ldr r1,=cursorAction
		mov r2,#1
		str r2,[r1]

		bl displayHighscores
		b moveHighCursorReturn

	moveVPosDone:
	b moveHighCursorReturnAdder

.pool
.data

.align
highNameBlank:
	.asciz "        "
	
.align
exitHigh:
	.word 0
entryFrame:
	.word 0
entryDelay:
	.word 0
