/*---------------------------------------------------------------------------------

	math functions

	Copyright (C) 2005
		Michael Noland (joat)
		Jason Rogers (dovoto)
		Dave Murphy (WinterMute)

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any
	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it and
	redistribute it freely, subject to the following restrictions:

	1.	The origin of this software must not be misrepresented; you
		must not claim that you wrote the original software. If you use
		this software in a product, an acknowledgment in the product
		documentation would be appreciated but is not required.
	2.	Altered source versions must be plainly marked as such, and
		must not be misrepresented as being the original software.
	3.	This notice may not be removed or altered from any source
		distribution.

---------------------------------------------------------------------------------*/

@ 16-bit
#define REG_DIVCNT			0x04000280
@ 64-bit
#define REG_DIV_NUMER		0x04000290
@ 32-bit
#define REG_DIV_NUMER_L		0x04000290
#define REG_DIV_NUMER_H		0x04000294
@ 64-bit
#define REG_DIV_DENOM		0x04000298
@ 32-bit
#define REG_DIV_DENOM_L		0x04000298
#define REG_DIV_DENOM_H		0x0400029C
@ 64-bit
#define REG_DIV_RESULT		0x040002A0
@ 32-bit
#define REG_DIV_RESULT_L	0x040002A0
#define REG_DIV_RESULT_H	0x040002A4
@ 64-bit
#define REG_DIVREM_RESULT	0x040002A8
@ 32-bit
#define REG_DIVREM_RESULT_L	0x040002A8
#define REG_DIVREM_RESULT_H	0x040002AC

@ 16-bit
#define REG_SQRTCNT			0x040002B0
@ 64-bit
#define REG_SQRT_PARAM		0x040002B8
@ 32-bit
#define REG_SQRT_PARAM_L	0x040002B8
#define REG_SQRT_PARAM_H	0x040002BC
#define REG_SQRT_RESULT		0x040002B4

@ Math coprocessor modes

#define DIV_64_64			2
#define DIV_64_32			1
#define DIV_32_32			0
#define DIV_BUSY			(1<<15)

#define SQRT_64				1
#define SQRT_32				0
#define SQRT_BUSY			(1<<15)
