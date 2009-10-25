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

	.global initAudio
	.global updateAudio
	
	.arm
	.align
	.text

@------------------------------------------------
	
initAudio:

	stmfd sp!, {r0-r10, lr}
	
	mov r1, #GAMEMODE_AUDIO
	ldr r2, =gameMode
	str r1,[r2]
	
	bl fxOff
	bl specialFXStop
	bl clearOAM	
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3

	bl initVideoTitle
	bl initSprites
	bl clearSpriteData
	
	bl stopMusic
	
	bl fxFadeBlackInit
	bl fxFadeMax

	@ draw top and bottom screens
	
	ldr r0,=AudioTopTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=AudioTopTilesLen
	bl decompressToVRAM	
	ldr r0, =AudioTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =AudioTopMapLen
	bl dmaCopy
	ldr r0, =AudioTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =AudioTopPalLen
	bl dmaCopy

	ldr r0,=AudioBottomTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=AudioBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =AudioBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =AudioBottomMapLen
	bl dmaCopy
	ldr r0, =AudioBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =AudioBottomPalLen
	bl dmaCopy
	
	@ set vars first
	mov r0,#0
	ldr r1,=audioPointer
	str r0,[r1]
@	ldr r1,=audioPlaying
@	str r0,[r1]	
	ldr r1,=audioPointerDelay
	str r0,[r1]	
	ldr r1,=audioPointerFrame
	str r0,[r1]	

	mov r0,#1
	ldr r1,=moveTrap
	str r0,[r1]

	bl drawAudioText
	bl drawAudioBars
	bl initAudioSprites
	bl updateAudioPointer
	bl playSelectedAudio

	bl fxFadeIn
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------
	
updateAudio:

	stmfd sp!, {r0-r10, lr}

	@ er, do stuff here!
	
	bl moveAudioPointer
	bl drawAudioText
	bl drawSprite
	bl updateAudioPointer
	bl displayAudio

	ldr r0,=REG_KEYINPUT						@ Read key input register
	ldr r10,[r0]								@ Read key value
	tst r10,#BUTTON_START
	beq audioStartPressed
	tst r10,#BUTTON_A
	beq audioStartPressed
	tst r10,#BUTTON_B
	beq instantExit
	
	audioStartReturn:
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------
audioStartPressed:

	ldr r0,=audioPointer
	ldr r0,[r0]
	cmp r0,#3
	bne audioStartReturn

	instantExit:

	mov r0,#1
	ldr r1,=moveTrap
	str r0,[r1]
	ldr r1,=trapStart
	str r0,[r1]
	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWait5:
	ldr r1,=fxFadeBusy
	ldr r1,[r1]
	cmp r1,#0
	beq jumpout

	b justWait5

	jumpout:

	bl initTitleScreen

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------

drawAudioText:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=audioVT						@ game vol
	mov r1,#4
	mov r2,#10
	bl drawTextBigMain

	add r2,#2
	ldr r0,=audioMT						@ music on off
	ldr r3,=audioMusic
	ldr r4,[r3]
	mov r3,#19
	mul r4,r3
	add r0,r4
	mov r1,#7
	bl drawTextBigMain	

	add r2,#2
	ldr r0,=audioPT						@ now playing
	mov r1,#6
	bl drawTextBigMain

	ldr r1,=audioPlaying				@ display tune number
	ldr r1,[r1]
	ldr r3,=audioTuneList
	ldrb r1,[r3,r1]
	mov r0,r1
	add r0,#1
	mov r1,#22
	bl drawTextBigDigits

	@ diplay name of tune, use audioPlaying for offset

	add r2,#2	
	ldr r4,=audioPlaying
	ldr r4,[r4]
	mov r5,#27
	mul r4,r5
	ldr r0,=audioNames
	add r0,r4
	mov r1,#3
	bl drawTextBigMain	
	
	add r2,#2
	ldr r0,=audioET						@ exit
	mov r1,#7
	bl drawTextBigMain	
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------

updateAudioPointer:
	@ draw pointer at correct position and animate
	stmfd sp!, {r0-r10, lr}
	
	ldr r3,=audioPointerFrame
	ldr r0,=audioPointerDelay
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#4
	str r1,[r0]
	bpl updateAudioPointerDone
		ldr r4,[r3]
		add r4,#1
		cmp r4,#8
		moveq r4,#0
		str r4,[r3]
	updateAudioPointerDone:

	ldr r4,[r3]

	ldr r0,=audioPointer			@ 0-2
	ldr r0,[r0]
	ldr r1,=audioPointerY
	ldrb r2,[r1,r0]					@ r2=y coord
	ldr r0,=OBJ_ATTRIBUTE0(0)
	ldr r3, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r3,r2
	strh r3,[r0]	
	ldr r0,=OBJ_ATTRIBUTE2(0)
	mov r1,#0
	orr r1,r4, lsl #3				@ or r1 with sprite pointer *16 (for sprite data block)
	strh r1, [r0]					@ store it all back
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------
	
