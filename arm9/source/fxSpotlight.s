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
	.global fxSpotlightOff
	.global fxSpotlightIn
	.global fxSpotlightOut
	.global fxSpotlightInVBlank
	.global fxSpotlightOutVBlank
	.global fxSpotlightCallbackAddress

fxSpotlightInit:

	stmfd sp!, {r0-r3, lr}
	
@	ldr r0, =REG_DISPCNT
@	ldr r1, [r0]
@	orr r1, #DISPLAY_WIN0_ON
@	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
@	ldr r2, =WIN_IN							@ Make bg's appear inside the window
@	ldr r3, [r2]
@	orr r3, #(WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
@	strh r3, [r2]
	
@	ldr r2, =WIN_OUT
@	mov r3, #0
@	strh r3, [r2]
	
	ldr r2, =SUB_WIN_IN						@ Make bg's appear inside the window
	ldr r3, [r2]
	orr r3, #(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =SUB_WIN_OUT
	mov r3, #(WIN0_BG0 | WIN0_BG1 | WIN0_BLENDS)
	strh r3, [r2]
	
@	ldr r2, =WIN0_Y0					@ Top pos
@	ldr r3, =0
@	strb r3, [r2]

@	ldr r2, =WIN0_Y1					@ Bottom pos
@	ldr r3, =192
@	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y0				@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y1				@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r0, =radius						@ Get our radius
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldr r0, =fxSpotlightCallbackAddress
	mov r1, #0
	str r1, [r0]
	
	ldmfd sp!, {r0-r3, pc}
	
	@ ---------------------------------------
	
