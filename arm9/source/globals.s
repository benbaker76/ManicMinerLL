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

	.arm
	.align
	.data

	.global startOfSaveData
	.global endOfSaveData

	.global levelNum

	.global gameMode
	.global fxMode
	.global digits
	.global screenOrder
	
	.global levelForTimer
	.global levelRecords
	
	.global spriteActive
	.global spriteActiveSub
	.global spriteX
	.global spriteXSub
	.global spriteY
	.global spriteYSub
	.global spriteObj
	.global spriteObjSub
	.global spriteObjBase
	.global spriteHFlip
	.global spriteBloom
	.global spriteAnimDelay
	.global spriteAnimDelaySub
	.global spriteDir
	.global spriteMin
	.global spriteMinSub	
	.global spriteMax
	.global spriteMaxSub
	.global spriteSpeed
	.global spriteMonster
	.global spriteMonsterMove
	.global spriteMonsterFlips
	.global spritePriority
	.global spritePrioritySub
	.global spriteSize
	.global id
	
	.global titleVidInit
	
	.global spriteScreen

	.global cheatMode
	.global cheat2Mode

	.global minerDelay
	.global minerDirection
	.global minerAction
	.global jumpCount
	.global fallCount
	
	.global hiscoreText
	.global scoreText
	.global loadingText
	.global pleaseWaitText
	.global minerText
	.global darkText
	.global spaceText
	.global egyptianText
	.global pianoText
	.global spectrumText
	.global casablancaText
	.global catText
	.global jungleText
	.global cavernText
	.global atmosphereText
	.global reggaeText
	.global terminatorText
	.global snugText
	.global ghostbustersText
	.global gooniesText
	.global horrorText
	.global frankensteinText
	.global gremlinsText
	.global kingKongText
	.global toccataText
	.global shuttleText
	.global undergroundText
	.global coldText
	.global radioText
	.global oldiesText
	.global titleText
	.global gameOverText
	.global highScoreText
	.global deepText
	.global oopsText
	.global doomText
	.global heroText
	.global xmasText
	.global endText
	.global haltText
	.global oldText
	
	.global spriteDataStart
	.global spriteDataEnd
	.global willyJumpData
	.global willyJumpData2
	.global conveyorFrame
	.global conveyorDirection
	.global lastMiner
	.global faller
	.global minerDied
	.global keyCounter
	.global exitX
	.global exitY
	.global monsterDelay
	.global musicPlay
	.global switch1
	.global switch2
	.global switch3
	.global switch4
	.global minerJumpDelay
	.global minerLives
	.global controlMode
	.global air
	.global airDelay
	.global score
	.global adder
	.global highScore
	.global musicRestart
	.global willySpriteType
	.global switchX
	.global switchY
	.global switchOn
	.global levelWraps
	.global liftMotion
	.global jumpTrap
	
	.global trapStart
	
	.global specialEffect
	
	.global highScoreScore
	.global highScoreName
	.global levelLLReached
	.global levelHWReached
	.global levelLLSelected
	.global levelHWSelected
	.global unlockedHW
	.global unlockedSelected
	.global levelTypes
	.global unlockedBonusesSelected
	.global unlockedBonuses
	.global levelBank
	.global levelSpecialFound
	.global platFours
	
	.global audioMusic
	.global audioSFXVol
	.global sfxValues
	
	.global specialDelay
	.global deathAnimation
	.global bonusDelay
	.global cursorAction
	
	.global levelSpecial
	.global gameType
	.global musicHeard

	.global frameLeft
	.global frameRight
	
	.global mPhase
	.global leafAmount
	
	.global bMin
	.global bSec
	.global bMil
	
	.global gotRecord
	.global gameBegin
	
	.global trivia

	.global levelStartFrom

levelStartFrom:
	.word 0
	
gameBegin:
	.word 0

bMin:
	.word 0
bSec:
	.word 0
bMil:
	.word 0
	
titleVidInit:
	.word 0
jumpTrap:
	.word 0

fadeCheck:
	.word 0
cursorAction:
	.word 0
leafAmount:
	.word 0
	
mPhase:
	.word 0
	
gameMode:
	.word 0
controlMode:
	.word 0
