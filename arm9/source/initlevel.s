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

	.global initLevel
	.global clearSpriteData

initLevel:
	
	@ This will be used to set level specifics, ie. colmap, initial x/y, facing etc...

	stmfd sp!, {r0-r12, lr}

	ldr r12,=gameMode
	ldr r12,[r12]
	cmp r12,#GAMEMODE_TITLE_SCREEN
	blne stopMusic	
	
	bl specialFXStop	
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl clearOAM
	bl clearSpriteData
	bl fxFadeIn

	mov r0,#0
	ldr r1,=switch
	str r0,[r1]
	ldr r1,=onSwitch
	str r0,[r1]
	ldr r1,=minerDelay
	str r0,[r1]
	ldr r1,=fallCount
	str r0,[r1]
	ldr r1,=jumpCount
	str r0,[r1]
	ldr r1,=airDelay
	str r0,[r1]

	
	mov r0,#160
	ldr r1,=air
	str r0,[r1]
	
	cmp r12,#GAMEMODE_TITLE_SCREEN
	movne r0,#1
	moveq r0,#0
	ldr r1,=spriteActive+256
	str r0,[r1]
	ldr r1,=minerJumpDelay
	str r0,[r1]


	mov r0,#0
	ldr r1,=spriteObj+256
	str r0,[r1]

	mov r0,#2
	ldr r1,=spritePriority+256
	str r0,[r1]
	
	mov r0,#0
	ldr r1,=spriteAnimDelay+256
	str r0,[r1]
	ldr r1,=minerDied
	str r0,[r1]

	mov r0,#MINER_NORMAL
	ldr r1,=minerAction
	str r0,[r1]

	bl generateColMap
	
	ldr r1,=levelData
	ldr r2,=levelNum
	ldr r2,[r2]
	sub r2,#1
	add r1,r2, lsl #6				@ add r1, level number *64, r1 is now the base for the level
		
	ldrb r0,[r1],#1
	add r0,#64
	ldr r2,=exitX					@ exit x (8 bit)
	str r0,[r2]

	ldrb r0,[r1],#1
	add r0,#384
	ldr r2,=exitY					@ exit y (8 bit)
	str r0,[r2]	

	ldrb r0,[r1],#1
	mov r3,r0
	and r3,#15
	ldr r2,=keyCounter
	str r3,[r2]
	ldr r2,=musicPlay
	lsr r0,#4
	str r0,[r2]

	ldrb r0,[r1],#1
	add r0,#64
	ldr r2,=spriteX+256
	str r0,[r2]	

	ldrb r0,[r1],#1
	add r0,#384
	ldr r2,=spriteY+256
	str r0,[r2]	

	ldrb r0,[r1],#1					@ low8 = willy dir / high8 = special FX
	mov r3,r0
	and r3,#0x1
	ldr r2,=spriteHFlip+256
	str r3,[r2]	
	ldr r2,=minerDirection
	str r3,[r2]
	lsr r0,#1
	ldr r2,=specialEffect
	str r0,[r2]


	cmp r12,#GAMEMODE_TITLE_SCREEN
	blne fxSpotlightIn
	
	ldrb r0,[r1],#1			@ Background number
	bl getLevelBackground

	ldrb r0,[r1],#1			@ Door number
	mov r3,r0,lsr #5		@ high 3 bits = willy sprite 0-7
	and r0,#31				@ low 8 bits = door banck 0-31
	bl getDoorSprite
	bl getWillySprite

	bl generateMonsters		@ r1 is the pointer to the first monsters data
	
	bl drawLevel			@ Display the level graphics
	
	cmp r12,#GAMEMODE_TITLE_SCREEN
	blne levelStory			@ Display the games story in the bottom screen
	
	blne levelMusic			@ start the music
	
	bl specialEffectStart
	
	bl levelName
	
	bl levelMusic
	
	@UNCOMMENT TO OPEN EXIT
