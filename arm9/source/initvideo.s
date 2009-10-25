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
	.global initVideo
	.global initVideoLoading
	.global initVideoMain
	.global initVideoIntro
	.global resetScrollRegisters
	.global initVideoTitle
	.global screenSwapper
	.global setScreens
	.global initVideoBG2_256
	.global initVideoGameOver
	.global initVideoHigh
	
initVideo:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_POWERCNT
	ldr r1, =POWER_ALL_2D			@ All power on
	str r1, [r0]
 
	mov r0, #REG_DISPCNT			@ Main screen to Mode 0 with BG0-3 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG0_ACTIVE | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB		@ Sub screen to Mode 0 with BG0-3 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG0_ACTIVE | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
 
	ldr r0, =VRAM_A_CR				@ Set VRAM A to be main bg address 0x06000000
	ldr r1, =(VRAM_ENABLE | VRAM_A_MAIN_BG_0x06000000)
	strb r1, [r0]

	ldr r0, =VRAM_B_CR				@ Use this for sprite data
	ldr r1, =(VRAM_ENABLE | VRAM_B_MAIN_SPRITE_0x06400000)
	strb r1, [r0]
	
	ldr r0, =VRAM_C_CR				@ Set VRAM C to be sub bg address 0x06200000
	ldr r1, =(VRAM_ENABLE | VRAM_C_SUB_BG_0x06200000)
	strb r1, [r0]
	
	ldr r0, =VRAM_D_CR				@ Use this for sprite data
	ldr r1, =(VRAM_ENABLE | VRAM_D_SUB_SPRITE)
	strb r1, [r0]
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl initVideoMain
	
	ldr r0, =gameMode
	ldr r1,[r0]
	cmp r1,#GAMEMODE_TITLE_SCREEN
	
	ldrne r0, =FontTiles
	ldrne r1, =BG_TILE_RAM(BG0_TILE_BASE)
	ldrne r2, =FontTilesLen
	blne dmaCopy
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------
	
initVideoBG2_256:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_BG2CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE) | BG_TILE_BASE(BG2_TILE_BASE) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE_SUB) | BG_TILE_BASE(BG2_TILE_BASE_SUB) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------
	
initVideoLoading:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_BG0CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG0CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE_SUB) | BG_TILE_BASE(BG0_TILE_BASE_SUB) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------
	
initVideoMain:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_BG0CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG0CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE_SUB) | BG_TILE_BASE(BG0_TILE_BASE_SUB) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG1_MAP_BASE) | BG_TILE_BASE(BG1_TILE_BASE) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG1CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG1_MAP_BASE_SUB) | BG_TILE_BASE(BG1_TILE_BASE_SUB) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE) | BG_TILE_BASE(BG2_TILE_BASE) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE_SUB) | BG_TILE_BASE(BG2_TILE_BASE_SUB) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]

	ldr r0, =REG_BG3CNT				@ Set main screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE) | BG_TILE_BASE(BG3_TILE_BASE) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG3CNT_SUB			@ Set sub screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE_SUB) | BG_TILE_BASE(BG3_TILE_BASE_SUB) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------

initVideoHigh:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_BG0CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG3CNT				@ Set main screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE) | BG_TILE_BASE(BG3_TILE_BASE) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG3CNT_SUB			@ Set sub screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE_SUB) | BG_TILE_BASE(BG3_TILE_BASE_SUB) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------
	
initVideoIntro:

	stmfd sp!, {r0-r1, lr}
	
	mov r0, #REG_DISPCNT			@ Main screen to Mode 0 with BG0-3 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB		@ Sub screen to Mode 0 with BG0-3 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
	
	ldr r0, =REG_BG0CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG0CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE_SUB) | BG_TILE_BASE(BG0_TILE_BASE_SUB) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG1_MAP_BASE) | BG_TILE_BASE(BG1_INTRO_TILE_BASE) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG1CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG1_MAP_BASE_SUB) | BG_TILE_BASE(BG1_INTRO_TILE_BASE_SUB) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE) | BG_TILE_BASE(BG2_INTRO_TILE_BASE) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE_SUB) | BG_TILE_BASE(BG2_INTRO_TILE_BASE_SUB) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]

	ldr r0, =REG_BG3CNT				@ Set main screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE) | BG_TILE_BASE(BG3_TILE_BASE) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG3CNT_SUB			@ Set sub screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE_SUB) | BG_TILE_BASE(BG3_TILE_BASE_SUB) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------

