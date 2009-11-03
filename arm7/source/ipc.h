/*---------------------------------------------------------------------------------

	Inter Processor Communication

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

#define IPC					0x027FF000

@ 32-bit
#define IPC_SOUND_DATA(n)	(IPC + (n << 4))
@ 32-bit
#define IPC_SOUND_LEN(n)	(IPC + (n << 4) + 4)
@ 32-bit
#define IPC_SOUND_RATE(n)	(IPC + (n << 4) + 8)
@ 8-bit
#define IPC_SOUND_VOL(n)	(IPC + (n << 4) + 12)
#define IPC_SOUND_PAN(n)	(IPC + (n << 4) + 13)
#define IPC_SOUND_CHAN(n)	(IPC + (n << 4) + 14)
#define IPC_SOUND_FORMAT(n)	(IPC + (n << 4) + 15)

@ 16-bit
#define REG_IPC_SYNC		0x04000180

#define IPC_SOUND_LOOP		BIT(0)
#define IPC_SOUND_16BIT		BIT(1)
#define IPC_SOUND_ADPCM		BIT(2)

#define IPC_SYNC_IRQ_ENABLE			BIT(14)
#define IPC_SYNC_IRQ_REQUEST		BIT(13)

#define IPC_SEND_SYNC(n)			((((n) & 0x0f) << 8) | IPC_SYNC_IRQ_REQUEST)