playSelectedAudio:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=audioPlaying
	ldr r1,[r1]
	ldr r2,=audioTuneList
	ldrb r0,[r2,r1]
	
@	bl levelMusicPlayEasy
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------
moveAudioPointer:

	stmfd sp!, {r0-r10, lr}

	ldr r0,=REG_KEYINPUT						@ Read key input register
	ldr r10,[r0]								@ Read key value
	tst r10,#BUTTON_UP; 	beq movePointerUD
	tst r10,#BUTTON_DOWN;	beq movePointerUD	
	tst r10,#BUTTON_LEFT;	beq moveAlter
	tst r10,#BUTTON_RIGHT;	beq moveAlter

		ldr r1,=trapStart	
		mov r0,#0;	str r0,[r1]
		ldr r1,=moveTrap	
		mov r0,#0;	str r0,[r1]
		b moveAPointerDone1	
	
	moveAPointerDone:
	
	bl moveTimer
	
	moveAPointerDone1:
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

movePointerUD:
	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne moveAPointerDone
	
	tst r10,#BUTTON_UP
	bne movePointerD
		@up
		ldr r1,=audioPointer
		ldr r2,[r1]
		subs r2,#1; movmi r2,#0
		str r2,[r1]
		b moveAPointerDone
	
	movePointerD:
		@dn
		ldr r1,=audioPointer
		ldr r2,[r1]
		add r2,#1
		cmp r2,#4; moveq r2,#3
		str r2,[r1]
		b moveAPointerDone

@-------------------------------------------------

moveTimer:

	stmfd sp!, {r0-r10, lr}

	ldr r1,=moveTrap	
	ldr r0,[r1]
	add r0,#1
	cmp r0,#POINTER_DELAY
	moveq r0,#0; str r0,[r1]

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

moveAlter:
	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne moveAPointerDone

	ldr r0,=audioPointer
	ldr r0,[r0]
	cmp r0,#2
	bne notTune
	
		@ alter Music playing @later add a check to see if that tune is unlocked yet!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
		tst r10,#BUTTON_RIGHT
		bne movePointerL

@		
getAnotherTune:
@
		
			@R
	selectRight:
			ldr r0,=audioPlaying
			ldr r1,[r0]
			
			rightHeard:
			add r1,#1

			ldr r2,=audioTuneList
			rightNew:
			ldrb r3,[r2,r1]					@ check if we are at end of the list
			cmp r3,#255
			moveq r1,#0						@ if so, return to the beginning
			beq rightNew
			
			@ ok, check if tune r3 had been heard
			
			ldr r4,=musicHeard
			ldrb r4,[r4,r3]
			cmp r4,#0
			beq rightHeard

			str r1,[r0]
			mov r0,r3
			bl playSelectedAudio
			b moveAPointerDone
	
		movePointerL:
			@L
		selectLeft:
			ldr r0,=audioPlaying
			ldr r1,[r0]
			leftHeard:
			
			subs r1,#1
			bpl leftOld
				@ ok, now we need to scan audioTuneList for 255 and be that -1
				mov r1,#0
				ldr r2,=audioTuneList
				musicScan:
					ldrb r3,[r2,r1]
					cmp r3,#255
					beq musicScanDone
					add r1,#1
				b musicScan
				musicScanDone:
				sub r1,#1
			leftOld:			
			
			ldr r2,=audioTuneList
			ldrb r3,[r2,r1]
			str r1,[r0]
			
			@ ok, check if tune r3 had been heard
			
			ldr r4,=musicHeard
			ldrb r4,[r4,r3]
			cmp r4,#0
			beq leftHeard			
			
			
			
			mov r0,r3			
			bl playSelectedAudio
			b moveAPointerDone	
	notTune:
	cmp r0,#0
	bne notVol
		@ alter SFX Volume
		tst r10,#BUTTON_RIGHT
		bne movePointerAL
		@vol up
			ldr r1,=audioSFXVol
			ldr r2,[r1]
			add r2,#1
			cmp r2,#8
			moveq r2,#7
			str r2,[r1]
			blne playKey
			bl drawAudioBars
			b moveAPointerDone			
		movePointerAL:
		@VolDown
			ldr r1,=audioSFXVol
			ldr r2,[r1]
			subs r2,#1
			movmi r2,#0
			str r2,[r1]
			bl drawAudioBars
			bl playKey
			b moveAPointerDone			
	notVol:
	cmp r0,#1
	bne notMusicOn
		@ turn on/off ingame musc
		tst r10,#BUTTON_RIGHT
		ldr r1,=audioMusic
		moveq r2,#1
		movne r2,#0
		str r2,[r1]
		
		b moveAPointerDone	
	notMusicOn:
	
	
	b moveAPointerDone
@-------------------------------------------------

