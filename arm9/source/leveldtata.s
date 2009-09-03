	.arm
	.align
	.text
	
	.global levelData
	
	
levelData:

@ 1,2 ok, the first 2 bytes are the x/y of the exit (as x/y strict coord - not +384 and 64)
@ 3 then, number of keys to collect LOW, high = tune to play (0=default, 1=creepy, 2=space)
@ 4,5 willies start position
@ 6 =willies initial direction (0=l 1=r) LOW / HIGH=Special effect (ie. rain) (0=none)
@												1=rain, 2=stars, 3=Leaves, 4=Glint
@ 7 =background number (0-?)
@ 8 =door bank number - used for the exit.. 0-???

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
	.byte 80,144,19,8,168,17,0,0

	.byte 72,88,17,1,1,17,8,144
	.byte 104,104,1,1,255,17,104,216
	.byte 160,144,1,1,1,1,160,208
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 2 / Oric - Level xx - Airlock
	.byte 128,104,35,8,104,33,1,1
	
	.byte 16,160,17,1,1,0,16,104
	.byte 144,168,17,1,1,7,144,232
	.byte 144,104,17,1,1,7,144,224
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 3 / GBA - Level xx - Mummy Daddy
	.byte 224,80,5,218,168,64,2,2
	
	.byte 104,108,1,16,1,12,108,168
	.byte 56,64,1,16,255,12,64,112
	.byte 120,112,1,16,255,12,64,112
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 4
	.byte 232,168,4,8,168,49,3,0

	.byte 120,56,1,16,1,18,56,104
	.byte 50,142,17,17,255,6,8,56
	.byte 64,168,17,1,1,14,16,72
	.byte 152,168,17,1,1,14,96,160
	.byte 232,168,0,1,1,14,168,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 5
	.byte 232,168,3,8,168,1,4,0

	.byte 104,168,17,1,255,0,104,144
	.byte 32,168,17,1,1,0,16,72
	.byte 24,72,17,1,255,15,24,216
	.byte 232,96,1,16,1,9,72,150
	.byte 152,128,17,3,255,15,152,208
	.byte 96,48,17,1,255,11,8,128
	.byte 144,48,17,1,1,11,144,208
	
	@ 6
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 7
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 8
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 9
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 10
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 11
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 12
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 13
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 14
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 15
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 16
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 17
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 18
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 19
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 20
	.byte 0,0,0,0,0,0,0,0

	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 21 / demo data for original level 1
	.byte 232,168,5,8,168,1,5,0
	
	.byte 60,120,17,1,1,0,60,122
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	.end