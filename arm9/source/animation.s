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
	.global drawCreditFrame
	
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
@	addeq r0,#5
	
	and r0,#15
	lsr r0,#1

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
	
	bl playKey
	
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
		
@------------- level 32 mod

	ldr r1,=levelNum
	ldr r1,[r1]
	cmp r1,#32
	bne stillKeysLeft
	
	bl fxSplashburstInit
	
	
@--------------	
	
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
	@ ok, r0 = offset, r1=colmap offset, r2=frame
	stmfd sp!, {r0-r10, lr}

	@ convert the offset r1 to x/y coord

	mov r3,r1
	lsr r3,#5			@ divide by 32, this is now the y area (0-23)
	mov r4,r1
	and r4,#31			@ r4 is now the x area (0-31)
	lsl r4,#3			@ r4=x
	sub r4,#4			@ centralise on X
	lsl r3,#3			@ r3=y
	add r4,#64
	add r3,#384
	
	ldr r5,=switchX
	str r4,[r5]
	ldr r5,=switchY
	str r3,[r5]
	ldr r5,=switchOn				@ say that we are on a switch
	mov r3,#1
	str r3,[r5]

	cmp r0,#32
	ldr r6,=switch1
	cmp r0,#33
	ldr r6,=switch2
	cmp r0,#34
	ldr r6,=switch3
	cmp r0,#35
	ldr r6,=switch4

	cmp r2,#0

	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, #1536					@ first tile of offscreen tiles
	addeq r4, #58					@ add 29 chars (30th along is our off switch)	
	addne r4, #60					@ add 30 chars (30th along is our on switch)
	ldrh r5,[r4]					@ r5 now=the graphic we need to display
	ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	add r4, r1, lsl #1
	strh r5,[r4]
	
	ldr r8,=levelNum
	ldr r8,[r8]
	cmp r8,#15
	beq flipSwitchWallDestroy
	cmp r8,#25
	beq flipSwitchWallDestroy
	cmp r8,#31
	beq flipSwithLiftThing
	
	@ now, flip the conveyors (ulp) (DEFAULT action)

	switchStandardReturn:
	
	mov r0,#0
	ldr r4,=colMapStore
	flipSwitchLoop:
	
		mov r2,#0
		ldrb r1,[r4,r0]
		cmp r1,#13
		moveq r2,#16
		cmp r1,#14
		moveq r2,#17
		cmp r1,#15
		moveq r2,#18
		
		cmp r1,#16
		moveq r2,#13
		cmp r1,#17
		moveq r2,#14
		cmp r1,#18
		moveq r2,#15
		cmp r2,#0
		beq notFlipSwitch
		strb r2,[r4,r0]
		notFlipSwitch:
		add r0,#1
		cmp r0,#768
	bne flipSwitchLoop
	
	flipSwitchDone:
	
	bl playClick
	
	ldmfd sp!, {r0-r10, pc}
	
@-----------------------------------------------

	flipSwitchWallDestroy:
	
	@ ok, act on 2 switches...
	@ 32= remove 2s, 33=remove 3s
	
	cmp r0,#32
	moveq r9,#2
	movne r9,#3					@ r9 = colmap tile to search for
	mov r8,#0					@ make 1 if explode sound needs to be played
	
	mov r0,#0
	ldr r4,=colMapStore
	wallDestroyLoop:
		ldrb r1,[r4,r0]
		cmp r1,r9
		bne wallDestroySkip
			mov r8,#1			@ we can explode!
		
			@ now remove the tile!!
			
			mov r7,#0
			strb r7,[r4,r0]

			ldr r5, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
			add r5, #1536					@ first tile of offscreen tiles
			add r5, #16						@ add 8 chars (Our blank)
			ldrh r5,[r5]					@ r5 now=the graphic we need to display
			ldr r6, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
			add r6, r0, lsl #1
			strh r5,[r6]

			@ we now need to call an effect to put an animation at offset r0...?


			bl r0Effect
		
		wallDestroySkip:
	
	
		add r0,#1
		cmp r0,#768
	bne wallDestroyLoop
	
	
	@ if r8<>0, make an explosion sound!!!!
	
	cmp r8,#0
	blne playExplode
	
	b flipSwitchDone
	
