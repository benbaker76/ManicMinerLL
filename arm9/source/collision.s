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
	
	.global checkLeft
	.global checkRight
	.global checkFeet
	.global checkHead
	
@----------------------- We are moving LEFT, we need to check what we collide into in colMapStore	
@ detection functions should return a value in r9 and r10 to signal a result

@--------------------- Check moving left

checkLeft:

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0
	
	@ first, top portion
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkLeftTNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	bmi checkLeftTNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r9,r5					@ store value for return
	
	checkLeftTNot:
	
	@ now bottom section
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkLeftBNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	add r1,#8
	bmi checkLeftBNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r10,r5					@ store value for return
	
	checkLeftBNot:
	ldmfd sp!, {r0-r8, pc}

@--------------------- Check moving right
	
checkRight:
	
	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0
	
	@ first, top portion
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkRightTNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	bmi checkRightTNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r9,r5					@ store value for return
	
	checkRightTNot:
	
	@ now bottom section
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkRightBNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	add r1,#8
	bmi checkRightBNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r10,r5					@ store value for return
	
	checkRightBNot:
	
	ldmfd sp!, {r0-r8, pc}
	
@----------------------------- CHECK FEET

checkFeet:

	@	This returns r9 and r10 for what is under left and right portion

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	add r0,#FEET_NIP			@ this is a little tweak to stop getting stuck in walls
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkFeetLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
	add r1,#16					@ check below feet
	add r1,#FEET_DROP
	subs r1,#384				@ our offset
	bmi checkFeetLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r9,r5	
	
	checkFeetLNot:
	
	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	sub r0,#FEET_NIP			@ use this for head detection also
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkFeetRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
	add r1,#16					@ check below feet
	add r1,#FEET_DROP
	subs r1,#384				@ our offset
	bmi checkFeetRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r10,r5

	checkFeetRNot:
	
	ldmfd sp!, {r0-r8, pc}
	
@----------------------------- CHECK HEAD

checkHead:

	@	This returns r9 and r10 for what is above left and right head portion

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	add r0,#FEET_NIP			@ this is a little tweak to stop getting stuck in walls
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
@	sub r1,#8					@ check above head
	subs r1,#384				@ our offset
	bmi checkHeadLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r9,r5	
	
	checkHeadLNot:
	
	mov r10,#0
	
	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	sub r0,#FEET_NIP			@ use this for head detection also
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY
	ldr r1,[r1]
@	sub r1,#8					@ check above head
	subs r1,#384				@ our offset
	bmi checkHeadRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r10,r5

	checkHeadRNot:
	
	ldmfd sp!, {r0-r8, pc}

	.pool
	.end