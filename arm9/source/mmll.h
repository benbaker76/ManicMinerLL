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

#include "../build/BottomScreen.h"

#include "../build/Level01.h"
#include "../build/Level02.h"
#include "../build/Level03.h"
#include "../build/Level04.h"
#include "../build/Level05.h"


#include "../build/Level21.h"

#include "../build/Background01.h"
#include "../build/Background02.h"
#include "../build/Background03.h"
#include "../build/Background04.h"
#include "../build/Background05.h"
#include "../build/Background06.h"
@#include "../build/Background07.h"

#include "../build/Exit01.h"
#include "../build/Exit02.h"
#include "../build/Exit03.h"
#include "../build/Exit04.h"

#include "../build/TopMenu.h"

#include "../build/GameBottom.h"

#include "../build/Sprites.h"
#include "../build/Font.h"
#include "../build/BigFont.h"
#include "../build/Status.h"

#include "../build/SpriteBank1.h"

@ View the VRAM layout at http://dev-scene.com/NDS/Tutorials_Day_4#Background_Memory_Layout_and_VRAM_Management

@ BG0 - Text / Score / Energy		16
@ BG1 - Level Foreground			256
@ BG2 - Level Layout				256
@ BG3 - Background					256

#define BG0_MAP_BASE				28
#define BG0_MAP_BASE_SUB			28

#define BG1_MAP_BASE				31
#define BG1_MAP_BASE_SUB			31

#define BG2_MAP_BASE				30
#define BG2_MAP_BASE_SUB			30

#define BG3_MAP_BASE				29
#define BG3_MAP_BASE_SUB			29

#define BG0_TILE_BASE				7
#define BG0_TILE_BASE_SUB			7

#define BG1_TILE_BASE				6
#define BG1_TILE_BASE_SUB			6

#define BG2_TILE_BASE				4
#define BG2_TILE_BASE_SUB			4

#define BG3_TILE_BASE				0
#define BG3_TILE_BASE_SUB			0

@ Our background priorities

#define BG0_PRIORITY				0
#define BG1_PRIORITY				1
#define BG2_PRIORITY				2
#define BG3_PRIORITY				3

@ Sprite priority is 1 so it appears below BG1

#define SPRITE_PRIORITY				2

@ Game modes

#define GAMEMODE_STOPPED			0
#define GAMEMODE_RUNNING			1
#define GAMEMODE_PAUSED				2
#define GAMEMODE_LEVEL_CLEAR		3

@ FX defines. These are bits so we can have multiple fx at once

#define FX_NONE						0
#define FX_SINE_WOBBLE				BIT(0)
#define FX_FADE_IN					BIT(1)
#define FX_FADE_OUT					BIT(2)
#define FX_MOSAIC_IN				BIT(3)
#define FX_MOSAIC_OUT				BIT(4)
#define FX_SPOTLIGHT_IN				BIT(5)
#define FX_SPOTLIGHT_OUT			BIT(6)
#define FX_SCANLINE					BIT(7)
#define FX_WIPE_IN_LEFT				BIT(8)
#define FX_WIPE_IN_RIGHT			BIT(9)
#define FX_WIPE_OUT_UP				BIT(10)
#define FX_WIPE_OUT_DOWN			BIT(11)
#define FX_CROSSWIPE				BIT(12)
#define FX_COLOR_CYCLE				BIT(13)
#define FX_COLOR_PULSE				BIT(14)
#define FX_COPPER_TEXT				BIT(15)
#define FX_COLOR_CYCLE_TEXT			BIT(16)
#define FX_TEXT_SCROLLER			BIT(17)
#define FX_VERTTEXT_SCROLLER		BIT(18)
#define FX_STARFIELD				BIT(19)
#define FX_PALETTE_FADE_TO_RED		BIT(20)
#define FX_STARFIELD_DOWN			BIT(21)
#define FX_STARFIELD_MULTI			BIT(22)
#define FX_FIREWORKS				BIT(23)
#define FX_STARBURST				BIT(24)

@ Colors

#define COLOR_BLACK					0x0000
#define COLOR_WHITE					0x7FFF
#define COLOR_RED					0x001F
#define COLOR_YELLOW				0x03FF
#define COLOR_ORANGE				0x029F
#define COLOR_LIME					0x03E0
#define COLOR_GREEN					0x0200
#define COLOR_CYAN					0x7FE0
#define COLOR_BLUE					0x7C00
#define COLOR_PURPLE				0x4010
#define COLOR_VIOLET				0x761D
#define COLOR_MAGENTA				0x7C1F
#define COLOR_BROWN					0x14B4

@ Levels

#define LEVEL_1						1
#define LEVEL_2						2
#define LEVEL_3						3
#define LEVEL_4						4
#define LEVEL_5						5
#define LEVEL_6						6
#define LEVEL_7						7
#define LEVEL_8						8
#define LEVEL_9						9
#define LEVEL_10					10
#define LEVEL_11					11
#define LEVEL_12					12
#define LEVEL_13					13
#define LEVEL_14					14
#define LEVEL_15					15
#define LEVEL_16					16

#define LEVEL_COUNT					5

@ Fade values

#define FADE_NOT_BUSY				0
#define FADE_BUSY					1

@ Drawsprite Values

#define SCREEN_LEFT					64
#define SCREEN_RIGHT				319
#define SCREEN_SUB_WHITESPACE		383
#define SCREEN_SUB_TOP				384
#define SCREEN_SUB_BOTTOM			575
#define SCREEN_MAIN_TOP				576
#define SCREEN_MAIN_BOTTOM			767
#define SCREEN_MAIN_WHITESPACE		768
#define SPRITE_KILL					788+32

@ Movement Values

#define MINER_STILL					0
#define MINER_LEFT					1
#define MINER_RIGHT					2

@ Miner Status Values

#define MINER_NORMAL				0
#define MINER_JUMP					1
#define MINER_FALL					2
#define MINER_CONVEYOR				4

#define MINER_MID_JUMP				22
#define MINER_JUMPLEN				34

#define LEFT_OFFSET					3
#define RIGHT_OFFSET				13
#define FEET_NIP					1		@ one or 2??? (1 works best)
#define FEET_DROP					0		@ This does not work :(

@ Effect defines
@ / These are fx triggers
#define FX_RAIN						1
#define FX_STARS					2
#define FX_LEAVES					3
#define FX_GLINT					4



@ / these are sprite active values used by drawsprite
#define DUST_ACTIVE					2
#define KEY_ACTIVE					3
#define FX_RAIN_ACTIVE				4
#define FX_RAIN_SPLASH				5
#define FX_STARS_ACTIVE				6
#define FX_LEAVES_ACTIVE			7
#define FX_GLINT_ACTIVE				8

@ / these are various animation settings
#define DUST_FRAME					60			@ start frame (or only frame)
#define DUST_FRAME_END				63			@ end frame
#define DUST_ANIM					4			@ animation delay
#define KEY_FRAME					52
#define KEY_FRAME_END				59
#define KEY_ANIM					2
#define DOOR_FRAME					16
#define DOOR_FRAME_END				23
#define RAIN_FRAME					24
#define RAIN_SPLASH_FRAME			25
#define RAIN_SPLASH_FRAME_END		28
#define RAIN_SPLASH_ANIM			4
#define STAR_FRAME					29
#define LEAF_FRAME					30
#define LEAF_FRAME_END				34
#define GLINT_FRAME					35
#define GLINT_FRAME_END				39
#define GLINT_ANIM					8
@ level defines

#define EXIT_CLOSED					64
#define EXIT_OPEN					65

