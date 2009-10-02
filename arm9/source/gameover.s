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

#define BUF_ATTRIBUTE2_SUB	(0x07000404)

	.global initGameOver
	.global updateGameOver

@---------------------------

initGameOver:

	stmfd sp!, {r0-r10, lr}
	
	lcdMainOnBottom
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	bl clearOAM
	bl clearSpriteData

	ldr r1,=gameMode
	mov r0,#GAMEMODE_GAMEOVER
	str r0,[r1]

	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn	
	
	@ draw 2 screens - Later we will do an animation before this!!
	
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
	
	ldreq r2, =GameOver_xm_gz
	ldreq r3, =GameOver_xm_gz_size
	bl initMusic
	
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------

updateGameOver:

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

@--------------------------

animateGameOver:	
	
	stmfd sp!, {r0-r10, lr}	
	
	ldmfd sp!, {r0-r10, pc}
	
	
.pool
.data

skullFrameOver:
.word 0
skullDelayOver:
.word 0