@------------------------------------------- Draw effect at offset r0

	r0Effect:

	stmfd sp!, {r0-r11, lr}
	
	@ First, make r0=x/y coord from offset r0..
	
	mov r3,r0
	lsr r3,#5			@ divide by 32, this is now the y area (0-23)

	mov r4,r0
	and r4,#31			@ r4 is now the x area (0-31)
	lsl r4,#3			@ r4=x
	sub r4,#4			@ centralise on X
	lsl r3,#3			@ r3=y
	add r4,#64
	add r3,#384
	sub r3,#4
	@ r3=y r4=x 
	
	@ now we need a free sprite?
	mov r11,#3
	
	r0ExplodeAgain:
	
		bl spareSprite		@ returns r10.. 0=none spare
	
		mov r1,r3
		mov r2,r4
	
		cmp r10,#0
		beq r0EffectNoneSpare
			@ generate an explosion at r2,r1 (=/- random)
			
			ldr r6,=spriteX
			bl getRandom
			and r8,#7
			subs r8,#3
			adds r2,r8
			str r2,[r6,r10,lsl#2]
			ldr r6,=spriteY
			bl getRandom
			and r8,#7
			subs r8,#3
			adds r1,r8
			str r1,[r6,r10,lsl#2]
			mov r7,#FX_EXPLODE_ACTIVE
			ldr r6,=spriteActive
			str r7,[r6,r10,lsl#2]
			mov r7,#EXPLODE_FRAME
			ldr r6,=spriteObj
			str r7,[r6,r10,lsl#2]	
			mov r7,#EXPLODE_ANIM
			bl getRandom
			and r8,#7
			add r7,r8
			ldr r6,=spriteAnimDelay
			str r7,[r6,r10,lsl#2]
			ldr r6,=spriteSpeed				@ delay backup
			str r7,[r6,r10,lsl#2]
			bl getRandom
			and r8,#1
			ldr r6,=spriteHFlip
			str r8,[r6,r10,lsl#2]
			mov r8,#1
			ldr r6,=spritePriority
			str r8,[r6,r10,lsl#2]
	
		subs r11,#1
	bpl r0ExplodeAgain

	r0EffectNoneSpare:

	ldmfd sp!, {r0-r11, pc}	
	
@-----------------------------

flipSwithLiftThing:

	@ only activate lift if liftmotion is 0
	
	ldr r1,=liftMotion
	ldr r2,[r1]
	cmp r2,#0
	moveq r2,#1
	str r2,[r1]

	bne flipSwitchDone
	
	@ ok, now remove 2 and 3 from colmap

	mov r0,#0
	ldr r4,=colMapStore
	liftClearLoop:
		ldrb r1,[r4,r0]
		cmp r1,#2
		beq liftClearPass
		cmp r1,#3
		bne liftClearFail
		
		liftClearPass:

			mov r7,#0
			strb r7,[r4,r0]
		
		liftClearFail:
	
		add r0,#1
		cmp r0,#768
	bne liftClearLoop

	@ and reverse the conveyors
	
b switchStandardReturn	

@------------------------------------------- Draw Credits side image

	drawCreditFrame:
	stmfd sp!, {r0-r11, lr}
	
	@ r10 is passed as the frame to dump - from 0-3 to BG3 SUB
	@ ok, the frames start from the map at the 25th y char
	
	ldr r0,=BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)
	add r0,#(24*32)*2							@ r1= bottom left source
	lsl r10,#3									@ 8 chars across
	lsl r10,#1									@ 2 bytes per char
	add r0,r10									@ r0=source
	
	ldr r1,=BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ r1=dest
	
	mov r2,#16
	mov r3,#24
	
	creditFrameLoop:
	
		bl dmaCopy
	
		add r0,#32*2
		add r1,#32*2
	
	subs r3,#1
	bpl creditFrameLoop

	

	ldmfd sp!, {r0-r11, pc}

@------------------------------



	.align
levelAnimDelay:
	.word 0
	
	.pool
	.end