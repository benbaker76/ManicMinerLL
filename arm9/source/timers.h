/*---------------------------------------------------------------------------------
	$Id: timers.h,v 1.13 2008/12/08 23:50:06 dovoto Exp $

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

@ timer clock / 1 (~33513.982 kHz)
#define CLOCKDIVIDER_1				0
@ timer clock / 64 (~523.657 kHz)
#define CLOCKDIVIDER_64				1
@ timer clock / 256 (~130.914 kHz)
#define CLOCKDIVIDER_256			2
@ timer clock / 1024 (~32.7284 kHz)
#define CLOCKDIVIDER_1024			3

#define TIMERFREQTOTICKS_1(freq) (-0x2000000 / freq)
#define TIMERFREQTOTICKS_64(freq) ((-0x2000000 >> 6) / freq)
#define TIMERFREQTOTICKS_256(freq) ((-0x2000000 >> 8) / freq)
#define TIMERFREQTOTICKS_1024(freq) ((-0x2000000 >> 10) / freq)

#define TIMER_FREQ(n)    (-0x2000000/(n))
#define TIMER_FREQ_64(n)  (-(0x2000000>>6)/(n))
#define TIMER_FREQ_256(n) (-(0x2000000>>8)/(n))
#define TIMER_FREQ_1024(n) (-(0x2000000>>10)/(n))

@ 16-bit
#define TIMER0_DATA    0x04000100
#define TIMER1_DATA    0x04000104
#define TIMER2_DATA    0x04000108
#define TIMER3_DATA    0x0400010C

#define TIMER_DATA(n)  (0x04000100+((n)<<2)))

#define TIMER0_CR   0x04000102
#define TIMER1_CR   0x04000106
#define TIMER2_CR   0x0400010A
#define TIMER3_CR   0x0400010E

#define TIMER_CR(n) (0x04000102+((n)<<2)))

@ Enables the timer.
#define TIMER_ENABLE    (1<<7)

@ Causes the timer to request an Interupt on overflow.
#define TIMER_IRQ_REQ   (1<<6)

@ When set will cause the timer to count when the timer below overflows (unavailable for timer 0).
#define TIMER_CASCADE   (1<<2)

@ Causes the timer to count at 33.514Mhz.
#define TIMER_DIV_1     0
@ Causes the timer to count at (33.514 / 64) Mhz.
#define TIMER_DIV_64    1
@ Causes the timer to count at (33.514 / 256) Mhz.
#define TIMER_DIV_256   2
@ Causes the timer to count at (33.514 / 1024)Mhz.
#define TIMER_DIV_1024  3
