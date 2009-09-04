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
	.global spareSprite
	.global spareSpriteFX

drawSprite:
	stmfd sp!, {lr}
	
	mov r10,#127 			@ our counter for 128 sprites, do not think we need them all though	
	SLoop:

		ldr r0,=spriteActive				@ r2 is pointer to the sprite active setting
		ldr r1,[r0,r10, lsl #2]				@ add sprite number * 4
		cmp r1,#0							@ Is sprite active? (anything other than 0)
		bne sprites_Draw					@ if so, draw it!

			@ If not - kill it
			
			mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
			ldr r0,=BUF_ATTRIBUTE0_SUB
			add r0,r10, lsl #3
			strh r1,[r0]

		b sprites_Done
	
	sprites_Draw:
	
		ldr r0,=spriteY					@ Load Y coord
		ldr r1,[r0,r10,lsl #2]			@ add ,rX for offsets
		cmp r1,#4096					@ account for floating point
		lsrge r1,#12

		@ Draw sprite to SUB screen ONLY (r1 holds Y)
		
		ldr r0,=BUF_ATTRIBUTE0_SUB	
		add r0,r10, lsl #3
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
		ldr r1,[r0,r10,lsl #2]			@ add ,rX for offsets
		cmp r1,#4096					@ account for floating point
		lsrge r1,#12
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1_SUB		@
		add r0,r10, lsl #3
		ldr r2, =(ATTR1_SIZE_16)
		and r1,r3
		orr r2,r1
		ldr r3,=spriteHFlip
		ldr r3,[r3,r10, lsl #2]			@ load flip H
		strh r2,[r0]
		orr r2, r3, lsl #12
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r10, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r10, lsl #2]
		ldr r1,=spritePriority
		ldr r1,[r1,r10, lsl #2]
		lsl r1,#10						@ set priority
		ldr r2,=spriteBloom
		ldr r2,[r2,r10, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #3				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

	sprites_Done:
	
		@----
		@ now we need to animate any shards
		@----
		ldr r9,=spriteActive
		ldr r0,[r9, r10, lsl #2]
		cmp r0,#DUST_ACTIVE						@ first, our little dust thing when you land
		bne drawnNotDust
					
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#DUST_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawnNotDust
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#DUST_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawnNotDust
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]
		drawnNotDust:
		cmp r0,#KEY_ACTIVE						@ now, our little key glisten
		bne drawnNotKey
						
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#KEY_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawnNotKey
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#KEY_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawnNotKey
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]	
		drawnNotKey:
		cmp r0,#EXIT_OPEN
		bne drawNotExitOpen
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#6
			str r2,[r1,r10,lsl #2]
			bne drawNotExitOpen
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#DOOR_FRAME_END+1
				moveq r2,#DOOR_FRAME
				str r2,[r1,r10,lsl #2]
		drawNotExitOpen:
		cmp r0,#FX_RAIN_SPLASH
		bne drawNotRainSplash
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#RAIN_SPLASH_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotRainSplash			
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#RAIN_SPLASH_FRAME_END+1
				str r2,[r1,r10,lsl #2]				
				bne drawNotRainSplash
				@ generate new rain

					bl getRandom				@ r8 returned
					ldr r7,=0x1FF
					and r8,r7
					add r8,#64
					ldr r1,=spriteX
					str r8,[r1,r10,lsl#2]		@ store X	0-255
					mov r8,#384+32
					ldr r1,=spriteY
					str r8,[r1,r10,lsl#2]		@ store y	0-191
					bl getRandom
					and r8,#3
					cmp r8,#0
					moveq r8,#1
					ldr r1,=spriteSpeed
					str r8,[r1,r10,lsl#2]
					mov r8,#FX_RAIN_ACTIVE
					ldr r1,=spriteActive
					str r8,[r1,r10,lsl#2]
					mov r8,#RAIN_FRAME
					ldr r1,=spriteObj
					str r8,[r1,r10,lsl#2]		
		
		drawNotRainSplash:
		cmp r0,#FX_GLINT_ACTIVE
		bne drawNotGlint
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#GLINT_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotGlint
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#GLINT_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawNotGlint
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]		
		drawNotGlint:
		
		
	subs r10,#1
	bpl SLoop

	ldmfd sp!, {pc}
	
@--------------------------------------------

spareSprite:
	stmfd sp!, {r0-r9, lr}

	mov r0,#96
	ldr r1,=spriteActive
	spareSpriteFind:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq spareSpriteFound
		add r0,#1
		cmp r0,#128
		bne spareSpriteFind
	mov r10,#0
	ldmfd sp!, {r0-r9, pc}
	
	spareSpriteFound:
	
	mov r10,r0

	ldmfd sp!, {r0-r9, pc}

	
@--------------------------------------------

spareSpriteFX:
	stmfd sp!, {r0-r9, lr}

	mov r0,#62
	ldr r1,=spriteActive
	spareSpriteFindFX:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq spareSpriteFoundFX
		subs r0,#1
		bpl spareSpriteFindFX
	mov r10,#0
	ldmfd sp!, {r0-r9, pc}
	
	spareSpriteFoundFX:
	
	mov r10,r0

	ldmfd sp!, {r0-r9, pc}
	
	.pool
	.end
