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

	mov r0,#1				@ set level to 1 for start of game
	ldr r1,=levelNum
	str r0,[r1]
	
	@ also set lives, score etc...
	
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
	bl dmaCopy	
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
	add r1,#StatusTilesLen
	ldr r2,=BigFontTilesLen
	bl dmaCopy

@	ldr r0,=BigFontTiles							@ copy the tiles used for large font
@	ldr r1,=BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
@	add r1,#StatusTilesLen
@	ldr r2,=BigFontTilesLen
@	bl dmaCopy
	
	
ldmfd sp!, {r0-r10, pc}