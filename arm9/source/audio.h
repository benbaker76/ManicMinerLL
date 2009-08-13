/*---------------------------------------------------------------------------------
	$Id: audio.h,v 1.19 2008/12/08 15:53:55 dovoto Exp $

	ARM7 audio control

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

#define BIT(n) (1<<(n))

#define SOUND_VOL(n)				(n)
#define SOUND_FREQ(n)				((-0x1000000 / (n)))
#define SOUND_ENABLE				BIT(15)
#define SOUND_REPEAT				BIT(27)
#define SOUND_ONE_SHOT				BIT(28)
#define SOUND_FORMAT_8BIT			(0 << 29)
#define SOUND_FORMAT_16BIT			(1 << 29)
#define SOUND_FORMAT_ADPCM			(2 << 29)
#define SOUND_FORMAT_PSG			(3 << 29)
#define SOUND_16BIT					BIT(29)
#define SOUND_8BIT					(0)

#define SOUND_BUSY					BIT(31)

#define SOUND_PAN(n)				((n) << 16)

#define SCHANNEL_ENABLE BIT(31)

@ registers
@ 32-bit
#define SCHANNEL_CR(n)				(0x04000400 + ((n)<<4))
@ 8-bit
#define SCHANNEL_VOL(n)				(0x04000400 + ((n)<<4))
#define SCHANNEL_PAN(n)				(0x04000402 + ((n)<<4))
@ 32-bit
#define SCHANNEL_SOURCE(n)			(0x04000404 + ((n)<<4))
@ 16-bit
#define SCHANNEL_TIMER(n)			(0x04000408 + ((n)<<4))
#define SCHANNEL_REPEAT_POINT(n)	(0x0400040A + ((n)<<4))
@ 32-bit
#define SCHANNEL_LENGTH(n)			(0x0400040C + ((n)<<4))

@ 16-bit
#define SOUND_CR          0x04000500
@ 8-bit
#define SOUND_MASTER_VOL  0x04000500
@ not sure on the following
@ 16-bit
#define SOUND_BIAS        0x04000504
#define SOUND508          0x04000508
#define SOUND510          0x04000510
#define SOUND514		  0x04000514
#define SOUND518          0x04000518
#define SOUND51C          0x0400051C
