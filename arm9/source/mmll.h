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

#include "../build/Level01.h"
#include "../build/Level02.h"
#include "../build/Level03.h"
#include "../build/Level04.h"
#include "../build/Level05.h"
#include "../build/Level06.h"
#include "../build/Level07.h"
#include "../build/Level08.h"
#include "../build/Level09.h"
#include "../build/Level10.h"
#include "../build/Level11.h"
#include "../build/Level12.h"
#include "../build/Level13.h"
#include "../build/Level14.h"
#include "../build/Level15.h"
#include "../build/Level16.h"
#include "../build/Level17.h"
#include "../build/Level18.h"
#include "../build/Level19.h"
#include "../build/Level20.h"
#include "../build/Level21.h"
#include "../build/Level22.h"
#include "../build/Level23.h"
#include "../build/Level24.h"
#include "../build/Level25.h"
#include "../build/Level26.h"
#include "../build/Level27.h"
#include "../build/Level28.h"
#include "../build/Level29.h"
#include "../build/Level30.h"
#include "../build/Level31.h"
#include "../build/Level32.h"
#include "../build/Level33.h"
#include "../build/Level34.h"
#include "../build/Level35.h"
#include "../build/Level36.h"
#include "../build/Level37.h"
#include "../build/Level38.h"
#include "../build/Level39.h"
#include "../build/Level40.h"
#include "../build/Level41.h"
#include "../build/Level42.h"

#include "../build/Level43.h"
#include "../build/Level44.h"
#include "../build/Level45.h"

#include "../build/Level49.h"

#include "../build/Background01.h"
#include "../build/Background02.h"
#include "../build/Background03.h"
#include "../build/Background04.h"
#include "../build/Background05.h"
#include "../build/Background06.h"
#include "../build/Background07.h"
#include "../build/Background08.h"
#include "../build/Background09.h"
#include "../build/Background10.h"
#include "../build/Background11.h"
#include "../build/Background12.h"
#include "../build/Background13.h"
#include "../build/Background14.h"
#include "../build/Background15.h"
#include "../build/Background16.h"
#include "../build/Background17.h"
#include "../build/Background18.h"
#include "../build/Background19.h"
#include "../build/Background20.h"
#include "../build/Background21.h"
#include "../build/Background22.h"
#include "../build/Background23.h"
#include "../build/Background24.h"
#include "../build/Background25.h"
#include "../build/Background26.h"
#include "../build/Background27.h"
#include "../build/Background29.h"
#include "../build/Background30.h"
#include "../build/Background31.h"
#include "../build/Background32.h"

#include "../build/Background39.h"

#include "../build/Background41.h"

#include "../build/Background49.h"

#include "../build/Exit01.h"
#include "../build/Exit02.h"
#include "../build/Exit03.h"
#include "../build/Exit04.h"
#include "../build/Exit05.h"
#include "../build/Exit06.h"
#include "../build/Exit07.h"
#include "../build/Exit08.h"
#include "../build/Exit10.h"
#include "../build/Exit14.h"
#include "../build/Exit15.h"
#include "../build/Exit16.h"
#include "../build/Exit17.h"
#include "../build/Exit18.h"
#include "../build/Exit19.h"
#include "../build/Exit20.h"
#include "../build/Exit12.h"
#include "../build/Exit21.h"
#include "../build/Exit22.h"
#include "../build/Exit23.h"
#include "../build/Exit24.h"
#include "../build/Exit25.h"
#include "../build/Exit26.h"
#include "../build/Exit27.h"
#include "../build/Exit29.h"
#include "../build/Exit30.h"
#include "../build/Exit31.h"
#include "../build/Exit32.h"
#include "../build/Exit33.h"
#include "../build/Exit34.h"
#include "../build/Exit35.h"

#include "../build/Exit41.h"
#include "../build/Exit42.h"
#include "../build/Exit43.h"
#include "../build/Exit44.h"
#include "../build/Exit45.h"

