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

#include "system.h"
#include "serial.h"
	
	.arm
	.align
	.text
	.global readPowerManagement
	.global writePowerManagement
	
readPowerManagement:

	@ r0 - reg

	stmfd sp!, {r1, lr}
	
	orr r0, #PM_READ_REGISTER
	mov r1, #0
	bl writePowerManagement

	ldmfd sp!, {r1, pc} 					@ restore registers and return

	@ ------------------------------------

writePowerManagement:

	@ r0 - reg
	@ r1 - command
	@ r0 - return value

	stmfd sp!, {r1-r3, lr}
	
	ldr r2, =REG_SPICNT

writePowerManagementLoop1:

	ldrh r3, [r2]
	tst r3, #SPI_BUSY
	bne writePowerManagementLoop1
	
	ldr r2, =REG_SPICNT
	ldr r3, =(SPI_ENABLE | SPI_BAUD_1MHZ | SPI_BYTE_MODE | SPI_CONTINUOUS | SPI_DEVICE_POWER)
	strh r3, [r2]
	
	ldr r2, =REG_SPIDATA
	strh r0, [r2]
	
	ldr r2, =REG_SPICNT

writePowerManagementLoop2:

	ldrh r3, [r2]
	tst r3, #SPI_BUSY
	bne writePowerManagementLoop2
	
	ldr r2, =REG_SPICNT
	ldr r3, =(SPI_ENABLE | SPI_BAUD_1MHZ | SPI_BYTE_MODE | SPI_DEVICE_POWER)
	strh r3, [r2]
	
	ldr r2, =REG_SPIDATA
	strh r1, [r2]
	
	ldr r2, =REG_SPICNT
	
writePowerManagementLoop3:

	ldrh r3, [r2]
	tst r3, #SPI_BUSY
	bne writePowerManagementLoop3
	
	ldr r0, =REG_SPIDATA
	ldrh r0, [r0]
	and r0, #0xFF

	ldmfd sp!, {r1-r3, pc} 					@ restore registers and return

	@ ------------------------------------

	.align
	.pool
	.end
