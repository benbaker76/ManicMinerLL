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

#define BUF_ATTRIBUTE0		(0x07000000)	@ WE CAN move these back to REAL registers!!
#define BUF_ATTRIBUTE1		(0x07000002)
#define BUF_ATTRIBUTE2		(0x07000004)
#define BUF_ATTRIBUTE0_SUB	(0x07000400)
#define BUF_ATTRIBUTE1_SUB	(0x07000402)
#define BUF_ATTRIBUTE2_SUB	(0x07000404)


	.arm
	.align
	.text
	.global drawSprite

drawSprite:
	stmfd sp!, {lr}
	
	mov r8,#127 			@ our counter for 128 sprites, do not think we need them all though	
	SLoop:

	ldr r0,=spriteActive				@ r2 is pointer to the sprite active setting
	ldr r1,[r0,r8, lsl #2]				@ add sprite number * 4
	cmp r1,#0							@ Is sprite active? (anything other than 0)
	bne sprites_Drawn					@ if so, draw it!

		@ If not - kill it
			
		mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		strh r1,[r0]
		ldr r0,=BUF_ATTRIBUTE0_SUB
		add r0,r8, lsl #3
		strh r1,[r0]

		b sprites_Done
	
	sprites_Drawn:
	
	ldr r0,=spriteY						@ Load Y coord
	ldr r1,[r0,r8,lsl #2]				@ add ,rX for offsets
	cmp r1,#SCREEN_MAIN_WHITESPACE		@ if is is > than screen base, do NOT draw it
	bpl sprites_Done

	ldr r3,=SCREEN_SUB_WHITESPACE-16	@ if it offscreen?
	cmp r1,r3							@ if it is less than - then it is in whitespace
	bmi sprites_Done					@ so, no need to draw it!
	ldr r3,=SCREEN_MAIN_TOP @+32		@ now is it on the main screen
	@ make above -32 for DS mode
	cmp r1,r3							@ check
	bpl spriteY_Main_Done				@ if so, we need only draw to main
	ldr r3,=SCREEN_MAIN_TOP-16			@ is it totally on the sub
	cmp r1,r3							@ Totally ON SUB
	bmi spriteY_Sub_Only

		@ The sprite is now between 2 screens and needs to be drawn to BOTH!
		@ Draw Y to MAIN screen (lower)
		ldr r0,=BUF_ATTRIBUTE0			@ get the sprite attribute0 base
		add r0,r8, lsl #3				@ add spritenumber *8
		ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
		ldr r3,=SCREEN_MAIN_TOP@+32			@ make r3 the value of top screen -sprite height (was -32)
		@ make above +32 for DS mode
		sub r1,r3						@ subtract our sprites y coord
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1						@ or with our attributes from earlier
		strh r2,[r0]					@ store it in sprite attribute0
		@ Draw X to MAIN screen
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,Rx for offsets later!
		cmp r1,#64						@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#64						@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1			@ get our ref to attribute1
		add r0,r8, lsl #3				@ add our sprite number * 8
		ldr r2, =(ATTR1_SIZE_16)		@ set to 32x32 (we may need to change this later)
		and r1,r3						@ and sprite y with 0x1ff (keep in region)
		orr r2,r1						@ orr result with the attribute
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		strh r2,[r0]
		orr r2, r3, lsl #12
		strh r2,[r0]					@ and store back
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2			@ load ref to attribute2
		add r0,r8, lsl #3				@ add sprite number * 8
		ldr r2,=spriteObj				@ make r2 a ref to our data for the sprites object
		ldr r3,[r2,r8, lsl #2]			@ r3=spriteobj+ sprite number *4 (stored in words)
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY))
		ldr r2,=spriteBloom				@ get our palette (bloom) number
		ldr r2,[r2,r8, lsl #2]			@ r2 = valuse
		orr r1,r2, lsl #12				@ orr it with attribute2 *4096 (to set palette bits)
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

		ldr r0,=spriteY					@ Load Y coord
		ldr r1,[r0,r8,lsl #2]			
	@ DRAW the Sprite on top screen
	spriteY_Sub_Done:
		@ Draw sprite to SUB screen (r1 holds Y)

		ldr r0,=BUF_ATTRIBUTE0_SUB		@ this all works in the same way as other sections
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
		ldr r3,=SCREEN_SUB_TOP
		cmp r1,r3
		addmi r1,#256
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,rX for offsets
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1_SUB		@
		add r0,r8, lsl #3
		ldr r2, =(ATTR1_SIZE_16)
		and r1,r3
		orr r2,r1
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		strh r2,[r0]
		orr r2, r3, lsl #12
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r8, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r8, lsl #2]
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY)) @ add palette here *****
		ldr r2,=spriteBloom
		ldr r2,[r2,r8, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back
	
		b sprites_Done
		
	@ DRAW the Sprite on top screen and KILL the sprite on bottom!!!
	spriteY_Sub_Only:
		@ Draw sprite to SUB screen ONLY (r1 holds Y)
		
		mov r3, #ATTR0_DISABLED			@ Kill the SAME number sprite on bottom Screen
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		strh r3,[r0]

		ldr r0,=BUF_ATTRIBUTE0_SUB		@ this all works in the same way as other sections
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
		ldr r3,=SCREEN_SUB_TOP
		cmp r1,r3
		addmi r1,#256
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,rX for offsets
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1_SUB		@
		add r0,r8, lsl #3
		ldr r2, =(ATTR1_SIZE_16)
		and r1,r3
		orr r2,r1
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		strh r2,[r0]
		orr r2, r3, lsl #12
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r8, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r8, lsl #2]
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY)) @ add palette here *****
		ldr r2,=spriteBloom
		ldr r2,[r2,r8, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

		@ Need to kill same sprite on MAIN screen - or do we???
		@ Seeing that for this to occur, the sprite is offscreen on MAIN!
	
		b sprites_Done	
	spriteY_Main_Done:
		mov r3, #ATTR0_DISABLED			@ Kill the SAME number sprite on Sub Screen
		ldr r0,=BUF_ATTRIBUTE0_SUB
		add r0,r8, lsl #3
		strh r3,[r0]
		@ Draw sprite to MAIN
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)	@ These will not change in our game!
		ldr r3,=SCREEN_MAIN_TOP-32	@ Calculate offsets
		sub r1,r3					@ R1 is STILL out Y coorrd
		cmp r1,#32					@ Acound for partial display
		addmi r1,#256				@ Modify if so (create a wrap)
		sub r1,#32					@ Take our sprite height off
		and r1,#0xff				@ Y is only 0-255
		orr r2,r1					@ Orr Y back with data in R2
		strh r2,[r0]				@ Store Y back
		@ Draw X
		ldr r0,=spriteX				@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]		@ add ,rX for offsets
		cmp r1,#SCREEN_LEFT			@ if less than 64, this is off left of screen
		addmi r1,#512				@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT			@ Take 64 off our X
		
		sub r1,r4					@ account for maps horizontal position
		
		ldr r3,=0x1ff				@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1
		add r0,r8, lsl #3			@ Add offset (attribs in blocks of 8)
		ldr r2, =(ATTR1_SIZE_16)	@ Need a way to modify! 16384,32768,49152 = 16,32,64
		and r1,r3					@ kick out extranious on the Coord
		orr r2,r1					@ Stick the Coord and Data together
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		strh r2,[r0]
		orr r2, r3, lsl #12
		strh r2,[r0]				@ and store them!
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2		@ Find out Buffer Attribute
		add r0,r8, lsl #3			@ multiply by 8 to find location (in r0)
		ldr r2,=spriteObj			@ Find our sprite to draw
		ldr r3,[r2,r8, lsl #2]		@ store in words (*2)
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY))
		ldr r2,=spriteBloom
		ldr r2,[r2,r8, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

	sprites_Done:
	
	subs r8,#1
	bpl SLoop

	ldmfd sp!, {pc}

	.pool
	.end
