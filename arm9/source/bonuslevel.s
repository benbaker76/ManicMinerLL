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
	.text
	
	.global bonusLevelUnlocked
	.global bonusAward
	
bonusAward:

	stmfd sp!, {r0-r10, lr}
	
	ldr r2,=gameMode
	ldr r2,[r2]
	cmp r2,#GAMEMODE_TITLE_SCREEN
	beq bonusAwardDone
	
	ldr r2,=levelNum
	ldr r2,[r2]
	sub r2,#1
	
	ldr r1,=levelSpecialFound
	ldr r1,[r1,r2,lsl#2]
	cmp r1,#1
	bne bonusAwardNot
	
	bl initBonusSprites
	b bonusAwardDone
	
	bonusAwardNot:
	
	mov r1, #ATTR0_DISABLED	
	ldr r0,=OBJ_ATTRIBUTE0(0)
	strh r1,[r0]
	ldr r0,=OBJ_ATTRIBUTE0(1)
	strh r1,[r0]	
	
	bonusAwardDone:

	ldmfd sp!, {r0-r10, pc}

bonusLevelUnlocked:

	stmfd sp!, {r0-r10, lr}
	
	@ ok, init starburst thing at location of collection
	@ ok, r0 = offset, r1=colmap
	@ use fxBonusBurst for effect, but we need new sprites first (bonus.png)	
	
	bl fxBonusburstInit
	ldr r0,=bonusDelay
	mov r1,#125
	str r1,[r0]

	mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
	ldr r0,=0x07000000
	strh r1,[r0]
	add r0,#8
	strh r1,[r0]
	
	@ load the graphics needed (do not use on level 20)
	
	ldr r0,=BonusSparkleTiles
	ldr r1,=SPRITE_GFX_SUB
	add r1,#40*256				@ dump at 40th sprite onwards
	ldr r2,=8*256
	bl dmaCopy

	@ play a special sound effect for the opening of a bonus level

	ldmfd sp!, {r0-r10, pc}
