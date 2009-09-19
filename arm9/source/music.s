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
#include "ipc.h"

	.arm
	.align
	.text
	.global initMusic
	.global stopMusic

	#define XM7_MODULEMANAGER_TYPE_SIZE			0xCE8
	#define XM7_MODULE_IPC						IPC+0x20
	#define XM7_STOP							-1
	#define XM7_MOD_NOT_LOADED					0
	#define XM7_MOD_LOADED						1
	#define ZLIB_UNCOMPRESS_BUFFER_SIZE			(300*1024)
	
initMusic:

	stmfd sp!, {r0-r2, lr}
	
	@ set r1 to module to play and call
	
	push {r2-r3}
	
	ldr r0, =modLoaded
	ldr r1, [r0]
	cmp r1, #XM7_MOD_LOADED
	bne initMusicContinue

	bl stopMusic
@	bl swiWaitForVBlank
	
	ldr r0, =Module
	bl XM7_UnloadXM
	
initMusicContinue:

	pop {r2-r3}

@	bl DC_FlushAll								@ Flush
	
	ldr r0, =ZLibBuffer							@ Uncompress module
@	ldr r1, =ZLibBufferLen
	mov r1,r3, lsl #2
	bl uncompress
	
	bl DC_FlushAll
	
	ldr r0, =Module								@ Pointer to module data
	ldr r1, =ZLibBuffer
	bl XM7_LoadXM								@ Load module
	
	bl DC_FlushAll								@ Flush
	
	ldr r0, =XM7_MODULE_IPC						@ Location in IPC for XM7 control
	ldr r1, =Module								@ Send module data location
	str r1, [r0]
	
	ldr r0, =modLoaded
	ldr r1, =XM7_MOD_LOADED
	str r1, [r0]

	ldmfd sp!, {r0-r2, pc}
	
	@ ---------------------------------------
	
stopMusic:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =XM7_MODULE_IPC						@ Location in IPC for XM7 control
	ldr r1, =XM7_STOP							@ Send stop command
	str r1, [r0]

	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------

	.data
	.align

modLoaded:
	.word 0
	
	.align
Module:
	.space XM7_MODULEMANAGER_TYPE_SIZE

	.align
ZLibBuffer:
	.space ZLIB_UNCOMPRESS_BUFFER_SIZE
	
	.align
ZLibBufferLen:
	.long ZLIB_UNCOMPRESS_BUFFER_SIZE
	
	.pool
	.end