air:
	.word 160
airDelay:
	.word 0
musicRestart:
	.word 0
levelWraps:
	.word 0
platFours:
	.word 0
	
cheatMode:
	.word 0
cheat2Mode:
	.word 0

fxMode:
	.word 0

digits:
	.space 32

switch1:
	.word 0
switch2:
	.word 0
switch3:
	.word 0
switch4:
	.word 0

liftMotion:
	.word 0
	
trapStart:
	.word 0

bonusDelay:
	.word 0


minerJumpDelay:
	.word 0
faller:
	.word 0
minerDied:
	.word 0
minerDelay:
	.word 0
minerDirection:					@ 0=no move, 1=left, 2=right
	.word 0
minerAction:					@ are we jumping, dieing, what?
	.word 0
jumpCount:						@ how far we have fallen
	.word 0
fallCount:
	.word 0
conveyorFrame:					@ 4 frames of animation to be used
	.word 0	
conveyorDirection:
	.word 0
lastMiner:
	.word 0
keyCounter:
	.word 0						@ number of keys collected
exitX:
	.word 0
exitY:
	.word 0
specialEffect:
	.word 0
musicPlay:
	.word 0
willySpriteType:
	.word 0
switchX:
	.word 0
switchY:
	.word 0
switchOn:
	.word 0
gotRecord:
	.word 0
	
	@ Text values
	
	.align
hiscoreText:
	.asciz "High Score"
	
	.align
scoreText:
	.asciz "Score"
	
	.align
loadingText:
	.asciz "LOADING..."
	
	.align
pleaseWaitText:
	.asciz "PLEASE WAIT"

	.align
minerText:
	.asciz "/Data/MMLL/Music/Miner"
	.align
darkText:
	.asciz "/Data/MMLL/Music/Dark"
	.align
spaceText:
	.asciz "/Data/MMLL/Music/Space"
	.align
egyptianText:
	.asciz "/Data/MMLL/Music/Egyptian"
	.align
pianoText:
	.asciz "/Data/MMLL/Music/Piano"
	.align
spectrumText:
	.asciz "/Data/MMLL/Music/Spectrum"
	.align
casablancaText:
	.asciz "/Data/MMLL/Music/Casablanca"
	.align
catText:
	.asciz "/Data/MMLL/Music/Cat"
	.align
jungleText:
	.asciz "/Data/MMLL/Music/Jungle"
	.align
cavernText:
	.asciz "/Data/MMLL/Music/Cavern"
	.align
atmosphereText:
	.asciz "/Data/MMLL/Music/Atmosphere"
	.align
reggaeText:
	.asciz "/Data/MMLL/Music/Reggae"
	.align
terminatorText:
	.asciz "/Data/MMLL/Music/Terminator"
	.align
snugText:
	.asciz "/Data/MMLL/Music/Snug"
	.align
ghostbustersText:
	.asciz "/Data/MMLL/Music/Ghostbusters"
	.align
gooniesText:
	.asciz "/Data/MMLL/Music/Goonies"
	.align
horrorText:
	.asciz "/Data/MMLL/Music/Horror"
	.align
frankensteinText:
	.asciz "/Data/MMLL/Music/Frankenstein"
	.align
gremlinsText:
	.asciz "/Data/MMLL/Music/Gremlins"
	.align
kingKongText:
	.asciz "/Data/MMLL/Music/KingKong"
	.align
toccataText:
	.asciz "/Data/MMLL/Music/Toccata"
	.align
shuttleText:
	.asciz "/Data/MMLL/Music/Shuttle"
	.align
undergroundText:
	.asciz "/Data/MMLL/Music/Underground"
	.align
coldText:
	.asciz "/Data/MMLL/Music/Cold"
	.align
radioText:
	.asciz "/Data/MMLL/Music/Radio"
	.align
oldiesText:
	.asciz "/Data/MMLL/Music/Oldies"
	.align
titleText:
	.asciz "/Data/MMLL/Music/Title"
	.align
gameOverText:
	.asciz "/Data/MMLL/Music/GameOver"
	.align
highScoreText:
	.asciz "/Data/MMLL/Music/HighScore"
	.align