drawAudioBars:

	@ draw bars based on audioSFXVol 0-7

	stmfd sp!, {r0-r10, lr}
	
	ldr r4,=audioSFXVol
	ldr r4,[r4]							@ r4=volume
	lsl r4,#7
	
	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)
	add r0, #1536						@ first tile of offscreen tiles
	add r0,r4							@ r0 = source

	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ r1 = destination
	add r1,#(32*10)*2
	add r1,#21*2
	mov r2,#14
	
	bl dmaCopy

	add r0,#64; add r1,#64
	
	bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

displayAudio:

	@ just a test for now!


	stmfd sp!, {r0-r10, lr}
	ldmfd sp!, {r0-r10, pc}	
bl DC_FlushAll
	ldr r0, =Module		@ This is the pointer to XM7_ModuleManager_Type where the data is loaded via XM7_LoadXM
	ldr r1,=46
	add r0, r1			@ Add the byte offset to channels
	ldrb r10, [r0] 		@ Read the byte value of channels
	
	ldr r2,=xmChannels	
	str r10,[r2]		@ store number of channels

	ldr r0, =Module		@ This is the pointer to XM7_ModuleManager_Type where the data is loaded via XM7_LoadXM
	ldr r1,=1596
	add r0, r1			@ Add the byte offset to channels
	ldrb r10, [r0] 		@ Read the byte value of channels

	@ r10 = number to display
	@ r7 = 0 = Main, 1 = Sub
	@ r8 = height to display to
	@ r9 = number of Digits to display
	@ r11 = X coord

	mov r7,#0
	mov r8,#1
	mov r9,#8
	mov r11,#1

	@bl drawDigits
	
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

.pool
.data
.align
xmChannels:
	.word 0
moveTrap:
	.word 0
audioPointer:					@ pointer value 0-3
	.word 0
audioPointerFrame:
	.word 0
audioPointerDelay:
	.word 0
audioPlaying:					@ what tune?
	.word 1	
.align
audioPointerY:					@ pointer Y values
	.byte 81,97,113,145
audioTuneList:					@ values of the tunes for r0, 0-? (end with 255)
	.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,255
audioVT:
	.asciz	"SFX GAME VOLUME:"		@ 24
audioMT:
	.asciz	"IN GAME MUSIC: OFF"
	.asciZ	"IN GAME MUSIC: ON "	@ 18
audioPT:
	.asciz	"- SELECT  TUNE: 00 -"	@ 20
audioNames:					@ names of all the tunes in order of audioTuneList offset (0-?)
	.asciz	"MINER WILLY'S MINING SONG!"	@ 26+1
	.asciz	"  ON A DARK MINING NIGHT  "
	.asciz	"MINER WILLY, SPACE EXPORER"
	.asciz	" THE PHARAOH'S LITTLE JIG "
	.asciz	"    WILLY'S LITTLE RAG    "
	.asciz	"    SMITHS EAR BLEEDER    "
	.asciz	"     AS TIME GOES BY.     "
	.asciz	"      DOWN THE ALLEY      "
	.asciz	" THE MIGHTY JUNGLE BEASTS "
	.asciz	"PLAYING LIVE AT THE CAVERN"
	.asciz	"   THE ODDNESS OF BEING   "
	.asciz	"   REGGIE LIKE'S REGGAE   "
	.asciz	"    TIME TO TERMINATE!    "
	.asciz	" THE 80'S WILL NEVER DIE! "
	.asciz	"   SIT DOWN RAY PARKER!   "
	.asciz	"THERE'S A CHUNK IN MY EYE!"
	.asciz	" SCREAM AND SCREAM AGAIN! "
	.asciz	"HOBNAIL BOOTS, AND TOP HAT"
	.asciz	" THE MICROWAVE GOES 'POP' "
	.asciz	"   TOP OF THE WORLD MA!   "
	.asciz	"AND SOMEONE MENTIONED YES!"
	.asciz	"  SEEN MY SHUTTLE, COCK?  "
	.asciz	"    A LIFE UNDERGROUND    "
	.asciz	" LOOKS LIKE A COLD FRONT! "
	.asciz	" IT'S TIME TO RETURN HOME "
	.asciz	" COMMODORES LITTLE WILLY! "
	.asciz	"  THE TITLED SIR. WILLY!  "
	.asciz	"     A SOMBER MOMENT.     "
	.asciz	"   OH JOY! BIG NUMBERS!   "
	.asciz	"   MARCH OF THE MINERS.   "
	.asciz	"  THE DEMONIC WHALE SONG  "
	.asciz	" ALL THIS DOOM AND GLOOM! "
	.asciz	" SUPERHEROES COME TO REST "
	.asciz	"       BAH! HUMBUG!       "
	.asciz	"   BEING SO TRIUMPHANT!   "
	.asciz	"      THE LAST WALTZ      "	

audioET:
	.asciz "EXIT AUDIO OPTIONS"				@ 18

@ call levelMusicPlayEasy with r0 to set to the tune to play	