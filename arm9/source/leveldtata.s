
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
@						(16= horror, 17=frankenstein, 18=Gremlins, 19=kingkong
@	high 1 = 0-1 = Wraparound level? 0=no / 1=yes
@ 4,5 willies start position
@ 6 =willies init dir (0=l 1=r) LOW BYTE / HIGH 7=Special effect (ie. rain) (0=none)
@						1=rain, 2=stars, 3=Leaves, 4=Glint 5=Drip 6=eyes 7=flies
@						8=mallow, 9=twinkle, 10=blood, 11=bulb flash, 12=blinks
@						13=animate killer blocks, 14=sparks 15=kong, 16=meteor storm
@						17=forcefield, 18=anton, 19=lift,20=rocky, 21=BTTF flag, 22=causeway
@						23=snow
@ 7 =background number (0-?)
@ 8 =door bank number (0-?)

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
	
	@ 3 / end of the world
	.byte 232,168,3,8,72,25,2,22

	.byte 8,168,17,17,1,16,8,216
	.byte 8,128,17,1,1,20,8,144
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	

	@ 4 / Oric - level 24 - Hall of the mountain kong
	.byte 232,168,8,7,168,7,3,3

	.byte 120,56,1,16,1,18,56,104
	.byte 50,142,17,17,255,6,8,56
	.byte 64,168,17,1,1,21,16,72
	.byte 152,168,17,1,1,21,96,160
	.byte 232,168,0,1,1,21,168,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 5 / Oric - level 18 - back to work
	.byte 232,168,4,8,168,11,4,0

	.byte 104,168,17,1,255,0,104,144
	.byte 32,168,17,1,1,0,18,72
	.byte 168,72,0,1,255,15,24,216
	.byte 232,96,1,16,1,9,72,150
	.byte 152,128,17,3,255,15,152,208
	.byte 96,48,17,1,255,19,8,128
	.byte 144,48,17,1,1,19,144,208
	
	@ 6 / Dragon - Level 21 - The dragon users bonus
	.byte 232,136,11,8,168,13,5,4

	.byte 172,152,17,17,1,6,148,196
	.byte 48,144,17,1,1,3,32,88
	.byte 80,96,17,1,1,3,80,136
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 7 / Oric - level 28 - not the central cavern
	.byte 232,168,5,8,168,1,6,5

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

	.byte 176,108,1,16,2,66,64,160
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
	
	@ 13 / Oric - level 27 - the channel tunnel	
	.byte 232,104,22,8,136,27,12,1

	.byte 136,152,17,1,1,37,136,222
	.byte 80,128,17,1,1,37,80,144
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 14  / GBA - Tokyo Uh oh						
	.byte 232,80,30,8,168,1,13,13

	.byte 32,72,1,16,255,2,72,168
	.byte 104,128,0,16,1,2,72,128
	.byte 142,72,1,16,1,2,72,168
	.byte 184,152,0,16,255,7,72,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 15 / Oric - Space Shuttle						
	.byte 232,112,21,104,80,1,14,14

	.byte 48,104,1,16,255,5,104,168
	.byte 200,64,1,16,255,4,64,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 16 / Oric - Wheres the hyperspace button
	.byte 162,168,2,8,96,5,15,15

	.byte 24,96,17,1,1,11,8,112
	.byte 112,120,17,1,1,11,112,176
	.byte 168,120,17,1,1,11,168,232
	.byte 16,152,17,1,1,8,8,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 17 / BBC - Meteor Storm
	.byte 120,96,20,6,168,33,16,16				

	.byte 56,168,17,1,1,45,18,56
	.byte 222,168,17,1,1,45,184,222
	.byte 152,152,17,1,1,45,72,152
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 18	/ Dragon32 - The end
	.byte 232,64,151,120,48,0,17,17					

	.byte 44,160,0,1,1,46,32,72
	.byte 224,152,0,1,1,46,172,232
	.byte 232,120,0,1,1,46,196,240
	.byte 184,88,0,16,255,47,48,120
	.byte 120,152,0,16,1,47,88,152
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 19	/ BBC - Final Barrier
	.byte 232,72,29,7,168,35,18,18

	.byte 80,136,0,1,255,48,16,80
	.byte 64,88,0,1,1,48,64,96
	.byte 148,72,0,1,255,48,102,148
	.byte 16,48,0,16,1,49,48,110
	.byte 208,96,0,16,1,49,96,166
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 20	/ CPC464 - thats all folks lev20
	.byte 152,104,31,216,168,36,19,19

	.byte 72,168,0,1,1,44,56,176
	.byte 120,96,17,1,1,44,8,128
	.byte 88,80,17,1,1,44,8,234
	.byte 192,120,0,16,1,50,104,168
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 21 / Horace
	.byte 240,80,5,8,168,7,20,20						@ music		NEED TO CORRECT!!
	
	.byte 60,128,17,1,1,25,32,192
	.byte 122,96,17,1,2,25,0,192
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	
	@ 22 / Blagger
	.byte 208,96,0,192,56,0,6,41

	.byte 104,168,17,1,1,57,88,174
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

@ movie Levels
	
	@ 23 / casablanca
	.byte 184,80,6,8,168,19,22,22

	.byte 190,120,17,1,1,29,144,216
	.byte 56,120,17,1,1,29,16,120
	.byte 144,168,17,1,1,28,88,184
	.byte 144,80,1,16,255,29,48,96
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 24 / gremlins
	.byte 8,80,18,16,168,23,23,23					

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
	.byte 240,168,19,108,168,30,28,28			

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
	.byte 255,255,24,232,160,40,31,0	@ no exit as uses water!

	.byte 16,160,17,1,1,14,0,60
	.byte 216,136,0,16,1,10,48,158
	.byte 90,144,17,1,255,14,84,120
	.byte 20,64,1,16,1,54,48,128
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
@ / MORE bonus levels
	
	@ 33 / cheese plant
	.byte 8,64,25,212,168,0,6,31

	.byte 32,168,17,1,1,61,32,160
	.byte 152,104,0,1,1,61,64,200
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 34 / The dodgy mine shaft
	.byte 168,64,25,16,168,1,6,31

	.byte 80,168,17,17,1,62,80,158
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 35 / the long drop thing
	.byte 152,144,25,8,168,1,6,34

	.byte 120,168,17,1,255,63,120,212
	.byte 152,112,17,1,1,63,152,220
	.byte 32,136,17,1,1,63,8,62
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 36 / bouncy-bouncy
	.byte 240,96,25,8,88,1,6,32

	.byte 96,168,0,17,2,59,8,232
	.byte 112,128,17,17,1,60,92,142
	.byte 112,88,17,17,1,58,56,172
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 37 / the rocky outcrop
	.byte 112,152,25,8,168,1,6,32

	.byte 40,152,0,17,1,64,40,94-16
	.byte 56,152,0,17,1,65,56,110-16
	.byte 160,96,17,1,1,61,160,212
	.byte 160,168,17,1,1,61,160,232
	.byte 88,48,17,16,1,12,48,120
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 38 / bottom of the mine shaft
	.byte 8,168,25,8,88,1,6,33

	.byte 72,88,17,1,1,61,32,112
	.byte 196,152,17,1,1,61,192,232
	.byte 8,108,17,16,2,12,108,152
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 39	/ cosmic causeway
	.byte 240,136,2,8,168,45,38,11

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 40	/ greatest logo
	.byte 232,120,0,16,120,1,6,41

	.byte 52,52,17,1,1,68,52,204
	.byte 102,81,17,1,1,69,52,204
	.byte 152,112,17,1,1,67,52,204
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	
	@ 41 / the central cavern
	.byte 232,168,5,8,168,1,40,0
	
	.byte 60,120,17,1,1,0,60,122
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 42 / the final conflict
	.byte 232,64,0,16,168,1,6,41

	.byte 16,120,17,1,1,70,16,96
	.byte 128,120,17,1,1,71,128,232
	.byte 104,144,17,1,1,70,104,232
	.byte 80,168,17,1,1,71,16,142
	.byte 142,168,17,1,1,70,142,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	
	@ 43 / The Vat
	.byte 120,168,5,14,168,1,6,42

	.byte 136,168,17,1,1,72,136,231
	.byte 120,72,17,1,1,73,120,231
	.byte 82,128,0,1,1,74,8,82
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	

	@ 44  mutant telephones
	.byte 8,72,5,21,72,1,6,43

	.byte 24,96,1,16,255,75,96,160
	.byte 96,64,1,16,1,76,64,120
	.byte 168,112,1,16,255,75,112,160
	.byte 208,110,0,16,2,77,64,160
	.byte 120,88,17,1,1,78,120,192			@ ok
	.byte 110,120,17,1,255,78,112,148		@ err
	.byte 120,168,0,1,1,79,40,152			@ ok
	@ 45 warehouse
	.byte 232,72,5,7,88,1,6,44

	.byte 24,132,17,0,1,81,128,164			@ ok
	.byte 80,124,0,0,254,80,68,160			@ ok
	.byte 152,112,17,0,255,82,64,128		@ ok
	.byte 216,68,17,0,2,81,68,156			@ ok
	.byte 40,168,17,1,255,83,40,64			@ ok
	.byte 96,168,17,1,1,84,96,200			@ ok
	.byte 0,0,0,0,0,0,0,0	
	
	@ 46 / GBA - Level xx - Mummy Daddy
	.byte 224,80,3,218,168,8,45,2
	
	.byte 104,108,1,16,1,16,108,168
	.byte 56,64,1,16,255,16,64,112
	.byte 120,112,1,16,255,16,64,112
	.byte 232,48,0,1,255,20,208,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 47 its christmas charley brown
	.byTe 152,112,128+33,240,56,46,46,46

	.byte 136,136,1,0,255,85,80,136
	.byte 32,56,17,1,1,86,32,216
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	@ 48 / ENDORIAN FOREST
	.byte 96,168,5,8,96,1,6,47

	.byte 68,120,17,1,1,87,68,116
	.byte 92,144,17,1,255,87,60,116
	.byte 132,104,17,1,1,89,132,172
	.byte 60,168,17,1,1,88,28,212
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	@ 49 / JUMP FOR JOY
	.byte 0,72,31,8,48,3,48,7

	.byte 120,80,1,0,2,4,80,176
	.byte 136,176,1,0,1,4,80,176
	.byte 60,168,17,1,1,3,0,104
	.byte 180,168,17,1,255,3,180,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	@ 50 / FINAL BARRIER
	.byte 152,104,0,220,168,0,49,0

	.byte 192,108,17,0,255,12,108,168
	.byte 56,168,17,1,1,19,56,176
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
	.ascii "     THE END OF THE WORLD     "
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
	.ascii "  BLAGGER COULD SMELL A RATT  "


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
	.ascii " DO YOU KNOW HOW TO MADISON?? "	@ ROCKY HORROR
	
@ bonus levels (from 33)
	.ascii "         CHEESE-PLANT         "
	.ascii "    THE DODGY MINE SHAFT!     "
	.ascii "         THE BIG DROP         "
	.ascii "        BOUNCY-BOUNCY!        "
	.ascii "      THE ROCKY OUTCROP.      "
	.ascii "   BOTTOM OF THE MINE SHAFT   "
	.ascii "       COSMIC  CAUSEWAY       "
	.ascii "     THE LOGO OF THE YEAR     "
	.ascii "      THE CENTRAL CAVERN      "

	.ascii "      THE FINAL CONFLICT      "
	.ascii "           THE VAT!           "
	.ascii "   ATTACK OF THE MUTANT...?   "
	.ascii "        THE WAREHOUSE.        "
	.ascii "       MUMMY!!, DADDY!!       "
	.ascii "IT'S CHRISTMAS, CHARLIE BROWN!"
	.ascii "       ENDORIAN  FOREST       "
	.ascii "         JUMP FOR JOY         "
	.ascii "      THE FINAL BARRIER.      "

@------------------------------- The story

	storyText:
	@ 1
	.ascii "WILLY FINALLY EMERGES FROM"
	.ascii "THE MINE ON A COLD, WINTRY"
	.ascii "EVENING TO FIND HIS FRONT "
	.ascii "GARDEN FULL OF WHAT APPEAR"
	.ascii "TO BE TRICK-OR-TREATERS.  "
	.ascii "                          "
	.ascii "HE DISCOVERS THAT HE SEEMS"
	.ascii "TO HAVE MISLAID HIS HOUSE "
	.ascii "KEYS SOMEWHERE IN THE MINE"
	.ascii "AND REALISES HE'S GOING TO"
	.ascii "HAVE TO BREAK IN THROUGH  "
	.ascii "THE THATCHED ROOF...      "
	@ 2
	.ascii "STAMPING DOWN THROUGH THE "
	.ascii "ROOF, WILLY SAFELY REACHES"
	.ascii "HIS ATTIC, BUT THE LOFT   "
	.ascii "TRAPDOOR IS STILL LOCKED. "
	.ascii "                          "
	.ascii "HE CAN SEE HIS SPARE KEYS "
	.ascii "SCATTERED AROUND, BUT THE "
	.ascii "STORM OUTSIDE SEEMS TO BE "
	.ascii "SUCKING AWAY ALL THE AIR  "
	.ascii "AND HE REALISES HE'LL NEED"
	.ascii "PROTECTION IF HE'S GOING  "
	.ascii "TO RETRIEVE THEM SAFELY..."
	@ 3
	.ascii "DROPPING ONTO THE LANDING,"
	.ascii "WILLY FINDS THE TOP FLOOR "
	.ascii "OF HIS HOUSE IN RUINS WITH"
	.ascii "ONLY FRAGMENTS OF LANDING "
	.ascii "AND STAIRS STILL INTACT.  "
	.ascii "                          "
	.ascii "HUGE DRIFTS OF SAWDUST AND"
	.ascii "DEBRIS ARE EVERYWHERE. THE"
	.ascii "ENTIRE FLOOR SEEMS TO HAVE"
	.ascii "DISINTEGRATED, AND ANOTHER"
	.ascii "FANCY-DRESS VICTIM BLOCKS "
	.ascii "THE EXIT TO THE HALLWAY..."
	@ 4
	.ascii "ENTERING WHAT USED TO BE  "
	.ascii "HIS BACK HALLWAY, WILLY IS"
	.ascii "SHOCKED TO SEE THAT IT HAS"
	.ascii "BEEN COMPLETELY DESTROYED,"
	.ascii "THE DOOR NOW LEADING INTO "
	.ascii "HIS ONCE-TRANQUIL GARDEN. "
	.ascii "                          "
	.ascii "GLANCING UP INTO THE TREES"
	.ascii "HE SEES THE CREATURE WHICH"
	.ascii "IS SURELY RESPONSIBLE, AND"
	.ascii "VOWS TO DEFEAT THE MONSTER"
	.ascii "FOR A THIRD TIME...       "
	@ 5
	.ascii "HAVING SENT THE KONG BEAST"
	.ascii "TO ITS DOOM YET AGAIN, OUR"
	.ascii "HERO WALKS OUT THROUGH THE"
	.ascii "GARDEN GATE AND COMES TO A"
	.ascii "DECISION. THE ONLY WAY TO "
	.ascii "GET TO THE BOTTOM OF THIS "
	.ascii "IS TO RETURN TO THE MINE. "
	.ascii "                          "
	.ascii "ENTERING THE COLLIERY, HE "
	.ascii "ISN'T AT ALL SURPRISED TO "
	.ascii "FIND DEADLY ROBOTS BETWEEN"
	.ascii "HIM AND THE LIFT SHAFT... "
	@ 6
	.ascii "THE ELEVATOR DOOR OPENS TO"
	.ascii "RELEASE WILLY NOT INTO THE"
	.ascii "OLD CENTRAL CAVERN, BUT TO"
	.ascii "AN AREA WHICH LOOKS AS IF "
	.ascii "IT'S BEEN NEWLY EXCAVATED."
	.ascii "                          "
	.ascii "THOUGH DISORIENTATED, THE "
	.ascii "BRAVE MINER IS SURE THAT A"
	.ascii "DOORWAY JUST VISIBLE AT   "
	.ascii "THE CAVE'S OPPOSITE SIDE  "
	.ascii "OUGHT TO LEAD HIM BACK TO "
	.ascii "MORE FAMILIAR TERRITORY..."
	@ 7
	.ascii "WILLY IS BRIEFLY DELIGHTED"
	.ascii "TO BE PROVED RIGHT, BUT ON"
	.ascii "CLOSER EXAMINATION HE SEES"
	.ascii "THAT THIS 'CENTRAL CAVERN'"
	.ascii "ISN'T THE ONE HE EXPECTED."
	.ascii "                          "
	.ascii "IF THIS IS THE OLD CAVE AT"
	.ascii "ALL, THERE HAVE BEEN A FEW"
	.ascii "SUBTLE ALTERATIONS SINCE  "
	.ascii "WILLY WAS LAST HERE, AND  "
	.ascii "THE UNMARKED SWITCH IN THE"
	.ascii "CEILING IS SUSPICIOUS...  "
	@ 8
	.ascii "SURE ENOUGH, THE EXIT DOES"
	.ascii "NOT LEAD TO THE COLD ROOM."
	.ascii "WILLY HAS BARELY STEPPED  "
	.ascii "THROUGH THE DOOR WHEN THE "
	.ascii "THE GROUND UNDER HIM GIVES"
	.ascii "WAY WITH A LOUD CRACK.    "
	.ascii "                          "
	.ascii "HE FINDS HIMSELF STUMBLING"
	.ascii "HELPLESSLY DOWN A STAIRWAY"
	.ascii "MADE SLIPPERY WITH MUD AND"
	.ascii "DEBRIS, AND REALISES THAT "
	.ascii "THERE'S NO WAY BACK UP... "
	@ 9
	.ascii "AS HE ENTERS THE NEXT ROOM"
	.ascii "A CHILL RUNS UP THE LENGTH"
	.ascii "OF WILLY'S SPINE. IT SEEMS"
	.ascii "HE'S NOT THE FIRST TO HAVE"
	.ascii "TO HAVE COME THIS WAY, AND"
	.ascii "IT LOOKS AS IF MOST OF THE"
	.ascii "PREVIOUS VISITORS DIDN'T  "
	.ascii "GET OUT IN ONE PIECE.     "
	.ascii "                          "
	.ascii "THE UNQUIET SPIRITS OF THE"
	.ascii "DEAD HAUNT HIS EVERY GRIM "
	.ascii "STEP TOWARDS THE EXIT...  "
	@ 10
	.ascii "THE DOOR OPENS INTO A HUGE"
	.ascii "SPACE HOLLOWED OUT OF THE "
	.ascii "VERY BOWELS OF THE EARTH. "
	.ascii "GODLESS MONSTERS WITH TINY"
	.ascii "SIGHTLESS EYES PROWL THESE"
	.ascii "SUBTERRANEAN FISSURES.    "
	.ascii "                          "
	.ascii "IT LOOKS LIKE AN ELEVATOR "
	.ascii "OF SOME SORT HAS COME TO  "
	.ascii "REST ON THE LOOSE SOIL AT "
	.ascii "THE CENTRE OF THE CAVERN. "
	.ascii "WILLY DARES TO HOPE...    "
	@ 11
	.ascii "MIRACULOUSLY, THE ELEVATOR"
	.ascii "GROANS INTO LIFE AS WILLY "
	.ascii "PRESSES THE BUTTON, AND IT"
	.ascii "SPEEDS UPWARDS, EVENTUALLY"
	.ascii "COMING TO REST IN A SMALL,"
	.ascii "UNMARKED SHED IN A FOREST."
	.ascii "                          "
	.ascii "OVERJOYED TO BREATHE FRESH"
	.ascii "AIR ONCE MORE, WILLY GRABS"
	.ascii "SOME FOOD BEFORE SPOTTING "
	.ascii "A TREEHUT AND DECIDING TO "
	.ascii "SEE WHAT IT MIGHT HIDE... "
	@ 12
	.ascii "TO WILLY'S HORROR, THE HUT"
	.ascii "IS IN FACT THE CABIN OF A "
	.ascii "CABLE-CAR, THE WIRE HIDDEN"
	.ascii "BY THE DARK. THE INSTANT  "
	.ascii "HE CLOSES THE DOOR BEHIND "
	.ascii "HIM IT PLUNGES DOWNWARDS  "
	.ascii "AT A TERRIFYING SPEED.    "
	.ascii "                          "
	.ascii "WHEN IT FINALLY STOPS, HE "
	.ascii "IS CRUSHED TO FIND HIMSELF"
	.ascii "ONCE MORE UNDERGROUND, AND"
	.ascii "IN PITCH BLACKNESS...     "
	@ 13
	.ascii "MAKING HIS WAY GINGERLY UP"
	.ascii "THE UNLIT STAIRWAY OF THE "
	.ascii "CABLE-CAR STATION, WILLY  "
	.ascii "EMERGES INTO WHAT APPEAR  "
	.ascii "TO BE NEW TUNNEL WORKINGS."
	.ascii "                          "
	.ascii "THE SOFT EARTH CONSTANTLY "
	.ascii "COLLAPSES BENEATH HIS FEET"
	.ascii "AS HE TRIES TO GATHER KEYS"
	.ascii "AND DODGE ROBOTS TO REACH "
	.ascii "A DOOR FROM BEHIND WHICH  "
	.ascii "DAYLIGHT SEEMS TO SHINE..."
	@ 14
	.ascii "THERE IS, INDEED, LIGHT AT"
	.ascii "THE END OF THE TUNNEL, BUT"
	.ascii "IT LEADS ONLY TO A BLEAK, "
	.ascii "DILAPIDATED AND ABANDONED "
	.ascii "SECTOR OF AN UNKNOWN CITY."
	.ascii "                          "
	.ascii "WHAT CAN HAVE HAPPENED IN "
	.ascii "THE FEW SHORT MONTHS WILLY"
	.ascii "WAS IN THE MINES? THE ONLY"
	.ascii "CLUE IS A STRANGE VEHICLE "
	.ascii "PARKED ATOP SOME RUBBLE.  "
	.ascii "WILLY CLIMBS TOWARDS IT..."
	@ 15
	.ascii "HIS WORST FEARS CONFIRMED,"
	.ascii "WILLY FINDS HIMSELF INSIDE"
	.ascii "SOME SORT OF ALIEN CRAFT. "
	.ascii "                          "
	.ascii "AS HE SEARCHES FOR A SAFE "
	.ascii "PLACE TO CONCEAL HIMSELF  "
	.ascii "FROM THE EXTRA-TERRESTRIAL"
	.ascii "BEINGS PATROLLING THE SHIP"
	.ascii "HE MANAGES TO DECIPHER THE"
	.ascii "MARKINGS ON SOME SWITCHES,"
	.ascii "AND OPENS THE SECRET PANEL"
	.ascii "LEADING TO AN AIRLOCK...  "
	@ 16
	.ascii "FEELING THE SHUTTLE TAKING"
	.ascii "OFF, WILLY DONS A GRAVITY "
	.ascii "SUIT HE FINDS HANGING IN  "
	.ascii "THE AIRLOCK, AND STEPS OUT"
	.ascii "INTO AN INCREDIBLE GLASS- "
	.ascii "PANELLED VIEWING DECK.    "
	.ascii "                          "
	.ascii "ONE ALIEN IS ENJOYING THE "
	.ascii "SCENERY, SO WILLY USES THE"
	.ascii "COVER OF SOME MAINTENANCE "
	.ascii "DROIDS TO HOP OVER SWIFTLY"
	.ascii "AND UNSEEN TO THE EXIT... "
	@ 17
	.ascii "AS THE SHUTTLE LANDS ON AN"
	.ascii "ALIEN WORLD, WILLY JUMPS  "
	.ascii "FROM THE HATCH AND PONDERS"
	.ascii "THAT ALIEN WEATHER IS MUCH"
	.ascii "LIKE THAT ON EARTH, EXCEPT"
	.ascii "WITH MORE METEORS.        "
	.ascii "                          "
	.ascii "THE ONLY PLACE TO GO IS A "
	.ascii "DOMED STRUCTURE WHOSE DOOR"
	.ascii "IS PROTECTED BY LASERS AND"
	.ascii "ROBOT GUARDS. WILLY SIGHS "
	.ascii "AND STEPS INTO THE RAIN..."
	@ 18
	.ascii "ON ENTERING THE DOMED HALL"
	.ascii "WILLY ENCOUNTERS ITS FINAL"
	.ascii "SECURITY MEASURE, IN THE  "
	.ascii "ODDLY FAMILIAR FORM OF A  "
	.ascii "COLLAPSING FLOOR.         "
	.ascii "                          "
	.ascii "DEFTLY SKIPPING OFF IT, HE"
	.ascii "OBSERVES THAT THE BUILDING"
	.ascii "IS ACTUALLY AN ENTRANCE TO"
	.ascii "A HUGE TUNNEL, WHICH LOOKS"
	.ascii "RATHER LIKE ONE HE'S SEEN "
	.ascii "SOMEWHERE BEFORE...       "
	@ 19
	.ascii "THE TUNNEL LEADS WILLY TO "
	.ascii "A CAVERN, WHERE THE PLUCKY"
	.ascii "PROSPECTOR SUDDENLY GRASPS"
	.ascii "THE MEANING OF ALL THESE  "
	.ascii "COINCIDENCES. THE ALIENS  "
	.ascii "ARE COLONISING THE EARTH! "
	.ascii "                          "
	.ascii "THEIR METEOR-RAVAGED WORLD"
	.ascii "CAN NO LONGER SUSTAIN THEM"
	.ascii "AND THEY'RE BURROWING INTO"
	.ascii "OURS! WILLY MUST GET HOME "
	.ascii "TO WARN MANKIND, AND FAST!"
	@ 20
	.ascii "RE-EMERGING ABOVE GROUND, "
	.ascii "WILLY IS STUNNED TO ARRIVE"
	.ascii "AT A COTTAGE JUST LIKE HIS"
	.ascii "OWN. THE ALIENS MUST HAVE "
	.ascii "BUILT A TRANS-DIMENSIONAL "
	.ascii "WARP GATE BETWEEN THE TWO!"
	.ascii "                          "
	.ascii "COULD IT BE THAT IF WILLY "
	.ascii "BREAKS IN THROUGH THE ROOF"
	.ascii "ONCE AGAIN, HE'LL BE ABLE "
	.ascii "TO GET BACK HOME AND SAVE "
	.ascii "THE EARTH?    (YES. - ED) "

	@ the first 2 bonus levels

	@ 21	/ HORACE - bonus 1
	.ascii "PSION'S HUNGRY HORACE WAS,"
	.ascii "ALONGSIDE MINER WILLY, ONE"
	.ascii "OF THE ZX SPECTRUM'S MOST "
	.ascii "FAMOUS GAMING CHARACTERS. "
	.ascii "                          "
	.ascii "HORACE IN THE MYSTIC WOODS"
	.ascii "WAS A 1995 RELEASE FOR THE"
	.ascii "COMPANY'S SERIES3 PERSONAL"
	.ascii "ORGANISER. WIDELY REGARDED"
	.ascii "AS THE 'LOST' HORACE GAME,"
	.ascii "IT'S CURRENTLY THE SUBJECT"
	.ascii "OF TWO DIFFERENT REMAKES. "	
	@ 22	/ BLAGGER - bonus 2
	.ascii "CREATED BY LEGENDARY CBM64"
	.ascii "AUTHOR TONY CROWTHER, THE "
	.ascii "'BLAGGER' SERIES OF GAMES "
	.ascii "WAS ARGUABLY MANIC MINER'S"
	.ascii "MAIN CONTEMPORARY RIVAL.  "
	.ascii "                          "
	.ascii "WITH A NEAR-IDENTICAL SET "
	.ascii "OF GAMEPLAY ELEMENTS, AND "
	.ascii "MANY WELL-DESIGNED LEVELS,"
	.ascii "THE FIRST 'BLAGGER' TITLE "
	.ascii "WAS BELOVED BY C64 OWNERS "
	.ascii "SHORT OF GOOD PLATFORMERS."
	
	@ movie levels
	
	@ 23	/CASABLANCA
	.ascii "WILLY WAS PUZZLED. HE WAS "
	.ascii "USED TO FINDING HIMSELF IN"
	.ascii "UNEXPECTED PLACES OF LATE,"
	.ascii "BUT TRAVELLING IN TIME WAS"
	.ascii "A NEW EXPERIENCE.         "
	.ascii "                          "
	.ascii "YET HERE HE WAS, FOR SOME "
	.ascii "REASON DRESSED AS HUMPHREY"
	.ascii "BOGART IN WHAT APPEARED TO"
	.ascii "BE THE EARLY 1930s. WILLY "
	.ascii "DECIDED TO COLLECT THE AIR"
	.ascii "FARE AND GET OUT OF THERE."
	@ 24	/ GREMLINS
	.ascii "WALKING THROUGH THE DOOR, "
	.ascii "WILLY WAS SURPRISED NOT TO"
	.ascii "FIND THE PROMISED AIRPORT "
	.ascii "ON THE OTHER SIDE, BUT THE"
	.ascii "SPACIOUS LIVING ROOM OF A "
	.ascii "LARGE MODERN HOUSE.       "
	.ascii "                          "
	.ascii "JUDGING BY THE ELECTRONICS"
	.ascii "ON DISPLAY IT WAS SOMETIME"
	.ascii "AROUND THE 1980S, BUT WHAT"
	.ascii "ON EARTH (OR WAS IT?) WERE"
	.ascii "THESE FURRY CREATURES?    "
	@ 25	/goonies
	.ascii "WILLY MADE HIS ESCAPE AND "
	.ascii "FOUND HIMSELF IN THE DARK "
	.ascii "BACK GARDEN OF THE HOUSE. "
	.ascii "AT LEAST, HE OBSERVED WITH"
	.ascii "SOME RELIEF, HE SEEMED NOT"
	.ascii "TO HAVE LEAPT BACKWARDS OR"
	.ascii "FORWARDS IN TIME AGAIN.   "
	.ascii "                          "
	.ascii "IF HE COULD JUST DODGE THE"
	.ascii "ODDLY PIRATICAL RESIDENTS,"
	.ascii "PERHAPS HE COULD CAST SOME"
	.ascii "LIGHT ON THE WAY OUT?     "
	@ 26	/BACK TO THE FUTURE
	.ascii "SOME AWFUL, HORRIBLE SONG "
	.ascii "WAS BLARING FROM A WINDOW "
	.ascii "OF A NEARBY HOUSE AS WILLY"
	.ascii "EMERGED FROM THE GARDEN TO"
	.ascii "ARRIVE IN A LARGE STREET. "
	.ascii "                          "
	.ascii "SPYING AN EMPTY SPORTS CAR"
	.ascii "WITH ITS DOORS OPEN ON THE"
	.ascii "ROOF OF A MULTI-STOREY CAR"
	.ascii "PARK ON THE OTHER SIDE OF "
	.ascii "THE STREET, WILLY DECIDED "
	.ascii "TO STEAL IT AND DRIVE OFF."
	@ 27	/ HELLRAISER
	.ascii "AS THE CAR REACHED 88 MPH,"
	.ascii "THERE WAS A FLASH OF LIGHT"
	.ascii "AND ON REGAINING HIS SIGHT"
	.ascii "WILLY FOUND HE HAD SOMEHOW"
	.ascii "BEEN TRANSPORTED INTO SOME"
	.ascii "SORT OF SLAUGHTERHOUSE.   "
	.ascii "                          "
	.ascii "THERE WAS BLOOD EVERYWHERE"
	.ascii "HE LOOKED. IT DRIPPED FROM"
	.ascii "MEATHOOKS HANGING FROM THE"
	.ascii "WALLS, AND WILLY COULD SEE"
	.ascii "THIS WAS NOT A SAFE PLACE."
	@ 28	/GHOSTBUSTERS
	.ascii "CLOSING THE SLAUGHTERHOUSE"
	.ascii "DOOR WITH A COLD SHUDDER, "
	.ascii "WILLY STEPPED BACK OUTSIDE"
	.ascii "INTO AN ALLEYWAY DOMINATED"
	.ascii "BY THE VIEW OF A GIGANTIC "
	.ascii "ADVERTISING HOARDING.     "
	.ascii "                          "
	.ascii "HE NEEDED TRANSPORT AGAIN,"
	.ascii "AND SCALING A WALL TO GET "
	.ascii "A BETTER VIEW, HE SPOTTED "
	.ascii "AN UNGUARDED STATION WAGON"
	.ascii "IN A NEARBY CAR PORT.     "
	@ 29	/ KING KONG
	.ascii "SPEEDING OFF IN THE ODDLY-"
	.ascii "MARKED CAR, WILLY CAME TO "
	.ascii "A CONSTRUCTION SITE BESIDE"
	.ascii "A WIDE BOULEVARD, AND WAS "
	.ascii "STUNNED AT WHAT HE SAW.   "
	.ascii "                          "
	.ascii "PERCHED ATOP A DOME IN THE"
	.ascii "DISTANCE WAS WHAT APPEARED"
	.ascii "UNMISTAKEABLY TO BE... THE"
	.ascii "KONG BEAST! WHAT WAS GOING"
	.ascii "ON? AND WHAT HAD HAPPENED "
	.ascii "TO ALL THE STREETLIGHTS?  "
	@ 30	/ TERMINATOR
	.ascii "DODGING KONG AND UNLOCKING"
	.ascii "WHAT HE HAD THOUGHT TO BE "
	.ascii "THE OFFICE OF THE BUILDING"
	.ascii "SITE, WILLY STUMBLED INTO "
	.ascii "SOME KIND OF FACTORY AREA."
	.ascii "                          "
	.ascii "IT SEEMED THAT HE'D AGAIN "
	.ascii "SOMEHOW JUMPED FORWARDS IN"
	.ascii "TIME, BECAUSE THE FACTORY "
	.ascii "WAS INHABITED BY SOME VERY"
	.ascii "LIFELIKE HUMANOID ROBOTS. "
	.ascii "COULD HE SHUT THEM DOWN?  "
	@ 31 	/ YOUNG FRANK
	.ascii "PASSING INTO THE NEXT AREA"
	.ascii "OF THE FACTORY, WILLY HAD "
	.ascii "TO STRAIN HIS EYES TO MAKE"
	.ascii "OUT SOME DISTURBING SHAPES"
	.ascii "IN THE SHADOWS.           "
	.ascii "                          "
	.ascii "HE DIDN'T LIKE THE INHUMAN"
	.ascii "CREATURES WANDERING DUMBLY"
	.ascii "AROUND THE FLOORS, BUT THE"
	.ascii "ONLY WAY OUT HE COULD SPOT"
	.ascii "WAS A LIFT WHICH SEEMED TO"
	.ascii "ONLY OFFER UPWARDS TRAVEL."
	@ 32	/ ROCKY HORROR
	.ascii "THE LIFT CARRIED THE TIRED"
	.ascii "MINER UP AND UP AND UP FOR"
	.ascii "WHAT FELT LIKE AN ETERNITY"
	.ascii "BEFORE FINALLY ARRIVING AT"
	.ascii "ITS DESTINATION.          "
	.ascii "                          "
	.ascii "THE DOORS OPENED AND WILLY"
	.ascii "STEPPED OUT INTO A STRANGE"
	.ascii "AUDITORIUM ON THE FACTORY "
	.ascii "ROOF, HIGH IN THE CLOUDS. "
	.ascii "WOULD HE EVER FIND HIS WAY"
	.ascii "HOME? WILLY DIDN'T KNOW.  "
	
	@ BONUS LEVELS 3-20
	
	@ 33	/ coupe Cheese-Plant
	.ascii "THE 1992 SAM COUPE PORT IS"
	.ascii "WIDELY REGARDED BY EXPERTS"
	.ascii "AS THE DEFINITIVE VERSION "
	.ascii "OF MANIC MINER.           "
	.ascii "                          "
	.ascii "IN ADDITION TO A FLAWLESS "
	.ascii "CONVERSION OF THE USUAL 20"
	.ascii "STAGES, IT ALSO CONTAINS  "
	.ascii "TWO NEW STANDALONE PSEUDO-"
	.ascii "SEQUELS, EACH OFFERING A  "
	.ascii "FURTHER 20 LEVELS OF VERY "
	.ascii "INVENTIVE DESIGN.         "
	@ 34	/ coupe dodgy mine shaft
	.ascii "THE DODGY MINE SHAFT ISN'T"
	.ascii "ONE OF THE SAM GAME'S BEST"
	.ascii "LEVELS, BUT NONETHELESS IS"
	.ascii "QUITE AN INTERESTING ONE. "
	.ascii "                          "
	.ascii "AS WITH SEVERAL OF THE NEW"
	.ascii "SAM STAGES, IT APPEARS TO "
	.ascii "BE DERIVED FROM ONE OF THE"
	.ascii "LEVELS OF THE ORIGINAL ZX "
	.ascii "GAME - IN THIS PARTICULAR "
	.ascii "CASE, FROM THE ABANDONED  "
	.ascii "URANIUM WORKINGS.         "	
	@ 35	/ BIG DROP
	.ascii "IN A SIMILAR VEIN, THE BIG"
	.ascii "DROP APPEARS TO HAVE TAKEN"
	.ascii "THE VAT FOR ITS TEMPLATE, "
	.ascii "IN TERMS OF BOTH PLATFORM "
	.ascii "LAYOUT AND THE APPEARANCE "
	.ascii "OF THE KANGAROO ENEMIES.  "
	.ascii "                          "
	.ascii "MORE INTERESTINGLY IT ALSO"
	.ascii "BOASTS ONE OF THE ALL-NEW "
	.ascii "GAME ELEMENTS EXCLUSIVE TO"
	.ascii "THE COUPE'S VERSION OF THE"
	.ascii "GAME - THE TRAMPOLINE.    "
	@ 36	/ BOUNCY BOUNCY
	.ascii "OF COURSE, THE TRAMPOLINE "
	.ascii "ISN'T REALLY VERY MUCH OF "
	.ascii "A TRAMPOLINE - IT CUSHIONS"
	.ascii "WILLY'S FALL, RATHER THAN "
	.ascii "CATAPULTING HIM RIGHT BACK"
	.ascii "UP INTO THE AIR.          "
	.ascii "                          "
	.ascii "IN FACT, IT'S BARELY EVEN "
	.ascii "AS BOUNCY AS THE BOUNCING "
	.ascii "CHEQUE, PLAINLY DELIGHTED "
	.ascii "TO BE MAKING A TRIUMPHANT "
	.ascii "RETURN FROM THE BANK.     "
	@ 37	/ ROCKY OUTCROP
	.ascii "THE SAM VERSION PIONEERED "
	.ascii "SEVERAL OTHER INNOVATIONS,"
	.ascii "INCLUDING THE DOUBLE-SIZED"
	.ascii "ENEMIES WHICH APPEARED IN "
	.ascii "SEVERAL LEVELS OF THE TWO "
	.ascii "20-STAGE 'PSEUDO-SEQUELS' "
	.ascii "EXCLUSIVE TO THE SAM PORT."
	.ascii "                          "
	.ascii "ONE OF THEM CAN BE SEEN IN"
	.ascii "THIS LEVEL, IN THE SHAPE  "
	.ascii "OF THE GIANT CAVE BEAST IN"
	.ascii "THE LOWER CENTRAL AREA.   "
	@ 38	/ BOTTOM OF THE MINE SHAFT
	.ascii "YET ANOTHER FEATURE UNIQUE"
	.ascii "TO THE SAM VERSION'S EXTRA"
	.ascii "LEVELS WERE SWITCHES WHICH"
	.ascii "REVERSED THE DIRECTION OF "
	.ascii "THE CONVEYOR BELTS.       "
	.ascii "                          "
	.ascii "SPEAKING OF THE DIRECTIONS"
	.ascii "OF THINGS, WILLY'S BOUNCES"
	.ascii "OFF OF THE TRAMPOLINES ARE"
	.ascii "DICTATED BY THE WAY HE'S  "
	.ascii "FACING WHEN HE FALLS. THIS"
	.ascii "IS VITAL FOR REALISM.     "
	@ 39	/ COSMIC CAUSEWAY
	.ascii "IT OCCURRED TO WILLY MORE "
	.ascii "THAN ONCE THAT DESPITE THE"
	.ascii "SEVERAL OCCASIONS ON WHICH"
	.ascii "HIS ADVENTURES HAD TAKEN  "
	.ascii "HIM INTO SPACE, HE'D NEVER"
	.ascii "EXPERIENCED THE SENSATION "
	.ascii "OF WEIGHTLESSNESS.        "
	.ascii "                          "
	.ascii "'PERHAPS', HE PONDERED ON "
	.ascii "ONE SUCH EXTRA-TERRESTRIAL"
	.ascii "JOB, 'THIS IS AN UNUSUALLY"
	.ascii "HEAVY SPACESUIT.'         "
	@ 40	/ LOGO OF THE YEAR
	.ascii "THE OTHER TWO GAMES IN THE"
	.ascii "'BLAGGER' SERIES - SON OF "
	.ascii "BLAGGER AND BLAGGER GOES  "
	.ascii "TO HOLLYWOOD - BOTH TOOK  "
	.ascii "THE FRANCHISE IN RADICALLY"
	.ascii "NEW DIRECTIONS.           "
	.ascii "                          "
	.ascii "WE MENTION THIS NOW DUE TO"
	.ascii "THE FACT THAT WE CAN THINK"
	.ascii "OF BASICALLY NOTHING VERY "
	.ascii "INTERESTING THAT WE COULD "
	.ascii "SAY ABOUT THIS LEVEL.     "
	@ 41	/ CENTRAL CAVERN
	.ascii "THE CENTRAL CAVERN REMAINS"
	.ascii "ONE OF THE MOST CELEBRATED"
	.ascii "LOCATIONS IN GAMING. APART"
	.ascii "FROM MANIC MINER, IT HAS  "
	.ascii "MADE CAMEO APPEARANCES IN "
	.ascii "SEVERAL OTHER VIDEOGAMES, "
	.ascii "INCLUDING SERVING AS -    "
	.ascii "                          "
	.ascii "   -- SPOILER ALERT! --   "
	.ascii "THE SECRET SURPRISE REVEAL"
	.ascii "ENDING OF JET SET WILLY 2."
	.ascii "   -- SPOILER ALERT! --   "	
	@ 42	/ FINAL CONFLICT
	.ascii "NUMEROUS LEVELS OF BLAGGER"
	.ascii "WERE BLATANTLY INSPIRED BY"
	.ascii "FAMOUS MANIC MINER STAGES,"
	.ascii "AND 'THE FINAL CONFLICT'  "
	.ascii "IS ONE SUCH EXAMPLE.      "
	.ascii "                          "
	.ascii "LIFTING THE ESCAPE-TO-THE-"
	.ascii "SURFACE MOTIF DIRECTLY OUT"
	.ascii "OF MM'S ICONIC 'THE FINAL "
	.ascii "BARRIER', IT ALSO BORROWED"
	.ascii "THE NOTION OF A LAST LEVEL"
	.ascii "BEING UNEXPECTEDLY EASY.  "
	@ 43	/ the vat
	.ascii "THE SEVENTH LEVEL OF THE  "
	.ascii "ORIGINAL MANIC MINER, AND "
	.ascii "THE ONLY APPEARANCE OF THE"
	.ascii "FAMOUS KANGAROOS.         "
	.ascii "                          "
	.ascii "THE KANGAROOS WERE NOT ONE"
	.ascii "OF THE ORIGINAL ENEMIES IN"
	.ascii "THE DESIGN, BUT WERE ADDED"
	.ascii "BY MATTHEW SMITH VERY LATE"
	.ascii "IN THE GAME'S DEVELOPMENT,"
	.ascii "WHEN THEY CAME TO HIM IN A"
	.ascii "DREAM WE'VE JUST MADE UP. "
	@ 44	/ mutant telephones
	.ascii "THE MUTANT TELEPHONES ARE "
	.ascii "SOME OF THE MOST ICONIC OF"
	.ascii "ALL MANIC MINER'S ENEMIES."
	.ascii "                          "
	.ascii "IN FACT, THEY'RE SO ICONIC"
	.ascii "THAT THEY WERE SHAMELESSLY"
	.ascii "COPIED FOR NOT ONE BUT TWO"
	.ascii "BLAGGER LEVELS - STARRING "
	.ascii "FIRST IN THE EIGHTH STAGE "
	.ascii "('TELEPHONE HOUSE'), THEN "
	.ascii "APPEARING AGAIN IN LEVEL  "
	.ascii "15 ('REVENGE OF BUZBY').  "
	@ 45	/ warehouse
	.ascii "THE VERTICALLY-PATROLLING "
	.ascii "ENEMIES DEPICTED HERE ARE "
	.ascii "THE ONES FROM THE ORIGINAL"
	.ascii "VERSION OF MM, RELEASED BY"
	.ascii "BUG-BYTE IN EARLY 1983.   "
	.ascii "                          "
	.ascii "THE VERSION WHICH CAME OUT"
	.ascii "OUT LATER IN THAT YEAR, BY"
	.ascii "SOFTWARE PROJECTS, SWAPPED"
	.ascii "THE THRESHING MACHINES FOR"
	.ascii "THAT COMPANY'S DISTINCTIVE"
	.ascii "IMPOSSIBLE-TRIANGLE LOGO. "
	@ 46 	mummy daddy
	.ascii "THIS STAGE APPEARED IN THE"
	.ascii "VERSION OF THE LOST LEVELS"
	.ascii "WHICH WAS DESCRIBED IN THE"
	.ascii "MAY 2009 EDITION OF RETRO "
	.ascii "GAMER MAGAZINE, THOUGH IT "
	.ascii "WASN'T ORIGINALLY PART OF "
	.ascii "THE LOST LEVELS CONCEPT.  "
	.ascii "                          "
	.ascii "(IT WAS INCLUDED SO THERE "
	.ascii "WOULDN'T BE TOO MANY ORIC "
	.ascii "LEVELS ON THE OPENING TWO "
	.ascii "PAGES OF THE FEATURE.)    "
	@ 47  its christmas charlie brown
	.ascii "TO BE HONEST, IT'S PRETTY "
	.ascii "HARD TO CONSTRUCT MUCH OF "
	.ascii "A RATIONAL EXPLANATION FOR"
	.ascii "HAVING A PEANUTS LEVEL IN "
	.ascii "A MANIC MINER GAME.       "
	.ascii "                          "
	.ascii "SNOOPY AND WOODSTOCK HAVE "
	.ascii "MADE A SURPRISINGLY SMALL "
	.ascii "NUMBER OF APPEARANCES IN  "
	.ascii "VIDEOGAMES, THOUGH, WHICH "
	.ascii "SEEMED LIKE A SHAME. SO WE"
	.ascii "PUT THEM IN THIS ONE.     "
	@ 48 / ENDORIAN FOREST
	.ascii "THE ENDORIAN FOREST SERVED"
	.ascii "AS THE INSPIRATION AND THE"
	.ascii "BASIC FRAMEWORK OF ANOTHER"
	.ascii "STAGE IN BLAGGER - IN THIS"
	.ascii "CASE, LEVEL 22 ('CHINESE  "
	.ascii "HAVE RETURNED ONCE MORE')."
	.ascii "                          "
	.ascii "FOR THE LOST LEVELS, WE'VE"
	.ascii "DEPICTED THE FOREST ALL IN"
	.ascii "GREEN, AS A BITING COMMENT"
	.ascii "ON THE WEST'S FAILURE TO  "
	.ascii "RATIFY THE KYOTO TREATY.  "
	@ 49 / JUMP FOR JOY
	.ascii "                          "
	.ascii "        - STOP! -         "
	.ascii "       - DANGER!-         "
	.ascii "                          "
	.ascii "  CLASSIFIED ACCESS ONLY  "
	.ascii "  LABORATORY - NO ENTRY!  "
	.ascii "                          "
	.ascii "ANY INJURIES SUSTAINED AS "
	.ascii "A RESULT OF UNPREDICTABLE "
	.ascii "GRAVITATIONAL FLUCTUATIONS"
	.ascii "ARE AT VISITOR'S OWN RISK."
	.ascii "                          "
	@ 50	/ the final barrier
	.ascii "BEATING THE 20TH STAGE OF "
	.ascii "THE ORIGINAL GAME SAW THE "
	.ascii "EXIT TRANSFORM INTO A PAIR"
	.ascii "OF CRYPTIC ICONS, IN THE  "
	.ascii "MYSTERIOUS FORMS OF A FISH"
	.ascii "AND A DAGGER (OR SWORD).  "
	.ascii "                          "
	.ascii "THERE WAS AN EXCEPTIONALLY"
	.ascii "GOOD REASON FOR THIS, WE'D"
	.ascii "IMAGINE. OR, ON THE OTHER "
	.ascii "HAND, IT'S QUITE POSSIBLE "
	.ascii "THAT THERE WASN'T.        "

@------------------------------- Level info	

levelInfo: @XXXXXXXXXXXXXXXXXXXXXXXXXX
	.ascii "   ORIC (1985) - LEVEL 17   "	@1
	.ascii "   ORIC (1985) - LEVEL 24   "	@2
	.ascii "   ORIC (1985) - LEVEL XX   "	@3
	.ascii "   ORIC (1985) - LEVEL 20   "	@4
	.ascii "   ORIC (1985) - LEVEL 18   "	@5
	.ascii "  DRAGON (1984) - LEVEL 21  "	@6
	.ascii "   ORIC (1985) - LEVEL 28   "	@7
	.ascii "   ORIC (1985) - LEVEL 19   "	@8
	.ascii "    GBA (2002) - LEVEL 06   "	@9
	.ascii "   ORIC (1985) - LEVEL 21   "	@10
	.ascii "  ARCHIMEDES (1991) - L22   "	@11
	.ascii "   ORIC (1985) - LEVEL 26   "	@12
	.ascii "   ORIC (1985) - LEVEL 27   "	@13
	.ascii "    GBA (2002) - LEVEL 08   "	@14
	.ascii "   ORIC (1985) - LEVEL 23   "	@15
	.ascii "   ORIC (1985) - LEVEL 25   "	@16
	.ascii " BBC MICRO (1984) - LVL 19  "	@17
	.ascii " DRAGON 32 (1984) - LVL 22  "	@18
	.ascii " BBC MICRO (1984) - LVL 20  "	@19
	.ascii " AMSTRAD (1984) - LEVEL 20  "	@20

	
	@ Bonus 2 LEVELS (HORACE AND BLAGGER)
	.ascii "    HORACE - PSION3 1995    "
	.ascii "     BLAGGER - C64 1983     "
	
	@ Movies
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "     SPACE FRACTAL 2009     "
	.ascii "   ORIGINAL - FLASH  2009   "
	.ascii "    ORIGINAL - LOBO 2009    "
	.ascii "   ORIGINAL - FLASH  2009   "
	.ascii "     SPACE FRACTAL 2009     "
	.ascii "   A SVERX ORIGINAL  2009   "
	.ascii "   ORIGINAL - FLASH  2009   "
	
	@ 33	/ bonus levels from 3rd onward to 20th
	.ascii "      SAM COUPE (1990)      "
	@ 34
	.ascii "      SAM COUPE (1990)      "
	@ 35
	.ascii "      SAM COUPE (1990)      "
	@ 36
	.ascii "      SAM COUPE (1990)      "
	@ 37
	.ascii "      SAM COUPE (1990)      "
	@ 38
	.ascii "      SAM COUPE (1990)      "
	@ 39
	.ascii "   ORIGINAL - FLASH  2009   "
	@ 40
	.ascii "    BLAGGER (1983) - C64    "
	@ 41
	.ascii "  LEVEL 01 - SPECTRUM 1983  "
	@ 42
	.ascii "    BLAGGER (1983) - C64    "
	@ 43
	.ascii "  SPECTRUM (1983) - LVL 07  "
	@ 44
	.ascii "  SPECTRUM (1983) - LVL 11  "
	@ 45
	.ascii "  SPECTRUM (1983) - LVL 17  "
	@ 46
	.ascii "    GBA (2002) - LEVEL 03   "
	@ 47
	.ascii "   ORIGINAL - FLASH  2009   "
	@ 48
	.ascii "   ORIC (1985) - LEVEL XX   "
	@ 49
	.ascii "   ORIGINAL - FLASH  2009   "
	@ 50
	.ascii "  SPECTRUM (1983) - LVL 20  "

	.end