resetScrollRegisters:

	stmfd sp!, {r0-r8, lr}

	@ Reset horizontal scroll registers
	
	ldr r0, =REG_BG0HOFS			@ Load our horizontal scroll register for BG0 on the main screen
	ldr r1, =REG_BG0HOFS_SUB		@ Load our horizontal scroll register for BG0 on the sub screen
	ldr r2, =REG_BG1HOFS			@ Load our horizontal scroll register for BG1 on the main screen
	ldr r3, =REG_BG1HOFS_SUB		@ Load our horizontal scroll register for BG1 on the sub screen
	ldr r4, =REG_BG2HOFS			@ Load our horizontal scroll register for BG2 on the main screen
	ldr r5, =REG_BG2HOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	ldr r6, =REG_BG3HOFS			@ Load our horizontal scroll register for BG3 on the main screen
	ldr r7, =REG_BG3HOFS_SUB		@ Load our horizontal scroll register for BG3 on the sub screen

	mov r8, #0						@ Offset the horizontal scroll register by 32 pixels to centre the map
	strh r8, [r0]					@ Write our offset value to REG_BG0HOFS
	strh r8, [r1]					@ Write our offset value to REG_BG0HOFS_SUB
	strh r8, [r2]					@ Write our offset value to REG_BG1HOFS
	strh r8, [r3]					@ Write our offset value to REG_BG1HOFS_SUB
	strh r8, [r4]					@ Write our offset value to REG_BG2HOFS
	strh r8, [r5]					@ Write our offset value to REG_BG2HOFS_SUB
	strh r8, [r6]					@ Write our offset value to REG_BG3HOFS
	strh r8, [r7]					@ Write our offset value to REG_BG3HOFS_SUB

	@ Reset vertical scroll registers

	mov r1, #0						@ Reset
	ldr r0, =REG_BG0VOFS			@ Load our vertical scroll register for BG0 on the main screen
	strh r1, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG0VOFS_SUB		@ Load our vertical scroll register for BG0 on the sub screen
	strh r1, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG1VOFS			@ Load our vertical scroll register for BG1 on the main screen
	strh r1, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG1VOFS_SUB		@ Load our vertical scroll register for BG1 on the sub screen
	strh r1, [r0]					@ Load the value into the scroll register
	
	ldr r0, =REG_BG2VOFS			@ Load our vertical scroll register for BG2 on the main screen
	strh r1, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG2VOFS_SUB		@ Load our vertical scroll register for BG2 on the sub screen
	strh r1, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG3VOFS			@ Load our vertical scroll register for BG3 on the main screen
	strh r1, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG3VOFS_SUB		@ Load our vertical scroll register for BG3 on the sub screen
	strh r1, [r0]
	
	ldmfd sp!, {r0-r8, pc}
	
	@ ------------------------------------

initVideoTitle:

	stmfd sp!, {r0-r10, lr}
	
	lcdMainOnBottom
	
	bl initVideoMain
	
	mov r0, #REG_DISPCNT			@ Main screen to Mode 0 with BG0-3 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG0_ACTIVE | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB		@ Sub screen to Mode 0 with BG0-3 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG0_ACTIVE | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
	
@ 	ldr r0, =REG_BG0CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
@	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE_SUB) | BG_TILE_BASE(BG0_TILE_BASE_SUB) | BG_PRIORITY(BG0_PRIORITY))
@	strh r1, [r0]
@	ldr r0, =REG_BG1CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
@	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG1_MAP_BASE_SUB) | BG_TILE_BASE(BG1_TILE_BASE_SUB) | BG_PRIORITY(BG1_PRIORITY))
@	strh r1, [r0]
@	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
@	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE_SUB) | BG_TILE_BASE(BG2_TILE_BASE_SUB) | BG_PRIORITY(BG2_PRIORITY))
@	strh r1, [r0]
@	ldr r0, =REG_BG3CNT_SUB			@ Set sub screen BG3 format to be 32x32 tiles at base address
@	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG3_MAP_BASE_SUB) | BG_TILE_BASE(BG3_TILE_BASE_SUB) | BG_PRIORITY(BG3_PRIORITY))
@	strh r1, [r0]

