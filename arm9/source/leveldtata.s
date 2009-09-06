	.arm
	.align
	.text
	
	.global levelData
	.global levelNames
	.global levelInfo
	.global storyText
	
	
levelData:

@ 1,2 ok, the first 2 bytes are the x/y of the exit (as x/y strict coord - not +384 and 64)
@ 3 then, number of keys to collect LOW, high = tune to play (0=default, 1=creepy, 2=space, 3=egypt 4=piano)
@ 4,5 willies start position
@ 6 =willies initial direction (0=l 1=r) LOW / HIGH=Special effect (ie. rain) (0=none)
@												1=rain, 2=stars, 3=Leaves, 4=Glint 5=Drip
@ 7 =background number (0-?)
@ 8 =door bank number - used for the exit.. 0-??? HIGH= Willy sprite to use (0=normal 1=spectrum 2=space)

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
	.byte 224,80,53,218,168,64,2,2
	
	.byte 104,108,1,16,1,16,108,168
	.byte 56,64,1,16,255,16,64,112
	.byte 120,112,1,16,255,16,64,112
	.byte 232,48,0,1,255,20,208,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 4 / Oric - level 24 - Hall of the mountain kong
	.byte 232,168,4,8,168,49,3,3

	.byte 120,56,1,16,1,18,56,104
	.byte 50,142,17,17,255,6,8,56
	.byte 64,168,17,1,1,21,16,72
	.byte 152,168,17,1,1,21,96,160
	.byte 232,168,0,1,1,21,168,232
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0

	@ 5 / Oric - level 18 - back to work
	.byte 232,168,67,6,168,81,4,0

	.byte 104,168,17,1,255,0,104,144
	.byte 32,168,17,1,1,0,16,72
	.byte 24,72,17,1,255,15,24,216
	.byte 232,96,1,16,1,9,72,150
	.byte 152,128,17,3,255,15,152,208
	.byte 96,48,17,1,255,19,8,128
	.byte 144,48,17,1,1,19,144,208
	
	@ 6 / Dragon - Level xx - 
	.byte 232,136,5,6,168,97,5,4

	.byte 172,152,17,17,1,6,148,196
	.byte 48,144,17,1,1,3,32,88
	.byte 80,96,17,1,1,3,80,136
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	@ 7 / Oric
	.byte 232,168,5,6,168,1,6,22

	.byte 96,112,17,1,1,22,96,138+32
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

	.ascii "        HOME AT LAST??        "
	.ascii "         THE  AIRLOCK         "
	.ascii "       MUMMY!!, DADDY!!       "
	.ascii "  HALL OF THE MOUNTAIN KONG!  "
	.ascii "         BACK TO WORK         "
	.ascii "    THE DRAGON USERS BONUS    "
	.ascii "      NOT CENTRAL CAVERN      "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
	.ascii "                              "
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
	@ 9
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
	@ 10
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

levelInfo:
	.ascii "    LEVEL 17 - ORIC 1985    "
	.ascii "    LEVEL 20 - ORIC 1985    "
	.ascii "    LEVEL XX - GBA  2002    "
	.ascii "    LEVEL 24 - ORIC 1985    "
	.ascii "    LEVEL 18 - ORIC 1985    "
	.ascii "  LEVEL 21 - DRAGON32 1983  "
	.ascii "    LEVEL 28 - ORIC 1983    "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "  LEVEL 01 - SPECTRUM 1983  "

	.end