deepText:
	.asciz "/Data/MMLL/Music/Deep"
	.align
oopsText:
	.asciz "/Data/MMLL/Music/Oops"
	.align
doomText:
	.asciz "/Data/MMLL/Music/Doom"
	.align
heroText:
	.asciz "/Data/MMLL/Music/Hero"
	.align
xmasText:
	.asciz "/Data/MMLL/Music/Xmas"
	.align
endText:
	.asciz "/Data/MMLL/Music/End"
	.align
haltText:
	.asciz "/Data/MMLL/Music/Halt"
	.align
oldText:
	.asciz "/Data/MMLL/Music/OldMiner"
	
	@ Sprite values
	
	.align
spriteDataStart:
	
spriteActive:
	.space 512
spriteX:
	.space 512
spriteY:
	.space 512
spriteObj:
	.space 512
spriteObjBase:
	.space 512
spriteHFlip:
	.space 512
spriteAnimDelay:
	.space 512
spriteDir:
	.space 512
spriteMin:
	.space 512
spriteMax:
	.space 512
spriteSpeed:
	.space 512
spriteMonster:
	.space 512
spriteMonsterMove:
	.space 512
spriteMonsterFlips:
	.space 512
spritePriority:
	.space 512
monsterDelay:
	.space 512
spriteSize:
	.space 512

spriteActiveSub:
	.space 512
spriteXSub:
	.space 512
spriteYSub:
	.space 512
spriteObjSub:
	.space 512
spriteAnimDelaySub:
	.space 512
spritePrioritySub:
	.space 512	
spriteMaxSub:
	.space 512
spriteMinSub:
	.space 512
spriteDataEnd:

	.align

willyJumpData:	@ dragon32/Oric mod
	.byte -2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0		@ 18
	.byte 0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2					@ 36
	willyJumpData2:	@ original Spectrum
	.byte -2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,0,0,0,0		@ 17
	.byte 0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2					@ 34


.align
	@ Game values

levelNum:
	.word 1

spriteScreen:
	.word 0
	
sfxValues:						@ values for sfx volume from 0-7 (0=off)
	.byte 0,20,35,50,70,90,110,127


	.align
score:
	.byte 0,0,0,0,0,0, 0,0
adder:
	.byte 0,0,0,0,0,0, 0,0

	.align
minerLives:
	.word 0
	
levelTypes:						@ a word for each level. 0=normal, 1=last level LL, 3=last level WW, 2=bonus
	.word 0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,1	@1-20 	- LL
	.word 2,2					@21-22	- Bonus
	.word 0,0,0,0,0,0,0,0,0,3	@23-32	- WW
	.word 2,2,2,2,2,2,2,2,2,2	@33-42	- Bonus
	.word 2,2,2,2,2,2,2,2		@43-50	- Bonus
levelBank:						@ 1=lost, 2=hollywood, 0=forget it (not important)
	.word 1,1,1,1,1,1,1,1,1,1
	.word 1,1,1,1,1,1,1,1,1,1
	.word 0,0
	.word 2,2,2,2,2,2,2,2,2,2
	.word 0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

levelSpecial:					@ adjusments for dif games (0=none, 1=Coupe - not walk on convs) 
	.word 0,0,0,0,0,0,0,0,0,0	@ 2=slippery 4s, 3=big jumper, 4=thin jump (original)
	.word 0,0,0,0,0,0,0,0,0,0
	.word 0,0
	.word 0,0,0,0,0,0,0,0,0,0
	.word 1,1,1,1,1,1,0,0,4,0
	.word 0,0,4,0,2,0,0,0
levelForTimer:
	.word 0,0,0,0,0,0,0,0,0,0	
	.word 0,0,0,0,0,0,0,0,0,0
	.word 0,1	@ 21 22
	.word 0,0,0,0,0,0,0,0,0,0
	.word 2,3,4,5,6,7,8,9,10,11 @ 33-42
	.word 12,13,14,15,16,17,18,19 @ 43-50

gameType:
	.word 0						@ store type in here from levelSpecial
	
frameLeft:
	.word 3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7	
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
	.word 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
frameRight:
	.word 4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0
	.word 7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0


@ THESE NEED TO BE SAVED AND LOADED