@	ldr r0, =REG_BG1CNT			@ Set sub screen BG0 format to be 32x32 tiles at base address
@	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG1_MAP_BASE) | BG_TILE_BASE(BG1_TILE_BASE) | BG_PRIORITY(BG1_PRIORITY))
@	strh r1, [r0]
	ldr r0, =REG_BG0CNT			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]

	ldr r1,=titleVidInit
	ldr r1,[r1]
	cmp r1,#0
	beq titleStart
	
	ldr r1,=levelNum
	ldr r1,[r1]
	cmp r1,#0
	beq titleStart2
	cmp r1,#128
	ble notTitleStart
	b titleStart2
	
	titleStart:								@ used when title initialised from anywhere (initTitleScreen called)
	
		ldr r0, =0
		ldr r1, =BG_PALETTE
		mov r2, #512
		bl dmaFillHalfWords	
			
		ldr r0, =0
		ldr r1, =BG_PALETTE_SUB
		mov r2, #512
		bl dmaFillHalfWords

		mov r0, #0
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM(BG0_MAP_BASE)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)
		bl dmaFillWords
		mov r0, #0
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
		bl dmaFillWords
	
		b notTitleStart

	titleStart2:							@ used when titlescreen changes credit pages, both skipped on level displays!
	
		ldr r0, =0
		ldr r1, =BG_PALETTE_SUB
		mov r2, #512
		bl dmaFillHalfWords
		
		ldr r0,=titleVidInit
		ldr r1,[r0]	
		cmp r1,#0
		bne titleTopOnly					@ never clear main screen during title
		
		mov r0, #0
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM(BG0_MAP_BASE)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)
		bl dmaFillWords

		titleTopOnly:

		mov r0, #0
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
		bl dmaFillWords
		ldr r2, =32*32*2
		ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
		bl dmaFillWords

	notTitleStart:

	ldr r0,=BigFontTiles							@ copy the tiles used for large font to main
	ldr r1,=BG_TILE_RAM(BG0_TILE_BASE)
	ldr r2,=BigFontTilesLen
	bl decompressToVRAM
	
	ldr r0, =ScrollFontTiles						@ copy out nice wide font to bottom screem
	ldr r1, =BG_TILE_RAM(BG2_TILE_BASE)
	ldr r2, =ScrollFontTilesLen
	bl decompressToVRAM	

	ldmfd sp!, {r0-r10, pc}
	
	@ ------------------------------------
	
screenSwapper:	
	
	stmfd sp!, {r0-r2, lr}
	
	@ use screenOrder.. 0=sub on top (L) 1=sub on bottom (R)
	
	ldr r2, =REG_KEYINPUT
	ldr r1, [r2]			
	tst r1,#BUTTON_L
	bne screenSwapper1

		ldr r2,=swapperLock
		ldr r2,[r2]
		cmp r2,#1
		beq screenSwapperFail

		ldr r2,=swapperLock
		mov r3,#1
		str r3,[r2]
		
		ldr r2,=screenOrder
		ldr r1,[r2]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r2]
		cmp r1,#0
		
		bne screenSwapper2

			lcdMainOnBottom
			
			b screenSwapperFail

			screenSwapper2:
			
			lcdMainOnTop
			
		screenSwapperFail:
			
		ldmfd sp!, {r0-r2, pc}	
	
	screenSwapper1:
	
		ldr r2,=swapperLock
		mov r1,#0
		str r1,[r2]
	
	ldmfd sp!, {r0-r2, pc}	

@------------------------------------

setScreens:
	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=screenOrder
	ldr r1,[r0]
	cmp r1,#0
	bne setScreens2
	
		lcdMainOnBottom
	
	b setScreensDone
	setScreens2:
	
		lcdMainOnTop
		
	setScreensDone:
	
	ldmfd sp!, {r0-r2, pc}

@--------------------------------------------

initVideoGameOver:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_BG0CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG0CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE_SUB) | BG_TILE_BASE(BG0_TILE_BASE_SUB) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x64 | BG_MAP_BASE(BG1_MAP_BASE) | BG_TILE_BASE(BG1_TILE_BASE) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG1CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x64 | BG_MAP_BASE(BG1_MAP_BASE_SUB) | BG_TILE_BASE(BG1_TILE_BASE_SUB) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT				@ Set main screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE) | BG_TILE_BASE(BG2_TILE_BASE) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG0 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x32 | BG_MAP_BASE(BG2_MAP_BASE_SUB) | BG_TILE_BASE(BG2_TILE_BASE_SUB) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]

	ldr r0, =REG_BG3CNT				@ Set main screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x64 | BG_MAP_BASE(BG3_MAP_BASE) | BG_TILE_BASE(BG3_TILE_BASE) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG3CNT_SUB			@ Set sub screen BG3 format to be 32x32 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x64 | BG_MAP_BASE(BG3_MAP_BASE_SUB) | BG_TILE_BASE(BG3_TILE_BASE_SUB) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}



.pool

swapperLock:
	.word 0
	
	.end