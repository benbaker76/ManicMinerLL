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

	@ 46 end of the world
	.byte 232,168,31,8,72,25,45,0

	.byte 8,168,17,1,1,15,8,216
	.byte 8,128,17,1,1,19,8,144
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
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
	@ 48
	.byte 232,120,0,16,120,1,6,41

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	@ 49
	.byte 232,120,5,16,120,1,6,41

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0	
	@ 50
	.byte 232,120,0,16,120,1,6,41

	.byte 0,0,0,0,0,0,0,0
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
	.ascii "       MUMMY!!, DADDY!!       "	@ TO end of the world
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
	.ascii "     THE END OF THE WORLD     "	@ to mummy daddy!
	.ascii "IT IS CHRISTMAS CHARLIE BROWN!"
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "

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
	.ascii "HAVE TO CLIMB IN THROUGH  "
	.ascii "THE OPEN SKYLIGHT...      "
	@ 2
	.ascii "DROPPING DOWN THROUGH THE "
	.ascii "ROOF, WILLY FINDS HIMSELF "
	.ascii "IN HIS ATTIC, BUT THE LOFT"
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
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
	.ascii ".........................."
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
	.ascii "AND DODGE CRABS TO REACH  "
	.ascii "A DOOR FROM BEHIND WHICH  "
	.ascii "DAYLIGHT SEEMS TO SHINE..."
	@ 14
	.ascii "THERE IS, INDEED, LIGHT AT"
	.ascii "THE END OF THE TUNNEL, BUT"
	.ascii "IT ILLUMINATES A SCENE OUR"
	.ascii "HERO WOULD HAVE RATHER NOT"
	.ascii "WITNESSED - A RUINED CITY."
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
	.ascii "DROIDS AS HE HOPS OVER THE"
	.ascii "PLATFORMS TO THE EXIT...  "
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
	.ascii "AT A COTTAGE IDENTICAL TO "
	.ascii "HIS OWN. HE REALISES THE  "
	.ascii "ALIENS HAVE BEEN USING HIS"
	.ascii "SEEMINGLY-ABANDONED HOUSE "
	.ascii "AS THE BASE CAMP FOR THEIR"
	.ascii "SUBTERRANEAN INVASION.    "
	.ascii "                          "
	.ascii "COULD THIS REPLICA CONTAIN"
	.ascii "A PORTAL TO GET HOME AND  "
	.ascii "SAVE EARTH?    (YES. - ED)"

	@ 21	/ HORACE
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
	@ 22	/ BLAGGER
	.ascii "  SO, IT LOOKS LIKE WILLY "
	.ascii "HAS TAKEN TO A LIFE OF    "
	.ascii "CRIME... ROBBING BANKS IS "
	.ascii "NOT A VENTURE FOR A WELL  "
	.ascii "EDUCATED MAN? WHY WOULD HE"
	.ascii "DO SUCH A THING?          "
	.ascii "  BEST HE GRABS THE KEYS  "
	.ascii "TO THE SAFE AND MAKES A   "
	.ascii "QUICK EXIT.               "
	.ascii "  I DON'T THINK WILLY     "
	.ascii "WOULD BE ABLE TO HANDLE   "
	.ascii "DOING A BIT OF 'BIRD'.    "
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
	.ascii "  NOT ONLY WAS WILLY BEING"
	.ascii "THROWN THOUGH CELLULOID   "
	.ascii "SPACE, HE WAS ALSO SLIDING"
	.ascii "THROUGH CELLULOID TIME.   "
	.ascii "  IT WOULD APPEAR TO BE   "
	.ascii "1933, THERE IS A KILLER   "
	.ascii "APE ON THE LOOSE, AND A   "
	.ascii "SCANTILY CLAD FAY WRAY IS "
	.ascii "NOWHERE TO BE SEEN, SADLY."
	.ascii "  SURELY THE EXIT MUST    "
	.ascii "TAKE POOR WILLY SOMEWHERE "
	.ascii "SAFER AND CLOSER TO HOME? "
	@ 30	/ TERMINATOR
	.ascii "  'OH NO' CRIED WILLY, NOW"
	.ascii "HE HAD PASSED INTO THE    "
	.ascii "FUTURE.                   "
	.ascii "  WILLY WONDERED WHY ANY  "
	.ascii "IMAGE OF THE FUTURE WAS   "
	.ascii "ACCOMPANIED BY SPARKS AND "
	.ascii "METALIC SURFACES?, 'I     "
	.ascii "WONDER', THOUGH WILLY.    "
	.ascii "  SO, NOW WITH THE WORRY  "
	.ascii "OF MACHINES OF ULTIMATE   "
	.ascii "DESTRUCTION, AGAIN WILLY  "
	.ascii "MUST FIND A WAY TO ESCAPE."
	@ 31 	/ YOUNG FRANK
	.ascii "  'I REALLY FEEL LIKE A   "
	.ascii "LITTLE DANCE', THOUGHT    "
	.ascii "WILLY.                    "
	.ascii "  THINKING SERIOUSLY FOR A"
	.ascii "MOMENT, WILLY REALISED    "
	.ascii "THAT THIS COULD BE A      "
	.ascii "DIFFICULT TASK TO FIND HIS"
	.ascii "WAY TO THE EXIT.          "
	.ascii "  'THAT LIFT LOOKS RATHER "
	.ascii "PROMISING', HE THOUGHT.   "
	.ascii "  AND TO BE FAIR, IT DID  "
	.ascii "LOOK RATHER PROMISING.    "
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
	
	@ BONUS LEVELS
	
	@ 33	/ coupe Cheese-Plant
	.ascii "  WILLY HAD JUST STEPPED  "
	.ascii "INTO THIS CAVERN WHEN A   "
	.ascii "THOUGHT ENTERED HIS HEAD, "
	.ascii "AS OFTEN HAPPENS,         "
	.ascii "'IS THIS A CAVERN THAT HAS"
	.ascii "A HIDDEN CHEESE PLANT IN  "
	.ascii "IT, OR.. IS THIS CAVERN A "
	.ascii "SECRET FACTORY, OR PLANT, "
	.ascii "WHERE THEY MAKE CHEESE?'  "
	.ascii "  WILLY WAS SURE THAT THIS"
	.ascii "WOULD GIVE HIM A FEW REST-"
	.ascii "LESS NIGHTS.              "
	@ 34	/ coupe dodgy mine shaft
	.ascii "  WILLY GINGERLY STEPPED  "
	.ascii "INTO THE MINE SHAFT.      "
	.ascii "  'NOW, WHY IS THIS CALLED"
	.ascii "THE 'DODGY' MINE SHAFT?', "
	.ascii "HE THOUGHT QUIETLY TO HIM-"
	.ascii "SELF. HE FOUND QUIET BOUTS"
	.ascii "OF THINKING REWARDING AND "
	.ascii "A MUCH LESS NOISY THAN    "
	.ascii "SHOUTING HIS THOUGHTS OUT "
	.ascii "LOUD TO ALL IN THE AREA.  "
	.ascii "  WILLY THOUGHT A LITTLE  "
	.ascii "LOUDER, AND GOT A HEADACHE"	
	@ 35	/ BIG DROP
	.ascii "                          "
	.ascii "  NOW THIS WAS SOMETHING  "
	.ascii "OUR ADVENTUROUS WILLY HAD "
	.ascii "NOT SEEN BEFORE. WHAT WAS "
	.ascii "THAT STRANGE TRAMPOLINE - "
	.ascii "SHAPED CONTRAPTION AT THE "
	.ascii "BOTTOM OF THAT DEEP SHAFT?"
	.ascii "  WORSE STILL, HOW WAS HE "
	.ascii "GOING TO BE ABLE TO GET   "
	.ascii "DOWN THERE WITHOUT SOME - "
	.ascii "THING TO BREAK HIS FALL?  "
	.ascii "                          "
	@ 36	/ BOUNCY BOUNCY
	.ascii "                          "
	.ascii "  NOW THAT WILLY HAD FOUND"
	.ascii "THE POWER OF THE BOUNCE,  "
	.ascii "IT SEEMED TO HIM THAT     "
	.ascii "EVERYONE WANTED TO BOUNCE "
	.ascii "ALSO.                     "
	.ascii "  'THIS IS A STRANGE PLACE"
	.ascii "FULL OF BOUNCING THINGS', "
	.ascii "THOUGH WILLY, JUST PRIOR  "
	.ascii "TO TRYING A FEW BOUNCING  "
	.ascii "MOVES HIMSELF.            "
	.ascii "                          "
	@ 37	/ ROCKY OUTCROP
	.ascii "  A STRANGE BEAST STOOD   "
	.ascii "GUARDING THE ENTRANCE TO  "
	.ascii "A CAVE, OR WAS THIS THE   "
	.ascii "EXIT FROM THE CAVE? WILLY "
	.ascii "WAS FAR FROM SURE, AND FAR"
	.ascii "FROM WHERE HE BEGAN.      "
	.ascii "  HE ALSO WONDERED WHY HE "
	.ascii "WOULD HAVE TO CLIMB EVERY-"
	.ascii "WHERE TO COLLECT THE KEYS,"
	.ascii "WHEN IT WAS CLEAR TO HIM  "
	.ascii "THAT THE EXIT HAD NO DOOR."
	.ascii "  HE DID LIKE KEYS THOUGH!"
	@ 38	/ BOTTOM OF THE MINE SHAFT
	.ascii "  WILLY VENTURE FORTH INTO"
	.ascii "THE BOTTOM OF THE MINE    "
	.ascii "SHAFT.                    "
	.ascii "  AS 'MINE SHAFT BOTTOMS' "
	.ascii "GO, THIS, HE THOUGHT, WAS "
	.ascii "PERHAPS ONE OF THE BEST HE"
	.ascii "HAD EVER SEEN. IF NOT THE "
	.ascii "BEST, IT CERTAINLY CAME A "
	.ascii "CLOSE SECOND.             "
	.ascii " AFTER SPENDING AROUND TEN"
	.ascii "MINUTES JUDGING THE MERITS"
	.ascii "OF THE SHAFT, HE MOVED ON."
	@ 39	/ COSMIC CAUSEWAY
	.ascii "  WILLY HAD ALWAYS LIKED  "
	.ascii "HIS VENTURES INTO SPACE,  "
	.ascii "THOUGH THIS SPACE JOURNEY "
	.ascii "WAS PERHAPS NOT QUITE AS  "
	.ascii "RELAXING AS HE HOPED. HE  "
	.ascii "DID WONDER WHY HE DID NOT "
	.ascii "EXPERIENCE WEIGHLESSNESS  "
	.ascii "LIKE HE HAD SEEN IN THE   "
	.ascii "FILMS AT THE LOCAL FLEA   "
	.ascii "PIT. PERHAPS IT WAS A VERY"
	.ascii "HEAVY SPACESUIT HE THOUGHT"
	.ascii "TO HIMSELF.               "
	@ 40	/ LOGO OF THE YEAR
	.ascii "  WILLY DECIDED TO TAKE A "
	.ascii "TRIP TO THE BANK OF       "
	.ascii "'ALLIGATOR', IN THE HEADY "
	.ascii "TOWN OF SHEFFIELD.        "
	.ascii "  'IF I CAN ROB THIS BANK,"
	.ascii "THE REWARDS WILL BE GREAT'"
	.ascii "HE THOUGHT. HE DID NOT    "
	.ascii "THINK THAT KEN WOULD HAVE "
	.ascii "UNLEASHED THE PHANTOM 2 - "
	.ascii "FRAMED DISCS OF DOOM TO   "
	.ascii "HINDER HIS ROBBERY.       "
	.ascii "  THAT DAMN KEN.          "
	@ 41	/ CENTRAL CAVERN
	.ascii "  WILLY SOMEHOW FELT MUCH "
	.ascii "MORE SECURE IN THE CAVERN "
	.ascii "THAT HE KNOWS SO WELL.    "
	.ascii "  'I FEEL MUCH MORE SECURE"
	.ascii "IN THIS CAVERN', THOUGHT  "
	.ascii "WILLY.                    "
	.ascii "  HE WAS MOST SUPRISED    "
	.ascii "TO DISCOVER THAT WHEN HE  "
	.ascii "JUMPED UP TO THE FIRST    "
	.ascii "PLATFORM, BITS OF HIM DID "
	.ascii "NO TURN RED.              "
	.ascii "'I'M SUPRISED!' HE MUSED. "	
	@ 42	/ FINAL CONFLICT
	.ascii "  SO, WILLY DECIDES TO TRY"
	.ascii "HIS HAND IN THE REALM OF  "
	.ascii "THE THIEF AGAIN.          "
	.ascii "  THIS IS THE FINAL BANK, "
	.ascii "HIS LAST JOB, AT LEAST    "
	.ascii "THAT IS WHAT HE HAS TOLD  "
	.ascii "HIMSELF. 'JUST THIS ONE   "
	.ascii "LAST JOB, AND THEN I WILL "
	.ascii "RETIRE FROM THIS FOUL     "
	.ascii "BUSINESS'. AT LEAST THAT  "
	.ascii "IS WHAT HE SAID.          "
	.ascii "  SO, WILL HE STOP?       "
	@ 43	/ the vat
	.ascii "  'THEY LOOK A BIT LIKE   "
	.ascii "KANGAROOS' THOUGHT THE    "
	.ascii "THOUGHTFUL WILLY.         "
	.ascii "  HE ALSO WONDERED TO     "
	.ascii "HIMSELF WHY THE CREATURES "
	.ascii "DID NOT MOVE AROUND       "
	.ascii "EXACTLY THE SAME AS HE WAS"
	.ascii "USED TO. 'WELL, AT LEAST  "
	.ascii "THIS MAY GIVE ME A NEW    "
	.ascii "CHALLENGE' HE PONDERED AS "
	.ascii "HE DECIDED TO PUT HIS BEST"
	.ascii "FOOT FORWARD (HIS LEFT).  "
	@ 44	/ mutant telephones
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
	@ 45	/ warehouse
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
	@ 46 	end of the world
	.ascii "                          "
	.ascii "  STU SAID 'THIS LEVEL IS "
	.ascii "LOST', THOUGH FLASH WAS   "
	.ascii "NOT SO SURE. 'PUT IT IN', "
	.ascii "SAID STU, 'NO, LEAVE IT   "
	.ascii "OUT', SAID FLASH.         "
	.ascii "  IN, OUT, IN, OUT, IN OUT"
	.ascii "IT TURNED OUT THAT THE END"
	.ascii "OF THE WORLD WAS CAUSED BY"
	.ascii "A GAME OF ARGUEMENTATIVE  "
	.ascii "HOKEY COKEY.. SAD!        "
	.ascii "                          "
	@ 47  its christmas charlie brown
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
	@ 48
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
	@ 49
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
	@ 50	/ the final barrier
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

