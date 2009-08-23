	.arm
	.align
	.text
	
	.global levelData
	
	
levelData:

@ 1,2 ok, the first 2 bytes are the x/y of the exit (as x/y strict coord - not +384 and 64)
@ 3 then, number of keys to collect
@ 4,5 willies start position
@ 5 willies initial direction (0=l 1=r)
@ 6 =
@ 7 =
@ 8 =

@ alien data
@ 1=initial X, 2=initial y
@ 3=initial direction (0=neg/1=pos)
@ 4=travel direction (0=up/dn 1=l/r 2=topr/botl 3=topl/botr)
@ 5=speed of travel (0=?) (do we need fractional movement?)
@ 6=level sprite to use (0=3 - or perhaps more??)
@ 7
@ 8
@ data for each level stored as up to 7 enemies

@ this makes each level description 64 bytes, do we need more?


	
levelData:

	@ demo data for original level 1

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