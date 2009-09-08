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
	
	@ Write the palette (our accepted pallet is in bg05)

	ldr r0, =Background01Pal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =Background01PalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	
	@ Write the tile data

	ldr r3,=levelNum
	ldr r3,[r3]
	
	cmp r3,#1
	ldreq r4,=Level01Tiles
	ldreq r5,=Level01TilesLen
	ldreq r6,=Level01Map
	ldreq r7,=Level01MapLen
	cmp r3,#2
	ldreq r4,=Level02Tiles
	ldreq r5,=Level02TilesLen
	ldreq r6,=Level02Map
	ldreq r7,=Level02MapLen
	cmp r3,#3
	ldreq r4,=Level03Tiles
	ldreq r5,=Level03TilesLen
	ldreq r6,=Level03Map
	ldreq r7,=Level03MapLen	
	cmp r3,#4
	ldreq r4,=Level04Tiles
	ldreq r5,=Level04TilesLen
	ldreq r6,=Level04Map
	ldreq r7,=Level04MapLen	
	cmp r3,#5
	ldreq r4,=Level05Tiles
	ldreq r5,=Level05TilesLen
	ldreq r6,=Level05Map
	ldreq r7,=Level05MapLen		
	cmp r3,#6
	ldreq r4,=Level06Tiles
	ldreq r5,=Level06TilesLen
	ldreq r6,=Level06Map
	ldreq r7,=Level06MapLen	
	cmp r3,#7
	ldreq r4,=Level07Tiles
	ldreq r5,=Level07TilesLen
	ldreq r6,=Level07Map
	ldreq r7,=Level07MapLen	
	cmp r3,#8
	ldreq r4,=Level08Tiles
	ldreq r5,=Level08TilesLen
	ldreq r6,=Level08Map
	ldreq r7,=Level08MapLen	
	cmp r3,#9
	ldreq r4,=Level09Tiles
	ldreq r5,=Level09TilesLen
	ldreq r6,=Level09Map
	ldreq r7,=Level09MapLen	
	cmp r3,#10
	ldreq r4,=Level10Tiles
	ldreq r5,=Level10TilesLen
	ldreq r6,=Level10Map
	ldreq r7,=Level10MapLen	
	cmp r3,#11
	ldreq r4,=Level11Tiles
	ldreq r5,=Level11TilesLen
	ldreq r6,=Level11Map
	ldreq r7,=Level11MapLen	
	cmp r3,#12
	ldreq r4,=Level12Tiles
	ldreq r5,=Level12TilesLen
	ldreq r6,=Level12Map
	ldreq r7,=Level12MapLen	
	cmp r3,#13
	ldreq r4,=Level13Tiles
	ldreq r5,=Level13TilesLen
	ldreq r6,=Level13Map
	ldreq r7,=Level13MapLen	
	cmp r3,#14
	ldreq r4,=Level14Tiles
	ldreq r5,=Level14TilesLen
	ldreq r6,=Level14Map
	ldreq r7,=Level14MapLen	


	cmp r3,#21
	ldreq r4,=Level21Tiles
	ldreq r5,=Level21TilesLen
	ldreq r6,=Level21Map
	ldreq r7,=Level21MapLen	

	@ Draw main game map!
	mov r0,r4
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	mov r2,r5
	bl decompressToVRAM
	mov r0,r6
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	@ destination
	add r1,#(32*6)*2
	mov r2,r7
	bl dmaCopy

	@ draw the top status on bg1 sub (so that sprites can be behind for effects and stuff)
	@ the first 2 character rows are the air gauge
	@ then each 4 rows are each screens title
	
	ldr r0,=StatusMap							@ draw the air (full)
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	add r1,#(32*4)*2
	mov r2,#128
	bl dmaCopy

	ldr r0,=StatusMap							@ draw the level name
	add r0,#128
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	mov r2,#256
	bl dmaCopy	

	ldmfd sp!, {r0-r10, pc}
	
	.pool
	.data
