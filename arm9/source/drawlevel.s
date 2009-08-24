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


	.global drawLevel

drawLevel:
	@ levelNum holds the number of the level needed

	stmfd sp!, {r0-r10, lr}

	@ for now we will just use level 1 without using levelNum
	
	@ Write the palette

	ldr r0, =Background01Pal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =Background01PalLen
	bl dmaCopy
	
	@ Write the tile data

	ldr r3,=levelNum
	ldr r3,[r3]
	
	cmp r3,#1
	ldreq r4,=Level02Tiles
	ldreq r5,=Level02TilesLen
	ldreq r6,=Level02Map
	ldreq r7,=Level02MapLen

	@ Draw main game map!
	mov r0,r4
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	mov r2,r5
	bl dmaCopy
	mov r0,r6
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	@ destination
	mov r2,r7
	bl dmaCopy

	@ draw the level foreground

	ldr r0 ,=LevelFront02Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =LevelFront02TilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =LevelFront02Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =LevelFront02MapLen
	bl dmaCopy
	
	@ Draw the background on bg3
	@ Write the tile data
	
	ldr r0 ,=Background03Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2, =Background03TilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =Background03Map
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =Background03MapLen
	bl dmaCopy
	
	@ Write the palette

	ldr r0, =TopMenuPal
	ldr r1, =BG_PALETTE
	ldr r2, =TopMenuPalLen
	bl dmaCopy
	
	@ Write the tile data
	
	ldr r0 ,=TopMenuTiles
	ldr r1, =BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2, =TopMenuTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =TopMenuMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =TopMenuMapLen
	bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

