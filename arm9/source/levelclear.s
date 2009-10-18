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
	.global initLevelClear
	.global levelClear
	
	
initLevelClear:										@ set up the level clear dat

	stmfd sp!, {r0-r10, lr}	

	bl stopTimer3

	@ first, remove willy
	mov r1,#0
	ldr r2,=spriteActive+256
	str r1,[r2]

	ldr r0,=gameMode
	mov r1,#GAMEMODE_LEVEL_CLEAR
	str r1,[r0]
	
	ldr r0,=levelEndTimer
	ldr r1,=450				@ 350 works
	str r1,[r0]
	
	ldr r1,=spriteActive		@ Close the door
	mov r0,#63					@ use the 63rd sprite
	mov r2,#EXIT_CLOSED			@ Stop door anim
	str r2,[r1,r0,lsl#2]
	mov r3,#DOOR_FRAME
	ldr r1,=spriteObj
	str r3,[r1,r0,lsl#2]
	
	bl fxStarburstInit
	
	bl playLevelEnd
	
	@ if this is a bonus level, we need to check the timer and see if we have a record!
	
	ldr r0,=levelNum
	ldr r0,[r0]
	sub r0,#1
	ldr r1,=levelTypes
	ldr r1,[r1,r0,lsl#2]
	cmp r1,#2
	bne notABonusLevel
	
		@ ok, bonus level
		
		ldr r0,=cheat2Mode
		ldr r0,[r0]
		cmp r0,#1
		beq notABonusLevel
	
		bl checkBonusTimer
	
	notABonusLevel:
	
	
	
	
	ldmfd sp!, {r0-r10, pc}	
@-----------------------------------------------

levelClear:											@ do the level clear stuff

	stmfd sp!, {r0-r10, lr}	
	
	
	ldr r0,=levelEndTimer
	ldr r10,[r0]
	
	
	levelClearLoop:
	
		bl swiWaitForVBlank	
		ldr r0,=cheat2Mode
		ldr r0,[r0]
		cmp r0,#1
		beq cheatClear
		ldr r0,=levelNum
		ldr r0,[r0]
		cmp r0,#21
		beq cheatClear
		ldr r0,=minerDelay
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
		bne skipFrameClear
			cheatClear:
			bl monsterMove
			bl scoreAir
		skipFrameClear:	
	
		bl drawSprite
		bl levelAnimate	
		bl drawScore
		bl updateSpecialFX	
		bl drawAir	
	
		bl fxMoveStarburst
	
	subs r10,#1
	bpl levelClearLoop
	
	bl levelNext
	
	ldmfd sp!, {r0-r10, pc}		
	
@-----------------------------------------------	
	
scoreAir:											@ reduce Air and score it

	stmfd sp!, {r0-r10, lr}		

	ldr r1,=air
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#0
	str r2,[r1]
	bmi scoreAirDone
	
		mov r4,#3
		ldr r5,=adder+5
		strb r4,[r5]
		bl addScore

	scoreAirDone:

	ldmfd sp!, {r0-r10, pc}

@-----------------------------------------------	
	
checkBonusTimer:

	stmfd sp!, {r0-r10, lr}	


	ldr r1,=levelNum
	ldr r1,[r1]
	sub r1,#1
	ldr r2,=levelForTimer
	ldr r0,[r2,r1,lsl#2]
	mov r1,#12
	mul r0,r1				@ r0= offset from records (0-1-2-3-4-)
	ldr r8,=levelRecords
	add r8,r0				@ r8 points to mins
	mov r9,r8

mov r5,#0
ldr r1,=bMin
ldr r1,[r1]
ldr r3,=1000000
mul r1,r3
add r5,r1
ldr r1,=bSec
ldr r1,[r1]
ldr r3,=10000
mul r1,r3
add r5,r1
ldr r1,=bMil
ldr r1,[r1]
add r5,r1	@ r5=our time

mov r6,#0
ldr r1,[r8]
ldr r3,=1000000
mul r1,r3
add r6,r1
add r8,#4
ldr r1,[r8]
ldr r3,=10000
mul r1,r3
add r6,r1
add r8,#4
ldr r1,[r8]
add r6,r1	@ r6=record

cmp r5,r6
bge notARecord

	@ ok, this is a record, copy to new record and display
	
	mov r3,r9
	ldr r1,=bMin
	ldr r1,[r1]
	str r1,[r3]
	mov r10,r1
	mov r7,#0
	mov r11,#14
	mov r8,#2
	mov r9,#2
	bl drawDigitsB	
	
	add r3,#4
	ldr r1,=bSec
	ldr r1,[r1]
	str r1,[r3]	
	mov r10,r1
	mov r7,#0
	mov r11,#17
	mov r8,#2
	mov r9,#2
	bl drawDigitsB
	
	add r3,#4
	ldr r1,=bMil
	ldr r1,[r1]
	str r1,[r3]
	mov r10,r1
	mov r7,#0
	mov r11,#20
	mov r8,#2
	mov r9,#3
	bl drawDigitsB

	@ ok, now we need to do something to make a noise and signal success!!


notARecord:

	ldmfd sp!, {r0-r10, pc}

	.pool
	.data
	
	levelEndTimer:
		.word 0