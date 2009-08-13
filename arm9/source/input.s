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

	#define INPUT_DELAY				16

	.arm
	.align
	.text
	.global readInput
	.global buttonPress
	.global buttonWaitPress
	.global keyWait
	
readInput:

	stmfd sp!, {r1-r6, lr}
	
	ldr r0, =buttonPress						@ Load hiScoreKeyPress address
	ldr r1, [r0]								@ Load hiScoreKeyPress value
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r3, [r2]								@ Read key value
	
	mov r4, r3
	and r4, #(BUTTON_UP	| BUTTON_DOWN | BUTTON_LEFT | BUTTON_RIGHT | BUTTON_A | BUTTON_B | BUTTON_SELECT | BUTTON_START)	
	cmp r4, #(BUTTON_UP	| BUTTON_DOWN | BUTTON_LEFT | BUTTON_RIGHT | BUTTON_A | BUTTON_B | BUTTON_SELECT | BUTTON_START)
	moveq r1, #0								@ if so, set to 0
	addne r1, #1								@ if not, a key is pressed, so add 1
	
	cmp r1, #INPUT_DELAY						@ if we are at INPUT_DELAY, reset to 0 to allow movement
	movpl r1, #1								@ INPUT_DELAY is a delay you may want to adjust to suit?
	
	str r1, [r0]
	
	mov r0, r1
	
	ldmfd sp!, {r1-r6, pc} 					@ restore registers and return
	
	@---------------------------------

keyWait:										@ this waits for key init and release... see pause for usage
	@ pass r1 as key and r1 will return 0 until that key is released!
	@ (remember to set buttonWaitPress=1 BEFORE any calls to this)
	@ also buttonWaitPress is used for secondary release check
	stmfd sp!, {r0,r2-r6, lr}

	ldr r0, =REG_KEYINPUT						@ Read Key Input
	ldr r0, [r0]								@ r0=key values
	tst r0,r1									@ test if the key is pressed
	beq keyWaitPressed							@ is it pressed?

		ldr r0,=buttonWaitPress					@ key is clear
		mov r1,#0
		str r1,[r0]								@ so zero button press
		mov r1,#1
	
		ldmfd sp!, {r0,r2-r6, pc}				@ and return with r1 as 0
	
	keyWaitPressed:
	
	ldr r0,=buttonWaitPress
	ldr r2,[r0]
	cmp r2,#0

	moveq r1,#0									@ if button is released return non-zero
	movne r1,#1									@ else return 0

	ldmfd sp!, {r0,r2-r6, pc}
	
	.data
	.align

buttonPress:
	.word 0
buttonWaitPress:
	.word 0
	
	.pool
	.end
