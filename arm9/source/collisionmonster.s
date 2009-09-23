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
	
	.global collisionMonster


collisionMonster:

	stmfd sp!, {r0-r10, lr}
	
	@ first grab our x,y coord into r0,r1
	@ then loop through all monsters (1-7)
	@ and check boundries
	@ if a boundry check is true, THEN do a per pixel check
	
	ldr r0,=spriteX+256
	ldr r0,[r0]					@ player X
	ldr r1,=spriteY+256
	ldr r1,[r1]					@ player y
	
	mov r10,#65					@ monster number (65-84)
	
	collisionMonsterCheckLoop:

		ldr r2,=spriteActive
		ldr r2,[r2, r10, lsl#2]
		cmp r2,#MONSTER_ACTIVE
		beq colMonPass
		cmp r2,#FX_METEOR_ACTIVE
		bne colMonFail
	@	cmp r2,#FX_METEORCRASH_ACTIVE
	@	bne colMonFail
		
		colMonPass:

			ldr r2,=spriteX
			ldr r2,[r2,r10,lsl#2]
			ldr r3,=spriteY
			ldr r3,[r3,r10,lsl#2]

			@ r0,r1=willy x/y
			@ r2,r3=monst x/y
	
			@ first, if px+15<mx or px>mx+15, no possible collision
			add r0,#15
			cmp r0,r2
			sub r0,#15
			blt colMonFail
			add r2,#15
			cmp r0,r2
			sub r2,#15
			bgt colMonFail
			@ next, if py+15<my or py>my+15, no possible collision
			add r1,#15
			cmp r1,r3
			sub r1,#15
			blt colMonFail
			add r3,#15
			cmp r1,r3
			sub r3,#15
			bgt colMonFail			

			bl pixelDetect

		colMonFail:
		add r10,#1
		cmp r10,#85
	bne collisionMonsterCheckLoop
	
	ldmfd sp!, {r0-r10, pc}
	
@-----------------------------------------------	

pixelDetect:

	stmfd sp!, {r0-r10, lr}
	
	@ clear cmap
	mov r0,#0
	ldr r1,=colMonMap
	ldr r2,=576
	bl dmaFillWords

	@ r10= number of the monster you have collided with
	@ we need to find what the sprite is ( we will also have to plot backwards for hflip=1)
	
	ldr r0,=spriteObj
	ldr r0,[r0,r10,lsl#2]					@ r0= sprite object (0-max)
	
	@ now get the pointer to the memory adress of the image (each sprite = 256 bytes)
	
	ldr r1,=SPRITE_GFX_SUB
	lsl r0,#8								@ image * 256
	add r1,r0								@ r1 should = pointer to image (8*8 tl)
	add r2,r1,#64							@ r2 = 8*8 tr
	add r3,r2,#64							@ r3 = 8*8 bl
	add r4,r3,#64							@ r4 = 8*8 br
	
	ldr r9,=spriteHFlip
	ldr r9,[r9,r10,lsl#2]					@ sprite flip? 0=normal 1=reversed
	
	cmp r9,#0
	bleq maskNormal							@ grab data and shove to centre of colMonMap
	blne maskFlipped						@ for normal and flipped sprites
	
@	bl displaySpriteMap
	
	@ now we need to make your x/y 0-47 and alien is plotted in colMonMap at 16,16
	
	ldr r0,=spriteX
	ldr r11,[r0,r10,lsl#2]					@ r11=monster X
	ldr r0,=spriteY
	ldr r12,[r0,r10,lsl#2]					@ r12=monster Y

	ldr r0,=spriteX+256
	ldr r0,[r0]								@ r0=your X

	sub r11,#16								@ r2 is now a diff value
	sub r0,r11								@ r0= x coord 0-47

	ldr r1,=spriteY+256
	ldr r1,[r1]								@ r0=your Y

	sub r12,#16
	sub r1,r12								@ r1= y coord 0-47
	
	@ r0,r1 = x/y coord of you 0-47, so all we need to do is check against colMonMap at the x/y coord created here
	@ we need 2 checks, one for normal and one for flipped... GOD!!!
	
	ldr r2,=spriteHFlip+128
	ldr r2,[r2]								@ r2 = flip status
	
	cmp r2,#0
	bleq pixelCheckNormal
	blne pixelCheckFlipped
	
	cmp r12,#1								@ r12 returned to say we have hit (0=false)
	bleq initDeath
	
	ldmfd sp!, {r0-r10, pc}

@--------------------------- Grab normal data

maskNormal:

	stmfd sp!, {r0-r12, lr}
	
	ldr r5,=colMonMap
	add r5,#768+16
	add r6,r5,#8
	add r7,r5,#384
	add r8,r7,#8
	
	@ r1,r2,r3,r4 = 4 seqments of original sprite image
	@ r5,r6,r7,r8 = 4 segments to store to
	
	mov r0,#0		@ counter (0-63)
	mov r10,#0		@ byte counter (0-7)
	mNormalLoop:
	
		ldrb r9,[r1,r0]
		strb r9,[r5,r0]
		ldrb r9,[r2,r0]
		strb r9,[r6,r0]
		ldrb r9,[r3,r0]
		strb r9,[r7,r0]
		ldrb r9,[r4,r0]
		strb r9,[r8,r0]		
		
		add r10,#1
		cmp r10,#8
		moveq r10,#0
		addeq r5,#40
		addeq r6,#40
		addeq r7,#40
		addeq r8,#40
		
		add r0,#1
		cmp r0,#64
	bne mNormalLoop
	
	ldmfd sp!, {r0-r12, pc}	
	
@--------------------------- Grab flipped data

maskFlipped:

	stmfd sp!, {r0-r12, lr}
	
	ldr r5,=colMonMap
	add r5,#768+16
	add r6,r5,#8
	add r7,r5,#384
	add r8,r7,#8
	
	@ r1,r2,r3,r4 = 4 seqments of original sprite image
	@ r5,r6,r7,r8 = 4 segments to store to
	mov r0,#0		@ counter (0-63)
	
	mov r10,#7		@ byte counter (7-0)
	mFlipLoop:
	
		ldrb r9,[r1,r0]			@ need to read backwards?
		strb r9,[r6,r10]
		ldrb r9,[r2,r0]
		strb r9,[r5,r10]
		ldrb r9,[r3,r0]
		strb r9,[r8,r10]
		ldrb r9,[r4,r0]
		strb r9,[r7,r10]		
		
		subs r10,#1
		movmi r10,#7
		addmi r5,#48
		addmi r6,#48
		addmi r7,#48
		addmi r8,#48
		
		add r0,#1
		cmp r0,#64
	bne mFlipLoop
	

	ldmfd sp!, {r0-r12, pc}

@--------------------------
displaySpriteMap:

	stmfd sp!, {r0-r10, lr}

	ldr r0,=colMonMap
	add r0,#768+16
	mov r11,#0		@ x
	mov r8,#0		@ y
	mov r9,#1		@ digits
	mov r7,#0		@ which display
	
	mov r1,#0		@ counter (0-256)
	dsmLoop:
	
		ldrb r10,[r0,r1]
		
		bl drawDigits
		
		add r11,#1
		cmp r11,#16
		moveq r11,#0
		addeq r8,#1
		addeq r0,#32
		
		add r1,#1
		cmp r1,#256
	
	bne dsmLoop

	ldmfd sp!, {r0-r10, pc}
	
@--------------------------- check Normal

pixelCheckNormal:

	stmfd sp!, {r0-r11, lr}
	
	@ r0,r1 = position to start in the colMonData, convert to location
	@ y*48+x
	
	mov r2,#48
	mul r1,r2					@ mul Y by 48
	add r1,r0					@ add x
	ldr r2,=colMonMap
	add r1,r2					@ r1=colmap top left pixel
	add r2,r1,#8				@ r2=colmap top right
	add r3,r1,#384				@ r3=colmap bot left
	add r4,r3,#8				@ r4=colmap bot right
	
	ldr r11,=spriteObj+256
	ldr r11,[r11]				@ r11= object of sprite
	ldr r5,=SPRITE_GFX_SUB
	lsl r11,#8					@ image * 256
	add r5,r11					@ r5 should = pointer to image (8*8 tl)
	add r6,r5,#64				@ r6 = 8*8 tr
	add r7,r6,#64				@ r7 = 8*8 bl
	add r8,r7,#64				@ r8 = 8*8 br
	
	@ ok, we need to loop through colmap and read the value if the players is not 0
	
	mov r9,#0					@ counter 0-63
	mov r10,#0					@ pixel counter 0-7
	
	pCheckNLoop:
	
		ldrb r11,[r5,r9]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckN1			@ skip if set
			ldrb r11,[r1,r9]
			cmp r11,#0
			bne pixelCheckNormalHit
		pCheckN1:
		
		ldrb r11,[r6,r9]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckN2			@ skip if set
			ldrb r11,[r2,r9]
			cmp r11,#0
			bne pixelCheckNormalHit
		pCheckN2:
		
		ldrb r11,[r7,r9]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckN3			@ skip if set
			ldrb r11,[r3,r9]
			cmp r11,#0
			bne pixelCheckNormalHit
		pCheckN3:
		
		ldrb r11,[r8,r9]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckN4			@ skip if set
			ldrb r11,[r4,r9]
			cmp r11,#0
			bne pixelCheckNormalHit
		pCheckN4:	
	
		add r10,#1
		cmp r10,#8
		moveq r10,#0
		addeq r1,#40
		addeq r2,#40
		addeq r3,#40
		addeq r4,#40
		
		add r9,#1
		cmp r9,#64	
	bne pCheckNLoop
	
	mov r12,#0
	
	ldmfd sp!, {r0-r11, pc}
		
pixelCheckNormalHit:
	
	mov r12,#1
	
	ldmfd sp!, {r0-r11, pc}

@--------------------------- check Flipped

pixelCheckFlipped:

	stmfd sp!, {r0-r11, lr}
	@ r0,r1 = position to start in the colMonData, convert to location
	@ y*48+x
	
	mov r2,#48
	mul r1,r2					@ mul Y by 48
	add r1,r0					@ add x
	ldr r2,=colMonMap
	add r1,r2					@ r1=colmap top left pixel
	add r2,r1,#8				@ r2=colmap top right
	add r3,r1,#384				@ r3=colmap bot left
	add r4,r3,#8				@ r4=colmap bot right
	
	ldr r11,=spriteObj+256
	ldr r11,[r11]				@ r11= object of sprite
	ldr r5,=SPRITE_GFX_SUB
	lsl r11,#8					@ image * 256
	add r5,r11					@ r5 should = pointer to image (8*8 tl)
	add r6,r5,#64				@ r6 = 8*8 tr
	add r7,r6,#64				@ r7 = 8*8 bl
	add r8,r7,#64				@ r8 = 8*8 br
	
	@ ok, we need to loop through colmap and read the value if the players is not 0
	
	mov r9,#0					@ counter 0-63
	mov r10,#7					@ pixel counter 0-7
	
	pCheckFLoop:
	
		ldrb r11,[r6,r10]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckF1			@ skip if set
			ldrb r11,[r1,r9]
			cmp r11,#0
			bne pixelCheckFlippedHit
		pCheckF1:
		
		ldrb r11,[r5,r10]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckF2			@ skip if set
			ldrb r11,[r2,r9]
			cmp r11,#0
			bne pixelCheckFlippedHit
		pCheckF2:
		
		ldrb r11,[r8,r10]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckF3			@ skip if set
			ldrb r11,[r3,r9]
			cmp r11,#0
			bne pixelCheckFlippedHit
		pCheckF3:
		
		ldrb r11,[r7,r10]		@ sprite top left 8*8
		cmp r11,#0
		beq pCheckN4			@ skip if set
			ldrb r11,[r4,r9]
			cmp r11,#0
			bne pixelCheckFlippedHit
		pCheckF4:	
	
		subs r10,#1
		movmi r10,#7
		addmi r1,#40
		addmi r2,#40
		addmi r3,#40
		addmi r4,#40
		addmi r5,#8
		addmi r6,#8
		addmi r7,#8
		addmi r8,#8                                        		
		add r9,#1
		cmp r9,#64	
	bne pCheckFLoop
	
	mov r12,#0
	
	ldmfd sp!, {r0-r11, pc}
		
pixelCheckFlippedHit:
	
	mov r12,#1	
	
	ldmfd sp!, {r0-r11, pc}
	
@--------------------------
	
	.pool
	.align
	colMonMap:
	.space 2304
	
	.end