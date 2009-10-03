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

#define KILLDROP			#384

	.global initGameOver
	.global updateGameOverScreen
	.global updateGameOver
	
@---------------------------					@ init the static screen for music

initGameOverScreen:

	stmfd sp!, {r0-r10, lr}
	
	lcdMainOnBottom
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	bl clearOAM
	bl clearSpriteData

	ldr r1,=gameMode
	mov r0,#GAMEMODE_GAMEOVER_SCREEN			@ this is our "wait and music" screen
	str r0,[r1]

	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn	
	
	ldr r0,=EndBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=EndBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =EndBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =EndBottomMapLen
	bl dmaCopy
	ldr r0, =EndBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =EndBottomPalLen
	bl dmaCopy	

	ldr r0,=EndTopTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=EndTopTilesLen
	bl decompressToVRAM	
	ldr r0, =EndTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =EndTopMapLen
	bl dmaCopy
	ldr r0, =EndTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =EndTopPalLen
	bl dmaCopy	
	
	mov r0,#-1
	ldr r1,=skullFrameOver
	str r0,[r1]
	ldr r1,=skullDelayOver
	str r0,[r1]
	mov r0,#1
	ldr r1,=trapStart
	str r0,[r1]
	
	ldreq r2, =GameOver_xm_gz
	ldreq r3, =GameOver_xm_gz_size
	bl initMusic
	
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------							update static screen with music

updateGameOverScreen:

	stmfd sp!, {r0-r10, lr}
	
	
	bl animateGameOverSkull
	
	@ Check for start or A pressed
	
	ldr r2, =REG_KEYINPUT
	ldr r10,[r2]
	
	tst r10,#BUTTON_START
	beq gOverEnd
	tst r10,#BUTTON_A
	beq gOverEnd

	ldmfd sp!, {r0-r10, pc}

	gOverEnd:
	
	@ return to title screen (or highscore at some point)
	
	ldr r1,=trapStart
	mov r0,#1
	str r0,[r1]
	
	bl initTitleScreen
	
	ldmfd sp!, {r0-r10, pc}

@--------------------------

animateGameOverSkull:	
	
	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=skullDelayOver
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#8
	str r1,[r0]
	bpl animateGameOverSkullDone
	
	ldr r0,=skullFrameOver
	ldr r8,[r0]
	add r8,#1
	cmp r8,#10
	moveq r8,#0
	str r8,[r0]
	
	@ r8=frame

	mov r1,#3
	mul r8,r1						@ banks of 3
	lsl r8,#1

	ldr r0, =BG_MAP_RAM(BG3_MAP_BASE)
	add r0, #1536					@ first tile of offscreen tiles (bottom left)
	add r0, r8						@ add 8 chars (8th along is our blank)
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)
	add r1,#(32*4)*2
	add r1,#15*2
	mov r2,#6
	
	mov r8,#2
	overSkullLoop:
	
	bl dmaCopy
	add r0,#64
	add r1,#64
	subs r8,#1
	bpl overSkullLoop
	
	animateGameOverSkullDone:
	ldmfd sp!, {r0-r10, pc}
@---------------------------					@ init the death animatiob 'here'

initGameOver:

	stmfd sp!, {r0-r10, lr}
	
	lcdMainOnBottom
	
	bl clearOAM
	bl clearSpriteData
	bl initVideoGameOver	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3

	ldr r1,=gameMode
	mov r0,#GAMEMODE_GAMEOVER					@ this is our Animation
	str r0,[r1]

	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn	
	
	@ use these 2 screens for now
	
	ldr r0,=EndBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=EndBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =EndBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)			@ destination
	ldr r2, =EndBottomMapLen
	bl dmaCopy
	ldr r0, =EndBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =EndBottomPalLen
	bl dmaCopy	

	ldr r0,=EndTopSplatTiles							@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=EndTopSplatTilesLen
	bl decompressToVRAM	
	ldr r0, =EndTopSplatMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =EndTopSplatMapLen
	bl dmaCopy
	ldr r0, =EndTopSplatPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =EndTopSplatPalLen
	bl dmaCopy	
	
	@ use bg1 and BG2 sub for the overlaid killing object (32x64 pixel map)

	ldr r0,=EndBootTiles							@ copy the tiles used for kill object
	ldr r1,=BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2,=EndBootTilesLen
	bl decompressToVRAM	
	ldr r0, =EndBootMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =EndBootMapLen
	bl dmaCopy	

	mov r8,#192
	ldr r6,=killPixelH
	str r8,[r6]

	ldr r5, =REG_BG1VOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	strh r8, [r5]					@ Write our offset value to REG_BG2HOFS_SUB

	mov r0,#0
	ldr r1,=killMotion
	str r0,[r1]
	ldr r0,=500
	ldr r1,=killDelay
	str r0,[r1]
	mov r0,#1
	ldr r1,=trapStart
	str r0,[r1]
	
	@ ok, init willys sprite
	
	mov r10,#0
	
	ldr r0,=spriteActive
	mov r1,#1
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteX
	mov r1,#128+64
	str r1,[r0,r10,lsl#2]	
	ldr r0,=spriteY
	mov r1,#160+384
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteObj
	mov r1,#0
	str r1,[r0,r10,lsl#2]
	ldr r0,=spritePriority
	mov r1,#2
	str r1,[r0,r10,lsl#2]	
	
	add r10,#1
	
	ldr r0,=spriteActive
	mov r1,#1
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteX
	mov r1,#128+64
	str r1,[r0,r10,lsl#2]	
	ldr r0,=spriteY
	mov r1,#144+384
	str r1,[r0,r10,lsl#2]
	ldr r0,=spriteObj
	mov r1,#0
	str r1,[r0,r10,lsl#2]
	ldr r0,=spritePriority
	mov r1,#2
	str r1,[r0,r10,lsl#2]
	
	@ now load the sprite data
	
	ldr r0,=DieGameOverTiles
	ldr r1,=SPRITE_GFX_SUB
	ldr r2,=DieGameOverTilesLen
	bl dmaCopy	
	ldr r0, =DieGameOverPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy	
	ldmfd sp!, {r0-r10, pc}
@--------------------------						@ do the death animation

updateGameOver:	
	
	stmfd sp!, {r0-r10, lr}

	ldr r10,=500
	
	updateGameOverLoop:
	
		cmp r10,KILLDROP					@ timer to drop something
		ldreq r1,=killMotion
		moveq r2,#1
		streq r2,[r1]
	
		bl swiWaitForVBlank	

		bl moveKiller
		bl drawSprite
	
	
	subs r10,#1
	bpl updateGameOverLoop


	mov r1,#0
	ldr r5, =REG_BG1VOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	strh r1, [r5]					@ Write our offset value to REG_BG2HOFS_SUB		
	
	bl initGameOverScreen
	
	ldmfd sp!, {r0-r10, pc}
@--------------------------						@ drop the killer Object

moveKiller:	
	
	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=killMotion
	ldr r0,[r0]
	cmp r0,#0
	beq moveKillerDone
	
		ldr r0,=killPixelH
		ldr r1,[r0]
		sub r1,#8
		cmp r1,#14								@ max fall position
		movle r1,#14
		str r1,[r0]
		
		ldr r5, =REG_BG1VOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
		strh r1, [r5]					@ Write our offset value to REG_BG2HOFS_SUB		
	
	
	
	
	moveKillerDone:
	
	ldmfd sp!, {r0-r10, pc}	
	
.pool
.data

skullFrameOver:
.word 0
skullDelayOver:
.word 0
killPixelH:
.word 0
killDelay:
.word 0
killMotion:
.word 0
