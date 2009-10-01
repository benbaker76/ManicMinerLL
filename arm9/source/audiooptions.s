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
#include "audio.h"

	.global initAudio
	.global updateAudio
	
	.arm
	.align
	.text

@------------------------------------------------
	
initAudio:

	stmfd sp!, {r0-r10, lr}
	
	mov r1, #GAMEMODE_AUDIO
	ldr r2, =gameMode
	str r1,[r2]
	
	bl fxOff
	bl specialFXStop
	bl clearOAM	
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3

	bl initVideo
	bl initSprites
	bl clearSpriteData
	
	bl stopMusic
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

	@ draw top and bottom screens
	
	ldr r0,=AudioTopTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=AudioTopTilesLen
	bl decompressToVRAM	
	ldr r0, =AudioTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =AudioTopMapLen
	bl dmaCopy
	ldr r0, =AudioTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =AudioTopPalLen
	bl dmaCopy

	ldr r0,=AudioBottomTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=AudioBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =AudioBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =AudioBottomMapLen
	bl dmaCopy
	ldr r0, =AudioBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =AudioBottomPalLen
	bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------
	
updateAudio:

	stmfd sp!, {r0-r10, lr}
	
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------