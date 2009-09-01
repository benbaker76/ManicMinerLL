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
	
	.global spriteActive
	.global spriteX
	.global spriteY
	.global spriteObj
	.global spriteObjBase
	.global spriteHFlip
	.global spriteBloom
	.global spriteAnimDelay
	.global spriteDir
	.global spriteMin
	.global spriteMax
	.global spriteSpeed
	.global spriteMonster
	.global spriteMonsterMove
	.global spriteMonsterFlips
	.global spritePriority

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
	.global conveyorFrame
	.global conveyorDirection
	.global lastMiner
	.global faller
	.global minerDied
	.global keyCounter
	.global exitX
	.global exitY
	.global monsterDelay
	
	.global specialEffect
	
gameMode:
	.word 0

fxMode:
	.word 0

digits:
	.space 32

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
monsterDelay:
	.word 0

specialEffect:
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
	
spriteDataEnd:

	.align

willyJumpData:
	.byte -2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,0,0,0,0
	.byte 0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2

	@ Game values

levelNum:
	.word 1
	
	.pool
	.end
