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
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.arm
	.section	.itcm,"ax",%progbits
	.align
	.global initInterruptHandler

initInterruptHandler:

	stmfd sp!, {r0-r1, lr}

	bl irqInit								@ Initialize Interrupts
		
	ldr r0, =IRQ_VBLANK						@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank			@ Function Address
	bl irqSet								@ Set the interrupt
	
	ldr r0, =IRQ_HBLANK						@ HBLANK interrupt
	ldr r1, =interruptHandlerHBlank			@ Function Address
	bl irqSet								@ Set the interrupt
	
	ldr r0, =IRQ_TIMER1						@ TIMER1 interrupt
	ldr r1, =interruptHandlerTimer1			@ Function Address
	bl irqSet
	
	ldr r0, =IRQ_TIMER2						@ TIMER3 interrupt
	ldr r1, =interruptHandlerTimer2			@ Function Address
	bl irqSet
	
	ldr r0, =(IRQ_VBLANK | IRQ_HBLANK | IRQ_TIMER1 | IRQ_TIMER2 | IRQ_IPC_SYNC)		@ Interrupts
	bl irqEnable							@ Enable
	
	ldr r0, =REG_IPC_SYNC					@ Turn on IPC_SYNC interrupt
	ldr r1, =IPC_SYNC_IRQ_ENABLE
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------
	
interruptHandlerVBlank:

	stmfd sp!, {lr}
	
	bl fxVBlank
	bl titleScroller
	
	ldmfd sp!, {pc}
	
	@ ------------------------------------
	
interruptHandlerHBlank:

	stmfd sp!, {lr}
	
	bl fxHBlank
	
	ldmfd sp!, {pc}
	
	@ ------------------------------------
	
interruptHandlerTimer1:

	stmfd sp!, {lr}
	
	ldmfd sp!, {pc}
	
	@ ------------------------------------
	
interruptHandlerTimer2:

	stmfd sp!, {lr}
	
	bl timerTimer2
	
	ldmfd sp!, {pc}
	
	@ ------------------------------------

	.pool
	.end
