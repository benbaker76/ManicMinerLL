	.arm
	.align
	.text
	
	.global levelData
	.global levelNames
	.global levelInfo
	.global storyText
	
	
levelData:

@ 1,2 ok, the first 2 bytes are the x/y of the exit (as x/y strict coord - not +384 and 64)
@ 3 0-127 tune to play 	(0=default, 1=creepy, 2=space, 3=egypt 4=piano 5=speccy)
@	(low 7)					(6=Casablanca, 7=alleycat, 8=jungle, 9=cavern, 10=atmosphere)
@						(11=reggae, 12=Terminator, 13=Snug, 14=ghostbusters, 15=goonies)
@						(16= horror, 17=frankenstein, 18=Gremlins
@	high 1 = 0-1 = Wraparound level? 0=no / 1=yes
@ 4,5 willies start position
@ 6 =willies init dir (0=l 1=r) LOW BYTE / HIGH 7=Special effect (ie. rain) (0=none)
@						1=rain, 2=stars, 3=Leaves, 4=Glint 5=Drip 6=eyes 7=flies
@						8=mallow, 9=twinkle, 10=blood, 11=bulb flash, 12=blinks
@						13=animate killer blocks, 14=sparks 15=kong, 16=meteor storm
@						17=forcefield, 18=anton, 19=lift,20=rocky, 21=BTTF flag
@ 7 =background number (0-?)
@ 8 =door bank number - LOW 5 BITS.. 0-31 HIGH 3 BITS= Willy sprite to use 0-7 (0=normal 1=spectrum 2=space 3=horace 4=Rick)

@ "this section is for the monsters only..."

@ alien data (if initial X and y is 0 = blank alien)
@ 1=initial X,
@ 2=initial y (offsets added at level construct)
@ 3=initial direction (0=neg/1=pos) (LOW 4 BITS) / sprites facing (HFLIP) (HI 4 BITS)
@ 4=travel direction (0=up/dn 1=l/r 2=topr/botl 3=topl/botr) LOW / Do we flip? HIGH (0=yes/1=no)
@ 5=speed of travel (0=?) (do we need fractional movement? yes) (255=every other frame movement update)
@ 6=level sprite to use (0-? read from spritebank)
@ 7=min movement location
@ 8=maximum movement locaton
@ data for each level stored as up to 7 enemies

@ this makes each level description 64 bytes, do we need more?

@ take level number -1 and mul by 64 for base of data!
	
levelData:

	# 1 / Oric - level 17 - Home at last?
	.byte 80,144,1,8,168,3,0,0

	.byte 72,88,17,1,1,17,8,144
	.byte 104,104,1,1,255,17,104,216
	.byte 160,144,1,1,1,1,160,208
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 2 / Oric - Level xx - Airlock
	.byte 128,104,2,8,104,5,1,1
	
	.byte 16,160,17,1,1,0,16,104
	.byte 144,168,17,1,1,7,144,232
	.byte 144,104,17,1,1,7,144,224
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 3 / GBA - Level xx - Mummy Daddy
	.byte 224,80,3,218,168,8,2,2
	
	.byte 104,108,1,16,1,16,108,168
	.byte 56,64,1,16,255,16,64,112
	.byte 120,112,1,16,255,16,64,112
	.byte 232,48,0,1,255,20,208,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 4 / Oric - level 24 - Hall of the mountain kong
	.byte 232,168,8,8,168,7,3,3

	.byte 120,56,1,16,1,18,56,104
	.byte 50,142,17,17,255,6,8,56
	.byte 64,168,17,1,1,21,16,72
	.byte 152,168,17,1,1,21,96,160
	.byte 232,168,0,1,1,21,168,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 5 / Oric - level 18 - back to work
	.byte 232,168,4,6,168,11,4,0

	.byte 104,168,17,1,255,0,104,144
	.byte 32,168,17,1,1,0,16,72
	.byte 168,72,0,1,255,15,24,216
	.byte 232,96,1,16,1,9,72,150
	.byte 152,128,17,3,255,15,152,208
	.byte 96,48,17,1,255,19,8,128
	.byte 144,48,17,1,1,19,144,208
	
	@ 6 / Dragon - Level 21 - The dragon users bonus
	.byte 232,136,11,6,168,13,5,4

	.byte 172,152,17,17,1,6,148,196
	.byte 48,144,17,1,1,3,32,88
	.byte 80,96,17,1,1,3,80,136
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 7 / Oric - level 28 - not the central cavern
	.byte 232,168,5,6,168,1,6,37

	.byte 96,112,17,1,1,22,96,138+32
	.byte 160,168,17,1,2,23,48,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 8 / oric - level - down the pit
	.byte 232,168,7,232,56,8,7,6

	.byte 56,96,1,16,1,24,96,140
	.byte 136,96,1,16,255,24,96,140
	.byte 8,168,17,1,2,21,8,216
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 9 / gba - level xx - metropolis bingo
	.byte 232,168,1,24,168,15,8,7

	.byte 24,116,1,16,255,34,48,168
	.byte 156,88,17,1,255,0,156,196
	.byte 188,136,0,1,255,0,156,188
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 10 / Oric - Level 21 - at the centre of the earth
	.byte 112,112,9,16,168,1,9,9

	.byte 16,48,1,16,1,12,48,168
	.byte 232,96,1,16,2,12,96,168
	.byte 96,168,17,1,1,21,96,142
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 11 / Dragon 32 - eddies forest
	.byte 232,72,8,128,72,7,10,3

	.byte 176,108,1,16,2,16,64,160
	.byte 132,168,17,1,1,21,72,160
	.byte 64,88,17,1,1,29,8,160
	.byte 72,128,0,1,1,29,32,160
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 12 / Oric - level xx - In a deep dark hole
	.byte 8,72,10,136,168,25,11,11

	.byte 152,48,1,16,1,12,48,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 13 / Oric - level 27 - the channel tunnel		@ music
	.byte 232,104,5,6,136,27,12,1

	.byte 136,152,17,1,1,37,136,222
	.byte 80,128,17,1,1,37,80,144
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 14  / GBA - Tokyo Uh oh						@ music
	.byte 232,80,5,6,168,1,13,13

	.byte 32,72,1,16,255,2,72,168
	.byte 104,128,0,16,1,2,72,128
	.byte 142,72,1,16,1,2,72,168
	.byte 184,152,0,16,255,7,72,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 15 / Oric - Space Shuttle						@ music
	.byte 232,112,5,104,80,1,14,14

	.byte 48,104,1,16,255,5,104,168
	.byte 200,64,1,16,255,4,64,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 16 / Oric - Wheres the hyperspace button
	.byte 162,168,2,6,96,5,15,79

	.byte 24,96,17,1,1,11,8,112
	.byte 112,120,17,1,1,11,112,176
	.byte 168,120,17,1,1,11,168,232
	.byte 16,152,17,1,1,8,8,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 17 / BBC - Meteor Storm
	.byte 120,96,5,6,168,33,16,16					@ music

	.byte 56,168,17,1,1,45,16,56
	.byte 224,168,17,1,1,45,184,224
	.byte 152,152,17,1,1,45,72,152
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 18	/ Dragon32 - The end
	.byte 232,64,133,120,48,0,17,17					@ music

	.byte 44,160,0,1,1,46,32,72
	.byte 224,152,0,1,1,46,172,232
	.byte 232,120,0,1,1,46,196,240
	.byte 184,88,0,16,255,47,48,120
	.byte 120,152,0,16,1,47,88,152
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 19	/ BBC - Final Barrier
	.byte 232,72,5,12,168,35,18,18

	.byte 80,136,0,1,255,48,16,80
	.byte 88,88,0,1,1,48,64,88
	.byte 148,72,0,1,255,48,104,148
	.byte 16,48,0,16,255,49,48,112
	.byte 208,96,0,16,1,49,96,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 20	/ CPC464 - thats all folks lev20
	.byte 152,104,5,216,168,36,19,19

	.byte 72,168,0,1,1,44,56,176
	.byte 120,96,17,1,1,44,8,128
	.byte 88,80,17,1,1,44,8,232
	.byte 192,120,0,16,255,50,104,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 21 / Horace
	.byte 240,80,5,8,168,7,20,116						@ music
	
	.byte 60,128,17,1,1,25,32,192
	.byte 122,96,17,1,2,25,0,192
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	
	@ 22 / BLANK
	.byte 232,168,0,6,168,1,6,37

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0


@ movie Levels
	
	@ 23 / casablanca
	.byte 184,80,6,8,168,19,22,150

	.byte 190,120,17,1,1,29,144,216
	.byte 56,120,17,1,1,29,16,120
	.byte 144,168,17,1,1,28,88,184
	.byte 144,80,1,16,255,29,48,96
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 24 / gremlins
	.byte 8,80,18,16,168,23,23,23					@ music

	.byte 190,72,17,1,255,33,112,176
	.byte 32,88,17,1,255,32,24,56
	.byte 88,168,0,1,1,32,48,144
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 25 / goonies
	.byte 232,136,15,158,48,0,24,24

	.byte 24,80,0,17,1,40,24,104
	.byte 24,168,0,1,1,39,8,128
	.byte 152,108,16,16,255,38,72,132
	.byte 184,72,0,16,255,38,72,108
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 26 / back to the future
	.byte 200,56,13,8,168,43,25,25

	.byte 128,120,17,16,1,43,72,168
	.byte 160,56,17,17,2,41,8,232
	.byte 240,112,17,1,1,42,192,232
	.byte 240,168,17,1,1,42,160,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 27 / hellraiser
	.byte 208,168,16,232,64,20,26,26

	.byte 168,120,1,16,255,30,48,168
	.byte 160,168,17,1,1,31,8,184
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 28 / ghostbusters
	.byte 112,168,14,8,168,17,21,21

	.byte 232,56,17,1,1,26,8,232
	.byte 104,120,17,1,1,27,104,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 29 / King Kong
	.byte 240,168,5,108,168,30,28,28			@ music

	.byte 40,48,17,1,1,13,0,128
	.byte 140,120,17,1,2,13,16,216
	.byte 216,144,0,1,1,13,192,240
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 30 / Terminator
	.byte 112,168,12,92,48,29,29,29

	.byte 48,88,17,1,1,35,24,80
	.byte 48,128,0,1,255,35,24,64
	.byte 128,168,17,1,2,35,8,232
	.byte 208,112,1,16,255,36,48,112
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
		
	@ 31 / Young Frankenstein
	.byte 112,96,17,100,80,39,30,30

	.byte 48,152,17,1,255,55,24,56
	.byte 48,168,17,1,255,56,24,56
	.byte 24,56,17,1,1,52,24,128
	.byte 192,168,17,1,1,51,192,232
	.byte 196,112,1,16,255,53,96,120
	.byte 156,48,17,1,1,53,152,232
	.byte 0,0,0,0,0,0,0,0
	
	@ 32 / Rocky Horror
	.byte 255,255,0,232,160,40,31,0

	.byte 16,160,17,1,1,14,0,60
	.byte 216,136,0,16,1,10,48,158
	.byte 90,144,17,1,255,14,84,120
	.byte 20,64,1,16,1,54,48,128
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 33 
	.byte 232,168,85,6,168,1,6,37

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 34
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 35
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 36
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 37
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 38
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 39
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 40
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	
	@ 41 / demo data for original level 1
	.byte 232,168,5,8,168,1,20,0
	
	.byte 60,120,17,1,1,0,60,122
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	
@------------------------------- Level names

levelNames:

@	/ Original levels

	.ascii "        HOME AT LAST??        "
	.ascii "         THE  AIRLOCK         "
	.ascii "       MUMMY!!, DADDY!!       "
	.ascii "  HALL OF THE MOUNTAIN KONG!  "
	.ascii "         BACK TO WORK         "
	.ascii "    THE DRAGON USERS BONUS    "
	.ascii "      NOT CENTRAL CAVERN      "
	.ascii "         DOWN THE PIT         "
	.ascii "       METROPOLIS BINGO       "
	.ascii "  AT THE CENTRE OF THE EARTH  "
	.ascii "        EDDIE'S FOREST        "
	.ascii "     IN A DEEP DARK HOLE!     "
	.ascii "      THE CHANNEL TUNNEL      "
	.ascii "         TOKYO UH OH!         "
	.ascii "      THE SPACE SHUTTLE!      "
	.ascii "WHERE'S THE HYPERSPACE BUTTON?"
	.ascii "       THE METEOR STORM       "
	.ascii "           THE END?           "
	.ascii "      THE FINAL? BARRIER      "
	.ascii "   THIS IS THE LAST CAVERN!   "
	
@	/ 2 mad levels based on horace?
	
	.ascii "       THE MYSTIC WOODS       "
	.ascii "   THE BLANKNESS OF BEING!!   "


@	/ The movie levels
	.ascii "  "
	.byte 34
	.ascii "I'M A DRUNKARD"
	.byte 34
	.ascii " SAID RICK  "					@ CASABLANCA

	.ascii "  BRIGHT LIGHT, BRIGHT LIGHT  "	@ GREMLINS
	.ascii " HELLO GUYS, I'M MR. PERKINS! " @ GOONIES
	.ascii "     WE DON'T NEED ROADS!     " @ BACK TO THE FUTURE
	.ascii "WE'VE SUCH SIGHTS TO SHOW YOU." @ HELLRAISER
	.ascii "        HE SLIMED ME!!        " @ GHOSTBUSTERS
	.ascii "BLONDES ARE SCARCE ROUND HERE!" @ KING KONG
	.ascii "         I'LL BE BACK         " @ TERMINATOR
	.ascii "        I HAD A HUNCH!        "	@ YOUNG FRANKENSTEIN
	.ascii " DO YOU KNOW HOW TO MADDISON? "	@ ROCKY HORROR
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "      THE CENTRAL CAVERN      "

@------------------------------- The story

	storyText:
	@ 1
	.ascii "  ON A STORMY NIGHT, WILLY"
	.ascii "FINALLY RETURNS HOME AFTER"
	.ascii "HIS RECENT EXPLOITS IN THE"
	.ascii "MINE.                     "
	.ascii "  SADLY, HE HAS LEFT HIS  "
	.ascii "KEYS SOMEWHERE IN THE MINE"
	.ascii "AND THE ONLY WAY TO ENTER "
	.ascii "HIS HOUSE IS THROUGH THE  "
	.ascii "ROOF.                     "
	.ascii "  THE APPLES LOOK SWEET,  "
	.ascii "IF ONLY IT WASN'T WITCHING"
	.ascii "HOUR...                   "
	@ 2
	.ascii "  DESCENDING THROUGH THE  "
	.ascii "CHIMNEY INTO HIS HOUSE, HE"
	.ascii "IS SUPRISED TO FIND THAT  "
	.ascii "HE IS NOT IN THE ATTIC,   "
	.ascii "BUT SOMEHOW HAS LANDED IN "
	.ascii "AN AIRLOCK THAT HE CANNOT "
	.ascii "REMEMBER BUILDING?        "
	.ascii "  MYSTIFIED, ALL HE KNOWS "
	.ascii "IS THAT HE MUST GET THE   "
	.ascii "KEYS NEEDED TO OPEN THE   "
	.ascii "CENTRAL AIRLOCK AND MAKE  "
	.ascii "HIS ESCAPE...             "
	@ 3
	.ascii "  WILLY JUMPED TROUGH THE "
	.ascii "AIRLOCK, BUT WAS THAT WHAT"
	.ascii "IT WAS?                   "
	.ascii "  HE WAS SURE THIS WAS HIS"
	.ascii "LOFT, BUT IT WAS DIFFERENT"
	.ascii "NOW? HE DID NOT REMEMBER  "
	.ascii "THE SAND, THE UNDEAD AND  "
	.ascii "THE MESS?                 "
	.ascii "  HE DECIDES THAT THE BEST"
	.ascii "IDEA IS TO GRAB THE JEWELS"
	.ascii "AND GET OUT OF THERE QUICK"
	.ascii "SHARP!                    "
	@ 4
	.ascii "  ESCAPING FROM THE ATTIC,"
	.ascii "WILLY FINDS HIMSELF IN    "
	.ascii "WHAT'S LEFT OF HIS HALLWAY"
	.ascii "  SOMEHOW, THE KONG BEAST "
	.ascii "HAS RETURNED AND STOMPED  "
	.ascii "SO HARD ON THE STAIRS THAT"
	.ascii "THEY ARE MOSTLY BROKEN AND"
	.ascii "ALSO, THE JUNGLE IS TAKING"
	.ascii "OVER, DESTROYING HIS ONCE "
	.ascii "BEAUTIFUL HOUSE.          "
	.ascii "  WILLY DECIDES TO RETURN "
	.ascii "TO THE MINES, AND ESCAPE! "
	@ 5
	.ascii "  WILLY DECIDES TO HEAD   "
	.ascii "FOR THE MINE SHAFT. MUCH  "
	.ascii "OF THE MINES ENTRANCE HAS "
	.ascii "BEEN DESTROYED,           "
	.ascii "  WILLY MUST GET THE MINE "
	.ascii "KEYS, AND WITH A BLIND    "
	.ascii "LEAP OF FAITH, JUMP INTO  "
	.ascii "THE MINESHAFT BELOW.      "
	.ascii "  TIME FOR WILLY TO GRAB  "
	.ascii "SOME GOLD AND JEWELS FROM "
	.ascii "THE MINES SO HE CAN ENJOY "
	.ascii "THAT JETSET LIFESTYLE.... "
	@ 6
	.ascii "  A DRAGON APPEARS TO HAVE"
	.ascii "OPENED A NEW ENTRYWAY INTO"
	.ascii "A TOTALLY NEW CAVERN, LIT "
	.ascii "BY A FEW SHARDS OF EVENING"
	.ascii "TWILIGHT.                 "
	.ascii "  WILLY SPOTS A SMALL,    "
	.ascii "ROUND DOOR, PERHAPS THIS  "
	.ascii "WILL LEAD HIM OUT OF THIS "
	.ascii "CAVERN AND BACK TO THE    "
	.ascii "'CENTRAL CAVERN' THAT HE  "
	.ascii "KNOWS SO WELL....         "
	.ascii "PERHAPS!                  "
	@ 7
	.ascii "  WILLY LOOKED AROUND,    "
	.ascii "'THIS SHOULD HAVE BEEN THE"
	.ascii "CENTRAL CAVERN' HE THOUGHT"
	.ascii "TO HIMSELF.               "
	.ascii "  SOMETHING VERY STRANGE  "
	.ascii "HAS HAPPENED, IT WAS LIKE "
	.ascii "HE HAD STEPPED BACK IN    "
	.ascii "TIME 26 YEARS, BUT STILL  "
	.ascii "IT WAS DIFFERENT?         "
	.ascii "  'WHAT IS THAT SWITCH?', "
	.ascii "WILLY THINKS TO HIMSELF AS"
	.ascii "VENTURES FORTH.           "
	@ 8
	.ascii "  UNLOCKING THE DOOR TO   "
	.ascii "WHERE HE ONLY HALF EXPECTS"
	.ascii "TO FIND THE COLD ROOM, THE"
	.ascii "INTREPID MINER HAS BARELY "
	.ascii "LAID HIS BOOT ON THE FLOOR"
	.ascii "WHEN THERE IS A LOUD CRACK"
	.ascii "AND THE GROUND DISAPPEARS "
	.ascii "BENEATH HIM.              "
	.ascii "  HE LANDS ON AN ESCALATOR"
	.ascii "HEADING DOWN INTO THE     "
	.ascii "GLOOMY DEPTHS BELOW.      "
	.ascii "  'WHAT NEXT?' HE THINKS. "
	@ 9
	.ascii "  ABRUPTLY THERE IS A     "
	.ascii "LIGHT AS WILLY ENTERS THE "
	.ascii "NEXT CAVERN, REVEALING A  "
	.ascii "HELLISH COLLECTION OF     "
	.ascii "SKULLS THAT MAY HAVE BEEN "
	.ascii "ANCIENT MINERS, YIKES!    "
	.ascii "  IT FEELS LIKE A COLLIERS"
	.ascii "GRAVEYARD, AND WILLY IS   "
	.ascii "SCARED THAT HE MAY END UP "
	.ascii "JOINING THE DECORATIONS..."
	.ascii "  ONLY QUICK THINKING AND "
	.ascii "SKILL WILL GET HIM OUT..  "
	@ 10
	.ascii "  GRIMLY SOLDIERING ON,   "
	.ascii "WILLY FINDS EVEN MORE     "
	.ascii "BLASPHEMIES AGAINST NATURE"
	.ascii "IN THE BOWELS OF THE EARTH"
	.ascii "  PREHISTORIC BEASTS PROWL"
	.ascii "THESE SUBTERRANEAN CAVES, "
	.ascii "AND THE SOIL ABOVE THEM   "
	.ascii "LOOKS LOOSE AND UNSTABLE. "
	.ascii "  LUCKILY, THERE APPEARS  "
	.ascii "TO BE A TYPE OF ELEVATOR  "
	.ascii "IN THE CENTRE OF THE CAVE."
	.ascii "  'UP OR DOWN?' HE THINKS."
	@ 11
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 12
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 13
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "	
	@ 14
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 15
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 16
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 17
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 18
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 19
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 20
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 21
	.ascii "  WILLY SUDDENLY BECAME   "
	.ascii "SOMEONE ELSE, 'WHAT!' HE  "
	.ascii "THOUGHT.                  "
	.ascii "  SOMEHOW HE HAD ENTERED A"
	.ascii "TIMEWARP, TIME WAS STILL, "
	.ascii "ALMOST MOTIONLESS.. HE    "
	.ascii "REMEMBERED THIS FROM THE  "
	.ascii "DISCOVERY CHANNEL, THEY   "
	.ascii "CALLED IT 'SOKURAHLAPSE', "
	.ascii "A HORRIFIC CONDITION..    "
	.ascii "  HE REALISED THAT HE WAS "
	.ascii "HORACE, AT LAST! HURRAH!  "	
	@ 22	/GB TEST
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 23	/CASABLANCA
	.ascii "  FALLING THROUGH THE VOID"
	.ascii "OF CELLULOID, WILLY VISITS"
	.ascii "THE SIGHT HE THOUGHT WAS  "
	.ascii "FAMILIAR.                 "
	.ascii "  GERMANS, GENDARME, 1942 "
	.ascii "SOMEWHERE IN MOROCCO.     "
	.ascii "IT'S ALL ABOUT GETTING ON "
	.ascii "A PLANE TO LISBON BUT HE  "
	.ascii "NEEDS TO COLLECT MONEY FOR"
	.ascii "THAT. ONLY THEN HE CAN    "
	.ascii "CALL HIMSELF 'A CITIZEN OF"
	.ascii " THE WORLD'.              "
	@ 24	/ GREMLINS
	.ascii "  80S WERE NOT OVER YET!  "
	.ascii "WILLY HAS JUST BEEN MOVED "
	.ascii "INTO ANOTHER WILD WORLD IN"
	.ascii " WHICH A COMPLEX FX SYSTEM"
	.ascii "CREATES CREATURES WITHOUT "
	.ascii "ANY NEED OF SOFTWARE. ALL "
	.ascii "DONE WITH WIRES, WILLY IS "   
	.ascii "SURE ABOUT IT. DON'T LET  "
	.ascii "THEM TOUCH THE WATER, THE "
	.ascii "VOICE OF SOME S. SPIELBERG"
	.ascii " THUNDERS THROUGH THE DARK"
	.ascii " ROOM...'USE REMOTE'...   "
	@ 25	/goonies
	.ascii "  'COME TO MAMA SLOTHY!'  "
	.ascii "WILLY HEARS A GRUBBY VOICE"
	.ascii "COMING FROM THE CELLAR OF "
	.ascii "YET ANOTHER WEIRDNESS HE  "
	.ascii "VISITS, DUE TO FLUCTUATION"
	.ascii "OF SUBDERMAL BURGERONION  "
	.ascii "OF PARTICLE DECIMATIONS BY"   
	.ascii "ELEVEN.                   "
	.ascii "AH WELL, MIGHT GO THROUGH "
	.ascii "THE EXIT AND COLLECT SOME "
	.ascii "OF THE GOLD THAT ONE-EYED "
	.ascii "WILLY IS PROTECTING?      "
	@ 26	/BACK TO THE FUTURE
	.ascii "  OHNO! JUST AS WILLY WAS "
	.ascii "ABOUT TO SMELL THE SWEET  "
	.ascii "FLOWERS OF HOME..PLUTONIUM"
	.ascii "CHARGED ROCKET OPENED YET "
	.ascii "ANOTHER DOORWAY LEADING TO"
	.ascii "THE RETRO PLACE LOST IN   "
	.ascii "1985. WALKMAN, NIKE, PINK "
	.ascii "HEADBANDS, BENETTON....   "
	.ascii "IT IS TOO MUCH FOR WILLY, "
	.ascii "HE SHIELDS HIS EYES WITH  "
	.ascii "RAYBAN SHADES AND TIGHTENS"
	.ascii "BANDANA AROUND HIS WAIST. "
	@ 27	/ HELLRAISER
	.ascii "  BY BLOODY CLIVE! WHAT IN"
	.ascii "HELL, OR WHERE IN HELL IS "
	.ascii "WILLY NOW? THE WALLS ARE  "
	.ascii "SPILLING BLOOD, HOOKS AND "
	.ascii "CHAINS FLOATING IN THE AIR"
	.ascii "REMAINS OF A TREACHEROUS  "
	.ascii "WIFE AND CRAZY BROTHER ARE"
	.ascii "BEING CHEWED UP BY RATS!  "
	.ascii "PG 13, NSFW, CONTAINS WHAT"
	.ascii "IS UNCONTAINABLE - HELL!  "
	.ascii "'NO TEARS, PLEASE. IT'S A "
	.ascii "WASTE OF GOOD SUFFERING'! "
	@ 28	/GHOSTBUSTERS
	.ascii "  ALAS, THE PLANE SWERVED "
	.ascii "THROUGH ANOTHER CELLULOID "
	.ascii "HOLE IN TIME! MADNESS! AS "
	.ascii "WILLY TRIES TO CLEAN HIS  "
	.ascii "PANTS FROM ODDLY SLIME, HE" 
	.ascii "NOTICES THAT THE PLACE IS "
	.ascii "OVERTAKEN BY THE GHASTLY  "
	.ascii "APPARITIONS! HE NEEDS TO  "
	.ascii "GET TO THAT DOOR AS SOON  "
	.ascii "AS POSSIBLE, OTHERWISE HE "
	.ascii "ENDS UP TASTING THAT ZOOL "
	.ascii "FLAVORED MARSHMALLOW!     "
	@ 29	/ KING KONG
	.ascii "KING KONG                 "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 30	/ TERMINATOR
	.ascii "Terminator                "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 31
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 32	/ ROCKY HORROR
	.ascii "  SOMEHOW, WILLY KNEW THAT"
	.ascii "THIS CELLULOID NIGHTMARE  "
	.ascii "WAS COMING TO AN END.     "
	.ascii "  HE REALLY HAD SEEN IT   "
	.ascii "ALL ON HIS TRAVELS. SUCH  "
	.ascii "SIGHTS, SUCH JOURNEYS,    "
	.ascii "SUCH, ER.. THINGS.        "
	.ascii "  HE KNEW THAT ALL HE HAD "
	.ascii "TO DO WAS COLLECT THE     "
	.ascii "LIGHTNING GUNS, BUT...    "
	.ascii "THEN WHAT? WILLY COULD SEE"
	.ascii "NO EXIT THIS TIME......   "
	@ 33
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 34
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "	
	@ 35
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 36
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 37
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 38
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 39
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 41
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 41
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "THIS IS JUST FOR FUN!!!!!!"
	.ascii "                          "
	.ascii "MAY NOT BE USED IN FINAL!!"
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "	

@------------------------------- Level info	

levelInfo: @XXXXXXXXXXXXXXXXXXXXXXXXXX
	.ascii "    LEVEL 17 - ORIC 1985    "
	.ascii "    LEVEL 20 - ORIC 1985    "
	.ascii "    LEVEL XX - GBA  2002    "
	.ascii "    LEVEL 24 - ORIC 1985    "
	.ascii "    LEVEL 18 - ORIC 1985    "
	.ascii "  LEVEL 21 - DRAGON32 1983  "
	.ascii "    LEVEL 28 - ORIC 1985    "
	.ascii "    LEVEL 19 - ORIC 1985    "
	.ascii "    LEVEL XX - GBA  2002    "
	.ascii "    LEVEL 21 - ORIC 1983    "
	.ascii "  LEVEL 22-ARCHIMEDES 19XX  "
	.ascii "    LEVEL 26 - ORIC 1985    "	
	.ascii "    LEVEL 27 - ORIC 1985    "
	.ascii "    LEVEL XX - GBA  2002    "
	.ascii "    LEVEL 23 - ORIC 1985    "
	.ascii "  I HAVE COCKED UP HERE ??  "
	.ascii "    LEVEL XX - BBC  198X    "
	.ascii "  LEVEL 22 - DRAGON32 1983  "
	.ascii "    LEVEL XX - BBC  198X    "
	.ascii "  LEVEL 20 - AMSTRAD  198X  "
	
	@ Bonus?
	.ascii "   LEVEL 01 - PSION3 1995   "
	.ascii "BLANKBLANKBLANKBLANKBLANKY  "
	
	@ Movies
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "     SPACE FRACTAL 2009     "
	.ascii "   ORIGINAL - FLASH  2009   "
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "   ORIGINAL - FLASH  2009   "
	.ascii "     SPACE FRACTAL 2009     "
	.ascii "ORIGNAL LEVEL - SVERX 2009  "
	.ascii "   ORIGINAL - FLASH  2009   "
	
	@ Anything?
	.ascii "                            "
	.ascii "                            "
	.ascii "                            "
	.ascii "                            "
	.ascii "                            "
	.ascii "                            "
	.ascii "                            "
	.ascii "                            "
	.ascii "  LEVEL 01 - SPECTRUM 1983  "

	.end