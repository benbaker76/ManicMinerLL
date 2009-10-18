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
#include "audio.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "ipc.h"
#include "timers.h"

	.arm
	.text
	.align
	.global startTimer
	.global stopTimer
	.global stopTimer3
	.global timerTimer2
	.global timerTimer3
	.global bonusTimerInit
	.global displayBonusTimer
	
	.global timerElapsed
	
startTimer:

	@ r0 - timer count in milliseconds
	@ r1 - callback function address

	stmfd sp!, {r0-r2, lr}
	
	bl stopTimer
	
	ldr r2, =timerCount
	str r0, [r2]
	
	ldr r2, =callbackAddress
	str r1, [r2]
	
	ldr r0, =timerElapsed
	ldr r1, =0
	str r1, [r0]
	
	ldr r0, =TIMER2_DATA
	ldr r1, =TIMER_FREQ(1000)
	strh r1, [r0]
	
	ldr r0, =TIMER2_CR
	ldr r1, =(TIMER_ENABLE | TIMER_IRQ_REQ | TIMER_DIV_1)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc}								@ Return
	
	@ ---------------------------------------------

stopTimer:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =TIMER2_CR
	ldrh r1, [r0]
	bic r1, #TIMER_ENABLE
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}								@ Return
	
	@ ---------------------------------------------
stopTimer3:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =TIMER3_CR
	ldrh r1, [r0]
	bic r1, #TIMER_ENABLE
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}								@ Return
	
	@ ---------------------------------------------
timerTimer2:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =timerElapsed
	ldr r1, [r0]
	
	ldr r2, =timerCount
	ldr r2, [r2]
	cmp r1, r2
	bleq stopTimer
	blne timerTimer2Return

	ldr lr, =timerTimer2Return
	ldr r0, =callbackAddress
	ldr r0, [r0]
	bx r0
	
timerTimer2Return:
	
	ldr r0, =timerElapsed
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]

	ldmfd sp!, {r0-r2, pc}								@ Return
	
	@ ------------------------------------------

bonusTimer:

	stmfd sp!, {r0-r2, lr}
	
	bl stopTimer3
	
	ldr r1, =0
	ldr r0, =bMin
	str r1, [r0]
	ldr r0, =bSec
	str r1, [r0]
	ldr r0, =bMil
	str r1, [r0]
	
	ldr r0, =TIMER3_DATA
	ldr r1, =TIMER_FREQ(1024)
	strh r1, [r0]
	
	ldr r0, =TIMER3_CR
	ldr r1, =(TIMER_ENABLE | TIMER_IRQ_REQ | TIMER_DIV_1)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc}								@ Return

	@ ------------------------------------------

timerTimer3:

	stmfd sp!, {r0-r2, lr}

	ldr r2,=gameMode
	ldr r1,[r2]
	cmp r1,#GAMEMODE_PAUSED
	beq bTimerDone
	
	ldr r0,=levelNum
	ldr r0,[r0]
	sub r0,#1
	ldr r1,=levelTypes
	ldr r1,[r1,r0,lsl#2]
	cmp r1,#2
	bne bTimerDone
	ldr r0,=cheat2Mode
	ldr r0,[r0]
	cmp r0,#1
	beq bTimerDone

	ldr r0, =bMil
	ldr r1,[r0]
	add r1,#1
	cmp r1,#1000
	moveq r1,#0
	str r1,[r0]
	bne bTimerDone
	
		ldr r0, =bSec
		ldr r1,[r0]
		add r1,#1
		cmp r1,#60
		moveq r1,#0
		str r1,[r0]
		bne bTimerDone
			ldr r0, =bMin
			ldr r1,[r0]
			add r1,#1
			str r1,[r0]	
	
	
	bTimerDone:


	ldmfd sp!, {r0-r2, pc}	

	@ ---------------------------------------------

bonusTimerInit:
	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=levelNum
	ldr r0,[r0]
	sub r0,#1
	ldr r1,=levelTypes
	ldr r1,[r1,r0,lsl#2]
	cmp r1,#2
	bne bonusTimerInitFail
	ldr r0,=cheat2Mode
	ldr r0,[r0]
	cmp r0,#1
	beq bonusTimerInitFail
	@-----------
	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)		
	add r0, #1536					@ first tile of offscreen tiles
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	
	add r1,#7*2
	
	mov r2,#36
	mov r3,#3
	
	drawTimerBox:
	
	bl dmaCopy
	add r0,#64
	add r1,#64
	subs r3,#1
	bpl drawTimerBox
	
	@ draw text - time, best
	
	ldr r0,=bTimeText
	mov r1,#9
	mov r2,#1
	mov r3,#0
	mov r4,#4
	bl drawTextBlack
	ldr r0,=bBestText
	mov r1,#9
	mov r2,#2
	bl drawTextBlack	
	ldr r0,=bSeperator
	mov r1,#16
	mov r2,#1
	mov r4,#1
	bl drawTextBlack
	mov r1,#19
	mov r2,#1
	bl drawTextBlack	
	mov r1,#16
	mov r2,#2
	bl drawTextBlack
	mov r1,#19
	mov r2,#2
	bl drawTextBlack
	
	@ ok, now to draw the record
	
	ldr r1,=levelNum
	ldr r1,[r1]
	sub r1,#1
	ldr r2,=levelForTimer
	ldr r0,[r2,r1,lsl#2]
	mov r1,#12
	mul r0,r1				@ r0= offset from records (0-1-2-3-4-)
	ldr r1,=levelRecords
	add r1,r0				@ r1 points to mins
	
	ldr r10,[r1]
	mov r7,#0
	mov r11,#14
	mov r8,#2
	mov r9,#2
	bl drawDigitsB
	add r1,#4
	ldr r10,[r1]
	mov r7,#0
	mov r11,#17
	mov r8,#2
	mov r9,#2
	bl drawDigitsB	
	add r1,#4
	ldr r10,[r1]
	mov r7,#0
	mov r11,#20
	mov r8,#2
	mov r9,#3
	bl drawDigitsB
	
	bl bonusTimer				@ start timer
	@-----------
	bonusTimerInitFail:


	ldmfd sp!, {r0-r2, pc}	

	@ ------------------------------------------

displayBonusTimer:

	stmfd sp!, {r0-r8, lr}

	ldr r0,=levelNum
	ldr r0,[r0]
	sub r0,#1
	ldr r1,=levelTypes
	ldr r1,[r1,r0,lsl#2]
	cmp r1,#2
	bne noBonusTimer	
	ldr r0,=cheat2Mode
	ldr r0,[r0]
	cmp r0,#1
	beq noBonusTimer
	
	ldr r0,=bMil
	ldr r10,[r0]
	mov r7,#0
	mov r11,#20
	mov r8,#1
	mov r9,#3
	bl drawDigitsB	

	ldr r0,=bSec
	ldr r10,[r0]
	mov r7,#0
	mov r11,#17
	mov r8,#1
	mov r9,#2
	bl drawDigitsB

	ldr r0,=bMin
	ldr r10,[r0]
	mov r7,#0
	mov r11,#14
	mov r8,#1
	mov r9,#2
	bl drawDigitsB

	noBonusTimer:

	ldmfd sp!, {r0-r8, pc}
	
	.data
	.align
	
timerElapsed:
	.word 0
	
timerCount:
	.word 0
	
callbackAddress:
	.word 0
	
	.align
bTimeText:
	.asciz "TIME"
bBestText:
	.asciz "BEST"
bSeperator:
	.asciz ":"
	
	.pool
	.end
