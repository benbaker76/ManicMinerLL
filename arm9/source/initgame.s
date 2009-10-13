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

	.global initGame

initGame:
stmfd sp!, {r0-r10, lr}

	bl setScreens
	@
	@ r12 MUST be sent here so that the game starts where it should
	@

mov r12,#7

	ldr r1,=levelNum
	str r12,[r1]
	mov r0,#3				@ set level to 3 for lives
	ldr r1,=minerLives
	str r0,[r1]	
	@ also set lives, score etc...
	mov r1,#0
	ldr r2,=score
	str r1,[r2],#4
	str r1,[r2],#4
	
	ldr r0,=musicRestart
	mov r1,#0
	str r1,[r0]
	
	@ Write the palette

	ldr r0, =GameBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =GameBottomPalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	
	@ Write the tile data for bottom screen
	
	ldr r0 ,=GameBottomTiles
	ldr r1, =BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2, =GameBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =GameBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =GameBottomMapLen
	bl dmaCopy
	
	ldr r0,=StatusTiles							@ copy the tiles used for status and air
	ldr r1,=BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2,=StatusTilesLen
	bl dmaCopy

	ldr r0,=BigFontTiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	add r1,#BigFontOffset
	ldr r2,=BigFontTilesLen
	bl decompressToVRAM

	bl initSprites

	bl initLevel
	bl drawSprite	@ move

	bl monsterMove	@ move (and add miner frame display)
	
	ldr r0, =gameMode							@ set to play time!!
	mov r1, #GAMEMODE_RUNNING
	str r1,[r0]

ldmfd sp!, {r0-r10, pc}