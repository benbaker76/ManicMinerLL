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
		mov r8,#2
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
	str r3,[r2]
	
	mov r0,#0
	ldr r2,=SUB_BLEND_Y
	str r0,[r2]
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r10, pc}	
	
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
		
		mov r0,#GLINT_ANIM
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
		ldr r1,=spritePriority+2
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
	
	.pool
	.data
	.align
	
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
