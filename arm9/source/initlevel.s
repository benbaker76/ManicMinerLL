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

	.arm
	.align
	.text

	.global initLevel

initLevel:
	
	@ This will be used to set level specifics, ie. colmap, initial x/y, facing etc...

	stmfd sp!, {r0-r10, lr}
	
	bl clearOAM
	bl clearSpriteData

	@ Dummy settings for now!
	
	mov r0,#1
	ldr r1,=spriteActive
	str r0,[r1]
	mov r0,#64+(2*8)
	ldr r1,=spriteX
	str r0,[r1]
	mov r0,#384+168
	
	ldr r1,=spriteY
	str r0,[r1]
	mov r0,#1
	ldr r1,=spriteObj
	str r0,[r1]
	
	mov r0,#0
	ldr r1,=spriteAnimDelay
	str r0,[r1]
	ldr r1,=minerDirection
	str r0,[r1]
	ldr r1,=minerAction
	str r0,[r1]
	ldr r1,=minerDied
	str r0,[r1]
	
	mov r0,#1								@ 0=left 1=right
	ldr r1,=spriteHFlip
	str r0,[r1]	
	
	bl generateColMap
	
	ldmfd sp!, {r0-r10, pc}

	@ ------------------------------------

clearSpriteData:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =spriteDataStart
	ldr r1, =spriteDataEnd								@ Get the sprite data end
	ldr r2, =spriteDataStart							@ Get the sprite data start
	sub r1, r2											@ sprite end - start = size
	bl DC_FlushRange
	
	mov r0, #0
	ldr r1, =spriteDataStart
	ldr r2, =spriteDataEnd								@ Get the sprite data end
	ldr r3, =spriteDataStart							@ Get the sprite data start
	sub r2, r3											@ sprite end - start = size
	bl dmaFillWords	

	ldmfd sp!, {r0-r3, pc}
	
	@ ------------------------------------

generateColMap:

	stmfd sp!, {r0-r10, lr}
	
	@ generate the colmapstore based on the levelNum
	
	ldr r0,=levelNum
	ldr r5,[r0]
	@ colmap is 768*level -1
	sub r5,#1
	mov r2,#768
	mul r5,r2
	ldr r0,=colMapLevels
	add r0,r5
	ldr r1,=colMapStore
	mov r2,#768
	@ r0,=src, r1=dst, r2=len
	bl dmaCopy
	
	
	
	
	
	ldmfd sp!, {r0-r10, pc}

	.pool
	.end