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
	
	
	ldr r0,=spriteX
	ldr r0,[r0]
	ldr r1,=spriteY
	ldr r1,[r1]
	
	mov r10,#1					@ monster number
	
	collisionMonsterCheckLoop:

		ldr r2,=spriteActive
		ldr r2,[r2, r10, lsl#2]
		cmp r2,#0
		beq colMonFail

			ldr r2,=spriteX
			ldr r2,[r2,r10,lsl#2]
			ldr r3,=spriteY
			ldr r3,[r3,r10,lsl#2]

			@ r0,r1=willy x/y
			@ r2,r3=monst x/y
			
			
			@ simple detect code!!! (can be REALLY tidied)
			@ first, if px+12<mx or px+3>mx+15, no possible collision
			add r0,#12
			cmp r0,r2
			sub r0,#12
			blt colMonFail
			add r2,#15
			add r0,#3
			cmp r0,r2
			sub r0,#3
			sub r2,#15
			bgt colMonFail
			@ next, if py+15<my or py>my+15, no possible collision
			add r1,#15
			cmp r1,r3
			sub r1,#15
			blt colMonFail
			add r3,#15
			cmp r1,r3
			sub r1,#15
			bgt colMonFail			

			bl pixelDetect

		colMonFail:
		add r10,#1
		cmp r10,#8
	bne collisionMonsterCheckLoop
	
	ldmfd sp!, {r0-r10, pc}
	
@-----------------------------------------------	

	
pixelDetect:

	stmfd sp!, {r0-r10, lr}
	
	@ r10= number of the monster you have collided with
	
	
	
@	bl initDeath
	
	ldmfd sp!, {r0-r10, pc}