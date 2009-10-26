#include "mmll.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.arm
	.align
	.text
	
	#define TRIVIA_PAGES		34

	.global initCompletionBonus
	.global updateCompletionBonus
	
@---------------------------				BONUS LEVEL COMPLETION INIT

initCompletionBonus:

	stmfd sp!, {r0-r10, lr}

	lcdMainOnBottom

	bl stopTimer3

	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	bl clearOAM
	bl clearSpriteData
@	bl stopMusic					@ remove when we have completion music

	ldr r1,=gameMode
	mov r0,#GAMEMODE_COMPLETION_BONUS
	str r0,[r1]

	bl fxFadeBlackInit
	bl fxFadeMax
	
	ldr r0,=VictoryBonusBottomTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=VictoryBonusBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryBonusBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)					@ destination
	ldr r2, =VictoryBonusBottomMapLen
	bl dmaCopy
	ldr r0, =VictoryBonusBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =VictoryBonusBottomPalLen
	bl dmaCopy	

	ldr r0,=VictoryBonusTopTiles						@ copy the tiles used for game over
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=VictoryBonusTopTilesLen
	bl decompressToVRAM	
	ldr r0, =VictoryBonusTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =VictoryBonusTopMapLen
	bl dmaCopy
	ldr r0, =VictoryBonusTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =VictoryBonusTopPalLen
	bl dmaCopy	

	ldr r0,=BigFont2Tiles							@ copy the tiles used for large font
	ldr r1,=BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	ldr r2,=BigFont2TilesLen
	bl decompressToVRAM

	mov r0,#35
	bl levelMusicPlayEasy

	@ draw the text!
	
	ldr r0,=line1								@ CONGRATS
	mov r1,#1
	mov r2,#0
	bl drawTextBigNormal
	ldr r0,=line2
	mov r2,#2
	bl drawTextBigNormal
	
	ldr r6,=unlockedBonuses
	ldr r6,[r6]									@ are there still any to find?
	cmp r6,#20
	ldreq r0,=line3all
	ldrne r0,=line3more
	mov r2,#6
	bl drawTextBigNormal
	
	@ now, have we beaten a record
	
	ldr r6,=gotRecord
	ldr r6,[r6]
	cmp r6,#1
	ldreq r0,=recordYes
	ldrne r0,=recordNo
	mov r2,#9
	bl drawTextBigNormal
	
	ldr r0,=fact
	mov r2,#14
	bl drawTextBigNormal
	ldr r0,=fact2
	mov r2,#16
	bl drawTextBigNormal		

	@ draw trivia (3*30 chars)

	ldr r3,=trivia
	ldr r8,[r3]
	add r8,#1
	cmp r8,#TRIVIA_PAGES
	moveq r8,#0
	str r8,[r3]
		
	mov r3,#90 			@ 3 lines
	mul r8,r3
	ldr r0,=facts
	add r0,r8			@ r8=first line
	
	add r2,#1
	bl drawTextBigNormal
	add r2,#2
	bl drawTextBigNormal
	add r2,#2
	bl drawTextBigNormal
	
	@ start special fx
	
	bl bonusInit
	
	bl fxFadeIn	

	@ if gotRecord=1, then a bonus time has been beaten
	
	bl saveGame
	
	ldmfd sp!, {r0-r10, pc}
	
@--------------------------- 			BONUS COMPLETION

updateCompletionBonus:

	stmfd sp!, {r0-r10, lr}
	
	bonusLoop:
		bl swiWaitForVBlank	
		bl updateSpecialFX
		bl drawSprite
	
		@ Check for start or A pressed
	
		ldr r2, =REG_KEYINPUT
		ldr r10,[r2]
	
		tst r10,#BUTTON_START
		beq completionBonusEnd

		ldr r1,=trapStart
		mov r0,#0
		str r0,[r1]
	
		bonusReturn:
	
	b bonusLoop
@--------------------

	completionBonusEnd:
	
	@ return to title screen (or highscore at some point)
	
	ldr r1,=trapStart
	ldr r0,[r1]
	cmp r0,#0
	bne bonusReturn
	mov r0,#1
	str r0,[r1]

	mov r0,#0
	ldr r1,=spriteScreen
	str r0,[r1]

	bl fxFadeBlackInit
	bl fxFadeMin
	bl fxFadeOut

	justWait:
		bl swiWaitForVBlank	
		bl updateSpecialFX
		bl drawSprite	
	
		ldr r1,=fxFadeBusy
		ldr r1,[r1]
		cmp r1,#0
	bne justWait

