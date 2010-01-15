@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"),  the rights to use, copy, modify, merge, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software both source and
@ the compiled code.
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
#include "audio.h"
#include "ipc.h"

	#define XM7_MODULE_IPC		IPC+0x100
	#define XM7_STOP			-1
	
	#define STOP_SOUND			-1
	#define NO_FREE_CHANNEL		-1
	#define FIND_FREE_CHANNEL	0x80

	.arm
	.align
	.text
	.global main
	
interruptHandlerIPC:

	stmfd sp!, {r0-r9, lr}
	
	mov r9, #15									@ Out channel 1-16
	
interruptHandlerIPCLoop:
	
	ldr r7, =IPC_SOUND_DATA(0)					@ Get a pointer to the sound data in IPC
	add r7, r9, lsl #4
	ldr r8, =IPC_SOUND_LEN(0)					@ Get a pointer to the sound data in IPC
	add r8, r9, lsl #4
	ldr r2, =IPC_SOUND_CHAN(0)					@ Get a pointer to the sound data in IPC
	add r2, r9, lsl #4
	ldr r3, =IPC_SOUND_RATE(0)					@ Get a pointer to the sound data in IPC
	add r3, r9, lsl #4
	ldr r4, =IPC_SOUND_VOL(0)					@ Get a pointer to the sound data in IPC
	add r4, r9, lsl #4
	ldr r5, =IPC_SOUND_PAN(0)					@ Get a pointer to the sound data in IPC
	add r5, r9, lsl #4
	ldr r6, =IPC_SOUND_FORMAT(0)				@ Get a pointer to the sound data in IPC
	add r6, r9, lsl #4
	ldr r0, [r7]								@ Read the value
	ldr r1, [r8]								@ Read the value
	ldrb r2, [r2]								@ Read the value
	ldr r3, [r3]								@ Read the value
	ldrb r4, [r4]								@ Read the value
	ldrb r5, [r5]								@ Read the value
	ldrb r6, [r6]								@ Read the value
	mov r8, #0									@ Value to reset
	cmp r0, #STOP_SOUND							@ Stop Sound value?
	streq r8, [r7]								@ Clear the data
	bleq stopSound								@ Stop Sound
	cmp r0, #0									@ Is there data there?
	strgt r8, [r7]								@ Clear the data
	blgt playSound								@ If so lets play the sound
	
	subs r9, #1
	bpl interruptHandlerIPCLoop
	
	ldmfd sp!, {r0-r9, pc} 					@ restore registers and return

	@ ------------------------------------
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r9, lr}
	
	ldr r1, =XM7_MODULE_IPC
	ldr r0, [r1]
	mov r2, #0
	cmp r0, #0
	strgt r2, [r1]
	blgt XM7_PlayModule
	
	@ldr r0, =XM7_MODULE_IPC
	@ldr r8, [r0]
	@cmp r8, #0
	@ldr r0, =debugString
	@blgt drawDebugString
	
	ldr r1, =XM7_MODULE_IPC
	ldr r0, [r1]
	mov r2, #0
	cmp r0, #XM7_STOP
	streq r2, [r1]
	bleq XM7_StopModule
	
	ldmfd sp!, {r0-r9, pc} 					@ restore registers and return

	@ ------------------------------------
	
main:
	bl irqInit									@ Initialize Interrupts
	
	ldr r0, =IRQ_VBLANK							@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank				@ Function Address
	bl irqSet									@ Set the interrupt
	
	ldr r0, =IRQ_IPC_SYNC						@ VBLANK interrupt
	ldr r1, =interruptHandlerIPC				@ Function Address
	bl irqSet									@ Set the interrupt
	
	ldr r0, =(IRQ_VBLANK | IRQ_IPC_SYNC)		@ Interrupts
	bl irqEnable								@ Enable
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SYNC_IRQ_ENABLE
	strh r1, [r0]
	
	ldr r0, =REG_POWERCNT
	ldr r1, =POWER_SOUND						@ Turn on sound
	str r1, [r0]
	
	ldr r0, =SOUND_CR							@ This just turns on global sound and sets volume
	ldr r1, =(SOUND_ENABLE | SOUND_VOL(127))	@ Turn on sound
	strh r1, [r0]
	
	bl XM7_Initialize
	
