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
	.global checkCollectDie
	.global checkHeadDie
	.global initDeath
	.global checkFall
	.global checkExit
	.global checkBlocked
	
@----------------------- We are moving LEFT, we need to check what we collide into in colMapStore	
@ detection functions should return a value in r9 and r10 to signal a result
@ also, are we going to need another check for killing things? or will these do? time will tell...
@--------------------- Check moving left

checkLeft:

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0
	
	@ first, top portion
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkLeftTNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	add r1,#4
	bmi checkLeftTNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	@ ok, r0,r1= actual screen pixels now.
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r9,r5					@ store value for return
	
	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	@
	
	checkLeftTNot:				@ now bottom section	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkLeftBNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8		
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	add r1,#4
	bmi checkLeftBNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#1					@ add 1 char down	
	@ ok, r0,r1= actual screen pixels now.
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r10,r5					@ store value for return

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	@
	
	checkLeftBNot:
	
	push {r9,r10}
	mov r2,r9
	mov r11,#26							@ X Pos
	mov r8,#5							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits
	mov r10,r2
	mov r11,#26							@ X Pos
	mov r8,#3							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits	
	pop {r9,r10}
	
	
	ldmfd sp!, {r0-r8, pc}

@--------------------- Check moving right
	
checkRight:
	
	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0
	
	@ first, top portion
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkRightTNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	add r1,#4 
	bmi checkRightTNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r9,r5					@ store value for return

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	@
	
	checkRightTNot:				@ now bottom section
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkRightBNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	add r1,#4
	bmi checkRightBNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#1					@ add 1 char down
	@ ok, r0,r1= actual screen pixels now.	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r10,r5					@ store value for return

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	@

	checkRightBNot:

	push {r9,r10}
	mov r2,r9
	mov r11,#29							@ X Pos
	mov r8,#5							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits
	mov r10,r2
	mov r11,#29							@ X Pos
	mov r8,#3							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits	
	pop {r9,r10}

	
	ldmfd sp!, {r0-r8, pc}
	
@----------------------------- CHECK FEET

checkFeet:

	@	This returns r9 and r10 for what is under left and right portion
	@   and must also check for conveyers, crumbles, and whatever else we need
	@ 	do we need a platform matching check? ie, make sure we are on a platform first?

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0					@ left Var
	mov r10,#0					@ right var

	ldr r0,=minerAction
	ldr r1,[r0]
	cmp r1,#MINER_CONVEYOR
	moveq r1,#0
	streq r1,[r0]

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	add r0,#FEET_NIP			@ this is a little tweak to stop getting stuck in walls
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkFeetLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	add r1,#FEET_DROP
	subs r1,#384				@ our offset
	bmi checkFeetLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#2					@ add 2 charaters (16 pixels)	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r8,r3					@ store r3 in r8 (this is our offset needed for crumblers)

	mov r9,r5	
	

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDieFeet
	

	
	checkFeetLNot:

	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	sub r0,#FEET_NIP			@ use this for head detection also
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkFeetRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	add r1,#FEET_DROP
	subs r1,#384				@ our offset
	bmi checkFeetRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#2
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value ('remember' r3 is the offset)

	mov r10,r5
	
	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDieFeet
	checkFeetRNot:
	
	@ ok, r9 and r10 relate to what is under our feet!
	@ we need to check for a crumbler
	@ this is from 5 to 11 in our colmap
	@ so, check r9 first, if this is in this range, set r8 as the x offset and call crumbler
	@ then check r10, set r8 to x offset and call crumbler
	
	push {r3,r8}
	
	@ I think we are going to need another way to put a delay on EACH crumble tile..??
	
	ldr r1,=crumbleWait			@ this is our little delay for crumble platforms
	ldr r2,[r1]
	add r2,#1
	cmp r2,#2					@ we are using 4 as a delay, but, I think we should have
	moveq r2,#0					@ less frames of anim for the crumbles and have them crumble
	str r2,[r1]					@ slower? The last frame is too fine imho, what do you think?
	bne notCrumblerR
	
	cmp r9,#5
	blt notCrumblerL
	cmp r9,#12
	bgt notCrumblerL
		@ r8 already contains the offset
		bl crumbler
	notCrumblerL:
	cmp r10,#5
	blt notCrumblerR
	cmp r10,#12
	bgt notCrumblerR
		@ r3 contains the offset
		mov r8,r3
		bl crumbler
	notCrumblerR:
	
	pop {r3,r8}
	
	@ Now we need to check for conveyer and act on it
	@ if on one, set minerAction and also the conveyorDirection


	cmp r9,#2
	moveq r9,#13
	beq r9OnConveyor
	cmp r9,#3
	moveq r9,#20
	beq r9OnConveyor

	cmp r9,#13
	blt feetNotLConveyor
	cmp r9,#20
	bgt feetNotLConveyor
	r9OnConveyor:
	mov r4,r9
	b feetOnConveyor
	
	feetNotLConveyor:
	
	cmp r10,#2
	moveq r10,#13
	beq r10OnConveyor
	cmp r10,#3
	moveq r10,#20
	beq r10OnConveyor
	cmp r10,#13
	blt feetNotRConveyor
	cmp r10,#20
	bgt feetNotRConveyor
	r10OnConveyor:
	mov r4,r10
	b feetOnConveyor	
	
	feetNotRConveyor:
	
	checkFeetFinish:

	push {r8-r10}				@ this is just so we can see what is under us
	mov r6,r10
	mov r10,r9
	mov r11,#2							@ X Pos
	mov r8,#9							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits
	mov r10,r6
	mov r11,#5							@ X Pos
	mov r8,#9							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits
	pop {r8-r10}
	
	ldmfd sp!, {r0-r8, pc}
	
