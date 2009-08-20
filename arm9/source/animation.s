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

@
@ This whole area of code will handle all our in-game animation
@ including conveyers, keys, flashing the exit, etc..
@


	.arm
	.align
	.text
	
	.global crumbler
	.global minerFrame
	.global levelAnimate
	.global collectKey
	
crumbler:
	@
	@ This will crumble a platform beneath your feet
	@ r8 is passed as the x offset so we can use this to find and modify the block
	@
	@ also, this must only ever work if you are 100% on a platform!, so not during a jump
	@
	@ we need to delay the fall of the platforms!!! Will try in the feetcheck!
	@
	
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=spriteY					@ make sure we are on the platform nice and firmly
	ldr r0,[r0]
	and r0,#7
	cmp r0,#0
	bne crumblerFail
	
	ldr r0,=colMapStore
	ldrb r1,[r0,r8]					@ r1= tile at location
	add r1,#1						@ r1 is next phase (11=blank, so we will set it to 0)
	
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, #1536					@ first tile of offscreen tiles
	mov r7, r1
	sub r7,#5						@ make tile 0-6
	add r4, r7, lsl #1				@ r4 now points to tile frame we need
	ldrh r7,[r4]					@ r7= tile to draw

	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r8, lsl #1
	strh r7,[r4]					@ draw the tile back to screen location
	
	cmp r1,#12
	moveq r1,#0
	strb r1,[r0,r8]					@ update colmapstore with new value
	
	crumblerFail:
	
	ldmfd sp!, {r0-r10, lr}
	
@----------------------- ANIMATE WILLY BASED ON X COORD

minerFrame:
	@ all this does is calculate the frame based on X coord
	@ This is still not correct!!! more of a sodding cludge
	
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=spriteX
	ldr r0,[r0]
	
	ldr r2,=spriteHFlip
	ldr r2,[r2]
	cmp r2,#0
	addeq r0,#4
	
	and r0,#15
	lsr r0,#2
	
@	add r0,#1
@	cmp r0,#4
@	moveq r0,#0
	
	ldr r1,=spriteObj
	str r0,[r1]
	
	ldmfd sp!, {r0-r10, pc}
	
	
@----------------------- ANIMATE OBJECTS ON LEVEL BACKGROUND ONLY

levelAnimate:
	stmfd sp!, {r0-r10, lr}
	@
	@ we will start at the begining of colmapstore and quicky cycle through looking for objects.
	@ we will scan all of colmapstore (768 chars) as we have AMPLE time to do all this.
	@
	ldr r1,=levelAnimDelay
	ldr r0,[r1]
	add r0,#1
	cmp r0,#4
	moveq r0,#0
	str r0,[r1]
	bne levelAnimateDone
	
	@ update conveyorFrame
	
	ldr r0,=conveyorFrame
	ldr r1,[r0]
	add r1,#1
	cmp r1,#4
	moveq r1,#0
	str r1,[r0]
	
	
	mov r0,#0						@ our counter
	ldr r1,=colMapStore				@ our data to check
	
	levelAnimateLoop:
		ldrb r2,[r1,r0]				@ r2=what we have found
		@ first check for keys (24-31)
		cmp r2,#24
		blt animNotKey
		cmp r2,#31
		bgt animNotKey
		
		b levelAnimateKey 
		
		animNotKey:
		
		cmp r2,#12
		blt animNotLeftConveyor
		cmp r2,#14
		bgt animNotLeftConveyor
		
		b levelAnimateLeftConveyor
		
		animNotLeftConveyor:

		cmp r2,#15
		blt animNotRightConveyor
		cmp r2,#17
		bgt animNotRightConveyor
		
		b levelAnimateRightConveyor
		
		animNotRightConveyor:
		
	levelAnimateReturn:
	
	add r0,#1
	cmp r0,#768
	bne levelAnimateLoop

	
	levelAnimateDone:
	

	
	ldmfd sp!, {r0-r10, pc}
	
levelAnimateKey:

	@ a little bit to animate keys... Well, it works!!
	@ ok, r0 = offset, r1=colmap, r2=frame
	add r2,#1
	cmp r2,#32
	moveq r2,#24
	strb r2,[r1,r0]
	@ now to update the screen with the frame, we need to grab the graphic first though
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, #1536					@ first tile of offscreen tiles
	add r4, #40						@ add 20 chars (20th along for first frame)
	sub r2, #24						@ make fram 0-7
	add r4, r2, lsl #1				@ add this to the offset
	ldrh r5,[r4]					@ r5 now=the graphic we need to display
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r0, lsl #1
	strh r5,[r4]
	
	b levelAnimateReturn

levelAnimateLeftConveyor:
	@ r0=offset, r1=colmap, r2=colmap graphic found
	@ we need to use conveyorFrame to update with the new frame
	
	ldr r6,=conveyorFrame
	ldr r6,[r6]						@ r6=frame of conveyor (0-3)
	@ now, find the graphic needed to draw.
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	
	add r4, #1536					@ first tile of offscreen tiles
	add r4, #16						@ add 8 chars (8th along for first frame/left edge)
	sub r2,#12						@ make image 0-2 (l/mid/r)
	lsl r2,#2						@ times by 4 to find position for frame
	add r2,r6						@ add conveyorFrame to it
	lsl r2,#1						@ times by 2 (for screen data)
	add r4,r2
	ldrh r5,[r4]					@ r5=tile to draw
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r0, lsl #1
	strh r5,[r4]					@ draw tile

	b levelAnimateReturn
	
levelAnimateRightConveyor:
	@ r0=offset, r1=colmap, r2=colmap graphic found
	@ we need to use conveyorFrame to update with the new frame
	
	ldr r6,=conveyorFrame
	ldr r6,[r6]						@ r6=frame of conveyor (0-3)
	@ now, find the graphic needed to draw.
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	
	add r4,#1536					@ first tile of offscreen tiles
	add r4,#38						@ add 11 chars (11th along for first frame/left edge)
	sub r2,#15						@ make image 0-2 (l/mid/r)
	lsl r2,#2						@ times by 4 to find position for frame
	add r2,r6						@ add conveyorFrame to it
	lsl r2,#1						@ times by 2 (for screen data)
	sub r4,r2
	ldrh r5,[r4]					@ r5=tile to draw
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r0, lsl #1
	strh r5,[r4]					@ draw tile

	b levelAnimateReturn
	
@---------------------------------------

collectKey:
	@ a little bit to animate keys... Well, it works!!
	@ ok, r0 = offset, r1=colmap, r2=frame
	stmfd sp!, {r0-r10, lr}

	ldr r4,=colMapStore
	mov r2,#0
	strb r2,[r4,r1]					@ remove from ColMapStore
	
	@ now to erase from the screen
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, #1536					@ first tile of offscreen tiles
	add r4, #14						@ add 7 chars (7th along is our blank)
	ldrh r5,[r4]					@ r5 now=the graphic we need to display
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r1, lsl #1
	strh r5,[r4]
	
	ldmfd sp!, {r0-r10, pc}
	
levelAnimDelay:
	.word 0
	
	.pool
	.end