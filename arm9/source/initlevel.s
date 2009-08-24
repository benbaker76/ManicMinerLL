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

	mov r0,#1
	ldr r1,=spriteObj
	str r0,[r1]
	
	mov r0,#0
	ldr r1,=spriteAnimDelay
	str r0,[r1]
	ldr r1,=minerAction
	str r0,[r1]
	ldr r1,=minerDied
	str r0,[r1]

	bl generateColMap
	
	ldr r1,=levelData
	ldr r2,=levelNum
	ldr r2,[r2]
	sub r2,#1
	add r1,r2, lsl #6				@ add r1, level number *64, r1 is now the base for the level
	
	ldrb r0,[r1],#1
	add r0,#64
	ldr r2,=exitX
	str r0,[r2]
	ldrb r0,[r1],#1
	add r0,#384
	ldr r2,=exitY
	str r0,[r2]	
	ldrb r0,[r1],#1
	ldr r2,=keyCounter
	str r0,[r2]		
	ldrb r0,[r1],#1
	add r0,#64
	ldr r2,=spriteX
	str r0,[r2]	
	ldrb r0,[r1],#1
	add r0,#384
	ldr r2,=spriteY
	str r0,[r2]	
	ldrb r0,[r1],#1
	ldr r2,=spriteHFlip
	str r0,[r2]	
	ldr r2,=minerDirection
	str r0,[r2]	
	
	ldrb r0,[r1],#1
	@ r0=spriteBank to uses
	bl getSprites
	@ the next 2 bytes are not used, so skip them for now
	add r1,#1
	
	bl generateMonsters				@ r1 is the pointer to the first monsters data
	
	bl drawLevel
	
	
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

	@ ------------------------------------

getSprites:

	stmfd sp!, {r0-r10, lr}
	cmp r0,#0
	ldreq r0, =SpriteBank1Tiles
	ldreq r2, =SpriteBank1TilesLen

	ldr r1, =SPRITE_GFX
	add r1, #(8*256)
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #(8*256)
	bl dmaCopy


	ldmfd sp!, {r0-r10, pc}

	@ ------------------------------------

generateMonsters:

	stmfd sp!, {r0-r10, lr}
	
	@ just set up a dummy monster for now!
	
	@ r9 = loop for the 7 monsters that can be used per level
	
	mov r9,#1
	
	gmLoop:
	
		ldrb r0,[r1],#1			@ monster x, if 0, no more monsters
		cmp r0,#0
		beq generateMonstersDone
		ldr r2,=spriteActive
		mov r3,#1
		str r3,[r2,r9,lsl#2]	@ activate sprite
		add r0,#64
		ldr r2,=spriteX
		str r0,[r2,r9,lsl#2]	@ store x coord	
		ldrb r0,[r1],#1	
		add r0,#384
		ldr r2,=spriteY
		str r0,[r2,r9,lsl#2]	@ store y coord		
		ldrb r0,[r1],#1			@ dirs... HHHHLLLL h=initial dir l=facing (hflip)
		mov r3,r0
		and r3,#7				@ r3=facing (keep lowest 4 bits)
		ldr r2,=spriteHFlip
		str r3,[r2,r9,lsl#2]
		lsr r0,#4				@ r0=init dir (highest 4 bits)
		ldr r2,=spriteDir
		str r0,[r2,r9,lsl#2]
		ldrb r5,[r1],#1			@ r0=monster movement direction
		ldr r2,=spriteMonsterMove
		str r5,[r2,r9,lsl#2]	@ use r5 later for min/max
		ldrb r0,[r1],#1			@ r0=speed
		ldr r2,=spriteSpeed
		str r0,[r2,r9,lsl#2]
		ldrb r0,[r1],#1			@ r0=sprite to use (0-4)
		add r0,#1
		lsl r0,#3
		ldr r2,=spriteObj
		str r0,[r2,r9,lsl#2]
		ldr r2,=spriteObjBase
		str r0,[r2,r9,lsl#2]
		cmp r5,#0
		movne r5,#64			@ offset for l/r movement
		moveq r5,#384			@ offset for u/d movement
		ldrb r0,[r1],#1			@ r0=min coord
		add r0,r5
		ldr r2,=spriteMin
		str r0,[r2,r9,lsl#2]
		ldrb r0,[r1],#1			@ r0=max coord
		add r0,r5
		ldr r2,=spriteMax
		str r0,[r2,r9,lsl#2]

	add r9,#1
	cmp r9,#8
	bne gmLoop
	
	generateMonstersDone:

	ldmfd sp!, {r0-r10, pc}

	.pool
	.end

	mov r0,#1			@ monster 1
	
	ldr r1,=spriteActive
	mov r2,#1
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteX
	mov r2,#(8*8)+60
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteY
	mov r2,#(15*8)+384
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteObj
	mov r2,#8
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteObjBase
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteHFlip
	mov r2,#1
	str r2,[r1,r0,lsl#2]	
	ldr r1,=spriteDir
	mov r2,#1
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteMin
	mov r2,#(8*8)+60
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteMax
	mov r2,#(7*8)+130
	str r2,[r1,r0,lsl#2]
	ldr r1,=spriteSpeed
	mov r2,#1
	str r2,[r1,r0,lsl#2]

	ldr r1,=spriteMonsterMove
	mov r2,#1
	str r2,[r1,r0,lsl#2]

