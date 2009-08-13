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
#include "windows.h"

	.arm
	.align
	.text
	.global fxOff
	.global fxVBlank
	.global fxHBlank

fxOff:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	beq fxOffDone
	tst r0, #FX_FADE_IN
	blne fxFadeOff
	tst r0, #FX_FADE_OUT
	blne fxFadeOff

	ldr r0, =fxMode
	mov r1, #FX_NONE
	str r1, [r0]
	
fxOffDone:
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxVBlank:

	stmfd sp!, {r0, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	beq fxVBlankDone
	tst r0, #FX_FADE_IN
	blne fxFadeInVBlank
	tst r0, #FX_FADE_OUT
	blne fxFadeOutVBlank
	
fxVBlankDone:
	
	ldmfd sp!, {r0, pc}
	
	@ ------------------------------------
	
fxHBlank:

	stmfd sp!, {r0, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	beq fxHBlankDone
	
fxHBlankDone:
	
	ldmfd sp!, {r0, pc}
	
	@ ------------------------------------

	.pool
	.end
	