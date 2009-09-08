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
	.global initSprites
	.global initTitleSprites
	.global clearOAM
	
initSprites:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0, =SpritesPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =SpritesTiles
	ldr r2, =SpritesTilesLen
	ldr r1, =SPRITE_GFX_SUB
	bl dmaCopy
	
	ldmfd sp!, {r0-r10, pc}
	
	@ --------------------------------------
	
initTitleSprites:

	stmfd sp!, {r0-r10, lr}

	ldr r0, =ATTR0_DISABLED			@ Set OBJ_ATTRIBUTE0 to ATTR0_DISABLED
	ldr r1, =OAM
	ldr r2, =1024					@ 3 x 16bit attributes + 16 bit filler = 8 bytes x 128 entries in OAM
	bl dmaFillWords
	
	ldr r0, =BotMenuPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy
	ldr r0, =TitleSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =TitleSpritesTilesLen
	bl dmaCopy
	
	ldr r0,=OBJ_ATTRIBUTE0(0)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#160
	strh r2,[r0]

	ldr r0,=OBJ_ATTRIBUTE1(0)
	ldr r2, =(ATTR1_SIZE_16)
	@mov r2,#0					@ x
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE2(0)
	mov r2,#0
	strh r2,[r0]

	ldr r0,=OBJ_ATTRIBUTE0(1)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#160
	strh r2,[r0]

	ldr r0,=OBJ_ATTRIBUTE1(1)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#240					@ x
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE2(1)
	mov r2,#1
	lsl r2,#3
	strh r2,[r0]
	
	ldmfd sp!, {r0-r10, pc}
	
	@ --------------------------------------
	
clearOAM:

	stmfd sp!, {r0-r6, lr}
	
	@ Clear the OAM (disable all 128 sprites for both screens)
	
	ldr r1,=gameMode
	ldr r1,[r1]
	cmp r1,#GAMEMODE_TITLE_SCREEN

	ldr r0, =ATTR0_DISABLED			@ Set OBJ_ATTRIBUTE0 to ATTR0_DISABLED
	ldr r1, =OAM
	ldr r2, =1024					@ 3 x 16bit attributes + 16 bit filler = 8 bytes x 128 entries in OAM
	blne dmaFillWords
	ldr r1, =OAM_SUB
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
	.pool
	.end