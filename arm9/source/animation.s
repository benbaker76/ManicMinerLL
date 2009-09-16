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
	.global shardDust
	.global monsterAnimate
	.global minerChange
	.global flipSwitch
	
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
	
	ldr r0,=spriteY+256					@ make sure we are on the platform nice and firmly
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
	
	cmp r1,#13
	moveq r1,#0
	strb r1,[r0,r8]					@ update colmapstore with new value
	
	crumblerFail:
	
	ldmfd sp!, {r0-r10, lr}
	
@----------------------- ANIMATE WILLY BASED ON X COORD

minerFrame:
	@ all this does is calculate the frame based on X coord
	@ This is still not correct!!! more of a sodding cludge
	
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=gameMode
	ldr r0,[r0]
	cmp r0,#GAMEMODE_RUNNING
	bne minerFrameDone
	
	
	ldr r0,=spriteX+256
	ldr r0,[r0]
	
	ldr r2,=spriteHFlip+256
	ldr r2,[r2]
	cmp r2,#0
	addeq r0,#5
	
	and r0,#15
	lsr r0,#2

	ldr r1,=spriteObj+256
	str r0,[r1]
	
	minerFrameDone:
	
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
		
		cmp r2,#13
		blt animNotLeftConveyor
		cmp r2,#15
		bgt animNotLeftConveyor
		
		b levelAnimateLeftConveyor
		
		animNotLeftConveyor:

		cmp r2,#16
		blt animNotRightConveyor
		cmp r2,#18
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
	add r4, #42						@ add 21 chars (20th along for first frame)
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
	add r4, #18						@ add 9 chars (9th along for first frame/left edge)
	sub r2,#13						@ make image 0-2 (l/mid/r)
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
	add r4,#40						@ add 20 chars (20th along for first frame/left edge)
	sub r2,#16						@ make image 0-2 (l/mid/r)
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
	add r4, #16						@ add 8 chars (8th along is our blank)
	ldrh r5,[r4]					@ r5 now=the graphic we need to display
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r1, lsl #1
	strh r5,[r4]
	
	@ now we need to convert the offset to a screen pixel area!! (ulp!)
	mov r3,r1
	lsr r3,#5			@ divide by 32, this is now the y area (0-23)
	mov r4,r1
	and r4,#31			@ r4 is now the x area (0-31)
	lsl r4,#3			@ r4=x
	sub r4,#4			@ centralise on X
	lsl r3,#3			@ r3=y
	add r4,#64
	add r3,#384
	
	bl keyDust
	
	ldr r3,=keyCounter
	ldr r4,[r3]
	sub r4,#1			@ decrement key counter
	str r4,[r3]			@ if 0 we need to open the door..
	
	cmp r4,#0
	bne stillKeysLeft
	
		mov r4,#63					@ activate the door..
		mov r3,#EXIT_OPEN
		ldr r2,=spriteActive
		str r3,[r2,r4,lsl#2]
	
		@ perhaps a sound effect??
	
	stillKeysLeft:
	
	@ add to score
	
	mov r1,#1				@ 10 points for a key!
	ldr r2,=adder+3
	strb r1,[r2]
	bl addScore
	
	ldmfd sp!, {r0-r10, pc}

	
@---------------------------------------

shardDust:
	stmfd sp!, {r0-r10, lr}

	@ first we need to find a spare sprite
	@ call spareSprite
	@ this will return r10 with the sprite index, or 0 if failed

	bl spareSprite
	
	cmp r10,#0
	beq shardDustFail

	mov r1,#DUST_ACTIVE
	ldr r2,=spriteActive
	str r1,[r2,r10,lsl #2]
	mov r1,#DUST_FRAME
	ldr r2,=spriteObj
	str r1,[r2,r10,lsl #2]
	mov r1,#DUST_ANIM
	ldr r2,=spriteAnimDelay
	str r1,[r2,r10,lsl #2]
	ldr r2,=spriteX+256
	ldr r3,[r2]
	ldr r2,=spriteX
	str r3,[r2,r10,lsl #2]
	ldr r2,=spriteY+256
	ldr r3,[r2]
	ldr r2,=spriteY
	str r3,[r2,r10,lsl #2]	
	ldr r2,=spriteHFlip+256
	ldr r3,[r2]
	ldr r2,=spriteHFlip
	str r3,[r2,r10,lsl #2]

	shardDustFail:
	ldmfd sp!, {r0-r10, pc}

@---------------------------------------

keyDust:
	@ r4=x, r3=y
	stmfd sp!, {r0-r10, lr}

	@ first we need to find a spare sprite
	@ call spareSprite
	@ this will return r10 with the sprite index, or 0 if failed

	bl spareSprite
	
	cmp r10,#0
	beq shardKeyFail

	mov r1,#KEY_ACTIVE
	ldr r2,=spriteActive
	str r1,[r2,r10,lsl #2]
	mov r1,#KEY_FRAME
	ldr r2,=spriteObj
	str r1,[r2,r10,lsl #2]
	mov r1,#KEY_ANIM
	ldr r2,=spriteAnimDelay
	str r1,[r2,r10,lsl #2]
	ldr r2,=spriteX
	str r4,[r2,r10,lsl #2]
	ldr r2,=spriteY
	str r3,[r2,r10,lsl #2]	
	
	bl getRandom
	and r8,#1
	ldr r2,=spriteHFlip
	str r8,[r2,r10,lsl #2]

	shardKeyFail:
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------------------

monsterAnimate:
	@ r1=monster 1-7
	@ r10=frame 0-7
	@ spriteObjBase tells us which sprite is used (0-1-2-3-4) from spriteBank
	stmfd sp!, {r0-r10, lr}

		mov r5,r1
		sub r5,#1
	
		ldr r2,=spriteObjBase
		ldr r2,[r2,r1,lsl #2]
		lsl r2,#3					@ the sprites are in areas of 8
		lsl r2,#8					@ and 256 bytes per sprite
						@ r2 is the base of the sprite we need in spritebank (sprite 0)
						@ now we need to add the frame
		lsl r10,#8		@ times frame by 256
		add r2,r10
		ldr r0,=SpriteBank1Tiles
		add r0,r2		@ r3= memory address of our sprite image
		
		@ r0 = FROM
		
		ldr r1,=SPRITE_GFX_SUB
		add r5,#8		@ add 8 to the monster number for the sprite used
		lsl r5,#8		@ each sprite is 256 bytes
		add r1,r5
		
		@ r1 = TO
		
		mov r2,#256
		
		@ r2 = how many bytes
		
		bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

@---------------------------------------

minerChange:

	stmfd sp!, {r0-r10, lr}

		ldr r1,=levelNum
		ldr r0,[r1]
		cmp r0,#2
		bne minerChangeFail

		ldr r1,=spriteX+256
		ldr r1,[r1]
		ldr r2,=spriteHFlip+256
		ldr r2,[r2]

		cmp r1,#128+64
		bne minerChangeFail
		
		ldr r1,=keyCounter
		ldr r1,[r1]
		cmp r1,#0
		beq minerChangeFail
		
		cmp r2,#0
		ldreq r0,=MinerNormalTiles
		ldreq r2,=MinerNormalTilesLen
		ldrne r0,=MinerSpaceTiles
		ldrne r2,=MinerSpaceTilesLen
		moveq r4,#0
		movne r4,#2
		
		
		ldr r1, =SPRITE_GFX_SUB
		bl dmaCopy
		
		ldr r1,=willySpriteType
		str r4,[r1]

		minerChangeFail:

	ldmfd sp!, {r0-r10, pc}
	
@---------------------------------------

flipSwitch:
	@ a little bit to animate keys... Well, it works!!
	@ ok, r0 = offset, r1=colmap, r2=frame
	stmfd sp!, {r0-r10, lr}
	
	ldr r5,=switch
	ldr r5,[r5]
	cmp r5,#0
	
	@ now to erase from the screen
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, #1536					@ first tile of offscreen tiles
	addeq r4, #58					@ add 29 chars (30th along is our off switch)	
	addne r4, #60					@ add 30 chars (30th along is our on switch)
	ldrh r5,[r4]					@ r5 now=the graphic we need to display
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r1, lsl #1
	strh r5,[r4]
	
	@ now, flip the conveyors (ulp)
	
	mov r0,#0
	ldr r4,=colMapStore
	flipSwitchLoop:
	
		mov r2,#0
		ldrb r1,[r4,r0]
		cmp r1,#13
		moveq r2,#18
		cmp r1,#14
		moveq r2,#17
		cmp r1,#15
		moveq r2,#16
		
		cmp r1,#16
		moveq r2,#15
		cmp r1,#17
		moveq r2,#14
		cmp r1,#18
		moveq r2,#13
		cmp r2,#0
		beq notFlipSwitch
		strb r2,[r4,r0]
		notFlipSwitch:
		add r0,#1
		cmp r0,#768
	bne flipSwitchLoop
	

	
	ldmfd sp!, {r0-r10, pc}
	
	.align
levelAnimDelay:
	.word 0
	
	.pool
	.end