@	bl specialFXStop
@	bl clearOAM	
	
	bl initTitleScreen
	
	ldmfd sp!, {r0-r10, pc}	

@-------------------
	
	.pool
	.align
	.data
line1:
	.ascii "       CONGRATULATIONS!       "
line2:
	.ascii "    BONUS LEVEL COMPLETED!    "
line3all:	@ ARE THEY ALL UNLOCKED
	.ascii "YOU HAVE FOUND ALL THE BONUSES"
line3more:
	.ascii "CAN YOU FIND THE REST OF THEM?"
recordYes:	@ HAVE YOU GOT A RECORD?
	.ascii "WELL DONE FOR SETTING A RECORD"
recordNo:
	.ascii "CAN YOU BEAT THE RECORD SPEED?"
fact:
	.ascii "   MANIC MINER TRIVIA FACT!   "
fact2:
	.ascii "   <======================>   "
	
facts:
	@ 1
	.ascii "  ROOM DATA FOR THE SPECTRUM  "
	.ascii "  VERSION IS HELD AT MEMORY   "
	.ascii "  ADDRESSES 45056 TO 65535.   "
	@ 2
	.ascii "  A 12-STAGE UNOFFICIAL PORT  "
	.ascii "  WITH HIGH-RES GRAPHICS WAS  "
	.ascii "  MADE FOR THE ZX81 IN 1984.  "
	@ 3
	.ascii "  A VERSION OF JET SET WILLY  "
	.ascii "  EXISTS WHICH MAKES ITS MAP  "
	.ascii "  OUT OF MANIC MINER LEVELS.  "
	@ 4
	.ascii "  AN EXTREMELY HARD 2008 MOD  "
	.ascii "  AMENDED THE GAME BASED ON   "
	.ascii "  COMMENTS BY MATTHEW SMITH.  "
	@ 5
	.ascii "  IN THE 'PERPETUAL MOTION'   "
	.ascii "  MOD VERSION (2005), WILLY   "
	.ascii "  IS UNABLE TO STAND STILL.   "
	@ 6
	.ascii "  THE COMMODORE 16 VERSION    "
	.ascii "  HAS NO MUSIC, 'GAME OVER'   "
	.ascii "  SCREEN OR END SEQUENCE.     "
	@ 7
	.ascii "  ON THE SAM COUPE VERSION,   "
	.ascii "  EUGENE'S LAIR WAS RENAMED   "
	.ascii "  AS 'THE SUGAR FACTORY'.     "
	@ 8
	.ascii "  ON THE AMSTRAD CPC VERSION  "
	.ascii "  EUGENE'S LAIR WAS RENAMED   "
	.ascii "  AS 'EUGENE WAS HERE'.       "
	@ 9
	.ascii "  THE SOLAR POWER GENERATOR   "
	.ascii "  DOES NOT APPEAR IN THE BBC  "
	.ascii "  MICRO VERSION OF THE GAME.  "
	@ 10
	.ascii "  ORIC LEVELS WERE UNIQUELY   "
	.ascii "  BUILT FROM TILES 6 PIXELS   "
	.ascii "  WIDE, RATHER THAN 8.        "
	@ 11
	.ascii "  MANIC MINER WAS THE FIRST-  "
	.ascii "  EVER SPECTRUM GAME TO HAVE  "
	.ascii "  CONTINUOUS MUSIC PLAYING.   "
	@ 12
	.ascii "  MATTHEW SMITH WROTE MANIC   "
	.ascii "  MINER WHEN HE WAS 17, AND   "
	.ascii "  MADE JUST 3 OTHER GAMES.    "
	@ 13
	.ascii "  THERE WERE THREE DIFFERENT  "
	.ascii "  VERSIONS OF SPECTRUM MANIC  "
	.ascii "  MINER WITH UNIQUE ARTWORK.  "
	@ 14
	.ascii "  AN ADVERTISED C64 UPDATE,   "
	.ascii "  CALLED MATTIE GOES MINING,  "
	.ascii "  WAS NEVER RELEASED.         "
	@ 15
	.ascii "  THE AMSTRAD CPC VERSION IS  "
	.ascii "  THE ONLY ONE WITH GRAPHICS  "
	.ascii "  IN SOME OF THE ROOM NAMES.  "
	@ 16
	.ascii "  BOTH COMMODORE CONVERSIONS  "
	.ascii "  LACK THE SCENERY GRAPHICS   "
	.ascii "  FOR 'THE FINAL BARRIER'.    "
	@ 17
	.ascii "  THE DRAGON, C64, C16 AND    "
	.ascii "  ORIC VERSIONS ALL DISPLAY   "
	.ascii "  LEVEL NAMES IN UPPER CASE.  "
	@ 18
	.ascii "  IT'S NOT NECESSARY TO KILL  "
	.ascii "  KONG IN EITHER OF THE KONG  "
	.ascii "  BEAST LEVELS TO BEAT THEM.  "
	@ 19
	.ascii "  IN THE AMIGA PORT, WILLY'S  "
	.ascii "  GARDEN HAS A CLOTHES LINE   "
	.ascii "  IN IT, INSTEAD OF FLOWERS.  "
	@ 20
	.ascii "  THE ENHANCED AMIGA VERSION  "
	.ascii "  IS THE ONLY OFFICIAL GAME   "
	.ascii "  CALLED 'MANIC MINER 2'.     "
	@ 21
	.ascii "  THE ENHANCED AMIGA VERSION  "
	.ascii "  COMPRISES JUST 18 LEVELS -  "
	.ascii "  MISSING OUT THE FINAL TWO.  "
	@ 22
	.ascii "  THE TOTAL NUMBER OF MANIC   "
	.ascii "  MINER PORTS BOTH OFFICIAL   "
	.ascii "  AND UNOFFICIAL IS OVER 20.  "
	@ 23
	.ascii "  THE FIRST DESIGN SKETCHES   "
	.ascii "  FOR MANIC MINER WERE DONE   "
	.ascii "  ON A SKI HOLIDAY IN ITALY.  "
	@ 24
	.ascii "  PORTS OF THE GAME USE ONE   "
	.ascii "  OF TWO QUITE SIGNIFICANTLY  "
	.ascii "  DIFFERENT JUMP PROTOCOLS.   "
	@ 25
	.ascii "  THE GOLD BARS IN EUGENE'S   "
	.ascii "  LAIR ARE SUPPOSED TO LOOK   "
	.ascii "  LIKE STACKED CREDIT CARDS.  "
	@ 26
	.ascii "  THE ENDORIAN FOREST LEVEL   "
	.ascii "  IS A TRIBUTE TO THE EWOKS   "
	.ascii "  FROM 'RETURN OF THE JEDI'.  "
	@ 27
	.ascii "  THE MUTANT TELEPHONES WERE  "
	.ascii "  INFLUENCED BY THIN-SKINNED  "
	.ascii "  HIPPY CODER JEFF MINTER.    "
	@ 28
	.ascii "  SOFTWARE PROJECTS' REDRAWN  "
	.ascii "  'REVENGE' AMOEBATRONS WERE  "
	.ascii "  THE BUG-BYTE LOGO MASCOT.   "
	@ 29
	.ascii "  THE SOFTWARE PROJECTS RE-   "
	.ascii "  RELEASE FEATURED A PAC-MAN  "
	.ascii "  GHOST IN PROCESSING PLANT.  "
	@ 30
	.ascii "  NO REASON IS OFFERED AS TO  "
	.ascii "  WHY THE AMOEBATRONS CHANGE  "
	.ascii "  APPEARANCE BETWEEN LEVELS.  "
	@ 31
	.ascii "  MATTHEW SMITH WAS BORN IN   "
	.ascii "  LONDON IN 1966, BUT MOVED   "
	.ascii "  TO WALLASEY ON MERSEYSIDE.  "
	@ 32
	.ascii "   THE '6031769' CHEAT CODE   "
	.ascii "   CAME FROM DIGITS IN MATT   "
	.ascii "   SMITH'S DRIVING LICENCE.   "
	@ 33
	.ascii "  THE MAIN ENEMY IN EUGENE'S  "
	.ascii "  LAIR IS BASED ON CELEBRITY  "
	.ascii "  IMAGINE CODER EUGENE EVANS. "
	@ 34
	.ascii "  THE FIRST GAME MATTHEW      "
	.ascii "  DEVELOPED WAS ON THE TRS80  "
	.ascii "  CALLED 'DELTA TOWER ONE'.   "