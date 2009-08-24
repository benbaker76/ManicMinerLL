	.arm
	.align
	.text
	
	.global levelData
	
	
levelData:

@ 1,2 ok, the first 2 bytes are the x/y of the exit (as x/y strict coord - not +384 and 64)
@ 3 then, number of keys to collect
@ 4,5 willies start position
@ 5 willies initial direction (0=l 1=r)
@ 6 =Sprite bank to use (block of 32 sprites for a level) (0-?)
@ 7 =
@ 8 =

@ alien data (if initial X and y is 0 = blank alien)
@ 1=initial X,
@ 2=initial y (offsets added at level construct)
@ 3=initial direction (0=neg/1=pos) (LOW 4 BITS) / sprites facing (HFLIP) (HI 4 BITS)
@ 4=travel direction (0=up/dn 1=l/r 2=topr/botl 3=topl/botr)
@ 5=speed of travel (0=?) (do we need fractional movement?)
@ 6=level sprite to use (0-4 - or perhaps more??)
@ 7=min movement location
@ 8=maximum movement locaton
@ data for each level stored as up to 7 enemies

@ this makes each level description 64 bytes, do we need more?

@ take level number -1 and mul by 64 for base of data!
	
levelData:

	@ demo data for original level 1

	.byte 232,160
	.byte 4
	.byte 8,168
	.byte 1
	.byte 0
	.byte 0
	
	.byte 60,120,17,1,1,0,60,122
	.byte 60,100,17,1,2,1,60,122
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@

	.byte 232,160
	.byte 4
	.byte 8,168
	.byte 1
	.byte 0
	.byte 0
	
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@





	.pool
	.end