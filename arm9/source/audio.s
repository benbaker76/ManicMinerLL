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
#include "video.h"
#include "background.h"
#include "dma.h"
#include "ipc.h"

	#define STOP_SOUND		-1
	#define FIND_FREE_CHANNEL	0x80

	.arm
	.align
	.text
	
	.global stopSound
	.global playDead
	.global playJump
	.global playTone
	.global playFall
	.global playLevelEnd
	.global playClick
	.global playKey

stopSound:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	mov r1, #STOP_SOUND									@ Stop sound value
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r1, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playDead:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r2,=effectVolume
	ldr r1,[r2]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =dead_raw_end								@ Get the sample end
	ldr r2, =dead_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =dead_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playJump:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =jumpCount									@ 22050 + 1500 * (9 - Sqr((jumpCount - 9) ^ 2))
	ldr r0, [r0]
	@sub r0, #9
	mov r1, #1
	lsl r1, #2
	bl sqrt32
	mov r1, #9
	sub r1, r0
	ldr r2, =1500
	ldr r3, =22050
	mul r1, r2
	add r1, r3
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r2,=effectVolume
	ldr r1,[r2]
ldr r1,=40

	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =0
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =jump_raw_end								@ Get the sample end
	ldr r2, =jump_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =jump_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playTone:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	ldr r1, =44100
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r2,=effectVolume
	ldr r1,[r2]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =IPC_SOUND_16BIT
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =tone_raw_end								@ Get the sample end
	ldr r2, =tone_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =tone_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playFall:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =fallCount
	ldr r0, [r0]
	
	mov r1, #1
	lsl r1, #2
	bl sqrt32
	sub r1, r0
	ldr r2, =1500
	ldr r3, =22050
	mul r1, r2
	add r1, r3
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r2,=effectVolume
	ldr r1,[r2]
ldr r1,=40
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =0
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =jump_raw_end								@ Get the sample end
	ldr r2, =jump_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =jump_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------


playLevelEnd:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r1,=127
@	ldr r1,[r2]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =levelend_raw_end							@ Get the sample end
	ldr r2, =levelend_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =levelend_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------


playClick:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r1,=127
@	ldr r1,[r2]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =click_raw_end							@ Get the sample end
	ldr r2, =click_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =click_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------


playKey:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r1,=127
@	ldr r1,[r2]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =key_raw_end							@ Get the sample end
	ldr r2, =key_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =key_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	.pool
	.end
