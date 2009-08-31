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
	
	.global updateSpecialFX
	.global rainInit
	.global rainUpdate
	.global rainStop

@------------------------------------ Special Effect Update

updateSpecialFX:
	stmfd sp!, {r0-r10, lr}

	ldr r0,=specialEffect
	ldr r0,[r0]
	cmp r0,#FX_RAIN
	bleq rainUpdate
	
	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------ Init rain
rainInit:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#62
	rainInitLoop:
		ldr r1,=spriteActive
		mov r2,#RAIN
		str r2,[r1,r0,lsl#2]
		ldr r1,=spriteObj
		mov r2,#24					@ object for rain
		str r2,[r1,r0,lsl#2]
		
		bl getRandom				@ r8 returned
		ldr r7,=0x1FF
		and r8,r7
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		bl getRandom				@ r8 returned
		and r8,#0xFF
		lsr r8,#2
		mov r3,#3
		mul r8,r3
		add r8,#384
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		and r8,#3
		cmp r8,#0
		moveq r8,#1
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]
	
	
	subs r0,#1
	bpl rainInitLoop
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------ Update rain
rainUpdate:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#62
	rainUpdateLoop:
		ldr r1,=spriteSpeed
		ldr r2,[r1,r0,lsl#2]			@ r3=speed
		
		ldr r1,=spriteX
		ldr r3,[r1,r0,lsl#2]			@ x coord
		sub r3,r2
		cmp r3,#32
		blt rainNew
		str r3,[r1,r0,lsl#2]
		
		ldr r1,=spriteY
		ldr r3,[r1,r0,lsl#2]			@ y coord
		add r3,r2
		cmp r3,#256+384
		bgt rainNew
		str r3,[r1,r0,lsl#2]	
	
		rainBack:
	
	subs r0,#1
	bpl rainUpdateLoop
	
	ldmfd sp!, {r0-r10, pc}

	rainNew:
		
		@ generate new rain

		bl getRandom				@ r8 returned
		ldr r7,=0x1FF
		and r8,r7
		add r8,#64
		ldr r1,=spriteX
		str r8,[r1,r0,lsl#2]		@ store X	0-255
		mov r8,#384+32
		ldr r1,=spriteY
		str r8,[r1,r0,lsl#2]		@ store y	0-191
		bl getRandom
		and r8,#3
		cmp r8,#0
		moveq r8,#1
		ldr r1,=spriteSpeed
		str r8,[r1,r0,lsl#2]		
		
	b rainBack

@------------------------------------ Stop rain
rainStop:
	stmfd sp!, {r0-r10, lr}

	mov r0,#62
	ldr r2,=spriteActive
	mov r3,#0
	rainStopLoop:
	
		str r3,[r2,r0,lsl#2]
	
	subs r0,#1
	bpl rainStopLoop
	
	ldr r2,=specialEffect
	str r3,[r3]
	
	ldmfd sp!, {r0-r10, pc}	