@------------------------------- Level info	

levelInfo: @XXXXXXXXXXXXXXXXXXXXXXXXXX
	.ascii "   ORIC (1985) - LEVEL 17   "	@1
	.ascii "   ORIC (1985) - LEVEL 24   "	@2
	.ascii "    GBA (2002) - LEVEL 03   "	@3
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
	
	@ 33
	.ascii "       SAM COUPE 1990       "
	@ 34
	.ascii "       SAM COUPE 1990       "
	@ 35
	.ascii "       SAM COUPE 1990       "
	@ 36
	.ascii "       SAM COUPE 1990       "
	@ 37
	.ascii "       SAM COUPE 1990       "
	@ 38
	.ascii "       SAM COUPE 1990       "
	@ 39
	.ascii "   ORIGINAL - FLASH  2009   "
	@ 40
	.ascii "     BLAGGER - C64 1983     "
	@ 41
	.ascii "  LEVEL 01 - SPECTRUM 1983  "
	@ 42
	.ascii "     BLAGGER - C64 1983     "
	@ 43
	.ascii "  LEVEL 07 - SPECTRUM 1983  "
	@ 44
	.ascii "  LEVEL 11 - SPECTRUM 1983  "
	@ 45
	.ascii "  LEVEL 17 - SPECTRUM 1983  "
	@ 46
	.ascii "    LEVEL XX - ORIC 1985    "
	@ 47
	.ascii "   ORIGINAL - FLASH  2009   "
	@ 48
	.ascii "                            "
	@ 49
	.ascii "                            "
	@ 50
	.ascii "  LEVEL 20 - SPECTRUM 1983  "

	.end