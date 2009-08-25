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
#include "audio.h"
#include "ipc.h"

	#define XM7_MODULE_IPC						IPC+0x20
	#define XM7_STOP							-1

	#define MUSIC_CHANNEL		0
	#define SOUND_CHANNEL		1
	#define FORCE_SOUND_CHANNEL	2
	
	#define STOP_SOUND			-1
	#define NO_FREE_CHANNEL		-1
	#define FIND_FREE_CHANNEL	0x80

	.arm
	.align
	.text
	.global main
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r8, lr}
	
	ldr r1, =XM7_MODULE_IPC
	ldr r0, [r1]
	cmp r0, #0
	blgt XM7_PlayModule
	
	@ldr r0, =XM7_MODULE_IPC
	@ldr r8, [r0]
	@cmp r8, #0
	@ldr r0, =debugString
	@blgt drawDebugString
	
	ldr r0, =XM7_MODULE_IPC
	ldr r1, [r0]
	mov r2, #0
	cmp r1, #0
	strgt r2, [r0]
	
	ldr r0, =XM7_MODULE_IPC
	ldr r1, [r0]
	cmp r1, #XM7_STOP
	bleq XM7_StopModule
	
	ldr r7, =IPC_SOUND_DATA(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r8, =IPC_SOUND_LEN(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r2, =IPC_SOUND_CHAN(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r3, =IPC_SOUND_RATE(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r4, =IPC_SOUND_VOL(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r5, =IPC_SOUND_PAN(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r6, =IPC_SOUND_FORMAT(SOUND_CHANNEL)	@ Get a pointer to the sound data in IPC
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
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return

	@ ------------------------------------
	
main:
	bl irqInit									@ Initialize Interrupts
	
	ldr r0, =IRQ_VBLANK							@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank				@ Function Address
	bl irqSet									@ Set the interrupt
	
	ldr r0, =IRQ_VBLANK							@ Interrupts
	bl irqEnable								@ Enable
	
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
	
playMusic:

	stmfd sp!, {r0-r4, lr}
	
	@ r0 - Data
	@ r1 - Len
	
	ldr r2, =SCHANNEL_TIMER(0)
	ldr r3, =SCHANNEL_TIMER(1)
	ldr r4, =SOUND_FREQ(32000)					@ Frequency currently hard-coded to 32000 Hz
	strh r4, [r2]
	strh r4, [r3]
	
	ldr r2, =SCHANNEL_SOURCE(0)					@ Channel source
	ldr r3, =SCHANNEL_SOURCE(1)					@ Channel source
	str r0, [r2]								@ Write the value
	str r0, [r3]								@ Write the value
	
	ldr r2, =SCHANNEL_LENGTH(0)
	ldr r3, =SCHANNEL_LENGTH(1)
	bic r1, #3									@ & ~0x7
	and r1, #0x7FFFFFFF							@ & 0x7FFFFFFF
	lsr r1, #2									@ Right shift (LEN >> 2)
	str r1, [r2]								@ Write the value
	str r1, [r3]								@ Write the value
	
	ldr r2, =SCHANNEL_REPEAT_POINT(0)
	ldr r3, =SCHANNEL_REPEAT_POINT(1)
	mov r4, #0
	strh r4, [r2]
	strh r4, [r3]
	
	ldr r2, =SCHANNEL_CR(0)
	ldr r3, =SCHANNEL_CR(1)
	ldr r4, =(SCHANNEL_ENABLE | SOUND_REPEAT | SOUND_VOL(127) | SOUND_PAN(64) | SOUND_8BIT)
	str r4, [r2]
	str r4, [r3]

	ldmfd sp!, {r0-r4, pc} 					@ restore rgisters and return
	
	@ ------------------------------------
	
stopMusic:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(MUSIC_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r1, =IPC_SOUND_LEN(MUSIC_CHANNEL)		@ Get a pointer to the sound data in IPC
	mov r2, #0
	str r2, [r0]
	str r2, [r1]
	
	ldr r0, =SCHANNEL_CR(0)
	ldr r1, =SCHANNEL_CR(1)
	mov r2, #0
	str r2, [r0]
	str r2, [r1]

	ldmfd sp!, {r0-r2, pc} 					@ restore rgisters and return
	
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
	orr r9, #127								@ Volume
	orr r9, r5, lsl #16							@ Pan
	tst r6, #IPC_SOUND_LOOP						@ Looping sound?
	orrne r9, #SOUND_REPEAT
	orreq r9, #SOUND_ONE_SHOT
	tst r6, #IPC_SOUND_16BIT					@ 16-bit?
	orrne r9, #SOUND_16BIT
	str r9, [r8, r0]
	
playSoundDone:				

	ldmfd sp!, {r0-r9, pc} 					@ restore registers and return
	
	@ ------------------------------------
	
stopSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r1, =IPC_SOUND_LEN(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
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

	mov r0, #15									@ Reset the counter
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
