/*---------------------------------------------------------------------------------

	Interrupt registers and vector pointers

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

#define IRQ_VBLANK			BIT(0)
#define IRQ_HBLANK			BIT(1)
#define IRQ_VCOUNT			BIT(2)
#define IRQ_TIMER0			BIT(3)
#define IRQ_TIMER1			BIT(4)
#define IRQ_TIMER2			BIT(5)
#define IRQ_TIMER3			BIT(6)
#define IRQ_NETWORK			BIT(7)
#define IRQ_DMA0			BIT(8)
#define IRQ_DMA1			BIT(9)
#define IRQ_DMA2			BIT(10)
#define IRQ_DMA3			BIT(11)
#define IRQ_KEYS			BIT(12)
#define IRQ_CART			BIT(13)
#define IRQ_IPC_SYNC		BIT(16)
#define IRQ_FIFO_EMPTY		BIT(17)
#define IRQ_FIFO_NOT_EMPTY	BIT(18)
#define IRQ_CARD			BIT(19)
#define IRQ_CARD_LINE		BIT(20)
#define IRQ_GEOMETRY_FIFO	BIT(21)
#define IRQ_LID				BIT(22)
#define IRQ_SPI				BIT(23)
#define IRQ_WIFI			BIT(24)
#define IRQ_ALL				(~0)

#define IRQ_TIMER(n) (1 << ((n) + 3))

#define MAX_INTERRUPTS  25

@ REG_IE
@
@ Interrupt Enable Register.
@
@ This is the activation mask for the internal interrupts.  Unless
@ the corresponding bit is set, the IRQ will be masked out.

#define REG_IE	0x04000210

@ REG_IF
@ Interrupt Flag Register.
@
@ Since there is only one hardware interrupt vector, the IF register
@ contains flags to indicate when a particular of interrupt has occured.
@To acknowledge processing interrupts, set IF to the value of the
@interrupt handled.

#define REG_IF	0x04000214

@ REG_IME
@
@ Interrupt Master Enable Register.
@
@ When bit 0 is clear, all interrupts are masked.  When it is 1,
@interrupts will occur if not masked out in REG_IE.
@

#define REG_IME	0x04000208

@ IME_VALUE
@ values allowed for REG_IME
@
#define IME_DISABLE		0
#deinfe IME_ENABLE		1

#define VBLANK_INTR_WAIT_FLAGS	__irq_flags
#define IRQ_HANDLER				__irq_vector
