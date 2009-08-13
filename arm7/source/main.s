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

	#define MUSIC_CHANNEL		0
	#define SOUND_CHANNEL		1
	#define FORCE_SOUND_CHANNEL	2
	
	#define STOP_SOUND			-1
	#define NO_FREE_CHANNEL		-1
	#define FIND_FREE_CHANNEL	-1

	.arm
	.align
	.text
	.global main
	
interruptHandlerIPC:

	stmfd sp!, {r0-r4, lr}
	
	mov r2, #FIND_FREE_CHANNEL					@ Find a free channel
	ldr r3, =IPC_SOUND_DATA(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r4, =IPC_SOUND_LEN(SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r0, [r3]								@ Read the value
	ldr r1, [r4]								@ Read the value
	mov r4, #0									@ Value to reset
	cmp r0, #STOP_SOUND							@ Stop Sound value?
	streq r4, [r3]								@ Clear the data
	bleq stopSound								@ Stop Sound
	cmp r0, #0									@ Is there data there?
	strgt r4, [r3]								@ Clear the data
	blgt playSound								@ If so lets play the sound
	
	mov r2, #FORCE_SOUND_CHANNEL				@ Channel 2
	ldr r3, =IPC_SOUND_DATA(FORCE_SOUND_CHANNEL)	@ Get a pointer to the sound data in IPC
	ldr r4, =IPC_SOUND_LEN(FORCE_SOUND_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r0, [r3]								@ Read the value
	ldr r1, [r4]								@ Read the value
	mov r4, #0									@ Value to reset
	cmp r0, #0									@ Is there data there?
	strgt r4, [r3]								@ Clear the data
	blgt playSound								@ If so lets play the sound
	
	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return

	@ ------------------------------------
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r4, lr}
	
	ldr r2, =IPC_SOUND_DATA(MUSIC_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r3, =IPC_SOUND_LEN(MUSIC_CHANNEL)		@ Get a pointer to the sound data in IPC
	ldr r0, [r2]								@ Read the value
	ldr r1, [r3]								@ Read the value
	mov r4, #0									@ Value to reset
	cmp r0, #STOP_SOUND							@ Stop Sound value
	streq r4, [r2]								@ Clear the data
	bleq stopMusic								@ Stop Sound
	cmp r0, #0									@ Is there data there?
	strgt r4, [r2]								@ Clear the data
	blgt playMusic								@ If so lets play the sound
	
	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return

	@ ------------------------------------
	
main:
	bl irqInit									@ Initialize Interrupts
	
	ldr r0, =IRQ_VBLANK							@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank				@ Function Address
	bl irqSet									@ Set the interrupt
	
	ldr r0, =IRQ_IPC_SYNC							@ VBLANK interrupt
	ldr r1, =interruptHandlerIPC				@ Function Address
	bl irqSet									@ Set the interrupt
	
	ldr r0, =(IRQ_VBLANK | IRQ_IPC_SYNC)						@ Interrupts
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

	stmfd sp!, {r0-r5, lr}
	
	@ r0 - Data
	@ r1 - Len
	@ r2 - Channel
	
	mov r3, r0
	
	cmp r2, #FIND_FREE_CHANNEL
	movne r0, r2
	bne playSoundContinue
	
	bl getFreeChannel
	cmp r0, #NO_FREE_CHANNEL
	beq playSoundDone
	
playSoundContinue:

	lsl r0, #4
	
	ldr r4, =SCHANNEL_TIMER(0)
	ldr r5, =SOUND_FREQ(11025)					@ Frequency currently hard-coded to 11025 Hz
	strh r5, [r4, r0]
	
	ldr r4, =SCHANNEL_SOURCE(0)					@ Channel source
	str r3, [r4, r0]							@ Write the value
	
	ldr r4, =SCHANNEL_LENGTH(0)
	bic r1, #3									@ & ~0x7
	and r1, #0x7FFFFFFF							@ & 0x7FFFFFFF
	lsr r1, #2									@ Right shift (LEN >> 2)
	str r1, [r4, r0]							@ Write the value
	
	ldr r4, =SCHANNEL_REPEAT_POINT(0)
	mov r5, #0
	strh r5, [r4, r0]
	
	ldr r4, =SCHANNEL_CR(0)
	ldr r5, =(SCHANNEL_ENABLE | SOUND_ONE_SHOT | SOUND_VOL(127) | SOUND_PAN(64) | SOUND_8BIT)
	str r5, [r4, r0]
	
playSoundDone:				

	ldmfd sp!, {r0-r5, pc} 					@ restore registers and return
	
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
