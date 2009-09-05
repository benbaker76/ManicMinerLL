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



	.global levelCleared
	.global levelCheat
	
	
levelCleared:

	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=levelNum
	ldr r1,[r0]
	add r1,#1
	cmp r1,#22
	moveq r1,#1
	beq skippy
	cmp r1,#LEVEL_COUNT
	movgt r1,#21
skippy:
	str r1,[r0]
	
	bl initSprites

	bl initLevel
	bl drawSprite

	ldr r0,=gameMode
	mov r1,#GAMEMODE_RUNNING
	str r1,[r0]
	
	ldmfd sp!, {r0-r10, pc}	
	
levelCheat:

	stmfd sp!, {r0-r10, lr}	
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r3, [r2]								@ Read key value
	
	tst r3,#BUTTON_R
	bleq cheatWait
	
	ldmfd sp!, {r0-r10, pc}	
	
	cheatWait:
	ldr r2, =REG_KEYINPUT
	ldr r4, [r2]
	cmp r4,r3
	beq cheatWait
	
	tst r3,#BUTTON_R
	bleq levelCleared
	
	
	
	ldmfd sp!, {r0-r10, pc}	
	