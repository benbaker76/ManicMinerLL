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
	.global levelMusicPlayEasy
	.global clearSpriteData

initLevel:
	
	@ This will be used to set level specifics, ie. colmap, initial x/y, facing etc...

	stmfd sp!, {r0-r12, lr}

	ldr r12,=gameMode
	ldr r12,[r12]
	cmp r12,#GAMEMODE_TITLE_SCREEN
@	blne stopMusic	
	
	bl specialFXStop	
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
@	bl clearOAM						@ IS THIS REALLY NEEDED!!!!?!?!!?!!?!!!?!
	bl clearSpriteData
	bl fxFadeIn

	mov r0,#0
	ldr r1,=switch1
	str r0,[r1]
	ldr r1,=switch2
	str r0,[r1]
	ldr r1,=switch3
	str r0,[r1]
	ldr r1,=switch4
	str r0,[r1]
	ldr r1,=switchOn
	str r0,[r1]
	ldr r1,=minerDelay
	str r0,[r1]
	ldr r1,=fallCount
	str r0,[r1]
	ldr r1,=jumpCount
	str r0,[r1]
	ldr r1,=airDelay
	str r0,[r1]
	ldr r1,=willySpriteType
	str r0,[r1]
	ldr r1,=bonusDelay
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
	and r3,#127
	ldr r2,=musicPlay				@ jingle 0-127
	str r3,[r2]
	lsr r0,#7
	ldr r2,=levelWraps				@ does the edges wrap? 0-1
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
	bl getDoorSprite
	bl getWillySprite

	bl generateMonsters		@ r1 is the pointer to the first monsters data
	
	bl drawLevel			@ Display the level graphics
	
	cmp r12,#GAMEMODE_TITLE_SCREEN
	blne levelStory			@ Display the games story in the bottom screen
	
	blne levelMusic			@ start the music
	
	bl specialEffectStart
	
	bl levelName

	@UNCOMMENT TO OPEN EXIT