#include "../build/TopMenu.h"
#include "../build/BotMenu.h"

#include "../build/GameBottom.h"

#include "../build/Sprites.h"
#include "../build/TitleSprites.h"
#include "../build/Font.h"
#include "../build/BigFont.h"
#include "../build/ScrollFont.h"
#include "../build/Status.h"
#include "../build/CreditPage.h"
#include "../build/CreditPageTop.h"
#include "../build/CreditPage2.h"
#include "../build/CreditPageTop2.h"
#include "../build/HighScore.h"
#include "../build/BonusSprite.h"
#include "../build/BonusSparkle.h"
#include "../build/BonusNormal.h"

#include "../build/EndBottom.h"
#include "../build/EndTop.h"
#include "../build/EndBoot.h"
#include "../build/EndFridge.h"
#include "../build/EndPoo.h"
#include "../build/EndPiano.h"
#include "../build/EndCase.h"
#include "../build/EndAnvil.h"
#include "../build/EndBus.h"
#include "../build/EndLoo.h"
#include "../build/EndMaid.h"
#include "../build/EndMax.h"
#include "../build/EndTardis.h"
#include "../build/EndMorrissey.h"
#include "../build/EndStarTrek.h"
#include "../build/EndEaster.h"
#include "../build/EndTopSplat.h"
#include "../build/EndBotSplat.h"

#include "../build/GameStart.h"
#include "../build/AudioBottom.h"
#include "../build/AudioTop.h"
#include "../build/AudioSprites.h"
#include "../build/VictoryTop.h"
#include "../build/VictoryBottom.h"
#include "../build/VictoryWWTop.h"
#include "../build/VictoryWWBottom.h"
#include "../build/VictoryBonusTop.h"
#include "../build/VictoryBonusBottom.h"
#include "../build/VictoryStars.h"

#include "../build/HighSprites.h"
#include "../build/HighTop.h"
#include "../build/HighBot.h"

@ intro graphics

#include "../build/Proteus.h"
#include "../build/Headsoft.h"
#include "../build/Infectuous.h"
#include "../build/Spacefractal.h"
#include "../build/Web.h"
#include "../build/Retrobytes.h"

@ miner sprites

#include "../build/MinerNormal.h"
#include "../build/MinerSpace.h"
#include "../build/MinerSpectrum.h"
#include "../build/MinerHorace.h"
#include "../build/MinerCasablanca.h"
#include "../build/MinerBlagger.h"
#include "../build/MinerCoupe.h"

#include "../build/SpriteBank1.h"

@ FX animated sprites

#include "../build/FXDrip.h"
#include "../build/FXFlies.h"
#include "../build/FXEyes.h"
#include "../build/FXMallow.h"
#include "../build/FXCasablanca.h"
#include "../build/FXBlood.h"
#include "../build/FXBulb.h"
#include "../build/FXBlinks.h"
#include "../build/FXSpark.h"
#include "../build/FXKongL.h"
#include "../build/FXKongR.h"
#include "../build/FXKHead.h"
#include "../build/FXScratch.h"
#include "../build/FXMeteor.h"
#include "../build/FXForceField.h"
#include "../build/FXAnton.h"
#include "../build/FXLift.h"
#include "../build/FXRocky.h"
#include "../build/FXBackFlag.h"

@ death animations

#include "../build/DieFall.h"
#include "../build/DieSkeleton.h"
#include "../build/DieChicken.h"
#include "../build/DieCrumble.h"
#include "../build/DieExplode.h"
#include "../build/DieSpaceMan.h"
#include "../build/DieRick.h"
#include "../build/DieHorace.h"
#include "../build/DieRIP.h"
#include "../build/DieCasket.h"
#include "../build/DieEatSelf.h"
#include "../build/DieEye.h"
#include "../build/DieRaven.h"
#include "../build/DieTravolta.h"
#include "../build/DieVanish.h"
#include "../build/DieGameOver.h"

