pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
local levels = {[[


-- intro
01,4,48
14,4,48
14,4,84
0a,4,88

-- Three green at right
0a,4,c8
02,4,c6
02,4,c4

-- discs from bottom
1,5,9,48
1,5,9,48
1,5,9,48
1,5,9,48
1,5,9,48
1,5,9,48

-- four at left
0f,4,22
00,4,43
00,4,62
00,4,83
-- five at right root sign
0a,4,f2
00,4,d3
00,4,c4
00,4,a6
00,4,86

-- powerup
0a,6,99
0a,7,99
0a,8,99
0a,9,99

-- four at left low
14,4,18
00,4,38
00,4,58
00,4,78

-- five at right
14,4,f4
00,4,d4
00,4,c4
00,4,a4
00,4,84

--four at left
14,4,18
00,4,38
00,4,58
00,4,78

0a,9,88

-- five at right again
14,4,f4
00,4,d4
00,4,c4
00,4,a4
00,4,84

-- discs spline 1
14,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60
1,5,1,60

-- discs spline 2
20,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48
1,5,2,48


-- discs spline 3

20,5,3,64,
1,5,3,ff
1,5,3,ff
0,4,76
0,4,96
1,5,3,64
1,5,3,64
0,4,76
0,4,96
1,5,3,64
1,5,4,64
1,5,4,64
1,5,4,64
1,5,4,64
1,5,4,64



-- formation 12 
---------------
-- Four middle



--two left & 2 right
06,4,44
00,4,54
00,4,b4
00,4,d4
--two left and 2 right lower
03,4,46
00,4,56
00,4,b6
00,4,d6

-- disc with four enemies in middle
20,5,2,32
1,5,2,32
1,5,2,32
0,4,7a
0,4,8a
1,5,1,48
0,5,2,32
0,4,76
0,4,86
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
6,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32
1,5,1,48
0,5,2,32

-- / formation
0f,4,0e
2,4,2c
2,4,4a
2,4,69
2,4,87
2,4,a5
2,4,c3
2,4,e1

--5 flaps
2f,1,24,8
0,1,d4,8
0,1,e4,8
6,1,26,8
0,1,d6,8

]],
[[
-- lazer
01,2,f8,d8,a0,20,33
00,2,08,28,e0,20,33
01,2,f6,d6,a0,20,33
00,2,06,26,e0,20,33
01,2,f4,d4,a0,20,33
00,2,02,22,e0,20,33
01,2,fa,da,a0,20,33
00,2,0a,2a,e0,20,33
ff,a,80,88
-- spin & tail
60,b,3,c0
2,5,3,c0
2,5,3,c0
2,5,3,c0
2,5,3,c0
-- spin & tail
15,b,4,c0
2,5,4,c0
2,5,4,c0
2,5,4,c0
2,5,4,c0


60,b,3,a0
0,4,22
0,4,43
0,4,62
0,4,83

]]
}

local start=0x2100
for level in all(levels) do 
	local dat={}
	for row in all(split(level,"\n")) do
		if sub(row,1,2) == "--" then 
			printh(sub(row,3))
		else
			local bytes = split(row,",",false)
			for byte in all(bytes) do
				add(dat, tonum("0x"..byte))
			end
		end
	end
	if (start+#dat+2>=0x2fff) then 
		stop("data to big")
	end
	poke2(start, #dat)
	printh("start"..tostr(start,true).." len"..tostr(#dat,true))
	poke(start+2, unpack(dat))
	
	start = start+#dat+2
end
cstore(0x2000, 0x2000, 0xfff, "shootinator.p8")
load("shootinator.p8", "back to levels")
__map__
e6e7f6f7eeefe7f7e7e6f7f7e7cecff7e7f6f7e6fefff6ecedf7f6e7e6dedfe7f7f6cccde7f7f7fcfde7f6eeeff7f7e6e6e7dcddf6e6e6f7f7e6e7feffe7e6e7e7e6f6f7eeefe7e6e7f7e6e7f7f7e6cef7ecedf6fefff7e7e6cef7e7f7eff6e7e7fcfde7f7e7f6f6f7f6f6e7e6cecfe6e7f7f6ecedf7e6f7e6e7e6eee7dedff7
e6e7f7fcfdf6e7e6e7e6e7f7f7e7f7e6e6f7e7f6cccde6e7eeefe6e7e7efcee7e6e7cecfdcdde7e7feffe7f7e6e6e6e7e6f7dedff7f7f7e7f7e6cccde7e6e6e6f7e6f7e7e6f7eff7e6f7dcddf7f6f7f7e7f7e7f7eee7e6e7e7e7e7e7f7ecede7e7e6f7e7e7e7e6e7cecfe6e7f6fcfde6e6e7f7eff7f7f6f7dedff7eef7e6e6e7
fd010104481404481404840a04880a04c80204c60204c40105094801050948010509480105094801050948010509480f04220004430004620004830a04f20004d30004c40004a60004860a06990a07990a08990a09991404180004380004580004781404f40004d40004c40004a40004841404180004380004580004780a0988
1404f40004d40004c40004a40004841405016001050160010501600105016001050160010501600105016001050160010501600105016001050160010501600105016001050160200502480105024801050248010502480105024801050248010502480105024801050248010502480105024820050364010503ff010503ff00
047600049601050364010503640004760004960105036401050464010504640105046401050464010504640604440004540004b40004d40304460004560004b60004d620050232010502320105023200047a00048a01050148000502320004760004860105014800050232010501480005023201050148000502320105014800
05023201050148000502320105014800050232010501480005023201050148000502320105014800050232010501480005023206050148000502320105014800050232010501480005023201050148000502320f040e02042c02044a0204690204870204a50204c30204e12f0124080001d4080001e408060126080001d60800