@---------------------------------------------------------------


.align
startOfSaveData:

	

id:
	.ascii "FLASH09"

highScoreScore:
	.byte 0,0,5,1,2,0
	.byte 0,0,4,0,9,6
	.byte 0,0,3,2,0,4
	.byte 0,0,2,7,1,0
	.byte 0,0,1,0,2,4
	.byte 0,0,0,9,0,9	@ 36+7
highScoreName:
	.ascii "FLASHMAN"
	.ascii " -LOBO- "
	.ascii "HEADKAZE"
	.ascii "REV.STU!"
	.ascii " SPACEF "
	.ascii " SVERX! "
musicHeard:
	.byte 0,1,0,0,0,0,0,0,0,0	@ 0-9			( set to one if the music is heard ingame)
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,1,1,0,0
	.byte 0,0,0,0,0,0,1,0,0,0	@ 30-39	(40 tunes)

@	.byte 1,1,1,1,1,1,1,1,1,1	@ 0-9			( set to one if the music is heard ingame)
@	.byte 1,1,1,1,1,1,1,1,1,1
@	.byte 1,1,1,1,1,1,1,1,1,1
@	.byte 1,1,1,1,1,1,1,1,1,1	@ 30-39	(40 tunes)
	
	.align
levelSpecialFound:				@ 0=not on level, 1=on level, 2=found
	.word 0,1,0,1,1,1,0,1,0,1
	.word 1,1,1,1,0,0,0,1,0,1
	.word 0,1					@ bonus 1 and 2 (20 and 21)
	.word 0,1,1,0,0,1,1,0,0,1	@ lost levels 23-32
	.word 0,0,0,0,0,0,0,0,0,0	@ bonus 3-12
	.word 0,0,1,0,0,1,0,0		@ bonus 13-20	( 32-49)

	.align
levelLLReached:					@ Lost max (highest visited)
	.word 1
levelLLSelected:				@ Lost level
	.word 1
levelHWReached:					@ hollywood max
	.word 1
levelHWSelected:				@ hollywood level
	.word 1
unlockedHW:						@ is hollywood unlocked yet?
	.word 0
unlockedSelected:				@ what is selected (0=lost, 1=holly)
	.word 0
screenOrder:					@ preference of the screen order	
	.word 0
unlockedBonuses:				@ 255=no, 1=first,2=second (number is max selectable)					
	.word 255
unlockedBonusesSelected:		@ current selected bonus level
	.word 1	

audioMusic:						@ play Music?
	.word 1	
audioSFXVol:					@ audio Volume
	.word 7
trivia:							@ bonus level trivia page
	.word -1

deathAnimation:
	.word -1					@ which animation to use on the game over

levelRecords:	
	@ bonus level records
	@ stored as min,sec,mil
	.word 0,15,0	@ 21	-	horace							ho
	.word 0,40,0	@ 22	-	blagger							bl
	.word 0,40,0	@ 33	- 	cheese plant					ch
	.word 0,30,0	@ 34	-	dodgy mine shaft				my
	.word 0,50,0	@ 35	-	the big drop					bi
	.word 0,45,0	@ 36	-	bouncy bouncy					bo
	.word 0,40,0	@ 37	-	rocky outcrop					ro
	.word 0,35,0	@ 38	-	bottom of the mine shaft		my
	.word 0,45,0	@ 39	-	cosmic causeway					cm
	.word 0,40,0	@ 40	-	that logo						th
	.word 0,35,0	@ 41	-	central cavern					re	al central
	.word 0,45,0	@ 42	-	final conflict					co				
	.word 0,35,0	@ 43	-	the vat							th
	.word 0,45,0	@ 44	-	mutant telephones				bu
	.word 0,35,0	@ 45	-	the warehouse					wa
	.word 0,35,0	@ 46	-	mummy daddy						wo??
	.word 0,50,0	@ 47	-	christmas charlie brown			ah
	.word 0,35,0	@ 48	-	endorian forest					ew
	.word 0,50,0	@ 49	-	jump for joy					ju
	.word 0,30,0	@ 50	-	the final barrier				fi

endOfSaveData:	

@-------------------------------------------

	.pool
	.end