@ tile offset for the status font

#define BigFontOffset				8192

@ View the VRAM layout at http://dev-scene.com/NDS/Tutorials_Day_4#Background_Memory_Layout_and_VRAM_Management

@ BG0 - Text / Score / Energy		16
@ BG1 - Level Foreground			256
@ BG2 - Level Layout				256
@ BG3 - Background					256

#define BG0_MAP_BASE				27
#define BG0_MAP_BASE_SUB			27

#define BG1_MAP_BASE				28
#define BG1_MAP_BASE_SUB			28

#define BG2_MAP_BASE				29
#define BG2_MAP_BASE_SUB			29

#define BG3_MAP_BASE				30
#define BG3_MAP_BASE_SUB			30

#define BG1_INTRO_TILE_BASE			4
#define BG1_INTRO_TILE_BASE_SUB		4

#define BG2_INTRO_TILE_BASE			0
#define BG2_INTRO_TILE_BASE_SUB		0

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

#define GAMEMODE_INIT_TITLESCREEN	3
#define GAMEMODE_TITLE_SCREEN		4
#define GAMEMODE_INTRO				5
#define GAMEMODE_LEVEL_CLEAR_INIT	6
#define GAMEMODE_LEVEL_CLEAR		7
#define GAMEMODE_DIES_INIT			8
#define GAMEMODE_DIES_UPDATE		9
#define GAMEMODE_SPOTLIGHT			10
#define GAMEMODE_GAMEOVER			11
#define GAMEMODE_AUDIO				12
#define GAMEMODE_COMPLETION			13
#define GAMEMODE_COMPLETION_BONUS	14
#define GAMEMODE_COMPLETION_WILLYW	15
#define GAMEMODE_GAMEOVER_SCREEN	16

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

#define LEVEL_COUNT					32

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

#define MINER_MID_JUMP				22			@ 22
#define MINER_JUMPLEN				34			@ 34

#define LEFT_OFFSET					3			@ 3
#define RIGHT_OFFSET				11			@ 11
#define FEET_NIP					0		@ one or 2??? (0 works best)
#define FEET_DROP					0		@ This does not work :(

@ Effect defines
@ / These are fx triggers
#define FX_RAIN						1
#define FX_STARS					2
#define FX_LEAVES					3
#define FX_GLINT					4
#define FX_DRIP						5
#define FX_EYES						6
#define FX_FLIES					7
#define FX_MALLOW					8
#define FX_CSTARS					9
#define FX_BLOOD					10
#define FX_BULB						11
#define FX_BLINKS					12
#define FX_KILLERS					13
#define FX_SPARK					14
#define FX_KONG						15
#define FX_METEOR					16
#define FX_FORCEFIELD				17
#define FX_ANTON					18
#define FX_LIFT						19
#define FX_ROCKY					20
#define FX_FFLAG					21
#define FX_CAUSEWAY					22


@ / these are sprite active values used by drawsprite
#define MONSTER_ACTIVE				128
#define DUST_ACTIVE					2
#define KEY_ACTIVE					3
#define FX_RAIN_ACTIVE				4
#define FX_RAIN_SPLASH				5
#define FX_STARS_ACTIVE				6
#define FX_LEAVES_ACTIVE			7
#define FX_GLINT_ACTIVE				8
#define FX_DRIP_ACTIVE				9
#define FX_DRIPFALL_ACTIVE			10
#define FX_DRIPSPLASH_ACTIVE		11
#define FX_EYES_ACTIVE				12
#define FX_FLIES_ACTIVE				13
#define FX_MALLOW_ACTIVE			14
#define FX_CSTARS_ACTIVE			15
#define FX_CFLAG_ACTIVE				16
#define FX_BLINKS_ACTIVE			17
#define FX_SPARK_ACTIVE				18
#define FX_EXPLODE_ACTIVE			19
#define FX_STARBURST_ACTIVE			20
#define FX_SCRATCH_ACTIVE			21
#define FX_METEOR_ACTIVE			22
#define FX_METEORCRASH_ACTIVE		23
#define FX_STARDUST_ACTIVE			24
#define FX_BLOOD_ACTIVE				25
#define FX_LIFT_ACTIVE				26
#define FX_BONUS					27
#define FX_SPARKLE					28
#define FX_GGLINT_ACTIVE			29
#define FX_CAUSEWAY_ACTIVE			77

