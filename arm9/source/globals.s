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


bMin:
	.word 0
bSec:
	.word 0
bMil:
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
	
	@ Text values
	
	.align
hiscoreText:
	.asciz "High Score"
	
	.align
scoreText:
	.asciz "Score"
	
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
spriteBloom:
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
	.byte -2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0
	.byte 0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
willyJumpData2:	@ original Spectrum
	.byte -2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,0,0,0,0
	.byte 0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2
	
	.byte 99
	.byte 3,3,3,3,3


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
	.byte 0,0,6,0,0,0,0,0
adder:
	.byte 0,0,0,0,0,0,0,0

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
	.word 0,1
	.word 0,0,0,0,0,0,0,0,0,0
	.word 2,3,4,5,6,7,8,9,10,11
	.word 12,13,14,15,16,17,18,19

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

startOfSaveData:

	
	.align
highScoreScore:
	.byte 0,0,5,1,2,0
	.byte 0,0,4,0,9,6
	.byte 0,0,3,2,0,4
	.byte 0,0,2,0,0,0
	.byte 0,0,1,0,2,4
	.byte 0,0,0,9,0,9
highScoreName:
	.ascii "FLASHMAN"
	.ascii " -LOBO- "
	.ascii "HEADKAZE"
	.ascii "FLETCHER"
	.ascii " SPACEF "
	.ascii " SVERX! "
musicHeard:
@	.byte 0,1,0,0,0,0,0,0,0,0	@ 0-9			( set to one if the music is heard ingame)
@	.byte 0,0,0,0,0,0,0,0,0,0
@	.byte 0,0,0,0,0,0,1,1,0,0
@	.byte 0,0,0,0,0,0,0,0,0,0	@ 30-39	(40 tunes)

	.byte 1,1,1,1,1,1,1,1,1,1	@ 0-9			( set to one if the music is heard ingame)
	.byte 1,1,1,1,1,1,1,1,1,1
	.byte 1,1,1,1,1,1,1,1,1,1
	.byte 1,1,1,1,1,1,1,1,1,1	@ 30-39	(40 tunes)
	
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
	.word 20
levelLLSelected:				@ Lost level
	.word 1
levelHWReached:					@ hollywood max
	.word 10
levelHWSelected:				@ hollywood level
	.word 1
unlockedHW:						@ is hollywood unlocked yet?
	.word 1
unlockedSelected:				@ what is selected (0=lost, 1=holly)
	.word 0
screenOrder:					@ preference of the screen order	
	.word 0
unlockedBonuses:				@ 255=no, 1=first,2=second (number is max selectable)					
	.word 20
unlockedBonusesSelected:		@ current selected bonus level
	.word 1	

audioMusic:						@ play Music?
	.word 1	
audioSFXVol:					@ audio Volume
	.word 7

deathAnimation:
	.word -1					@ which animation to use on the game over

levelRecords:	
	@ bonus level records
	@ stored as min,sec,mil
	.word 0,35,0
	.word 0,55,0
	.word 1,00,0
	.word 0,55,0
	.word 0,45,0
	.word 1,15,0
	.word 1,10,0
	.word 1,00,0
	.word 0,55,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0
	.word 2,30,0



endOfSaveData:	

@-------------------------------------------
				
	.pool
	.end