@	ldr r1,=spriteActive
@	mov r0,#63				@ use the 63rd sprite
@	mov r2,#EXIT_OPEN
@	str r2,[r1,r0,lsl#2]

	@ ok, now are we greater than the last level we could select?
	
	ldr r1,=gameMode
	ldr r1,[r1]
	cmp r1,#GAMEMODE_TITLE_SCREEN
	beq highestLevelDone

	ldr r2,=levelNum
	ldr r2,[r2]
	sub r3,r2,#1
	
	ldr r1,=levelTypes
	ldr r1,[r1,r3,lsl#2]
	cmp r1,#0
	bne highestLevelDone

	ldr r1,=levelBank		@ 1=lost, 2=hollywood
	ldr r1,[r1,r3,lsl#2]	@ r2=level type
	cmp r1,#1
	bne highestLevelHollyWood
	
		ldr r1,=levelLLReached
		ldr r0,[r1]
		cmp r2,r0
		ble highestLevelDone
		str r2,[r1]
		b highestLevelDone
	
	highestLevelHollyWood:
	cmp r1,#2
	bne highestLevelDone

		ldr r1,=levelHWReached
		ldr r0,[r1]
		cmp r2,r0
		ble highestLevelDone
		str r2,[r1]
		b highestLevelDone	
	
	highestLevelDone:
	
	bl bonusAward										@ display award if level has a bonus level in it

	@ read if level is special and store in gameType
	
	ldr r1,=levelNum
	ldr r1,[r1]
	add r1,#1
	ldr r0,=levelSpecial
	ldr r1,[r0,r1,lsl#2]
	ldr r0,=gameType
	str r1,[r0]

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
	ldr r10,=keyCounter
	mov r9,#0
	str r9,[r10]
	@ r0=source, r1=destination
	mov r3,#768
	colMapLoop:
		ldrb r2,[r0],#1
		cmp r2,#24
		blt notColMapKey
		cmp r2,#31
		bgt notColMapKey
		add r9,#1
		notColMapKey:
		strb r2,[r1],#1
		subs r3,#1
	bpl colMapLoop
	str r9,[r10]
	
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
	cmp r0,#9
	ldreq r0, =Exit10Tiles
	ldreq r2, =Exit10TilesLen
	cmp r0,#11
	ldreq r0, =Exit12Tiles
	ldreq r2, =Exit12TilesLen
	cmp r0,#13
	ldreq r0, =Exit14Tiles
	ldreq r2, =Exit14TilesLen
	cmp r0,#14
	ldreq r0, =Exit15Tiles
	ldreq r2, =Exit15TilesLen
	cmp r0,#15
	ldreq r0, =Exit16Tiles
	ldreq r2, =Exit16TilesLen
	cmp r0,#16
	ldreq r0, =Exit17Tiles
	ldreq r2, =Exit17TilesLen
	cmp r0,#17
	ldreq r0, =Exit18Tiles
	ldreq r2, =Exit18TilesLen
	cmp r0,#18
	ldreq r0, =Exit19Tiles
	ldreq r2, =Exit19TilesLen
	cmp r0,#19
	ldreq r0, =Exit20Tiles
	ldreq r2, =Exit20TilesLen
	cmp r0,#20
	ldreq r0, =Exit21Tiles
	ldreq r2, =Exit21TilesLen
	cmp r0,#21
	ldreq r0, =Exit22Tiles
	ldreq r2, =Exit22TilesLen	
	cmp r0,#22
	ldreq r0, =Exit23Tiles
	ldreq r2, =Exit23TilesLen
	cmp r0,#23
	ldreq r0, =Exit24Tiles
	ldreq r2, =Exit24TilesLen
	cmp r0,#24
	ldreq r0, =Exit25Tiles
	ldreq r2, =Exit25TilesLen
	cmp r0,#25
	ldreq r0, =Exit26Tiles
	ldreq r2, =Exit26TilesLen
	cmp r0,#26
	ldreq r0, =Exit27Tiles
	ldreq r2, =Exit27TilesLen
	
	cmp r0,#28
	ldreq r0, =Exit29Tiles
	ldreq r2, =Exit29TilesLen
	cmp r0,#29
	ldreq r0, =Exit30Tiles
	ldreq r2, =Exit30TilesLen
	cmp r0,#30
	ldreq r0, =Exit31Tiles
	ldreq r2, =Exit31TilesLen	
	cmp r0,#31
	ldreq r0, =Exit32Tiles
	ldreq r2, =Exit32TilesLen
	cmp r0,#32
	ldreq r0, =Exit33Tiles
	ldreq r2, =Exit33TilesLen
	cmp r0,#33
	ldreq r0, =Exit34Tiles
	ldreq r2, =Exit34TilesLen	
	cmp r0,#34
	ldreq r0, =Exit35Tiles
	ldreq r2, =Exit35TilesLen	

	cmp r0,#40
	ldreq r0, =Exit41Tiles
	ldreq r2, =Exit41TilesLen
	cmp r0,#41
	ldreq r0, =Exit42Tiles
	ldreq r2, =Exit42TilesLen	
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
	
	ldr r8,=levelNum
	ldr r9,[r8]
	cmp r9,#26
	ldreq r1,=spritePriority
	moveq r3,#3
	streq r3,[r1,r0,lsl#2]
	
	
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
	cmp r0,#10
	ldreq r4,=Background11Tiles
	ldreq r5,=Background11TilesLen
	ldreq r6,=Background11Map
	ldreq r7,=Background11MapLen
	cmp r0,#11
	ldreq r4,=Background12Tiles
	ldreq r5,=Background12TilesLen
	ldreq r6,=Background12Map
	ldreq r7,=Background12MapLen
	cmp r0,#12
	ldreq r4,=Background13Tiles
	ldreq r5,=Background13TilesLen
	ldreq r6,=Background13Map
	ldreq r7,=Background13MapLen
	cmp r0,#13
	ldreq r4,=Background14Tiles
	ldreq r5,=Background14TilesLen
	ldreq r6,=Background14Map
	ldreq r7,=Background14MapLen
	cmp r0,#14
	ldreq r4,=Background15Tiles
	ldreq r5,=Background15TilesLen
	ldreq r6,=Background15Map
	ldreq r7,=Background15MapLen
	cmp r0,#15
	ldreq r4,=Background16Tiles
	ldreq r5,=Background16TilesLen
	ldreq r6,=Background16Map
	ldreq r7,=Background16MapLen
	cmp r0,#16
	ldreq r4,=Background17Tiles
	ldreq r5,=Background17TilesLen
	ldreq r6,=Background17Map
	ldreq r7,=Background17MapLen
	cmp r0,#17
	ldreq r4,=Background18Tiles
	ldreq r5,=Background18TilesLen
	ldreq r6,=Background18Map
	ldreq r7,=Background18MapLen
	cmp r0,#18
	ldreq r4,=Background19Tiles
	ldreq r5,=Background19TilesLen
	ldreq r6,=Background19Map
	ldreq r7,=Background19MapLen
	cmp r0,#19
	ldreq r4,=Background20Tiles
	ldreq r5,=Background20TilesLen
	ldreq r6,=Background20Map
	ldreq r7,=Background20MapLen
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
	cmp r0,#23
	ldreq r4,=Background24Tiles
	ldreq r5,=Background24TilesLen
	ldreq r6,=Background24Map
	ldreq r7,=Background24MapLen
	cmp r0,#24
	ldreq r4,=Background25Tiles
	ldreq r5,=Background25TilesLen
	ldreq r6,=Background25Map
	ldreq r7,=Background25MapLen
	cmp r0,#25
	ldreq r4,=Background26Tiles
	ldreq r5,=Background26TilesLen
	ldreq r6,=Background26Map
	ldreq r7,=Background26MapLen
	cmp r0,#26
	ldreq r4,=Background27Tiles
	ldreq r5,=Background27TilesLen
	ldreq r6,=Background27Map
	ldreq r7,=Background27MapLen
	cmp r0,#28
	ldreq r4,=Background29Tiles
	ldreq r5,=Background29TilesLen
	ldreq r6,=Background29Map
	ldreq r7,=Background29MapLen
	cmp r0,#29
	ldreq r4,=Background30Tiles
	ldreq r5,=Background30TilesLen
	ldreq r6,=Background30Map
	ldreq r7,=Background30MapLen
	cmp r0,#30
	ldreq r4,=Background31Tiles
	ldreq r5,=Background31TilesLen
	ldreq r6,=Background31Map
	ldreq r7,=Background31MapLen
	cmp r0,#31
	ldreq r4,=Background32Tiles
	ldreq r5,=Background32TilesLen
	ldreq r6,=Background32Map
	ldreq r7,=Background32MapLen


	cmp r0,#40
	ldreq r4,=Background41Tiles
	ldreq r5,=Background41TilesLen
	ldreq r6,=Background41Map
	ldreq r7,=Background41MapLen

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
		mov r3,#MONSTER_ACTIVE
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
	
@-------------------------------------
	levelMusicPlayEasy:
	
	stmfd sp!, {r0-r10, lr}	
	
	b levelMusicJumpIn

@-------------------------------------------------

	levelMusic:
	stmfd sp!, {r0-r10, lr}	

	ldr r0,=musicRestart
	ldr r1,[r0]
	ldr r2,=levelNum
	ldr r2,[r2]
	cmp r1,r2
	beq levelMusicFail
	str r2,[r0]
	

	ldr r0,=musicPlay
	ldr r0,[r0]
	
	levelMusicJumpIn:
	
	cmp r0,#0
	ldreq r2, =Miner_xm_gz
	ldreq r3, =Miner_xm_gz_size
	cmp r0,#1
	ldreq r2, =Dark_xm_gz
	ldreq r3, =Dark_xm_gz_size
	cmp r0,#2
	ldreq r2, =Space_xm_gz
	ldreq r3, =Space_xm_gz_size
	cmp r0,#3
	ldreq r2, =Egyptian_xm_gz
	ldreq r3, =Egyptian_xm_gz_size
	cmp r0,#4
	ldreq r2, =Piano_xm_gz
	ldreq r3, =Piano_xm_gz_size
	cmp r0,#5
	ldreq r2, =Spectrum_xm_gz
	ldreq r3, =Spectrum_xm_gz_size
	cmp r0,#6
	ldreq r2, =Casablanca_xm_gz
	ldreq r3, =Casablanca_xm_gz_size
	cmp r0,#7
	ldreq r2, =Cat_xm_gz
	ldreq r3, =Cat_xm_gz_size
	cmp r0,#8
	ldreq r2, =Jungle_xm_gz
	ldreq r3, =Jungle_xm_gz_size
	cmp r0,#9
	ldreq r2, =Cavern_xm_gz
	ldreq r3, =Cavern_xm_gz_size
	cmp r0,#10
	ldreq r2, =Atmosphere_xm_gz
	ldreq r3, =Atmosphere_xm_gz_size
	cmp r0,#11
	ldreq r2, =Reggae_xm_gz
	ldreq r3, =Reggae_xm_gz_size
	cmp r0,#12
	ldreq r2, =Terminator_xm_gz
	ldreq r3, =Terminator_xm_gz_size
	cmp r0,#13
	ldreq r2, =Snug_xm_gz
	ldreq r3, =Snug_xm_gz_size
	cmp r0,#14
	ldreq r2, =Ghostbusters_xm_gz
	ldreq r3, =Ghostbusters_xm_gz_size
	cmp r0,#15
	ldreq r2, =Goonies_xm_gz
	ldreq r3, =Goonies_xm_gz_size
	cmp r0,#16
	ldreq r2, =Horror_xm_gz
	ldreq r3, =Horror_xm_gz_size
	cmp r0,#17
	ldreq r2, =Frankenstein_xm_gz
	ldreq r3, =Frankenstein_xm_gz_size
	cmp r0,#18
	ldreq r2, =Gremlins_xm_gz
	ldreq r3, =Gremlins_xm_gz_size
	cmp r0,#19
	ldreq r2, =KingKong_xm_gz
	ldreq r3, =KingKong_xm_gz_size
	cmp r0,#20
	ldreq r2, =Toccata_xm_gz
	ldreq r3, =Toccata_xm_gz_size	
	cmp r0,#21
	ldreq r2, =Shuttle_xm_gz
	ldreq r3, =Shuttle_xm_gz_size	
	cmp r0,#22
	ldreq r2, =Underground_xm_gz
	ldreq r3, =Underground_xm_gz_size
	cmp r0,#23
	ldreq r2, =Cold_xm_gz
	ldreq r3, =Cold_xm_gz_size
	cmp r0,#24
	ldreq r2, =Radio_xm_gz
	ldreq r3, =Radio_xm_gz_size
	cmp r0,#25
	ldreq r2, =Oldies_xm_gz
	ldreq r3, =Oldies_xm_gz_size
	
	
	cmp r0,#26	@ 37
	ldreq r2, =Title_xm_gz
	ldreq r3, =Title_xm_gz_size	
	cmp r0,#27	@ 38
	ldreq r2, =GameOver_xm_gz
	ldreq r3, =GameOver_xm_gz_size
	cmp r0,#28	@ 39
	ldreq r2, =HighScore_xm_gz
	ldreq r3, =HighScore_xm_gz_size
	
	bl initMusic
	
	@ now we hear music, set the flag in musicHeard (byte)
	
	ldr r1,=musicHeard
	mov r2,#1
	strb r2,[r1,r0]					@ set byte to say heard
	
	
	levelMusicFail:
	
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

		@ r3=sprite (0=normal 1=spectrum 2=space 3=horace, 4=dirk, 5 blagger, 6 coupe )

		ldr r0,=levelNum
		ldr r0,[r0]
		sub r0,#1
		ldr r1,=levelWilly
		ldrb r3,[r1,r0]

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
		cmp r3,#5
		ldreq r0,=MinerBlaggerTiles
		ldreq r2,=MinerBlaggerTilesLen
		cmp r3,#6
		ldreq r0,=MinerCoupeTiles
		ldreq r2,=MinerCoupeTilesLen		

		ldr r1, =SPRITE_GFX_SUB
		bl dmaCopy
		
		ldr r0,=willySpriteType
		str r3,[r0]

	ldmfd sp!, {r0-r10, pc}

.align
.data
levelWilly:							@ this tells us what sprite for what level
	.byte 0,0,0,0,0,0,1,0,0,0
	.byte 0,0,0,0,0,2,0,0,0,0	@ ll
	.byte 3,5
	.byte 4,0,0,0,0,0,0,0,0,0	@ ww
	.byte 6,6,6,6,6,6,2,0,0,0	@ BONUS
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0	
.align
.text
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
	cmp r0,#FX_BULB
		bleq bulbInit
	cmp r0,#FX_BLINKS
		bleq blinksInit
	cmp r0,#FX_KILLERS
		bleq killersInit
	cmp r0,#FX_SPARK
		bleq sparkInit
	cmp r0,#FX_KONG
		bleq kongInit
	cmp r0,#FX_METEOR
		bleq meteorInit
	cmp r0,#FX_FORCEFIELD
		bleq forceFieldInit
	cmp r0,#FX_ANTON
		bleq antonInit
	cmp r0,#FX_LIFT
		bleq liftInit
	cmp r0,#FX_ROCKY
		bleq rockyInit
	cmp r0,#FX_FFLAG
		bleq fFlagInit
	cmp r0,#FX_CAUSEWAY
		bleq causeInit
	@ etc
	ldmfd sp!, {r0-r1, pc}	


	.pool

	.end