@ / these are various animation settings
#define DUST_FRAME					60			@ start frame (or only frame)
#define DUST_FRAME_END				63			@ end frame
#define DUST_ANIM					8			@ animation delay

#define KEY_FRAME					52
#define KEY_FRAME_END				59
#define KEY_ANIM					6

#define DOOR_FRAME					16
#define DOOR_FRAME_END				23

#define RAIN_FRAME					24
#define RAIN_LIGHTNING_DELAY		25
#define RAIN_SPLASH_FRAME			25
#define RAIN_SPLASH_FRAME_END		28
#define RAIN_SPLASH_ANIM			4

#define STAR_FRAME					29

#define LEAF_FRAME					30
#define LEAF_FRAME_END				34

#define GLINT_FRAME					35
#define GLINT_FRAME_END				39
#define GLINT_ANIM					8

#define DRIP_FRAME					24
#define DRIP_FRAME_END				31
#define DRIP_ANIM					2
#define DRIPFALL_FRAME				31
#define DRIPFALL_ANIM				1
#define DRIPSPLASH_FRAME			32
#define DRIPSPLASH_FRAME_END		37
#define DRIPSPLASH_ANIM				8

#define EYE_FRAME					24
#define EYE_FRAME_END				36
#define EYE_ANIM					8

#define FLY_FRAME					24
#define FLY_FRAME_END				28
#define FLY_ANIM					4

#define CSTARS_FRAME				32
#define CSTARS_FRAME_END			39
#define CSTARS_ANIM					10

#define CFLAG_FRAME					24
#define CFLAG_FRAME_END				31
#define CFLAG_ANIM					10

#define BULB_FRAME					24

#define BLINKS_FRAME				24
#define BLINKS_FRAME_END			31
#define BLINKS_ANIM					8

#define SPARK_FRAME					24
#define SPARK_FRAME_END				37
#define SPARK_ANIM					4

#define EXPLODE_FRAME				48
#define EXPLODE_FRAME_END			51
#define EXPLODE_ANIM				4

#define METEOR_FRAME				24
#define METEOR_FRAME_END			27
#define METEOR_ANIM					8
#define METEOREXP_FRAME				28
#define METEOREXP_FRAME_END			35
#define METEOREXP_ANIM				4
#define FORCEF_FRAME				36
#define FORCEF_FRAME_END			39
#define FORCEF_ANIM					2
#define FORCEF_DELAY				75
#define STARDUST_FRAME				40

#define FORCEFIELD_FRAME			24
#define FORCEFIELD_FRAME_END		27
#define FORCEFIELD_ANIM				2

#define BLOOD_FRAME					27
#define BLOOD_FRAME_END				34
#define BLOOD_ANIM				 	8

#define BONUS_ANIM					16

#define SPARKLE_FRAME				4
#define SPARKLE_FRAME_END			11
#define SPARKLE_ANIM				12

#define GGLINT_FRAME				0
#define GGLINT_FRAME_END			7
#define GGLINT_ANIM					6

#define CAUSE_FRAME					40
#define CAUSE_FRAME_END				47
#define CAUSE_ANIM					8

@ level defines

#define EXIT_CLOSED					64
#define EXIT_OPEN					65

@ other defines

#define HIGH_NAME_LEN				8
#define HIGH_SCORE_LEN				6
#define SECRET_MAX					15			@ use this to make sure that we don't unlock more than we have
#define POINTER_DELAY				10

