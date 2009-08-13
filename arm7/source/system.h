/*---------------------------------------------------------------------------------

	Power control, keys, and HV clock registers

	Copyright (C) 2005
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

@ LCD status register.
#define	REG_DISPSTAT		0x04000004

#define DISP_IN_VBLANK		BIT(0)
#define DISP_IN_HBLANK		BIT(1)
#define DISP_YTRIGGERED		BIT(2)
#define DISP_VBLANK_IRQ		BIT(3)
#define DISP_HBLANK_IRQ		BIT(4)
#define DISP_YTRIGGER_IRQ	BIT(5)

@ Current display scanline.
#define	REG_VCOUNT			0x4000006

@ Halt control register.
@ Writing 0x40 to HALT_CR activates GBA mode.
@ HALT_CR can only be accessed via the BIOS.
#define HALT_CR				0x04000300

@ Power control register.
@ This register controls what hardware should
@ be turned on or off.
#define	REG_POWERCNT		0x4000304

#define POWER_SOUND       	BIT(0)
#define POWER_UNKNOWN     	BIT(1)

#define PM_CONTROL_REG		0
#define PM_BATTERY_REG		1
#define PM_AMPLIFIER_REG	2
#define PM_READ_REGISTER	(1<<7)
#define PM_AMP_OFFSET		2
#define PM_GAIN_OFFSET		3
#define PM_GAIN_20			0
#define PM_GAIN_40			1
#define PM_GAIN_80			2
#define PM_GAIN_160			3
#define PM_AMP_ON			1
#define PM_AMP_OFF			0

#define PM_LED_CONTROL(m)  ((m)<<4)

@ Key input register.
@ On the ARM9, the hinge "button", the touch status, and the
@ X and Y buttons cannot be accessed directly.

#define	REG_KEYINPUT		0x04000130

@ Key input control register.
#define	REG_KEYCNT			0x04000132

@ Default location for the user's personal data (see %PERSONAL_DATA).
#define PersonalData		0x27FFC80

#define BUTTON_A          BIT(0)
#define BUTTON_B          BIT(1)
#define BUTTON_SELECT     BIT(2)
#define BUTTON_START      BIT(3)
#define BUTTON_RIGHT      BIT(4)
#define BUTTON_LEFT       BIT(5)
#define BUTTON_UP         BIT(6)
#define BUTTON_DOWN       BIT(7)
#define BUTTON_R          BIT(8)
#define BUTTON_L          BIT(9)
