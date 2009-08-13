#define BIT(n) (1<<(n))

@ makes bg0 appear inside window 0
#define WIN0_BG0		BIT(0)
@ makes bg1 appear inside window 0
#define WIN0_BG1		BIT(1)
@ makes bg2 appear inside window 0
#define WIN0_BG2		BIT(2)
@ makes bg3 appear inside window 0
#define WIN0_BG3		BIT(3)
#define WIN0_SPRITES	BIT(4)		
#define WIN0_BLENDS		BIT(5)
@ makes bg0 appear inside window 1	
#define WIN1_BG0		BIT(8)
@ makes bg1 appear inside window 1
#define WIN1_BG1		BIT(9)
@ makes bg2 appear inside window 1
#define WIN1_BG2		BIT(10)
@ makes bg3 appear inside window 1
#define WIN1_BG3		BIT(11)
#define WIN1_SPRITES	BIT(12)		
#define WIN1_BLENDS		BIT(13)

@ makes bg0 appear outside windows
#define WINOUT_BG0		BIT(0)
@ makes bg1 appear outside windows
#define WINOUT_BG1		BIT(1)
@ makes bg2 appear outside windows
#define WINOUT_BG2		BIT(2)
@ makes bg3 appear outside windows
#define WINOUT_BG3		BIT(3)
#define WINOUT_SPRITES	BIT(4)
#define WINOUT_BLENDS	BIT(5)
#define SWIN_BG0		BIT(8)
#define SWIN_BG1		BIT(9)
#define SWIN_BG2		BIT(10)
#define SWIN_BG3		BIT(11)
#define SWIN_SPRITES	BIT(12)
#define SWIN_BLENDS		BIT(13)
