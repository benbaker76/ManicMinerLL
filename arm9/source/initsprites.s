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
@	add r1,#*256
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
	orr r2,#160					@ y
	strh r2,[r0]

	ldr r0,=OBJ_ATTRIBUTE1(1)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#240					@ x
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE2(1)
	mov r2,#1
	lsl r2,#3
	strh r2,[r0]

	ldmfd sp!, {r0-r10, pc}	@ FORGET THIS - OVERWITTEN BY THE MAIN SCREENS SPRITES??

	
	@ --------------------  initialise the arm sprites...
	ldr r0,=OBJ_ATTRIBUTE0(2)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(2)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#7*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(2)
	mov r2,#2
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(3)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(3)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#9*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(3)
	mov r2,#3
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(4)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(4)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#11*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(4)
	mov r2,#4
	lsl r2,#3
	strh r2,[r0]		
@	
	ldr r0,=OBJ_ATTRIBUTE0(5)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(5)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#7*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(5)
	mov r2,#5
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(6)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(6)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#9*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(6)
	mov r2,#6
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(7)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(7)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#11*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(7)
	mov r2,#7
	lsl r2,#3
	strh r2,[r0]			
	
@	
	ldr r0,=OBJ_ATTRIBUTE0(8)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(8)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#7*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(8)
	mov r2,#8
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(9)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(9)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#9*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(9)
	mov r2,#9
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(10)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(10)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#11*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(10)
	mov r2,#10
	lsl r2,#3
	strh r2,[r0]

@ Right

	ldr r0,=OBJ_ATTRIBUTE0(11)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(11)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#18*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(11)
	mov r2,#11
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(12)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(12)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#20*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(12)
	mov r2,#12
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(13)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#7*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(13)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#22*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(13)
	mov r2,#13
	lsl r2,#3
	strh r2,[r0]		
@	
	ldr r0,=OBJ_ATTRIBUTE0(14)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(14)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#18*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(14)
	mov r2,#14
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(15)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(15)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#20*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(15)
	mov r2,#15
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(16)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#9*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(16)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#22*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(16)
	mov r2,#16
	lsl r2,#3
	strh r2,[r0]			
	
@	
	ldr r0,=OBJ_ATTRIBUTE0(17)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(17)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#18*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(17)
	mov r2,#17
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(18)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(18)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#20*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(18)
	mov r2,#18
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(19)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#11*8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(19)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#22*8				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(19)
	mov r2,#19
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
	
	.data
	
	arm1X:
	
	arm1Y:
	
	arm1O:
	
	.pool
	.end