mainLoop:

	bl swiWaitForVBlank
	
	bl checkSleepMode
	
	b mainLoop
	
	@ ------------------------------------
	
playSound:

	stmfd sp!, {r0-r9, lr}
	
	@ r0 - Data
	@ r1 - Len
	@ r2 - Channel
	@ r3 - Rate
	@ r4 - Volume
	@ r5 - Pan
	@ r6 - Format
	
	mov r7, r0
	
	cmp r2, #FIND_FREE_CHANNEL
	movne r0, r2
	bne playSoundContinue
	
	bl getFreeChannel
	cmp r0, #NO_FREE_CHANNEL
	beq playSoundDone
	
playSoundContinue:

	lsl r0, #4
	
	ldr r8, =SCHANNEL_TIMER(0)
	
	push { r0-r1 }
	ldr r0, =-0x1000000
	mov r1, r3
	bl swiDivide
	mov r9, r0
	pop { r0-r1 }
	
	strh r9, [r8, r0]
	
	ldr r8, =SCHANNEL_SOURCE(0)					@ Channel source
	str r7, [r8, r0]							@ Write the value
	
	ldr r8, =SCHANNEL_LENGTH(0)
	bic r1, #3									@ & ~0x7
	and r1, #0x7FFFFFFF							@ & 0x7FFFFFFF
	lsr r1, #2									@ Right shift (LEN >> 2)
	str r1, [r8, r0]							@ Write the value
	
	ldr r8, =SCHANNEL_REPEAT_POINT(0)
	mov r9, #0
	strh r9, [r8, r0]
	
	ldr r8, =SCHANNEL_CR(0)
	ldr r9, =SCHANNEL_ENABLE					@ Enable
	orr r9, r4									@ Volume
	orr r9, r5, lsl #16							@ Pan
	tst r6, #IPC_SOUND_LOOP						@ Looping sound?
	orrne r9, #SOUND_REPEAT
	orreq r9, #SOUND_ONE_SHOT
	tst r6, #IPC_SOUND_16BIT					@ 16-bit?
	orrne r9, #SOUND_16BIT
	tst r6, #IPC_SOUND_ADPCM					@ ADPCM-bit?
	orrne r9, #SOUND_FORMAT_ADPCM
	str r9, [r8, r0]
	
playSoundDone:				

	ldmfd sp!, {r0-r9, pc} 					@ restore registers and return
	
	@ ------------------------------------
	
stopSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)					@ Get a pointer to the sound data in IPC
	add r0, r9, lsl #4
	ldr r1, =IPC_SOUND_LEN(0)					@ Get a pointer to the sound data in IPC
	add r1, r9, lsl #4
	mov r2, #0
	str r2, [r0]
	str r2, [r1]
	
	mov r0, #15									@ Reset the counter
	ldr r1, =SCHANNEL_CR(0)						@ This is the base address of the sound channel
	mov r2, #0									@ Clear
	
stopSoundLoop:
	
	str r2, [r1, r0, lsl #4]					@ Add the offset (0x04000400 + ((n)<<4))
	sub r0, #1									@ sub one from our counter
	cmp r0, #1
	bne stopSoundLoop							@ back to our loop

	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@ ------------------------------------
	
getFreeChannel:

	@ RetVal r0 = channel number (0 - 15)

	stmfd sp!, {r1-r2, lr}

	mov r0, #7									@ Reset the counter
	ldr r1, =SCHANNEL_CR(0)						@ This is the base address of the sound channel
	
getFreeChannelLoop:
	
	ldr r2, [r1, r0, lsl #4]					@ Add the offset (0x04000400 + ((n)<<4))
	tst r2, #SCHANNEL_ENABLE					@ Is the sound channel enabled?
	beq getFreeChannelFound						@ (if not equal = channel clear)
	sub r0, #1									@ sub one from our counter
	cmp r0, #1
	bne getFreeChannelLoop						@ keep looking
	
	mov r0, #NO_FREE_CHANNEL

getFreeChannelFound:

	ldmfd sp!, {r1-r2, pc}						@ restore registers and return
	
	@ ------------------------------------

	.pool
	.end
