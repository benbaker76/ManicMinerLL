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

#include "system.h"
#include "interrupts.h"
#include "serial.h"
	
	#define KEY_LID				BIT(7)

	.arm
	.align
	.text
	.global checkSleepMode
	
checkSleepMode:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_KEYXY
	ldrh r1, [r0]
	tst r1, #KEY_LID
	beq checkSleepModeReset
	
	ldr r0, =sleepCounter
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]	
	cmp r1, #20
	blt checkSleepModeDone
	
	bl systemSleep

checkSleepModeReset:

	ldr r0, =sleepCounter
	mov r1, #0
	str r1, [r0]
	
checkSleepModeDone:

	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return

	@ ------------------------------------
	
systemSleep:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =REG_IE
	ldr r2, [r0]
	
	push {r2}
	
	mov r0, #0
	mov r1, #0x400
	bl swiChangeSoundBias
	
	ldr r0, =PM_CONTROL_REG
	bl readPowerManagement
	mov r3, r0
	
	push {r3}
	
	ldr r0, =PM_CONTROL_REG
	ldr r1, =PM_LED_CONTROL(1)
	bl writePowerManagement
	
	ldr r0, =REG_IE
	ldr r1, =IRQ_LID
	str r1, [r0]
	
	bl swiSleep
	
	ldr r0, =838000
	bl swiDelay
	
	pop {r3}
	
	pop {r2}
	
	ldr r0, =REG_IE
	str r2, [r0]
	
	ldr r0, =PM_CONTROL_REG
	mov r1, r3
	bl writePowerManagement
	
	ldr r0, =1
	ldr r1, =0x400
	bl swiChangeSoundBias

	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return

	@ ------------------------------------

	.data
	.align
	
sleepCounter:
	.word 0
	
	.align
	.pool
	.end

	