feetOnConveyor:

	ldr r0,=spriteY+256						@ make sure we are on the platform nice and firmly
	ldr r0,[r0]
	and r0,#7
	cmp r0,#0
	bne checkFeetFinish

	ldr r0,=minerAction
	mov r1,#MINER_CONVEYOR
	str r1,[r0]

	cmp r4,#14
	movle r3,#MINER_LEFT
	movgt r3,#MINER_RIGHT				@ set conveyor direction
	cmp r4,#19
	moveq r3,#MINER_LEFT
	cmp r4,#20
	moveq r3,#MINER_RIGHT

	ldr r1,=conveyorDirection
	str r3,[r1]

	b checkFeetFinish
	
@----------------------------- CHECK HEAD

checkHead:

	@	This returns r9 and r10 for what is above left and right head portion

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	add r0,#FEET_NIP			@ this is a little tweak to stop getting stuck in walls
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
add r1,#1
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
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	sub r0,#FEET_NIP			@ use this for head detection also
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
add r1,#1
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

@-----------------------------------------------

checkHeadDie:

	stmfd sp!, {r0-r10, lr}
	
	mov r9,#0
	mov r10,#0

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	add r0,#FEET_NIP			@ this is a little tweak to stop getting stuck in walls
add r0,#1
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadDieLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	bmi checkHeadDieLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r9,r5	

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie

	checkHeadDieLNot:
	
	mov r10,#0
	
	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	sub r0,#FEET_NIP			@ use this for head detection also
sub r0,#1
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadDieRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	bmi checkHeadDieRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r10,r5

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie

	checkHeadDieRNot:
	
	push {r9,r10}
	mov r2,r9
	mov r11,#29							@ X Pos
	mov r8,#9							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits
	mov r10,r2
	mov r11,#25							@ X Pos
	mov r8,#9							@ Y Pos
	mov r9,#2							@ Digits
	mov r7, #1							@ 0 = Main, 1 = Sub
@	bl drawDigits	
	pop {r9,r10}
	
	ldmfd sp!, {r0-r10, pc}


@--------------------------------------------
	