fxSpotlightOff:

	stmfd sp!, {r0-r4, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #(FX_SPOTLIGHT_IN | FX_SPOTLIGHT_OUT)
	str r1, [r0]

	@ldr r0, =REG_DISPCNT
	@ldr r1, [r0]
	@bic r1, #DISPLAY_WIN0_ON
	@str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB
	ldr r1, [r0]
	bic r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	@mov r0, #0
	@mov r1, #0
	@mov r2, #0
	@mov r3, #0
	@mov r4, #0
	
	@bl dmaTransfer
	
	mov r0, #1
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0
	
	bl dmaTransfer

	ldmfd sp!, {r0-r4, pc}
	
	@ ---------------------------------------

fxSpotlightIn:

	stmfd sp!, {r0-r1, lr}
	
	bl fxSpotlightInit
	
	ldr r0, =fxMode					@ lets set the spotlight effect
	ldr r1, [r0]
	orr r1, #FX_SPOTLIGHT_IN
	str r1, [r0]
	
	bl fxSpotlightInVBlank

	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxSpotlightOut:

	stmfd sp!, {r0-r1, lr}
	
	bl fxSpotlightInit
	
	ldr r0, =fxMode					@ lets set the spotlight effect
	ldr r1, [r0]
	orr r1, #FX_SPOTLIGHT_OUT
	str r1, [r0]
	
	bl fxSpotlightOutVBlank

	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxSpotlightInVBlank:

	stmfd sp!, {r0-r2, lr}
	
	bl clearTable
	
	ldr r2,	=radius							@ radius
	ldr r2, [r2]
	
	ldr r0,=spriteX+256
	ldr r0,[r0]
	sub r0,#64
	add r0,#8
	ldr r1,=spriteY+256
	ldr r1,[r1]
	sub r1,#384
	add r1,#8
	
	bl createCircleTable
	
	bl dmaCircle
	
	ldr r0,	=radius							@ radius
	ldr r1, [r0]							@ Read radius value
	add r1, #4								@ Add to radius
	str r1, [r0]							@ Write back radius
	cmp r1, #164+128						@ Radius == 164?
	blge fxSpotlightOff
	blge fxSpotlightExecuteCallback
	
	ldmfd sp!, {r0-r2, pc}
	
@ ---------------------------------------
	
fxSpotlightOutVBlank:

	stmfd sp!, {r0-r3, lr}
	
	bl clearTable

	@mov r0, #128							@ x position
	@mov r1, #96							@ y position
	ldr r0,=spriteX+256
	ldr r0,[r0]
	sub r0,#64
	add r0,#8
	ldr r1,=spriteY+256
	ldr r1,[r1]
	sub r1,#384
	add r1,#8
	
	ldr r2,	=radius							@ radius
	ldr r2, [r2]
	
	ldr r3, =164							@ Subtract from 164 to reverse value
	sub r2, r3, r2

	bl createCircleTable
	
	bl dmaCircle
	
	ldr r0,	=radius							@ radius
	ldr r1, [r0]							@ Read radius value
	add r1, #4								@ Add to radius
	str r1, [r0]							@ Write back radius
	cmp r1, #164							@ Radius == 164?
	bleq fxSpotlightOff
	bleq fxSpotlightExecuteCallback
	
	ldmfd sp!, {r0-r3, pc}

	@ ---------------------------------------
	
clearTable:

	stmfd sp!, {r0-r2, lr}
	
	bl DC_FlushAll							@ Flush the cache for the dma copy

	mov r0, #0								@ Clear
	ldr r1, =winh							@ Table address
	ldr r2, =((192 + 1) * 2)				@ Size of table
	
	bl dmaFillWords							@ Clear table
	
	ldmfd sp!, {r0-r2, pc}
	
	@ ---------------------------------------

dmaCircle:

	stmfd sp!, {r0-r4, lr}
	
	@bl DC_FlushAll							@ Flush the cache for the dma copy
	
	@mov r0, #0								@ Dma channel
	@ldr r1, =winh							@ Table with our window values (source)
	@add r1, #2								@ &winh[1]
	@ldr r2, =REG_WIN0H						@ Horizontal window register (dest)
	@mov r3, #1								@ Count
	@ldr r4, =(DMA_ENABLE | DMA_REPEAT | DMA_START_HBL | DMA_DST_RESET)
	
	bl DC_FlushAll							@ Flush the cache for the dma copy
	
	mov r0, #1								@ Dma channel
	ldr r1, =winh							@ Table with our window values (source)
	add r1, #2								@ &winh[1]
	ldr r2, =REG_WIN0H_SUB					@ Horizontal window register (dest)
	mov r3, #1								@ Count
	ldr r4, =(DMA_ENABLE | DMA_REPEAT | DMA_START_HBL | DMA_DST_RESET)
	
	bl dmaTransfer
	
	ldmfd sp!, {r0-r4, pc}
	
	@ ---------------------------------------
	
createCircleTable:

	stmfd sp!, {r0-r7, lr}

	@ r0 - x0 position
	@ r1 - y0 position
	@ r2 - radius
	
	mov r3, #0								@ r3 = x
	mov r4, r2								@ r4 = y (y = radius)
	mov r5, #1
	subs r5, r2								@ r5 = d = 1 - radius 
	mov r6, #0								@ r6 = tmp

createCircleTableLoop:

	@ ---------------- Side octs
	@ ---------------- tmp = clamp(x0 + y, 0, VID_WIDTH);

	push { r0-r2 }							@ Push registers
	
	add r0, r4								@ value = x0 + y
	mov r1, #0								@ min = 0
	mov r2, #256							@ max = 256
	
	bl clamp								@ clamp values
	
	mov r6, r0								@ tmp = clamp
	
	pop { r0-r2 }							@ Pop registers
	
	@ ---------------- tmp += clamp(x0 - y, 0, VID_WIDTH);
	
	push { r0-r2 }							@ Push registers
	
	subs r0, r4								@ value = x0 - y
	mov r1, #0								@ min = 0
	mov r2, #256							@ max = 256
	
	bl clamp								@ clamp values
	
	add r6, r0, lsl #8						@ tmp += clamp << 8
	
	pop { r0-r2 }							@ Pop registers
	
	@ ---------------- IN_RANGE(y0 - x, 0, VID_HEIGHT);
	
	push { r0-r2 }							@ Push registers
	
	subs r0, r1, r3						@ r0 = y0 - x
	mov r1, #0								@ min = 0
	mov r2, #192							@ max = VID_HEIGHT
	
	bl inRange								@ In Range?
	
	ldr r1, =winh							@ winh table
	lsl r0, #1								@ 2 bytes (16 bit) values
	strneh r6, [r1, r0]					@ winh[y0 - x] = tmp
	
	pop { r0-r2 }							@ Pop registers
	
	@ ---------------- IN_RANGE(y0 + x, 0, VID_HEIGHT);
	
	push { r0-r2 }							@ Push registers
	
	add r0, r1, r3							@ r0 = y0 + x
	mov r1, #0								@ min = 0
	mov r2, #192							@ max = VID_HEIGHT
	
	bl inRange								@ In Range?
	
	ldr r1, =winh							@ winh table
	lsl r0, #1								@ 2 bytes (16 bit) values
	strneh r6, [r1, r0]					@ winh[y0 - x] = tmp
	
	pop { r0-r2 }							@ Pop registers
	
	cmp r5, #0								@ if (d >= 0)
	blt jumpTopBottomOcts					@ (d < 0)
	
	@ ---------------- Change in y: top/bottom octs
	@ ---------------- tmp = clamp(x0 + x, 0, VID_WIDTH);

	push { r0-r2 }							@ Push registers
	
	add r0, r3								@ value = x0 + x
	mov r1, #0								@ min = 0
	mov r2, #256							@ max = 256
	
	bl clamp								@ clamp values
	
	mov r6, r0								@ tmp = clamp
	
	pop { r0-r2 }							@ Pop registers
	
	@ ---------------- tmp += clamp(x0 - x, 0, VID_WIDTH);
	
	push { r0-r2 }							@ Push registers
	
	subs r0, r3								@ value = x0 - x
	mov r1, #0								@ min = 0
	mov r2, #256							@ max = 256
	
	bl clamp								@ clamp values
	
	add r6, r0, lsl #8						@ tmp += clamp << 8
	
	pop { r0-r2 }							@ Pop registers
	
	@ ---------------- IN_RANGE(y0 - y, 0, VID_HEIGHT);
	
	push { r0-r2 }							@ Push registers
	
	subs r0, r1, r4						@ r0 = y0 - y
	mov r1, #0								@ min = 0
	mov r2, #192							@ max = VID_HEIGHT
	
	bl inRange								@ In Range?
	
	ldr r1, =winh							@ winh table
	lsl r0, #1								@ 2 bytes (16 bit) values
	strneh r6, [r1, r0]					@ winh[y0 - x] = tmp
	
	pop { r0-r2 }							@ Pop registers
	
	@ ---------------- IN_RANGE(y0 + y, 0, VID_HEIGHT);
	
	push { r0-r2 }							@ Push registers
	
	add r0, r1, r4							@ r0 = y0 + y
	mov r1, #0								@ min = 0
	mov r2, #192							@ max = VID_HEIGHT
	
	bl inRange								@ In Range?
	
	ldr r1, =winh							@ winh table
	lsl r0, #1								@ 2 bytes (16 bit) values
	strneh r6, [r1, r0]					@ winh[y0 - x] = tmp
	
	pop { r0-r2 }							@ Pop registers
	
	subs r4, #1								@ y--
	subs r5, r4, lsl #1						@ d -= ((y--) << 1)
	
	@ ----------------
	
jumpTopBottomOcts:

	push { r0-r2 }							@ Push registers
	
	ldr r0, =winh							@ winh table
	ldrh r1, [r0]
	add r0, #192							@ winh[VID_HEIGHT] = winh[0]
	lsl r0, #1								@ 2 bytes (16 bit) values
	strh r1, [r0]
	
	pop { r0-r2 }							@ Pop registers
	
	@ ----------------

	add r3, #1								@ x++
	add r5, #3								@ d += 3
	add r5, r3, lsl #1						@ d += (((x++) + 3) << 1)
	cmp r4, r3
	bge createCircleTableLoop				@ while (y >= x)

	ldmfd sp!, {r0-r7, pc}
	
	@ ---------------------------------------
	
inRange:

	@ return ((value) >= (min) && (value) < (max));
	@ r0 = value
	@ r1 = min
	@ r2 = max
	@ return value sets Z
	
	stmfd sp!, {r3-r4, lr}
	
	mov r3, #0								@ reset result
	mov r4, #0								@ reset result
	cmp r0, r1
	movge r3, #1							@ if (value >= min) r3 = 1
	cmp r0, r2
	movlt r4, #1							@ (value < max) r4 = 1
	and r3, r4								@ r3 and r4
	cmp r3, #0								@ set Z to true or false

	ldmfd sp!, {r3-r4, pc}
	
	@ ---------------------------------------

clamp:

	@ return ((value) >= (max) ? ((max) - 1) : (((value) < (min)) ? (min) : (value)));
	@ r0 = value
	@ r1 = min
	@ r2 = max
	@ r0 = return value (value clamped)
	
	stmfd sp!, {r3-r4, lr}
	
	mov r3, #0								@ reset result
	mov r4, #0								@ reset result
	cmp r0, r2								@ if (value >= max)
	subge r0, r2, #1						@ r0 = max - 1
	bge clampDone							@ condition met so done
	
	cmp r0, r1
	movlt r0, r1							@ (value < min) r0 = min
	movge r0, r0							@ (value >= min) r0 = value
	
clampDone:

	ldmfd sp!, {r3-r4, pc}
	
	@ ---------------------------------------
	
fxSpotlightExecuteCallback:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxSpotlightCallbackAddress
	ldr r0, [r0]
	cmp r0, #0
	beq fxSpotlightExecuteCallbackReturn

	ldr lr, =fxSpotlightExecuteCallbackReturn
	bx r0
	
fxSpotlightExecuteCallbackReturn:

	ldr r0, =fxSpotlightCallbackAddress
	mov r1, #0
	str r1, [r0]

	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------

	.data
	.align
	
count:
	.word 0

radius:
	.word 0

fxSpotlightCallbackAddress:
	.word 0

	.align
winh:
	.space ((192+1) * 2)					@ Window values to store into REG_WIN0H

	.pool
	.end
