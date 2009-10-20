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

	.arm
	.align
	.text
	.global fxFadeBlackInit
	.global fxFadeWhiteInit
	.global fxFadeBG0Init
	.global fxFadeBG0SubInit
	.global fxFadeBG0SubBG1SubInit
	.global fxFadeBG1BG2Init
	.global fxFadeMin
	.global fxFadeMax
	.global fxFadeOff
	.global fxFadeIn
	.global fxFadeOut
	.global fxFadeInVBlank
	.global fxFadeOutVBlank
	.global fxFadeCallbackAddress
	.global fxFadeBlackLevelInit
	.global fxFadeBusy
	
fxFadeBlackInit:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_FADE_BLACK | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_BLACK | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]

	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------

fxFadeBlackLevelInit:

	stmfd sp!, {r0-r1, lr}
	
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_BLACK | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	
	@ ---------------------------------------
	
fxFadeWhiteInit:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeBG0Init:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG0 | BLEND_DST_BG0 | BLEND_DST_BG1 | BLEND_DST_BG2 | BLEND_DST_BG3)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG0 | BLEND_DST_BG0 | BLEND_DST_BG1 | BLEND_DST_BG2 | BLEND_DST_BG3)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeBG0SubInit:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =BLEND_CR
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG0 | BLEND_DST_BG0 | BLEND_DST_BG1 | BLEND_DST_BG2 | BLEND_DST_BG3)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeBG0SubBG1SubInit:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_DST_BG0 | BLEND_DST_BG1 | BLEND_DST_BG2 | BLEND_DST_BG3)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeBG1BG2Init:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG1 | BLEND_DST_BG2)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG1 | BLEND_DST_BG2)
	str r1, [r0]
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeMin:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =BLEND_Y					@ Blend register
	ldr r1, =0							@ Set to min
	strh r1, [r0]						@ Write to BLEND_Y
	
	ldr r0, =SUB_BLEND_Y				@ Blend register
	ldr r1, =0							@ Set to min
	strh r1, [r0]						@ Write to BLEND_Y
	
	ldr r0, =BLEND_AB					@ Blend register
	ldr r1, =0xF						@ Set to max
	strh r1, [r0]						@ Write to BLEND_AB
	
	ldr r0, =SUB_BLEND_AB				@ Blend register
	ldr r1, =0xF						@ Set to max
	strh r1, [r0]						@ Write to SUB_BLEND_AB
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeMax:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =BLEND_Y					@ Blend register
	ldr r1, =16							@ Set to max
	strh r1, [r0]						@ Write to BLEND_Y
	
	ldr r0, =SUB_BLEND_Y				@ Blend register
	ldr r1, =16							@ Set to max
	strh r1, [r0]						@ Write to BLEND_Y
	
	ldr r0, =BLEND_AB					@ Blend register
	ldr r1, =(0xF << 8)					@ Set to min
	strh r1, [r0]						@ Write to BLEND_AB
	
	ldr r0, =SUB_BLEND_AB				@ Blend register
	ldr r1, =(0xF << 8)					@ Set to min
	strh r1, [r0]						@ Write to SUB_BLEND_AB
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeOff:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #(FX_FADE_IN | FX_FADE_OUT)
	str r1, [r0]
	
	ldr r0, =BLEND_CR
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeIn:

	stmfd sp!, {r0-r1, lr}

	bl fxFadeMax
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_IN
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =1
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxFadeOut:

	stmfd sp!, {r0-r1, lr}
	
	bl fxFadeMin
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_OUT
	str r1, [r0]
	
	ldr r0, =fxFadeBusy
	ldr r1, =1
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------

fxFadeInVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, [r0]
	
	ldr r3, =16							@ Subtract from 16 to reverse value
	sub r4, r3, r1						@ 16 - fadeValue to reverse
	mov r5, r1							@ Put fadeValue in register
	
	ldr r2, =BLEND_Y					@ Blend register
	strh r4, [r2]						@ Write to BLEND_Y
	
	ldr r2, =SUB_BLEND_Y				@ Blend register
	strh r4, [r2]						@ Write to SUB_BLEND_Y
	
	ldr r2, =BLEND_AB					@ Blend register
	mov r6, r4, lsl #8
	orr r6, r5
	strh r6, [r2]						@ Write to BLEND_AB
	
	ldr r2, =SUB_BLEND_AB				@ Blend register
	mov r6, r4, lsl #8
	orr r6, r5
	strh r6, [r2]						@ Write to SUB_BLEND_AB
	
	add r1, #1							@ Add 1 to fadeValue
	str r1, [r0]						@ Write fadeValue back
	cmp r1, #16							@ Is our fadeValue greater than 16?
	blgt fxFadeOff						@ Yes turn off effect
	blgt fxFadeExecuteCallback			@ Execute callback
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeOutVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, [r0]
	
	ldr r3, =16							@ Subtract from 16 to reverse value
	sub r4, r3, r1						@ 16 - fadeValue to reverse
	mov r5, r1							@ Put fadeValue in register
	
	ldr r2, =BLEND_Y					@ Blend register
	strh r5, [r2]						@ Write to BLEND_Y
	
	ldr r2, =SUB_BLEND_Y				@ Blend register
	strh r5, [r2]						@ Write to SUB_BLEND_Y
	
	ldr r2, =BLEND_AB					@ Blend register
	mov r6, r5, lsl #8
	orr r6, r4
	strh r6, [r2]						@ Write to BLEND_AB
	
	ldr r2, =SUB_BLEND_AB				@ Blend register
	mov r6, r5, lsl #8
	orr r6, r4
	strh r6, [r2]						@ Write to SUB_BLEND_AB
	
	add r1, #1							@ Add 1 to fadeValue
	str r1, [r0]						@ Write fadeValue back
	cmp r1, #16							@ Is our fadeValue greater than 16?
	blgt fxFadeOff						@ Yes turn off effect
	blgt fxFadeExecuteCallback			@ Execute callback
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeExecuteCallback:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxFadeCallbackAddress
	ldr r0, [r0]
	cmp r0, #0
	beq fxFadeExecuteCallbackReturn

	ldr lr, =fxFadeExecuteCallbackReturn
	bx r0
	
fxFadeExecuteCallbackReturn:

	ldr r0, =fxFadeCallbackAddress
	mov r1, #0
	str r1, [r0]

	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------

	.data
	.align

fadeValue:
	.word 0
	
fxFadeBusy:
	.word 0

fxFadeCallbackAddress:
	.word 0
	
	.pool
	.end
