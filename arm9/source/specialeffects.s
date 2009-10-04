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
	
	.global updateSpecialFX
	
	.global rainInit
	.global rainUpdate
	.global starsInit
	.global starsUpdate
	.global leafInit
	.global leafUpdate
	.global glintInit
	.global glintUpdate
	.global dripInit
	.global dripUpdate
	.global eyesInit
	.global fliesInit
	.global mallowInit
	.global cStarsInit
	.global bloodInit
	.global bulbInit
	.global blinksInit
	.global killersInit
	.global sparkInit
	.global kongInit
	.global meteorInit
	.global meteorPhase
	.global meteorDrops
	.global forceFieldInit
	.global antonInit
	.global liftInit
	.global rockyInit
	.global fFlagInit

	.global specialFXStop

@------------------------------------ Special Effect Update

updateSpecialFX:
	stmfd sp!, {r0-r10, lr}

	ldr r0,=specialEffect
	ldr r0,[r0]
	cmp r0,#FX_RAIN
	bleq rainUpdate
	cmp r0,#FX_STARS
	bleq starsUpdate	
	cmp r0,#FX_LEAVES
	bleq leafUpdate
	cmp r0,#FX_GLINT
	bleq glintUpdate
	cmp r0,#FX_DRIP
	bleq dripUpdate
	cmp r0,#FX_FLIES
	bleq fliesUpdate
	cmp r0,#FX_MALLOW
	bleq mallowUpdate
	cmp r0,#FX_BULB
	bleq bulbUpdate
	cmp r0,#FX_BLINKS
	bleq blinksUpdate
	cmp r0,#FX_KILLERS
	bleq killersUpdate
	cmp r0,#FX_SPARK
	bleq sparkUpdate
	cmp r0,#FX_KONG
	bleq kongUpdate
	cmp r0,#FX_METEOR
	bleq meteorUpdate
	cmp r0,#FX_FORCEFIELD
	bleq forceFieldUpdate
	cmp r0,#FX_ANTON
	bleq antonUpdate
	cmp r0,#FX_LIFT
	bleq liftUpdate
	cmp r0,#FX_ROCKY
	bleq rockyUpdate
	cmp r0,#FX_FFLAG
	bleq fFlagUpdate

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Init rain
rainInit:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#62
	rainInitLoop:
		ldr r1,=spriteActive
		mov r2,#FX_RAIN_ACTIVE
		str r2,[r1,r0,lsl#2]
		ldr r1,=spriteObj
		mov r2,#RAIN_FRAME			@ object for rain
		str r2,[r1,r0,lsl#2]
		
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF
		and r8,r7
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		add r8,#384
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		and r8,#3
		cmp r8,#0
		moveq r8,#1
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]
		
	
	subs r0,#1
	bpl rainInitLoop
	
	mov r8,#0
	ldr r1,=lightningFlash
	str r8,[r1]
	
	ldr r9,=lightningDelay
	mov r10,#RAIN_LIGHTNING_DELAY
	str r10,[r9]
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update rain
rainUpdate:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#62
	rainUpdateLoop:
		ldr r1,=spriteActive
		ldr r2,[r1,r0,lsl#2]
		cmp r2,#FX_RAIN_ACTIVE
		bne rainBack
		
		ldr r1,=spriteSpeed
		ldr r2,[r1,r0,lsl#2]			@ r3=speed
		
		ldr r1,=spriteX
		ldr r3,[r1,r0,lsl#2]			@ x coord
		sub r3,r2
		cmp r3,#32
		blt rainNew
		str r3,[r1,r0,lsl#2]
		
		ldr r1,=spriteY
		ldr r4,[r1,r0,lsl#2]			@ y coord
		add r4,r2
		cmp r4,#192+384
		bgt rainNew
		str r4,[r1,r0,lsl#2]	
		
		cmp r3,#64+8
		ble rainBack
		cmp r3,#(64+256)-8
		bge rainBack
		
		@ check for 'SPLASHY TIME'
		@ r3,r4= rain x/y
		sub r3,#64
		lsr r3,#3
		sub r4,#384
		add r4,#16
		lsr r4,#3
		
		lsl r5,r4,#5
		add r5,r5,r3					@ r5=offset for pixel detect
		ldr r6,=colMapStore
		ldrb r1,[r6,r5]					@ r5=value
		cmp r4,#0
		beq skipRandomSplash
		cmp r4,#23
		bge skipRandomSplash
		
		@ if this is between 1 and 23 this is a platform
		
		bl getRandom
		and r8,#0xFF
		cmp r8,#32
		bpl rainBack
		
		skipRandomSplash:
		
		cmp r1,#0
		beq rainNotPlatform
		cmp r1,#23
		bgt rainNotPlatform
		
			@ now we need to check 1 char above
			sub r5,#32
			ldrb r1,[r6,r5]
			cmp r1,#0
			beq rainOnPlatform
			cmp r1,#23
			bgt rainOnPlatform
			b rainNotPlatform
		
			@ ok, this is now a good area for a splash
			
			rainOnPlatform:
			
			ldr r1,=spriteY
			ldr r4,[r1,r0,lsl #2]
			lsr r4,#3
			lsl r4,#3
			str r4,[r1,r0,lsl #2]
			
			ldr r1,=spriteX
			ldr r4,[r1,r0,lsl #2]
			sub r4,#3
			str r4,[r1,r0,lsl #2]
	
			mov r2,#FX_RAIN_SPLASH
			ldr r1,=spriteActive
			str r2,[r1,r0,lsl #2]
			mov r2,#RAIN_SPLASH_FRAME

			ldr r1,=spriteObj
			str r2,[r1,r0,lsl #2]
			mov r2,#RAIN_SPLASH_ANIM
			ldr r1,=spriteAnimDelay
			str r2,[r1,r0,lsl #2]		
		
		rainNotPlatform:

		rainBack:
	
	subs r0,#1
	bpl rainUpdateLoop

	
	@ OK, check for lightning... (if delay is 0)
	
	ldr r9,=lightningDelay
	ldr r10,[r9]
	cmp r10,#0
	beq rainLightning
	sub r10,#1
	str r10,[r9]
	b rainNoLightningFlash
	
	rainLightning:
	
	ldr r1,=lightningFlash
	ldr r0,[r1]

	bl getRandom
	ldr r7,=1023
	and r8,r7
	cmp r8,#4
	bgt rainNoLightning
		cmp r0,#0
		bne rainNoLightning
		mov r0,#14
		str r0,[r1]
		
		@-----          LIGHTNING NOISE
	rainNoLightning:
	
	@ UPDATE LIGHTNING
	
	cmp r0,#0
	subne r0,#1
	str r0,[r1]

@	ldr r2,=gameMode
@	ldr r2,[r2]
@	cmp r2,#GAMEMODE_DIES_UPDATE
@	beq rainNoLightningFlash


	ldr r2,=SUB_BLEND_Y
	str r0,[r2]
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	strh r1, [r0]
	
	rainNoLightningFlash:
	
	ldmfd sp!, {r0-r10, pc}

	rainNew:
		
		@ generate new rain

		bl getRandom				@ r8 returned
		ldr r7,=0x1FF
		and r8,r7
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		mov r8,#384+32
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		and r8,#3
		cmp r8,#0
		moveq r8,#1
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]		
		
	b rainBack

@------------------------------------ Stop rain
specialFXStop:
	stmfd sp!, {r0-r10, lr}

	mov r0,#62
	ldr r2,=spriteActive
	mov r3,#0
	rainStopLoop:
	
		str r3,[r2,r0,lsl#2]
	
	subs r0,#1
	bpl rainStopLoop
	
	ldr r2,=specialEffect
	ldr r4,[r2]
	str r3,[r2]
	cmp r4,#FX_RAIN
	beq sFXStop
	cmp r4,#FX_KONG
	beq sFXStop
		
	mov r0,#0
	ldr r2,=SUB_BLEND_Y
	str r0,[r2]
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	strh r1, [r0]
	
	sFXStop:
	
	ldmfd sp!, {r0-r10, pc}	
	
@-----------------

.pool	
	
@------------------------------------ Init stars
starsInit:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#62
	starsInitLoop:
		ldr r1,=spriteActive
		mov r2,#FX_STARS_ACTIVE
		str r2,[r1,r0,lsl#2]
		ldr r1,=spriteObj
		mov r2,#STAR_FRAME			@ object for stars
		str r2,[r1,r0,lsl#2]
		
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF				@ and with 256
		and r8,r7
		add r8,#64
		lsl r8,#12
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		add r8,#384+48
		lsl r8,#12
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		lsr r8,#20
		add r8,#1024
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]

	subs r0,#1
	bpl starsInitLoop
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update stars
starsUpdate:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#62
	starsUpdateLoop:
		ldr r1,=spriteActive
		ldr r2,[r1,r0,lsl#2]
		cmp r2,#FX_STARS_ACTIVE
		bne starsReturn
		
		ldr r1,=spriteSpeed
		ldr r2,[r1,r0,lsl#2]			@ r3=speed
		
		ldr r1,=spriteX
		ldr r3,[r1,r0,lsl#2]			@ x coord
		sub r3,r2
		mov r4,#32
		lsl r4,#12
		cmp r3,r4
		blt starsNew
		str r3,[r1,r0,lsl#2]


		starsReturn:
	subs r0,#1
	bpl starsUpdateLoop
	
	ldmfd sp!, {r0-r10, pc}
	
starsNew:
		mov r8,#256
		add r8,#64
		lsl r8,#12
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		add r8,#384+48
		lsl r8,#12
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		lsr r8,#20
		add r8,#1024
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]	
	b starsReturn
	ldmfd sp!, {r0-r10, pc}
@------------------------------------

.pool
	
@------------------------------------ Init leaves
leafInit:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#30
	leafInitLoop:
		ldr r1,=spriteActive
		mov r2,#FX_LEAVES_ACTIVE
		str r2,[r1,r0,lsl#2]
		ldr r1,=spriteObj
		mov r2,#LEAF_FRAME			@ object for rain
		str r2,[r1,r0,lsl#2]
		
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF				@ and with 256
		and r8,r7
		add r8,#64
		lsl r8,#12
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		add r8,#384+48
		lsl r8,#12
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		lsr r8,#21
		add r8,#256
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]
		ldr r1,=spriteMonsterMove
		mov r8,#0
		str r8,[r1,r0,lsl#2]		
		ldr r1,=spriteAnimDelay
		mov r8,#16
		str r8,[r1,r0,lsl#2]
		
		bl getRandom
		and r8,#0x1					@ random float direction
		ldr r1,=spriteDir
		str r8,[r1,r0,lsl#2]
		
		@ Ok, we need to rock them???
	
	subs r0,#1
	bpl leafInitLoop
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update leaves
leafUpdate:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#30
	leafUpdateLoop:
		ldr r1,=spriteActive
		ldr r2,[r1,r0,lsl#2]
		cmp r2,#FX_LEAVES_ACTIVE
		bne leafReturn
		
		ldr r1,=spriteSpeed
		ldr r2,[r1,r0,lsl#2]			@ r3=speed
		ldr r3,=leafFall
		ldr r4,=spriteAnimDelay
		ldr r4,[r4,r0,lsl#2]
		ldrb r4,[r3,r4]
		lsl r4,#4
		subs r2,r4
		cmp r2,#0
		movmi r2,#128
		
		ldr r1,=spriteY
		ldr r3,[r1,r0,lsl#2]			@ Y coord
		add r3,r2
		mov r4,#248
		add r4,#384
		lsl r4,#12
		cmp r3,r4
		bgt leafNew
		str r3,[r1,r0,lsl#2]
		
		ldr r1,=spriteX
		ldr r5,=spriteDir
		ldr r3,[r5,r0,lsl#2]
		ldr r6,=spriteAnimDelay
		ldr r7,[r6,r0,lsl#2]
		cmp r3,#0
		bne leafRight
		@ leaf Left
			bl getRandom
			and r8,#0xFF
			cmp r8,#4
			bpl leftLeafNoChange
			cmp r7,#4
			movle r3,#1
			strle r3,[r5,r0,lsl#2]			
			leftLeafNoChange:
			@ r1=sprite
			
			ldr r2,[r1,r0,lsl#2]			@ r2=x co
			ldr r9,=spriteMonsterMove
			ldr r10,[r9,r0,lsl#2]			@ r10=speed
			cmp r10,#-2048
			subgt r10,#128
			str r10,[r9,r0,lsl#2]
			adds r2,r10
			str r2,[r1,r0,lsl#2]
			mov r10,#32
			lsl r10,#12
			cmp r2,r10
			blt leafNew

			ldr r1,=spriteAnimDelay
			cmp r7,#0
			subne r7,#1
			str r7,[r1,r0,lsl#2]
			
			b leafMoved
		
		leafRight:
			bl getRandom
			and r8,#0xFF
			cmp r8,#4
			bpl rightLeafNoChange
			cmp r7,#28
			movge r3,#0
			strge r3,[r5,r0,lsl#2]			
			rightLeafNoChange:
			
			ldr r2,[r1,r0,lsl#2]			@ r2=x co
			ldr r9,=spriteMonsterMove
			ldr r10,[r9,r0,lsl#2]			@ r10=speed
			cmp r10,#2048
			addlt r10,#128
			str r10,[r9,r0,lsl#2]
			adds r2,r10
			str r2,[r1,r0,lsl#2]
			mov r10,#256+96
			lsl r10,#12
			cmp r2,r10
			bgt leafNew
			
			ldr r1,=spriteAnimDelay
			cmp r7,#31
			addne r7,#1
			str r7,[r1,r0,lsl#2]

		leafMoved:
			@ generate frame from spriteAnimDelay
			
			ldr r1,=leafSwing
			ldrb r5,[r1,r7]
			ldr r1,=spriteObj
			str r5,[r1,r0,lsl#2]			

		leafReturn:
	subs r0,#1
	bpl leafUpdateLoop
	
	ldmfd sp!, {r0-r10, pc}
	
leafNew:
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF				@ and with 256
		and r8,r7
		add r8,#64
		lsl r8,#12
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		mov r8,#384
		add r8,#32
		lsl r8,#12
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		lsr r8,#21
		add r8,#256
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]
		
		ldr r1,=spriteMonsterMove
		mov r8,#0
		str r8,[r1,r0,lsl#2]		
		
		ldr r1,=spriteAnimDelay
		mov r8,#16
		str r8,[r1,r0,lsl#2]
		
		bl getRandom
		and r8,#0x1					@ random float direction
		ldr r1,=spriteDir
		str r8,[r1,r0,lsl#2]
	
	b leafReturn
	ldmfd sp!, {r0-r10, pc}	
	
	
@------------------------------------ Init Glint
glintInit:
	stmfd sp!, {r0-r10, lr}
	
	@ I am not sure we need to init anything????
		
	mov r2,#0
	mov r0,#62
	glintInitLoop:
		ldr r1,=spriteActive
		str r2,[r1,r0,lsl#2]
	subs r0,#1
	bpl glintInitLoop
	

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update Glint
glintUpdate:
	stmfd sp!, {r0-r10, lr}
	
	@ get a random x/y coord and check against level for 1 in colmap
	@ all we want to glint is walls
	
	bl getRandom
	and r8,#0xFF
	mov r0,r8						@ r0=x=0-255
	bl getRandom
	and r8,#0xFF
	lsr r8,#2
	mov r3,#3
	mul r8,r3
	mov r1,r8						@ r1=y=0-191

	
	mov r3,r0,lsr #3				@ x=0-31
	mov r4,r1,lsr #3				@ y=0-23
	lsl r4,#5
	add r3,r4
@	add r5,r3,r4,lsl #5
	ldr r2,=colMapStore
	ldrb r2,[r2,r3]
	cmp r2,#1
	bne glintUpdateFail

		@ ok, we have a hit, start at r0,r1 (both minus 4)
		@ first find a spare sprite..
		bl spareSpriteFX
		cmp r10,#0
		beq glintUpdateFail

		@ r10=sprite
		ldr r2,=spriteActive
		mov r3,#FX_GLINT_ACTIVE
		str r3,[r2,r10,lsl#2]
	
		add r0,#64
		ldr r2,=spriteX
		str r0,[r2,r10,lsl#2]
		add r1,#384
		sub r1,#12
		ldr r2,=spriteY
		str r1,[r2,r10,lsl#2]
		
		mov r0,#GLINT_FRAME
		ldr r2,=spriteObj
		str r0,[r2,r10,lsl#2]
		
		ldr r2,=spritePriority
		mov r0,#2
		str r0,[r2,r10,lsl#2]
		
		mov r0,#GLINT_ANIM
		ldr r2,=spriteAnimDelay
		str r0,[r2,r10,lsl#2]
	
	
	glintUpdateFail:
	
	
	ldmfd sp!, {r0-r10, pc}
	
	
.pool	
@------------------------------------ Init Drip
dripInit:
	stmfd sp!, {r0-r10, lr}
	
	@ Load the fxdrip sprites (FXDrip)

	
		ldr r0,=FXDripTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXDripTilesLen
		
		bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update Drip
dripUpdate:
	stmfd sp!, {r0-r10, lr}
	
	@ get a random x/y coord and check against level for 1 in colmap
	@ all we want to glint is walls
	
	bl getRandom
	and r8,#0xFF
	mov r0,r8						@ r0=x=0-255
	bl getRandom
	and r8,#0xFF
	lsr r8,#2
	mov r3,#3
	mul r8,r3
	mov r1,r8						@ r1=y=0-191
	
	cmp r1,#191-8
	bge dripUpdateFail
	
	mov r3,r0,lsr #3				@ x=0-31 r3
	mov r4,r1,lsr #3				@ y=0-23 r4
	lsl r4,#5
	add r6,r3,r4					@ r6=colmap offset
	ldr r2,=colMapStore
	ldrb r3,[r2,r6]
	cmp r3,#0
	beq dripUpdateFail
	cmp r3,#12
	bge dripUpdateFail
	add r6,#32
	ldrb r3,[r2,r6]
	cmp r3,#0
	bne dripUpdateFail

		@ ok, we have a hit, start at r0,r1 (both minus 4)
		@ first find a spare sprite..
		bl spareSpriteFX
		cmp r10,#0
		beq dripUpdateFail

		@ r10=sprite
		ldr r2,=spriteActive
		mov r3,#FX_DRIP_ACTIVE
		str r3,[r2,r10,lsl#2]
	
		add r0,#64
		ldr r2,=spriteX
		lsr r0,#3
		lsl r0,#3
		bl getRandom
		and r8,#3
		subs r8,#2
		adds r0,r8
		str r0,[r2,r10,lsl#2]
		lsr r1,#3
		lsl r1,#3
		add r1,#8
		add r1,#384
		ldr r2,=spriteY
		str r1,[r2,r10,lsl#2]
		
		mov r0,#DRIP_FRAME
		ldr r2,=spriteObj
		str r0,[r2,r10,lsl#2]
		
		ldr r2,=spritePriority
		mov r0,#2
		str r0,[r2,r10,lsl#2]
		
		mov r0,#DRIP_ANIM
		ldr r2,=spriteAnimDelay
		str r0,[r2,r10,lsl#2]
	
	
	dripUpdateFail:
	
	
	ldmfd sp!, {r0-r10, pc}

	
@------------------------------------ Init Eyes
eyesInit:
	stmfd sp!, {r0-r10, lr}
	
	@ Load the eyes sprites (FXEyes)

	
		ldr r0,=FXEyesTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXDripTilesLen
		
		bl dmaCopy
		
		ldr r1,=spriteActive
		mov r0,#FX_EYES_ACTIVE
		str r0,[r1]
		ldr r1,=spriteX
		mov r0,#(11*8)+64
		str r0,[r1]
		ldr r1,=spriteY
		mov r0,#(6*8)+384
		str r0,[r1]
		ldr r1,=spriteObj
		mov r0,#EYE_FRAME
		str r0,[r1]
		ldr r1,=spriteAnimDelay
		mov r0,#EYE_ANIM
		str r0,[r1]

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Init Flies
fliesInit:
	stmfd sp!, {r0-r10, lr}
	
	@ Load the fly sprites (FXFlies)

	
		ldr r0,=FXFliesTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXFliesTilesLen
		
		bl dmaCopy

	mov r0,#30
	flieInitLoop:
		ldr r1,=spriteActive
		mov r2,#FX_FLIES_ACTIVE
		str r2,[r1,r0,lsl#2]
		ldr r1,=spriteObj
		mov r2,#FLY_FRAME			@ object for FLIES
		bl getRandom
		and r8,#03
		add r2,r8
		str r2,[r1,r0,lsl#2]
		
		bl getRandom				@ r8 returned
		and r8,#127
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#31
		add r8,#384+48
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r8,#FLY_ANIM
		str r8,[r1,r0,lsl#2]
	
	subs r0,#1
	bpl flieInitLoop

	ldmfd sp!, {r0-r10, pc}
@------------------------------------ Init Eyes
fliesUpdate:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#30
	
	fliesUpdateLoop:
	
		ldr r1,=spriteActive
		ldr r2,[r1,r0,lsl#2]
		cmp r2,#FX_FLIES_ACTIVE
		bne fliesSkip	
		@ ok, time to move our flies
		bl getRandom
		and r8,#1	
		ldr r3,=spriteX
		ldr r4,[r3,r0,lsl#2]
		cmp r8,#0
		bne fliesRight
			sub r4,#1
			cmp r4,#64
			movlt r4,#64
			b fliesLRDone
		fliesRight:
			add r4,#1
			cmp r4,#191
			movgt r4,#191
	
		fliesLRDone:
		str r4,[r3,r0,lsl#2]
		bl getRandom
		and r8,#1	
		ldr r3,=spriteY
		ldr r4,[r3,r0,lsl#2]
		cmp r8,#0
		bne fliesDown
			sub r4,#1
			cmp r4,#424
			movlt r4,#424
			b fliesUDDone
		fliesDown:
			add r4,#1
			cmp r4,#424+48
			movgt r4,#424+48
		fliesUDDone:
		str r4,[r3,r0,lsl#2]
	
		fliesSkip:
	subs r0,#1
	bpl fliesUpdateLoop


	ldmfd sp!, {r0-r10, pc}
	

@------------------------------------ Init mallow mans eyes
mallowInit:
	stmfd sp!, {r0-r10, lr}
	
	@ Load the mallow sprites (FXMallow)

	
		ldr r0,=FXMallowTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXMallowTilesLen		
		bl dmaCopy

		@ Ok, we need 2 eyes pointing left (24 and 28)

		ldr r1,=spriteActive
		mov r2,#FX_MALLOW_ACTIVE
		str r2,[r1]
		ldr r1,=spriteObj
		mov r2,#24		
		str r2,[r1]
		mov r8,#190
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1]		@ store X	0-255
		mov r8,#69
		add r8,#384
		ldr r1,=spriteY
		str r8,[r1]		@ store y	0-191
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1]

		ldr r1,=spriteActive+4
		mov r2,#FX_MALLOW_ACTIVE
		str r2,[r1]
		ldr r1,=spriteObj+4
		mov r2,#28		
		str r2,[r1]
		mov r8,#190+16
		add r8,#64
		ldr r1,=spriteX+4
		str r8,[r1]		@ store X	0-255
		mov r8,#67
		add r8,#384
		ldr r1,=spriteY+4
		str r8,[r1]		@ store y	0-191
		ldr r1,=spritePriority+4
		mov r8,#3
		str r8,[r1]


	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Update mallow mans eyes
mallowUpdate:
	stmfd sp!, {r0-r10, lr}	
	
	@ If x is between 193 and 203, go crosseyed.. Left=27 right=29
	
	ldr r1,=spriteX+256
	ldr r1,[r1]
	
	ldr r5,=193+64
	ldr r6,=203+64
	
	cmp r1,r5
	blt mallowNoCross
	cmp r1,r6
	bgt mallowNoCross
	
		mov r2,#27
		ldr r1,=spriteObj
		str r2,[r1]
		mov r2,#29
		add r1,#4
		str r2,[r1]
	
		b mallowUpdateDone
	mallowNoCross:
	
	
	ldr r3,=197+64
	ldr r4,=224+64
	
	cmp r1,#80+64
	movlt r2,#24
	blt mallowDone
	cmp r1,r3
	movlt r2,#25
	blt mallowDone
	cmp r1,r4
	movlt r2,#26
	blt mallowDone
	mov r2,#27
	mallowDone:
	
	ldr r1,=spriteObj
	str r2,[r1]
	add r2,#4
	add r1,#4
	str r2,[r1]
	
	mallowUpdateDone:

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ init stars for casablanca.. (call twinkleInit)
cStarsInit:
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=FXCasablancaTiles
	ldr r1,=SPRITE_GFX_SUB
	add r1,#24*256				@ dump at 24th sprite
	ldr r2,=FXCasablancaTilesLen
	
	bl dmaCopy
	
	bl twinkleInit

	@ ok, add the flag at sprite 62
	
	mov r10,#62
	ldr r2,=spriteActive
	mov r3,#FX_CFLAG_ACTIVE
	str r3,[r2,r10,lsl#2]
	
	mov r0,#196+18
	add r0,#64
	ldr r2,=spriteX
	str r0,[r2,r10,lsl#2]
	mov r0,#72
	add r0,#384
	ldr r2,=spriteY
	str r0,[r2,r10,lsl#2]
		
	mov r0,#CFLAG_FRAME
	ldr r2,=spriteObj
	str r0,[r2,r10,lsl#2]
		
	ldr r2,=spritePriority
	mov r0,#2
	str r0,[r2,r10,lsl#2]
		
	mov r0,#CFLAG_ANIM
	ldr r2,=spriteAnimDelay
	str r0,[r2,r10,lsl#2]

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Generate Twinkle stars over #39 tiles
	
twinkleInit:
	stmfd sp!, {r0-r10, lr}
		
	@ get a random x/y coord and check against level for 39 in colmap
	@ then generate a twinkly

	ldr r5,=CSTARS_FRAME

	mov r10,#61
	
	twinkleInitLoop:
	
		mov r9,#10
	
		twinkleTryLoop:
	
			bl getRandom
			and r8,#0xFF
			mov r0,r8						@ r0=x=0-255
			bl getRandom
			and r8,#0xFF
			lsr r8,#2
			mov r3,#3
			mul r8,r3
			mov r1,r8						@ r1=y=0-191
	
			mov r3,r0,lsr #3				@ x=0-31
			mov r4,r1,lsr #3				@ y=0-23
			lsl r4,#5
			add r3,r4
			ldr r2,=colMapStore
			ldrb r2,[r2,r3]
			cmp r2,#39
			beq twinkleFound
		
			subs r9,#1
		bpl twinkleTryLoop
		b twinkleInitFail
		
		twinkleFound:
		ldr r2,=spriteActive
		mov r3,#FX_CSTARS_ACTIVE
		str r3,[r2,r10,lsl#2]
	
		add r0,#64
		ldr r2,=spriteX
		str r0,[r2,r10,lsl#2]
		add r1,#384
		sub r1,#6
		ldr r2,=spriteY
		str r1,[r2,r10,lsl#2]
		
		bl getRandom
		and r8,#0x7
		add r8,#CSTARS_FRAME
		ldr r2,=spriteObj
		str r8,[r2,r10,lsl#2]
		
		ldr r2,=spritePriority
		mov r0,#3
		str r0,[r2,r10,lsl#2]
		
		mov r0,#CSTARS_ANIM
		ldr r2,=spriteAnimDelay
		bl getRandom
		and r8,#0x15
		add r0,r8
		str r0,[r2,r10,lsl#2]
		ldr r2,=spriteSpeed			@ use this as a anim speed backup
		str r0,[r2,r10,lsl#2]
	
	
	twinkleInitFail:
	
	subs r10,#1
	bpl twinkleInitLoop


	ldmfd sp!, {r0-r10, pc}	
	
	
@------------------------------------ Init Eyes
bloodInit:
	stmfd sp!, {r0-r10, lr}

	
		ldr r0,=FXBloodTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXBloodTilesLen
		
		bl dmaCopy


	ldr r0,=specialEffect
	mov r1,#FX_DRIP
	str r1,[r0]

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Init Bulb flash!

bulbInit:
	stmfd sp!, {r0-r10, lr}


		ldr r0,=FXBulbTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXBulbTilesLen
		
		bl dmaCopy

		ldr r0,=lightningDelay		@ use this for length of time that light is on
		mov r1,#0					@ if 0, turn off
		str r1,[r0]
		
		@ need to display the sprites (turned off)
		@ 12 sprites from 0-11(+24)
		@ first at 80,XX
		mov r0,#72+64
		mov r1,#48+384
		
		mov r2,#0			@ sprite to use (also our counter)

		bulbInitLoop:
		
			ldr r4,=spriteActive
			mov r5,#0
			str r5,[r4,r2,lsl#2]		@ sprite off
			ldr r4,=spriteX
			str r0,[r4,r2,lsl#2]
			ldr r4,=spriteY
			str r1,[r4,r2,lsl#2]
			ldr r4,=spriteObj
			add r5,r2,#24
			str r5,[r4,r2,lsl#2]
			ldr r4,=spritePriority
			mov r5,#3
			str r5,[r4,r2,lsl#2]
			ldr r4,=spriteHFlip
			mov r5,#0
			str r5,[r4,r2,lsl#2]			
			
			add r0,#16
			cmp r0,#(64+72)+64
			moveq r0,#64+72
			addeq r1,#16
			
			add r2,#1
			cmp r2,#12
			
		bne bulbInitLoop

	ldmfd sp!, {r0-r10, pc}	

@------------------------------------ Update Bulb flash!

bulbUpdate:
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=lightningDelay
	ldr r1,[r0]
	cmp r1,#0
	beq bulbCanFlash
		subs r1,#1
		movmi r1,#0
		str r1,[r0]
		bmi bulbCanFlash
	
	ldmfd sp!, {r0-r10, pc}		
	
	bulbCanFlash:
		
	bl getRandom
	and r8,#0xff
	cmp r8,#16
	ble bulbOn
	
	@ turn Bulb off
	
	mov r3,#0
	
	bulbChange:
	
	mov r2,#11
	ldr r4,=spriteActive
	bulbChangeLoop:
	
		str r3,[r4,r2,lsl #2]
		subs r2,#1
	bpl bulbChangeLoop
	
	ldmfd sp!, {r0-r10, pc}		
	
	bulbOn:
	
	@ turn Bulb on
	
	mov r1,#10
	str r1,[r0]				@ set on timer
	mov r3,#1
	
	b bulbChange

	ldmfd sp!, {r0-r10, pc}	

	
@------------------------------------ Init blinky eyes
blinksInit:
	stmfd sp!, {r0-r10, lr}

	
		ldr r0,=FXBlinksTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXBlinksTilesLen
		
		bl dmaCopy
		
		bl blinksUpdate

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ update blinky eyes
blinksUpdate:
	stmfd sp!, {r0-r10, lr}	

	mov r10,#11
	
	blinksInitLoop:
		
			ldr r2,=spriteActive
			ldr r2,[r2,r10,lsl#2]
			cmp r2,#FX_BLINKS_ACTIVE
			beq blinksInitFail
	
			bl getRandom
			and r8,#0xff
			cmp r8,#1
			bne blinksInitFail
	
	
			bl getRandom
			and r8,#0xFF
			mov r0,r8						@ r0=x=0-255
			cmp r0,#16
			movlt r0,#16
			cmp r0,#232
			movgt r0,#232
			bl getRandom
			and r8,#0xFF
			lsr r8,#2
			mov r3,#3
			mul r8,r3
			mov r1,r8						@ r1=y=0-191
			
			cmp r1,#56
			movlt r1,#56
			cmp r1,#176
			movgt r1,#176
	
			ldr r2,=spriteActive
			mov r3,#FX_BLINKS_ACTIVE
			str r3,[r2,r10,lsl#2]
	
			add r0,#64
			lsr r0,#3
			lsl r0,#3
			bl getRandom
			and r8,#7
			subs r8,#3
			adds r0,r8
			ldr r2,=spriteX
			str r0,[r2,r10,lsl#2]
			add r1,#384
			lsr r1,#3
			lsl r1,#3
			sub r1,#6
			bl getRandom
			and r8,#7
			subs r8,#3
			adds r1,r8
			ldr r2,=spriteY
			str r1,[r2,r10,lsl#2]
		
			mov r8,#BLINKS_FRAME
			ldr r2,=spriteObj
			str r8,[r2,r10,lsl#2]
		
			ldr r2,=spritePriority
			mov r0,#3
			str r0,[r2,r10,lsl#2]
		
			mov r0,#BLINKS_ANIM
			ldr r2,=spriteAnimDelay
			bl getRandom
			and r8,#0x15
			add r0,r8
			str r0,[r2,r10,lsl#2]

	@	ldmfd sp!, {r0-r10, pc}
	
	blinksInitFail:
	
	subs r10,#1
	bpl blinksInitLoop

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Init killer anims
killersInit:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=killerDelay
	mov r0,#8
	str r0,[r1]
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update killer anims
killersUpdate:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=killerDelay
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#8
	str r0,[r1]
	bpl killersUpdateDone
	
		@ Time to animate them!!
	
		mov r0,#0
		ldr r1,=colMapStore
		ldr r5,=killerFrame
		
		killerLoop:
		
			ldrb r2,[r1,r0]
			cmp r2,#64
			blt killerLoopSkip
			cmp r2,#69
			bgt killerLoopSkip
			
			add r2,#1
			cmp r2,#69
			moveq r2,#64
			strb r2,[r1,r0]					@ store back in colmap
			sub r2,#64						@ r2=frame 0-4
			ldr r6,[r5,r2,lsl#2]			@ r6=graphical frame
			
			@ now to update the screen with the frame, we need to grab the graphic first though
			ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
			add r4, #1536					@ first tile of offscreen tiles
			add r4, #58						@ add 29 chars (58th along for first frame)
			sub r2, #24						@ make fram 0-7
			add r4, r6, lsl #1				@ add this to the offset
			ldrh r7,[r4]					@ r7 now=the graphic we need to display
			ldr r4, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
			add r4, r0, lsl #1
			strh r7,[r4]
		
			killerLoopSkip:
			
		add r0,#1
		cmp r0,#768
		bne killerLoop
	
	killersUpdateDone:
	
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Init Spark
sparkInit:
	stmfd sp!, {r0-r10, lr}
	
	@ Load the fxSpark sprites

		ldr r0,=FXSparkTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXSparkTilesLen
		
		bl dmaCopy

	ldmfd sp!, {r0-r10, pc}
	
.pool

@------------------------------------ Update Spark
sparkUpdate:
	stmfd sp!, {r0-r10, lr}
	
	bl getRandom
	and r8,#0xFF
	mov r0,r8						@ r0=x=0-255
	bl getRandom
	and r8,#0xFF
	lsr r8,#2
	mov r3,#3
	mul r8,r3
	mov r1,r8						@ r1=y=0-191
	
	cmp r1,#191-8
	bge sparkUpdateFail
	
	mov r3,r0,lsr #3				@ x=0-31 r3
	mov r4,r1,lsr #3				@ y=0-23 r4
	lsl r4,#5
	add r6,r3,r4					@ r6=colmap offset
	ldr r2,=colMapStore
	ldrb r3,[r2,r6]
	cmp r3,#0
	beq sparkUpdateFail
	cmp r3,#20
	bge sparkUpdateFail
	add r6,#32
	ldrb r3,[r2,r6]
	cmp r3,#0
	bne sparkUpdateFail
	add r6,#32
	ldrb r3,[r2,r6]
	cmp r3,#0
	bne sparkUpdateFail
	
		@ ok, we have a hit, start at r0,r1 (both minus 4)
		@ first find a spare sprite..
		bl spareSpriteFX
		cmp r10,#0
		beq sparkUpdateFail

		@ r10=sprite
		ldr r2,=spriteActive
		mov r3,#FX_SPARK_ACTIVE
		str r3,[r2,r10,lsl#2]
	
		add r0,#64
		ldr r2,=spriteX
		lsr r0,#3
		lsl r0,#3
		bl getRandom
		and r8,#3
		subs r8,#2
		adds r0,r8
		sub r0,#4
		str r0,[r2,r10,lsl#2]
		lsr r1,#3
		lsl r1,#3
		add r1,#8
		add r1,#384
		ldr r2,=spriteY
		str r1,[r2,r10,lsl#2]
		
		mov r0,#SPARK_FRAME
		ldr r2,=spriteObj
		str r0,[r2,r10,lsl#2]
		
		ldr r2,=spritePriority
		mov r0,#2
		str r0,[r2,r10,lsl#2]
		
		mov r0,#SPARK_ANIM
		ldr r2,=spriteAnimDelay
		str r0,[r2,r10,lsl#2]
	
		bl getRandom
		and r8,#1
		ldr r2,=spriteHFlip
		str r8,[r2,r10,lsl#2]
	
	sparkUpdateFail:
	
	
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Init kong sprites
kongInit:
	stmfd sp!, {r0-r10, lr}

	mov r0,#0
	ldr r1,=flickerDelay
	str r0,[r1]
	ldr r1,=kongLFrame
	str r0,[r1]
	ldr r1,=kongRFrame
	str r0,[r1]
	ldr r1,=kongHeadFrame
	str r0,[r1]
	ldr r1,=kongLDelayL
	str r0,[r1]
	ldr r1,=kongLDelayR
	str r0,[r1]
	ldr r1,=kongDelayHead
	str r0,[r1]

	@ draw the sprites to screen
	mov r10,#72						@ sprite counter
	mov r9,#0						@ coord pointer
	
	kongLeftInitLoop:
	
		ldr r1,=spriteActive
		mov r2,#MONSTER_ACTIVE
		str r2,[r1,r10,lsl#2]
		ldr r5,=kongLX
		ldr r6,[r5,r9,lsl#2]
		ldr r1,=spriteX
		str r6,[r1,r10,lsl#2]
		ldr r4,=kongLY
		ldr r6,[r4,r9,lsl#2]

		ldr r1,=spriteY
		str r6,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		add r2,r9,#24
		str r2,[r1,r10,lsl#2]
		ldr r1,=spritePriority
		mov r2,#1
		str r2,[r1,r10,lsl#2]
		
		add r10,#1
		add r9,#1
		cmp r9,#6
	bne kongLeftInitLoop

	mov r9,#0						@ coord pointer
	
	kongRightInitLoop:
	
		ldr r1,=spriteActive
		mov r2,#MONSTER_ACTIVE
		str r2,[r1,r10,lsl#2]
		
		ldr r5,=kongRX
		ldr r6,[r5,r9,lsl#2]
		ldr r1,=spriteX
		str r6,[r1,r10,lsl#2]
		ldr r4,=kongRY
		ldr r6,[r4,r9,lsl#2]
		ldr r1,=spriteY
		str r6,[r1,r10,lsl#2]
		
		ldr r1,=spriteObj
		add r2,r9,#30
		str r2,[r1,r10,lsl#2]
		ldr r1,=spritePriority
		mov r2,#1
		str r2,[r1,r10,lsl#2]
		
		add r10,#1
		add r9,#1
		cmp r9,#8
	bne kongRightInitLoop		
	
	bl kongDraw
	
	@ now the head
	
	mov r10,#84						@ sprite 84 is the head

	ldr r1,=spriteActive
	mov r2,#MONSTER_ACTIVE
	str r2,[r1,r10,lsl#2]
		
	mov r6,#128+84
	ldr r1,=spriteX
	str r6,[r1,r10,lsl#2]
	mov r6,#384
	add r6,#69
	ldr r1,=spriteY
	str r6,[r1,r10,lsl#2]
	
	ldr r1,=spriteObj
	mov r2,#39						@ 39 is the image
	str r2,[r1,r10,lsl#2]
	ldr r1,=spritePriority
	mov r2,#0
	str r2,[r1,r10,lsl#2]
	
	bl kongDraw
	
	ldr r0,=FXScratchTiles				@ tiles for dust effects
	ldr r1,=SPRITE_GFX_SUB
	add r1,#48*256						@ dump at 48th sprite
	ldr r2,=FXScratchTilesLen
	bl dmaCopy
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Draw know based on frame
kongDraw:

	@ left arm first
	stmfd sp!, {r0-r10, lr}
	
		ldr r0,=kongLFrame
		ldr r1,[r0]
		ldr r0,=FXKongLTiles
		mov r2,#6
		mul r1,r2
		add r0,r1,lsl#8 			@ r0=source
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite (6 sprites)
		ldr r2,=6*256	
		bl dmaCopy

		ldr r0,=kongRFrame
		ldr r1,[r0]
		ldr r0,=FXKongRTiles
		lsl r1,#3
		add r0,r1,lsl#8 			@ r0=source
		ldr r1,=SPRITE_GFX_SUB
		add r1,#30*256				@ dump at 30th sprite (8 sprites)
		ldr r2,=8*256	
		bl dmaCopy	
		
		@ do head
		
		ldr r0,=kongHeadFrame
		ldr r1,[r0]
		ldr r0,=FXKHeadTiles
		add r0,r1,lsl#8 			@ r0=source
		ldr r1,=SPRITE_GFX_SUB
		add r1,#39*256				@ dump at 39th sprite (1 sprites)
		mov r2,#256	
		bl dmaCopy		
	@ need to draw head also... (say, 7 frames looking left right?)
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update Kong
kongUpdate:

	@ left arm first
	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=kongLDelayL
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#28
	str r1,[r0]
	bpl kongNotLeft
	
		ldr r0,=kongLFrame
		ldr r1,[r0]
		add r1,#1
		cmp r1,#6
		moveq r1,#0
		str r1,[r0]

	kongNotLeft:

	ldr r0,=kongLDelayR
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#14
	str r1,[r0]
	bpl kongNotRight
	
		ldr r0,=kongRFrame
		ldr r1,[r0]
		add r1,#1
		cmp r1,#6
		moveq r1,#0
		str r1,[r0]

	kongNotRight:
	
	@ do head
	
	ldr r0,=kongDelayHead
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#16
	str r1,[r0]
	bpl kongNotHead
	
		ldr r0,=kongHeadFrame
		ldr r1,[r0]
		add r1,#1
		cmp r1,#8
		moveq r1,#0
		str r1,[r0]

	kongNotHead:	
	
	bl kongDraw
	
	@ now we need some kind of film effect?
	
	ldr r1,=flickerDelay
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#3
	str r0,[r1]
	bpl skipKongFlicker
	
	bl getRandom
	and r8,#7
	cmp r8,#4
	subge r8,#4
	
	ldr r2,=SUB_BLEND_Y
	str r8,[r2]
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	strh r1, [r0]	
	
	skipKongFlicker:
	
	bl getRandom
	and r8,#0xFF
	cmp r8,#64
	bpl skipKongMarks
	
		@ ok, generate a random mark on the screen
		bl spareSpriteFX
		cmp r10,#0
		beq skipKongMarks
		
		bl	kongDust

	
	skipKongMarks:

	ldmfd sp!, {r0-r10, pc}

@---------------------------------

kongDust:
	stmfd sp!, {r0-r10, lr}
	
		@ Generate dust (frame is 24-27)
		
		bl getRandom
		and r8,#7
		add r9,r8,#48

		ldr r1,=spriteActive
		mov r2,#FX_SCRATCH_ACTIVE
		str r2,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		str r9,[r1,r10,lsl#2]
		
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF
		and r8,r7
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1,r10,lsl#2]		@ store X	0-255
		
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		cmp r8,#48
		addlt r8,#120
		add r8,#384
		ldr r1,=spriteY
		str r8,[r1,r10,lsl#2]		@ store y	0-191
		ldr r1,=spritePriority
		mov r8,#1
		str r8,[r1,r10,lsl#2]		
	
		bl getRandom
		and r8,#1
		ldr r1,=spriteHFlip
		str r8,[r1,r10,lsl#2]
	
		bl getRandom
		and r8,#7
		add r8,#6
		ldr r1,=spriteAnimDelay
		str r8,[r1,r10,lsl#2]
	
	
	ldmfd sp!, {r0-r10, pc}	

@------------------------------------ Meteor Init
meteorInit:
	stmfd sp!, {r0-r10, lr}
	
	@ Load the eyes sprites (FXEyes)

	
		ldr r0,=FXMeteorTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXMeteorTilesLen
		bl dmaCopy
		
		ldr r1,=meteorPhase
		mov r0,#0
		str r0,[r1]
		ldr r1,=forcefState
		mov r0,#1
		str r0,[r1]
		ldr r1,=forcefDelay
		ldr r0,=FORCEF_DELAY
		str r0,[r1]
		
		mov r10,#84					@ 84th sprite is our meteor
		
		ldr r1,=spriteActive
		mov r0,#FX_METEOR_ACTIVE
		str r0,[r1,r10,lsl#2]
		
		ldr r1,=meteorDrops
		ldr r0,[r1]
		lsl r0,#3
		add r0,#60
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		
		ldr r1,=spriteY
		mov r0,#28+384
		str r0,[r1,r10,lsl#2]
		
		ldr r1,=spriteObj
		mov r0,#METEOR_FRAME
		str r0,[r1,r10,lsl#2]
		
		ldr r1,=spriteAnimDelay
		mov r0,#METEOR_ANIM
		str r0,[r1,r10,lsl#2]

		ldr r1,=spritePriority
		mov r0,#2
		str r0,[r1,r10,lsl#2]
		
		@ now init 4 force fields

		mov r10,#80					@ 80th sprite is our force field
		
		ldr r1,=spriteActive
		mov r0,#MONSTER_ACTIVE
		str r0,[r1,r10,lsl#2]
		mov r0,#128+24
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteY
		mov r0,#96+384
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		mov r0,#FORCEF_FRAME
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r0,#FORCEF_ANIM
		str r0,[r1,r10,lsl#2]
		add r10,#1
		ldr r1,=spriteActive
		mov r0,#MONSTER_ACTIVE
		str r0,[r1,r10,lsl#2]
		mov r0,#128+88
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteY
		mov r0,#96+384
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		mov r0,#FORCEF_FRAME
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r0,#FORCEF_ANIM
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteHFlip
		mov r0,#1
		str r0,[r1,r10,lsl#2]
		add r10,#1
		ldr r1,=spriteActive
		mov r0,#MONSTER_ACTIVE
		str r0,[r1,r10,lsl#2]
		mov r0,#128+24
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteY
		mov r0,#128+384
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		mov r0,#FORCEF_FRAME
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r0,#FORCEF_ANIM
		str r0,[r1,r10,lsl#2]
		add r10,#1
		ldr r1,=spriteActive
		mov r0,#MONSTER_ACTIVE
		str r0,[r1,r10,lsl#2]
		mov r0,#128+88
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteY
		mov r0,#128+384
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		mov r0,#FORCEF_FRAME
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r0,#FORCEF_ANIM
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteHFlip
		mov r0,#1
		str r0,[r1,r10,lsl#2]
		
		@ ok, now we need some star dust
		
	mov r0,#62
	starDInitLoop:
		ldr r1,=spriteActive
		mov r2,#FX_STARDUST_ACTIVE
		str r2,[r1,r0,lsl#2]
		ldr r1,=spriteObj
		mov r2,#STARDUST_FRAME			@ object for stars
		str r2,[r1,r0,lsl#2]
		
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF				@ and with 256
		and r8,r7
		add r8,#64
		lsl r8,#12
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		add r8,#384+48
		lsl r8,#12
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		lsr r8,#20
		add r8,#1024
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]

	subs r0,#1
	bpl starDInitLoop


	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Meteor Update
meteorUpdate:
	stmfd sp!, {r0-r10, lr}
	
	mov r10,#80
	
	meteorUpdateLoop:				@ animate force field
		
		ldr r1,=spriteAnimDelay
		ldr r0,[r1,r10,lsl#2]
		subs r0,#1
		movmi r0,#FORCEF_ANIM
		str r0,[r1,r10,lsl#2]
		bpl meteorPass
			ldr r1,=spriteObj
			ldr r0,[r1,r10,lsl#2]
			add r0,#1
			cmp r0,#FORCEF_FRAME_END+1
			moveq r0,#FORCEF_FRAME
			str r0,[r1,r10,lsl#2]
		meteorPass:
		add r10,#1
		cmp r10,#84
	bne meteorUpdateLoop
	
	ldr r1,=forcefDelay
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#FORCEF_DELAY
	str r0,[r1]
	bpl meteorUpdateDone
	
		ldr r1,=forcefState
		ldr r0,[r1]
		cmp r0,#0
		moveq r0,#1
		movne r0,#0
		str r0,[r1]
		
		beq forcefOn
		
		@ force off
		
			mov r10,#80
			mov r0,#0
			ldr r1,=spriteActive
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]		
			b meteorUpdateDone
		
		forcefOn:
	
		@ force on
			mov r10,#80
			mov r0,#MONSTER_ACTIVE
			ldr r1,=spriteActive
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]	
	
	meteorUpdateDone:
	
	@ now update them stars

	mov r0,#62
	starDUpdateLoop:
		ldr r1,=spriteActive
		ldr r2,[r1,r0,lsl#2]
		cmp r2,#FX_STARDUST_ACTIVE
		bne starDReturn
		
		ldr r1,=spriteSpeed
		ldr r2,[r1,r0,lsl#2]			@ r3=speed
		
		ldr r1,=spriteY
		ldr r3,[r1,r0,lsl#2]			@ y coord
		add r3,r2
		mov r4,#192+384
		lsl r4,#12
		cmp r3,r4
		bge starDNew
		str r3,[r1,r0,lsl#2]


		starDReturn:
	subs r0,#1
	bpl starDUpdateLoop
	
	ldmfd sp!, {r0-r10, pc}
	
starDNew:
		ldr r8,=32+384
		lsl r8,#12
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store Y	32
		bl getRandom				@ r8 returned
		and r8,#0xFF
		add r8,#64
		lsl r8,#12
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom
		lsr r8,#20
		add r8,#1024
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1,r0,lsl#2]	
	b starDReturn
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Force Field Init
forceFieldInit:
	stmfd sp!, {r0-r10, lr}

		ldr r0,=FXForceFieldTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256				@ dump at 24th sprite
		ldr r2,=FXForceFieldTilesLen
		bl dmaCopy

		ldr r1,=forcefState
		mov r0,#1
		str r0,[r1]
		ldr r1,=forcefDelay
		ldr r0,=FORCEF_DELAY
		str r0,[r1]

		mov r10,#80					@ 80th sprite is our force field
		
		ldr r1,=spriteActive
		mov r0,#MONSTER_ACTIVE
		str r0,[r1,r10,lsl#2]
		mov r0,#128+64
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteY
		mov r0,#144+384
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		mov r0,#FORCEFIELD_FRAME
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r0,#FORCEFIELD_ANIM
		str r0,[r1,r10,lsl#2]
		add r10,#1
		ldr r1,=spriteActive
		mov r0,#MONSTER_ACTIVE
		str r0,[r1,r10,lsl#2]
		mov r0,#128+96+32
		ldr r1,=spriteX
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteY
		mov r0,#72+384
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteObj
		mov r0,#FORCEFIELD_FRAME
		str r0,[r1,r10,lsl#2]
		ldr r1,=spriteAnimDelay
		mov r0,#FORCEFIELD_ANIM
		str r0,[r1,r10,lsl#2]


	ldmfd sp!, {r0-r10, pc}	
	


@------------------------------------ Force Field Update
forceFieldUpdate:	
	stmfd sp!, {r0-r10, lr}	

	mov r10,#80
	
	forceFUpdateLoop:				@ animate force field
		
		ldr r1,=spriteAnimDelay
		ldr r0,[r1,r10,lsl#2]
		subs r0,#1
		movmi r0,#FORCEF_ANIM
		str r0,[r1,r10,lsl#2]
		bpl forceFPass
			ldr r1,=spriteObj
			ldr r0,[r1,r10,lsl#2]
			add r0,#1
			cmp r0,#FORCEFIELD_FRAME_END+1
			moveq r0,#FORCEFIELD_FRAME
			str r0,[r1,r10,lsl#2]
		forceFPass:
		add r10,#1
		cmp r10,#84
	bne forceFUpdateLoop
	
	ldr r1,=forcefDelay
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#FORCEF_DELAY
	str r0,[r1]
	bpl forceFUpdateDone
	
		ldr r1,=forcefState
		ldr r0,[r1]
		cmp r0,#0
		moveq r0,#1
		movne r0,#0
		str r0,[r1]
		
		beq forceFieldOn
		
		@ force off
		
			mov r10,#80
			mov r0,#0
			ldr r1,=spriteActive
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]	
			b forceFUpdateDone
		
		forceFieldOn:
	
		@ force on
			mov r10,#80
			mov r0,#MONSTER_ACTIVE
			ldr r1,=spriteActive
			str r0,[r1,r10,lsl#2]
			add r10,#1
			str r0,[r1,r10,lsl#2]
			add r10,#1
	
	forceFUpdateDone:

	ldmfd sp!, {r0-r10, pc}		

@------------------------------------ Init Anton
antonInit:
	stmfd sp!, {r0-r10, lr}

		mov r1,#0
		ldr r0,=antonFrame
		str r1,[r0]

				
		@ display L eye
		
		ldr r1,=spriteActive
		mov r2,#FX_MALLOW_ACTIVE
		str r2,[r1]
		ldr r1,=spriteObj
		mov r2,#24		
		str r2,[r1]
		mov r8,#188+7
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1]		@ store X	0-255
		mov r8,#96+32
		add r8,#384
		ldr r1,=spriteY
		str r8,[r1]		@ store y	0-191
		ldr r1,=spritePriority
		mov r8,#3
		str r8,[r1]

		@ display R eye
		
		ldr r1,=spriteActive+4
		mov r2,#FX_MALLOW_ACTIVE
		str r2,[r1]
		ldr r1,=spriteObj+4
		mov r2,#25		
		str r2,[r1]
		mov r8,#198+16+4
		add r8,#64
		ldr r1,=spriteX+4
		str r8,[r1]		@ store X	0-255
		mov r8,#96+33
		add r8,#384
		ldr r1,=spriteY+4
		str r8,[r1]		@ store y	0-191
		ldr r1,=spritePriority+4
		mov r8,#3
		str r8,[r1]		
		
		@ display mouth
		
		ldr r1,=spriteActive+8
		mov r2,#FX_MALLOW_ACTIVE
		str r2,[r1]
		ldr r1,=spriteObj+8
		mov r2,#26		
		str r2,[r1]
		mov r8,#196+5
		add r8,#64
		ldr r1,=spriteX+8
		str r8,[r1]		@ store X	0-255
		mov r8,#96+48+10
		add r8,#384
		ldr r1,=spriteY+8
		str r8,[r1]		@ store y	0-191
		ldr r1,=spritePriority+8
		mov r8,#3
		str r8,[r1]	
		
		@ copy new effect for level complete
		
		ldr r0,=FXAntonTiles
		add r0,#24*256
		ldr r1,=SPRITE_GFX_SUB
		add r1,#40*256				@ dump at 40th sprite onwards
		ldr r2,=8*256
		bl dmaCopy

		@ copy blood ripples

		ldr r0,=FXAntonTiles
		add r0,#31*256				@ 31st tile
		ldr r1,=SPRITE_GFX_SUB
		add r1,#27*256				@ dump at 27th sprite onwards
		ldr r2,=8*256
		bl dmaCopy
		
		
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ update Anton
antonUpdate:
	stmfd sp!, {r0-r10, lr}
	
	ldr r2,=antonFrame
	ldr r0,[r2]
	cmp r0,#0
	bne antonWinkDone
		ldr r0,=antonBlinkDelay
		ldr r1,[r0]
		subs r1,#1
		movmi r1,#0
		str r1,[r0]
		bpl antonWinkDone
	
		ldr r9,=0xfff
		bl getRandom
		and r8,r9
		cmp r8,#25
		movle r0,#13
		strle r0,[r2]
		ldrle r0,=antonBlinkDelay
		movle r1,#128
		strle r1,[r0]

	antonWinkDone:
	
	ldr r9,=0xfff
	ldr r2,=antonMouthFrame
	bl getRandom
	and r8,r9
	cmp r8,#35
	movle r0,#14
	strle r0,[r2]

	b antonAnimate
	
	antonUpdateDone:
	
	@ ok, now blood
	
	
	@ get a random x/y coord and check against level for 1 in colmap
	@ all we want to splat above platforms
	
	mov r9,#8
	
	bloodTry:
	
	bl getRandom
	and r8,#0xFF
	mov r0,r8						@ r0=x=0-255
	bl getRandom
	and r8,#0xFF
	lsr r8,#2
	mov r3,#3
	mul r8,r3
	mov r1,r8						@ r1=y=0-191
	
@	cmp r1,#191-8
@	bge bloodUpdateFail
	
	mov r3,r0,lsr #3				@ x=0-31 r3
	mov r4,r1,lsr #3				@ y=0-23 r4
	lsl r4,#5
	add r6,r3,r4					@ r6=colmap offset
	ldr r2,=colMapStore
	ldrb r3,[r2,r6]
	cmp r3,#0
	beq bloodUpdateFail
	cmp r3,#21
	bge bloodUpdateFail

	sub r6,#32
	ldrb r3,[r2,r6]
	cmp r3,#0
	bne bloodUpdateFail

		@ ok, we have a hit, start at r0,r1
		@ first find a spare sprite..
		bl spareSpriteFX
		cmp r10,#0
		beq bloodUpdateFail

		@ r10=sprite
		ldr r2,=spriteActive
		mov r3,#FX_BLOOD_ACTIVE
		str r3,[r2,r10,lsl#2]
	
		add r0,#64
		ldr r2,=spriteX
		lsr r0,#3
		lsl r0,#3

		str r0,[r2,r10,lsl#2]
		lsr r1,#3
		lsl r1,#3
		sub r1,#16
		add r1,#384
		ldr r2,=spriteY
		str r1,[r2,r10,lsl#2]
		
		mov r0,#BLOOD_FRAME
		ldr r2,=spriteObj
		str r0,[r2,r10,lsl#2]
		
		ldr r2,=spritePriority
		mov r0,#2
		str r0,[r2,r10,lsl#2]
		
		mov r0,#BLOOD_ANIM
		ldr r2,=spriteAnimDelay
		str r0,[r2,r10,lsl#2]
		
		beq bloodPassed

	bloodUpdateFail:	
	
	subs r9,#1
	bpl bloodTry
	
	bloodPassed:
	
	
	ldmfd sp!, {r0-r10, pc}

@--------------

antonAnimate:

	ldr r10,=antonFrame
	ldr r9,[r10]
	cmp r9,#0
	beq antonLeftFail
	
		ldr r1,=antonEyeDelay
		ldr r2,[r1]
		subs r2,#1
		movmi r2,#2
		str r2,[r1]
	
		submi r9,#1
		str r9,[r10]
	antonLeftFail:
	
	ldr r2,=antonLeft
	ldr r3,[r2,r9,lsl#2]		@ r3=frame to copy to sprite 24
	
	ldr r0,=FXAntonTiles
	add r0,r3,lsl#8				@ add 256*sprite image
	ldr r1,=SPRITE_GFX_SUB
	add r1,#24*256				@ 24th sprite image
	mov r2,#256
	bl dmaCopy

	ldr r2,=antonRight
	ldr r3,[r2,r9,lsl#2]		@ r3=frame to copy to sprite 25
	
	ldr r0,=FXAntonTiles
	add r0,r3,lsl#8				@ add 256*sprite image
	ldr r1,=SPRITE_GFX_SUB
	add r1,#25*256				@ 25th sprite image
	mov r2,#256
	bl dmaCopy

	ldr r5,=antonMouthFrame
	ldr r6,[r5]
	cmp r6,#0
	beq antonMouthSkip
		ldr r1,=antonMouthDelay
		ldr r2,[r1]
		subs r2,#1
		movmi r2,#10
		str r2,[r1]
		bpl antonMouthSkip

			sub r6,#1
			str r6,[r5]
	
	antonMouthSkip:
	ldr r5,=antonMouth
	ldr r3,[r5,r6,lsl#2]		@ r3=frame to copy to sprite 26
	ldr r0,=FXAntonTiles
	add r0,r3,lsl#8				@ add 256*sprite image
	ldr r1,=SPRITE_GFX_SUB
	add r1,#26*256				@ 24th sprite image
	mov r2,#256
	bl dmaCopy

b antonUpdateDone

@------------------------------------ lift Init
liftInit:
	stmfd sp!, {r0-r10, lr}

		ldr r0,=FXLiftTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256
		ldr r2,=FXLiftTilesLen
		bl dmaCopy


		mov r10,#0				@ sprite number
		mov r9,#0				@ Y coord
		mov r8,#0				@ X coord

		liftInitLoop:

			ldr r1,=spriteActive
			mov r0,#FX_LIFT_ACTIVE
			str r0,[r1,r10,lsl#2]
		
			ldr r1,=spriteX
			mov r3,r8,lsl#4
			add r3,#64+96+40
			str r3,[r1,r10,lsl#2]
		
			ldr r1,=spriteY
			mov r3,r9,lsl#4
			add r3,#384+96+40
			str r3,[r1,r10,lsl#2]
			ldr r1,=spriteObj
			add r11,r10,#24

			str r11,[r1,r10,lsl#2]
			ldr r1,=spritePriority
			mov r0,#2
			str r0,[r1,r10,lsl#2]

			add r8,#1
			cmp r8,#3
			moveq r8,#0
			addeq r9,#1
		
			add r10,#1
			cmp r10,#9
		bne liftInitLoop
		
		ldr r1,=liftMotion
		mov r0,#0
		str r0,[r1]


	ldmfd sp!, {r0-r10, pc}
@---------------

liftUpdate:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=liftMotion
	ldr r0,[r0]
	cmp r0,#1
	bne liftMoveNot
	
		@ we need to move the lift upwards to destination here,
		@ remembering to remove the rope LOL
	
	
		ldr r1,=spriteY
		ldr r0,[r1]
		cmp r0,#(6*8)+384+24
		ldreq r1,=liftMotion
		moveq r0,#2
		streq r0,[r1]
		beq liftMoveFail
		
		
			@ move lift (sprites 0-8)
			ldr r2,=liftDelay
			ldr r3,[r2]
			subs r3,#1
			movmi r3,#2
			str r3,[r2]
		@	bpl liftMoveNot
			
			mov r10,#0
			
			liftUpdateLoop:
			
				ldr r0,[r1,r10,lsl#2]
				sub r0,#1
				str r0,[r1,r10,lsl#2]
				
			add r10,#1
			cmp r10,#9
			bne liftUpdateLoop

			@ now we need to remove the rope!!
			
			ldr r5, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
			add r5, #1536					@ first tile of offscreen tiles
			add r5, #16						@ add 8 chars (Our blank)
			ldrh r5,[r5]					@ r5 now=the graphic we need to display
			
			@ r5=tile to plot at y+(x+2)
			
			ldr r1,[r1]						@ r1=y
			ldr r0,=spriteX
			ldr r0,[r0]						@ r0=x
			
			sub r1,#384
			lsr r1,#3
			sub r0,#64
			lsr r0,#3
			
			ldr r3, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
			
			add r1,#1
			lsl r1,#5
			add r1,r0
			add r1,#2
			add r3,r1,lsl #1 
			
			
			strh r5,[r3]
			add r3,#2
			strh r5,[r3]	
	
			b liftMoveNot
	
		liftMoveFail:
		
		@ lift is at destination, so we need to make it solid
		
		mov r0,#0
		ldr r4,=colMapStore
		liftSolidLoop:
			ldrb r1,[r4,r0]
			mov r5,#0
			cmp r1,#61
			moveq r5,#2
			cmp r1,#62
			moveq r5,#3
			cmp r5,#0
			beq liftSolidSkip
			strb r5,[r4,r0]
			liftSolidSkip:
			add r0,#1
			cmp r0,#768
		bne liftSolidLoop

	
	liftMoveNot:
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ rocky Init
rockyInit:
	stmfd sp!, {r0-r10, lr}

		ldr r0,=FXRockyTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#40*256
		ldr r2,=8*256
		bl dmaCopy
	
	ldr r1,=killerDelay
	mov r0,#8
	str r0,[r1]

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ rocky Update
rockyUpdate:
	stmfd sp!, {r0-r10, lr}

	bl killersUpdate

	bl fxMoveSplashburst

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ flag Init
fFlagInit:
	stmfd sp!, {r0-r10, lr}

		ldr r0,=FXBackFlagTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#24*256
		ldr r2,=8*256
		bl dmaCopy
	
	ldr r1,=killerDelay
	mov r0,#8
	str r0,[r1]

	mov r10,#62
	ldr r2,=spriteActive
	mov r3,#FX_CFLAG_ACTIVE
	str r3,[r2,r10,lsl#2]
	
	mov r0,#128
	add r0,#64
	ldr r2,=spriteX
	str r0,[r2,r10,lsl#2]
	mov r0,#112
	add r0,#384
	ldr r2,=spriteY
	str r0,[r2,r10,lsl#2]
		
	mov r0,#CFLAG_FRAME
	ldr r2,=spriteObj
	str r0,[r2,r10,lsl#2]
		
	ldr r2,=spritePriority
	mov r0,#2
	str r0,[r2,r10,lsl#2]
		
	mov r0,#CFLAG_ANIM
	ldr r2,=spriteAnimDelay
	str r0,[r2,r10,lsl#2]

	ldmfd sp!, {r0-r10, pc}

@------------------------------------ flag Update
fFlagUpdate:
	stmfd sp!, {r0-r10, lr}

	bl killersUpdate

	ldmfd sp!, {r0-r10, pc}
	
	.pool
	.data
	.align
	liftDelay:
	.word 0
	
	antonLeft:
	.word 7,6,5,4,3,2,1,0,1,2,3,4,5,6
	antonRight:
	.word 15,14,13,12,11,10,9,8,9,10,11,12,13,14
	antonMouth:
	.word 16,17,18,19,20,21,22,23,22,21,20,19,18,17,16
	antonFrame:
	.word 0
	antonMouthFrame:
	.word 0
	antonMouthDelay:
	.word 0
	antonBlinkDelay:
	.word 0
	antonEyeDelay:
	.word 0
	killerDelay:
	.word 0
	killerFrame:
	.word 0,1,2,1,0
	meteorPhase:
	.word 0
	meteorDrops:
	.word 4,27,8,9,22,29,2,24,5,23,7,25,10,28,21,3
	forcefState:
	.word 0					@ 0=off 1=on
	forcefDelay:
	.word 0
	
	lightningFlash:
	.word 0
	lightningDelay:
	.word 0
	
	.align
	leafSwing:
	.byte 30,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32
	.byte 32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,34
	leafFall:
	.byte 20,20,20,20,14,14,14,14,10,10,8,4,0,0,0,0
	.byte 0,0,0,0,4,8,10,10,14,14,14,14,20,20,20,20
	.align
	kongLX:
	.word 192,208,192,208,192,208
	kongLY:
	.word 448,448,464,464,480,480
	.align
	kongRX:
	.word 224,240,224,240,224,240,224,240
	kongRY:
	.word 434,434,448,448,464,464,480,480
	kongLFrame:
	.word 0
	kongRFrame:
	.word 0
	kongHeadFrame:
	.word 0
	kongLDelayL:
	.word 0
	kongLDelayR:
	.word 0
	kongDelayHead:
	.word 0
	flickerDelay:
	.word 0