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

	.arm
	.align
	.text


	.global dieChecker
	.global initDeathAnim
	.global updateDeathAnim
	
	
dieChecker:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=minerDied		@ this will be moved, just for testing
	ldr r1,[r1]
	cmp r1,#1
	bne dieCheckFailed
	
		@ we have already removed a life

		@ Bugger, we have died :(
		
		ldr r0,=minerLives
		ldr r0,[r0]
	@	cmp r0,#0
	@	bleq initTitleScreen
	@	blne initLevel

		@ now we need to set the gamemode to dying and use update die
		
		ldr r1,=gameMode
		mov r2,#GAMEMODE_DIES_INIT	
		str r2,[r1]
	

	dieCheckFailed:
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------
	
initDeathAnim:

	@ init all we need for dying animation and sound!

	stmfd sp!, {r0-r10, lr}
	
		ldr r1,=gameMode
		mov r2,#GAMEMODE_DIES_INIT	
		str r2,[r1]	
	

		bl playDead

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------------
	
updateDeathAnim:

	@ update the death animation and either return to game or gameover!

	stmfd sp!, {r0-r10, lr}
	
	ldmfd sp!, {r0-r10, pc}