checkCollectDie:
	@ we need to pass this 2 things for now - the r9,r10 from detect code and also
	@ the offset value for colmapstore
	@ r0 = collide value
	@ r1 = offset
	
	stmfd sp!, {r0-r10, lr}
	
	cmp r0,#64							@ check for DEATH first!
	blt notDieThing

		ldr r3,=spriteX+256
		ldr r3,[r3]
		and r3,#7
		cmp r3,#1
		bgt dieCheck2
		cmp r3,#6
		blt dieCheck2
		
		b notDieThing
		
		dieCheck2:
		
		bl initDeath

		b checkCollectDieDone

	notDieThing:

	@ if between 24 and 31, this is a key (collectable)

	cmp r0,#24
	blt notKeyThing
	cmp r0,#31
	bgt notKeyThing
	 
		
		@ We have a key, so collect it!
		
		bl collectKey 
		b checkCollectDieDone

	notKeyThing:
	
	@ ok, is it a switch? (#switch=state 0=0ff 1=on)
	
	cmp r0,#32
	bne notSwitchThing
		@ ok, we need to change the state of the switch to on
		ldr r4,=onSwitch
		ldr r2,[r4]
		cmp r2,#0
		bne notSwitchThing
		
		ldr r4,=switch 
		ldr r2,[r4]
		cmp r2,#1
		movne r2,#1					@ flip switch
		moveq r2,#0
		str r2,[r4]
		@ now to redraw the switch
		
		bl flipSwitch
		
		ldr r4,=onSwitch
		mov r2,#125
		str r2,[r4]					@ set timer so it cannot flip in same contact
		b checkCollectDieDone

	notSwitchThing:
	ldr r4,=onSwitch
	ldr r2,[r4]
	sub r2,#1
	cmp r2,#0
	movlt r2,#0
	str r2,[r4]						@ reduce switch timer	




	checkCollectDieDone:
	ldmfd sp!, {r0-r10, pc}

@--------------------------------------------
	
checkCollectDieFeet:
	@ we need to pass this 2 things for now - the r9,r10 from detect code and also
	@ the offset value for colmapstore
	@ r0 = collide value
	@ r1 = offset
	
	stmfd sp!, {r0-r10, lr}
	
	cmp r0,#64							@ check for DEATH first!
	blt notDieThingFeet

		ldr r3,=spriteX+256
		ldr r3,[r3]
		and r3,#7
		cmp r3,#1
		bgt dieCheckFeet2
		cmp r3,#6
		blt dieCheckFeet2
		
		b notDieThingFeet
		
		dieCheckFeet2:
		
		bl initDeath

		b checkCollectDieDone

	notDieThingFeet:

	ldr r3,=minerAction
	ldr r3,[r3]
	cmp r3,#MINER_FALL
	beq notDieThing
	cmp r3,#MINER_JUMP
	beq notDieThing

	ldmfd sp!, {r0-r10, pc}


@--------------------------------------------

initDeath:
	stmfd sp!, {r0-r10, lr}

	ldr r1,=cheatMode
	ldr r0,[r1]
	cmp r0,#1
	moveq r0,#0
	movne r0,#1

	ldr r1,=minerDied
	str r0,[r1]
	
	ldr r1,=minerLives
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#0
	str r0,[r1]

	bl drawLives
	
	bl playDead

	ldmfd sp!, {r0-r10, pc}	

@--------------------------------------------

checkFall:
	stmfd sp!, {r0-r7,r9,r10, lr}	
	
	@ call this with r9 and r10 set from a collision check
	@ and it will return r8 with 0 if fall continues and 1 if fall is over

	@ if both r9,r10 >=24 or 0 fall is ok
	
	mov r8,#0
	
	cmp r9,#0
	beq checkFall2
	cmp r9,#24
	bge checkFall2

		ldr r7,=spriteY+256				@ this is perhaps not the best way???
		ldr r6,[r7]
		and r6,#7
		cmp r6,#3			@ was 5...
		bge checkFall3

	mov r8,#1

	ldmfd sp!, {r0-r7,r9,r10, pc}		
	
	checkFall2:
	cmp r10,#0
	beq checkFall3
	cmp r10,#24
	bge checkFall3

		ldr r7,=spriteY+256				@ this is perhaps not the best way???
		ldr r6,[r7]
		and r6,#7
		cmp r6,#3			@ was 5...
		bge checkFall3

	mov r8,#1

	ldmfd sp!, {r0-r7,r9,r10, pc}	
	
	checkFall3:

	ldmfd sp!, {r0-r7,r9,r10, pc}

@--------------------------------------------

checkExit:
	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=keyCounter
	ldr r0,[r0]
	cmp r0,#0
@	bne checkExitFail

	ldr r1,=spriteActive
	mov r0,#63				@ use the 63rd sprite
	ldr r2,[r1,r0,lsl#2]
	cmp r2,#EXIT_OPEN
	bne checkExitFail

			ldr r0,=spriteX+256
			ldr r0,[r0]
			ldr r1,=spriteY+256
			ldr r1,[r1]
			ldr r2,=exitX
			ldr r2,[r2]
			ldr r3,=exitY
			ldr r3,[r3]
			ldr r4,=minerAction
			ldr r4,[r4]
			cmp r4,#MINER_NORMAL
			moveq r5,#3
			movne r5,#13
	
			mov r5,#6
			add r0,r5
			cmp r0,r2
			sub r0,r5
			blt checkExitFail
			add r2,r5
			cmp r0,r2
			sub r2,r5
			bgt checkExitFail
			add r1,r5
			cmp r1,r3
			sub r1,r5
			blt checkExitFail
			add r3,r5
			cmp r1,r3
			sub r3,r5
			bgt checkExitFail			

				ldr r0,=gameMode
				mov r1,#GAMEMODE_LEVEL_CLEAR_INIT
				str r1,[r0]

	checkExitFail:

	ldmfd sp!, {r0-r10, pc}	

@--------------------------------------------

checkBlocked:
	stmfd sp!, {r0-r10, lr}	
	@ pass r9,r10 as 2 to check 
	@ if r9=1-3 or r10=1-3 return 1, else 0 in r11
	
	mov r11,#0
	
	cmp r9,#0
	beq checkBlock2
	cmp r9,#3
	bgt checkBlock2

	mov r11,#1
	ldmfd sp!, {r0-r10, pc}		
	
	checkBlock2:
	cmp r10,#0
	beq checkBlock3
	cmp r10,#3
	bgt checkBlock3

	mov r11,#1

	ldmfd sp!, {r0-r10, pc}	

	checkBlock3:

	ldmfd sp!, {r0-r10, pc}	


@--------------------------------------------
	
	crumbleWait:
		.word 0

	.pool
	.end