@	ldr r1,=spriteActive
@	mov r0,#63				@ use the 63rd sprite
@	mov r2,#EXIT_OPEN
@	str r2,[r1,r0,lsl#2]

	ldmfd sp!, {r0-r12, pc}

@-------------------------------------------------

clearSpriteData:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =spriteDataStart
	ldr r1, =spriteDataEnd								@ Get the sprite data end
	ldr r2, =spriteDataStart							@ Get the sprite data start
	sub r1, r2											@ sprite end - start = size
	bl DC_FlushRange
	
	mov r0, #0
	ldr r1, =spriteDataStart
	ldr r2, =spriteDataEnd								@ Get the sprite data end
	ldr r3, =spriteDataStart							@ Get the sprite data start
	sub r2, r3											@ sprite end - start = size
	bl dmaFillWords	

	ldmfd sp!, {r0-r3, pc}
	
@-------------------------------------------------

generateColMap:

	stmfd sp!, {r0-r10, lr}
	
	@ clear colmapstore
	ldr r0, =colMapStore
	ldr r1, =colMapStoreEnd
	ldr r2, =colMapStore
	sub r1, r2 @ sprite end - start = size
	bl DC_FlushRange

	mov r0, #0
	ldr r1, =colMapStore
	ldr r2, =colMapStoreEnd
	ldr r3, =colMapStore
	sub r2, r3 @ sprite end - start = size
	bl dmaFillWords 
	
	@ generate the colmapstore based on the levelNum
	
	ldr r0,=levelNum
	ldr r5,[r0]
	@ colmap is 768*level -1
	sub r5,#1
	mov r2,#768
	mul r5,r2
	ldr r0,=colMapLevels
	add r0,r5
	ldr r1,=colMapStore
	mov r2,#768
	@ r0,=src, r1=dst, r2=len
	bl dmaCopy
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

getDoorSprite:

	stmfd sp!, {r0-r10, lr}
	mov r2,#0
	cmp r0,#0
	ldreq r0, =Exit01Tiles
	ldreq r2, =Exit01TilesLen
	cmp r0,#1
	ldreq r0, =Exit02Tiles
	ldreq r2, =Exit02TilesLen
	cmp r0,#2
	ldreq r0, =Exit03Tiles
	ldreq r2, =Exit03TilesLen	
	cmp r0,#3
	ldreq r0, =Exit04Tiles
	ldreq r2, =Exit04TilesLen	
	cmp r0,#4
	ldreq r0, =Exit05Tiles
	ldreq r2, =Exit05TilesLen	
	cmp r0,#5
	ldreq r0, =Exit06Tiles
	ldreq r2, =Exit06TilesLen
	cmp r0,#6
	ldreq r0, =Exit07Tiles
	ldreq r2, =Exit07TilesLen
	cmp r0,#7
	ldreq r0, =Exit08Tiles
	ldreq r2, =Exit08TilesLen
	cmp r0,#20
	ldreq r0, =Exit21Tiles
	ldreq r2, =Exit21TilesLen
	cmp r0,#21
	ldreq r0, =Exit22Tiles
	ldreq r2, =Exit22TilesLen	
	cmp r0,#22
	ldreq r0, =Exit23Tiles
	ldreq r2, =Exit23TilesLen
	cmp r0,#26
	ldreq r0, =Exit27Tiles
	ldreq r2, =Exit27TilesLen
	cmp r2,#0
	beq skipExit
	
	@ sprite images 16-23 are for the door and its animation (door is 9th sprite)
	ldr r1, =SPRITE_GFX
	add r1, #(16*256)
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #(16*256)
	bl dmaCopy
	skipExit:
	@ now we need to add it to the screen
	ldr r1,=spriteActive
	mov r0,#63				@ use the 63rd sprite
	mov r2,#EXIT_CLOSED
	str r2,[r1,r0,lsl#2]
	ldr r3,=exitX
	ldr r3,[r3]
	ldr r1,=spriteX
	str r3,[r1,r0,lsl#2]
	ldr r3,=exitY
	ldr r3,[r3]
	ldr r1,=spriteY
	str r3,[r1,r0,lsl#2]
	mov r3,#DOOR_FRAME
	ldr r1,=spriteObj
	str r3,[r1,r0,lsl#2]
	mov r3,#0
	ldr r1,=spriteHFlip
	str r3,[r1,r0,lsl#2]
	mov r3,#4
	ldr r1,=spriteAnimDelay
	str r3,[r1,r0,lsl#2]
	
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------------------------------

getLevelBackground:

	stmfd sp!, {r0-r10, lr}
	cmp r0,#0
	ldreq r4,=Background01Tiles
	ldreq r5,=Background01TilesLen
	ldreq r6,=Background01Map
	ldreq r7,=Background01MapLen
	cmp r0,#1
	ldreq r4,=Background02Tiles
	ldreq r5,=Background02TilesLen
	ldreq r6,=Background02Map
	ldreq r7,=Background02MapLen
	cmp r0,#2
	ldreq r4,=Background03Tiles
	ldreq r5,=Background03TilesLen
	ldreq r6,=Background03Map
	ldreq r7,=Background03MapLen
	cmp r0,#3
	ldreq r4,=Background04Tiles
	ldreq r5,=Background04TilesLen
	ldreq r6,=Background04Map
	ldreq r7,=Background04MapLen
	cmp r0,#4
	ldreq r4,=Background05Tiles
	ldreq r5,=Background05TilesLen
	ldreq r6,=Background05Map
	ldreq r7,=Background05MapLen
	cmp r0,#5
	ldreq r4,=Background06Tiles
	ldreq r5,=Background06TilesLen
	ldreq r6,=Background06Map
	ldreq r7,=Background06MapLen
	cmp r0,#6
	ldreq r4,=Background07Tiles
	ldreq r5,=Background07TilesLen
	ldreq r6,=Background07Map
	ldreq r7,=Background07MapLen
	cmp r0,#7
	ldreq r4,=Background08Tiles
	ldreq r5,=Background08TilesLen
	ldreq r6,=Background08Map
	ldreq r7,=Background08MapLen
	cmp r0,#8
	ldreq r4,=Background09Tiles
	ldreq r5,=Background09TilesLen
	ldreq r6,=Background09Map
	ldreq r7,=Background09MapLen
	cmp r0,#9
	ldreq r4,=Background10Tiles
	ldreq r5,=Background10TilesLen
	ldreq r6,=Background10Map
	ldreq r7,=Background10MapLen
	cmp r0,#20
	ldreq r4,=Background21Tiles
	ldreq r5,=Background21TilesLen
	ldreq r6,=Background21Map
	ldreq r7,=Background21MapLen
	cmp r0,#21
	ldreq r4,=Background22Tiles
	ldreq r5,=Background22TilesLen
	ldreq r6,=Background22Map
	ldreq r7,=Background22MapLen
	cmp r0,#22
	ldreq r4,=Background23Tiles
	ldreq r5,=Background23TilesLen
	ldreq r6,=Background23Map
	ldreq r7,=Background23MapLen
	
	cmp r0,#26
	ldreq r4,=Background27Tiles
	ldreq r5,=Background27TilesLen
	ldreq r6,=Background27Map
	ldreq r7,=Background27MapLen
	@ Draw main game map!
	mov r0,r4
	ldr r1, =BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	mov r2,r5
	bl decompressToVRAM
	mov r0,r6
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	add r1,#384
	mov r2,r7
	bl dmaCopy
	
	noLevelBackground:

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

generateMonsters:

	stmfd sp!, {r0-r10, lr}
	
	@ just set up a dummy monster for now!
	
	@ r9 = loop for the 7 monsters that can be used per level
	@ using sprites 65-71
	
	mov r9,#65
	
	gmLoop:
		mov r0,#0
		ldr r2,=monsterDelay
		str r0,[r2,r9,lsl#2]
		ldrb r0,[r1],#1			@ monster x, if 0, no more monsters
		cmp r0,#0
		beq generateMonstersDone
		ldr r2,=spriteActive
		mov r3,#1
		str r3,[r2,r9,lsl#2]	@ activate sprite
		add r0,#64
		ldr r2,=spriteX
		str r0,[r2,r9,lsl#2]	@ store x coord	
		ldrb r0,[r1],#1	
		add r0,#384
		ldr r2,=spriteY
		str r0,[r2,r9,lsl#2]	@ store y coord		
		ldrb r0,[r1],#1			@ dirs... HHHHLLLL h=initial dir l=facing (hflip)
		mov r3,r0
		and r3,#7				@ r3=facing (keep lowest 4 bits)
		ldr r2,=spriteHFlip
		str r3,[r2,r9,lsl#2]
		lsr r0,#4				@ r0=init dir (highest 4 bits)
		ldr r2,=spriteDir
		str r0,[r2,r9,lsl#2]

		ldrb r5,[r1],#1			@ r0=monster movement direction (lowest 4 bits)
		mov r3,r5				@ use r5 later for min/max
		and r5,#7
		ldr r2,=spriteMonsterMove
		str r5,[r2,r9,lsl#2]
		lsr r3,#4
		ldr r2,=spriteMonsterFlips
		str r3,[r2,r9,lsl#2]
		
		ldrb r0,[r1],#1			@ r0=speed
		ldr r2,=spriteSpeed
		str r0,[r2,r9,lsl#2]

		ldrb r0,[r1],#1			@ r0=monster to use from spriteBank (0-?)
		ldr r2,=spriteObjBase	@ objbase tells us what sprite to dma (+anim stage)	
		str r0,[r2,r9,lsl#2]

		ldr r2,=spriteObj
		mov r3,r9				@ r3=number of the alien 1-8
		add r3,#7
		str r3,[r2,r9,lsl#2]	@ store monster number for the sprite Object (8+)

		cmp r5,#0
		movne r5,#64			@ offset for l/r movement
		moveq r5,#384			@ offset for u/d movement
		ldrb r0,[r1],#1			@ r0=min coord
		add r0,r5
		ldr r2,=spriteMin
		str r0,[r2,r9,lsl#2]
		ldrb r0,[r1],#1			@ r0=max coord
		add r0,r5
		ldr r2,=spriteMax
		str r0,[r2,r9,lsl#2]

	add r9,#1
	cmp r9,#72
	bne gmLoop
	
	generateMonstersDone:

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

	levelMusic:
	stmfd sp!, {r0-r10, lr}	

	ldr r0,=musicPlay
	ldr r0,[r0]
	
	cmp r0,#0
	ldreq r1, =Miner_xm
	cmp r0,#1
	ldreq r1, =Dark_xm
	cmp r0,#2
	ldreq r1, =Space_xm
	cmp r0,#3
	ldreq r1, =Egyptian_xm
	cmp r0,#4
	ldreq r1, =Piano_xm
	cmp r0,#5
	ldreq r1, =Spectrum_xm
	cmp r0,#6
	ldreq r1, =Toccata_xm	
	cmp r0,#7
	ldreq r1, =Cat_xm	
	cmp r0,#8
	ldreq r1, =Jungle_xm	
	cmp r0,#9
	ldreq r1, =Cavern_xm
	
	bl initMusic
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------------------------------------------

levelName:

	stmfd sp!, {r0-r10, lr}
	
	mov r1,#1
	mov r2,#1
	ldr r0,=levelNames
	ldr r3,=levelNum
	ldr r3,[r3]
	sub r3,#1
	mov r4,#30
	mul r3,r4
	add r0,r3
	
	bl drawTextBig	

	ldmfd sp!, {r0-r10, pc}
	

@-------------------------------------------------

getWillySprite:

	stmfd sp!, {r0-r10, lr}

		@ r3=sprite (0=normal 1=spectrum 2=space 3=horace, 4=dirk )

		cmp r3,#0
		ldreq r0,=MinerNormalTiles
		ldreq r2,=MinerNormalTilesLen
		cmp r3,#1
		ldreq r0,=MinerSpectrumTiles
		ldreq r2,=MinerSpectrumTilesLen		
		cmp r3,#2
		ldreq r0,=MinerSpaceTiles
		ldreq r2,=MinerSpaceTilesLen
		cmp r3,#3
		ldreq r0,=MinerHoraceTiles
		ldreq r2,=MinerHoraceTilesLen
		cmp r3,#4
		ldreq r0,=MinerCasablancaTiles
		ldreq r2,=MinerCasablancaTilesLen		
		ldr r1, =SPRITE_GFX_SUB
		bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------
	
specialEffectStart:

	stmfd sp!, {r0-r1, lr}
	ldr r0,=specialEffect
	ldr r0,[r0]
	cmp r0,#FX_RAIN
		bleq rainInit
	cmp r0,#FX_STARS
		bleq starsInit
	cmp r0,#FX_LEAVES
		bleq leafInit
	cmp r0,#FX_GLINT
		bleq glintInit
	cmp r0,#FX_DRIP
		bleq dripInit
	cmp r0,#FX_EYES
		bleq eyesInit
	cmp r0,#FX_FLIES
		bleq fliesInit
	cmp r0,#FX_MALLOW
		bleq mallowInit
	cmp r0,#FX_CSTARS
		bleq cStarsInit
	cmp r0,#FX_BLOOD
		bleq bloodInit
	@ etc
	ldmfd sp!, {r0-r1, pc}	
	.pool
	.end
