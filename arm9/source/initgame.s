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

	mov r0,#2				@ set level to 1 for start of game
	ldr r1,=levelNum
	str r0,[r1]
	

	@ Write the palette

	ldr r0, =GameBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =GameBottomPalLen
	bl dmaCopy
	
	@ Write the tile data
	
	ldr r0 ,=GameBottomTiles
	ldr r1, =BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2, =GameBottomTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =GameBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =GameBottomMapLen
	bl dmaCopy
	
	
ldmfd sp!, {r0-r10, pc}