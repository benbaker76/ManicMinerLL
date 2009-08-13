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

	.arm
	.align
	.text
	
	.global stopSound
	.global playMySound

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

playMySound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	@ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	@ldr r1, =mysound_raw_end							@ Get the sample end
	@ldr r2, =mysound_raw								@ Get the same start
	@sub r1, r2											@ Sample end - start = size
	@str r1, [r0]										@ Write the sample size
	
	@ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	@ldr r1, =mysound_raw								@ Get the sample address
	@str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

	.pool
	.end
