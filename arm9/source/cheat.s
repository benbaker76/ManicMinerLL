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

#include "MMLL.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	#define	CHEAT_AMOUNT 		4
	#define	CHEAT2_AMOUNT 		6
	
	.arm
	.align
	.text
	.global initCheat
	.global updateCheatCheck
	.global useCheat
	.global initCheat2
	.global updateCheat2Check
	.global useCheat2
	
initCheat:

	stmfd sp!, {r0-r8, lr}

	ldr r0, =cheatSection
	mov r1, #0
	str r1, [r0]
	ldr r0, =cheatKey
	str r1,[r0]
	
	ldmfd sp!, {r0-r8, pc}
	
	@---------------------------------

updateCheatCheck:
	@ repeating the sequence (you can change if wanted) will turn cheats on and off
	stmfd sp!, {r0-r8, lr}
	
	ldr r1, =REG_KEYINPUT						@ Read Key Input
	ldr r2, [r1]
	ldr r8,=1023								@ all buttons clear (but in DS=set?)
	cmp r2,r8
	beq noCheatKey								@ if no key pressed, no need to check!
	ldr r3,=cheatKey
	ldr r3,[r3]
	cmp r2,r3
	bne cheatCheck								@ if key pressed is same, wait for release 
	ldmfd sp!, {r0-r8, pc}

	cheatCheck:
	ldr r4,=cheatSequence
	ldr r5,=cheatSection
	ldr r7,[r5]
	ldr r6,[r4, r7, lsl #2]					@ r6=key in sequence to find
	tst r2,r6
	bne wrongCheatKey
		add r7,#1
		cmp r7,#CHEAT_AMOUNT
		beq activateCheat
		str r7,[r5]
		ldr r3,=cheatKey
		str r2,[r3]
		ldmfd sp!, {r0-r8, pc}	
	
	wrongCheatKey:
		mov r7,#0
		str r7,[r5]
		ldr r3,=cheatKey
		str r2,[r3]
		ldmfd sp!, {r0-r8, pc}	

	noCheatKey:
		mov r2,#0
		ldr r3,=cheatKey
		str r2,[r3]
		ldmfd sp!, {r0-r8, pc}
		
	activateCheat:
		mov r2,#0
		str r2,[r5]					@ reset cheatSection	
		ldr r5,=cheatMode
		ldr r6,[r5]
		cmp r6,#0
		beq activateCheatON
@---------- Cheats off
	
	mov r2,#0
	str r2,[r5]
	
	bl playDead		
	
	ldmfd sp!, {r0-r8, pc}		
	
@---------- Cheats on
	
	activateCheatON:
	
	mov r2,#1
	str r2,[r5]
	
	bl playDead	

	ldmfd sp!, {r0-r8, pc}



@----------------------------------------------------------------------------


	
	@---------------------------------
initCheat2:

	stmfd sp!, {r0-r8, lr}

	ldr r0, =cheat2Section
	mov r1, #0
	str r1, [r0]
	ldr r0, =cheat2Key
	str r1,[r0]
	
	ldmfd sp!, {r0-r8, pc}
	
	@---------------------------------

updateCheat2Check:
	@ repeating the sequence (you can change if wanted) will turn cheats on and off
	stmfd sp!, {r0-r8, lr}
	
	ldr r1, =REG_KEYINPUT						@ Read Key Input
	ldr r2, [r1]
	ldr r8,=1023								@ all buttons clear (but in DS=set?)
	cmp r2,r8
	beq noCheat2Key								@ if no key pressed, no need to check!
	ldr r3,=cheat2Key
	ldr r3,[r3]
	cmp r2,r3
	bne cheat2Check								@ if key pressed is same, wait for release 
	ldmfd sp!, {r0-r8, pc}

	cheat2Check:
	ldr r4,=cheat2Sequence
	ldr r5,=cheat2Section
	ldr r7,[r5]
	ldr r6,[r4, r7, lsl #2]					@ r6=key in sequence to find
	tst r2,r6
	bne wrongCheat2Key
		add r7,#1
		cmp r7,#CHEAT2_AMOUNT
		beq activateCheat2
		str r7,[r5]
		ldr r3,=cheat2Key
		str r2,[r3]
		ldmfd sp!, {r0-r8, pc}	
	
	wrongCheat2Key:
		mov r7,#0
		str r7,[r5]
		ldr r3,=cheat2Key
		str r2,[r3]
		ldmfd sp!, {r0-r8, pc}	

	noCheat2Key:
		mov r2,#0
		ldr r3,=cheat2Key
		str r2,[r3]
		ldmfd sp!, {r0-r8, pc}
		
	activateCheat2:
		mov r2,#0
		str r2,[r5]					@ reset cheatSection	
		ldr r5,=cheat2Mode
		ldr r6,[r5]
		cmp r6,#0
		beq activateCheat2ON
@---------- Cheats off
	
	mov r2,#0
	str r2,[r5]
	
	bl playDead		
	
	ldmfd sp!, {r0-r8, pc}		
	
@---------- Cheats on
	
	activateCheat2ON:
	
	mov r2,#1
	str r2,[r5]
	
	bl playDead	

	ldmfd sp!, {r0-r8, pc}
	
	@---------------------------------


	.data
	.align
	
cheatSection:
	.word 0

	.align
cheatSequence:									@ in the current check - you must use different key for each part!
	.word BUTTON_UP, BUTTON_DOWN, BUTTON_UP, BUTTON_DOWN

	.align
cheatKey:
	.word 0

cheat2Section:
	.word 0

	.align
cheat2Sequence:									@ in the current check - you must use different key for each part!
	.word BUTTON_LEFT, BUTTON_RIGHT, BUTTON_LEFT, BUTTON_RIGHT, BUTTON_UP, BUTTON_B

	.align
cheat2Key:
	.word 0

	.pool
	.end