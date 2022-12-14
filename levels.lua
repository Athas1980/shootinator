local level = [[


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

]]

-- level = [[

-- 01,a,80,88

-- ]]

--In the end this should just be
--a sequence of bytes
--so it can be converted later
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

printh("level bytes used:"..#dat)
-- for byte in all(dat) do
--  printh(byte)
-- end

function level_iter()
	local i=0
	return function()
		i+=1 return dat[i]
	end
end

local distance_spawn={}

local next=level_iter()

local function append(f2, f1)
	return function() f1() f2() end
end

function read_green(fn_next)
	local byte=fn_next()
	local x,ty=((byte&0xf0)>>>4)*8, (byte&0xf)*8
	return function()
		add(mobs,create_enemy("green", x, -8, ty))
	end
end

function read_flap(fn_next)
	local byte=fn_next()
	local hp = fn_next()
	local x,ty=((byte&0xf0)>>>4)*8, (byte&0xf)*8
	return function()
	local en = create_enemy("flap", x, -8, ty)
	en.hp=hp
	add(mobs,en)
	end
end

function read_disc(fn_next)
	local num,dur=fn_next(),fn_next()*4
	return function()
		local en = create_enemy(
			"disc",98,-8, splines[num]
		)
		en.dur=dur
		add(mobs,en)
	end
end

function read_p_up(idx, fn_next)
	local byte=fn_next()
	local x,y=((byte&0xf0)>>>4)*8, (byte&0xf)*8
	return function()
		create_powerup(idx, x, y)
	end
end

function read_lazer_turret(fn_next)
	printh("reading lazer")
	local byte = fn_next()
	local x,y=((byte&0xf0)>>>4)*8, (byte&0xf)*8
	printh("x:".. x.. " y:"..y)
	if x==0 then x=-8	end
	if y==0 then	y=-8	end
	if x==120 then x=132 end
	if y==120 then y=132 end
	byte=fn_next()
	local tx,ty=((byte&0xf0)>>>4)*8, (byte&0xf)*8
	printh("tx:".. tx.. " ty:"..ty)
	return function() 
		printh("Spawning lazer")
		local en = create_enemy(
			"lazer_turret",x,y,{tx,ty}
		)
		add(mobs,en)
	end
end

local dist=0
finished=false
while finished==false do
	local d,value=next(),next()
	if (d==nil or value == nil) then
		finished=true
	else
		-- printh("d:"..d.." value:"..value)
		dist+=d*8
		if value==1 then
			local fn=read_flap(next)
			if distance_spawn[dist] then
				distance_spawn[dist] = append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end
		if value==4 then
			local fn=read_green(next)
			if distance_spawn[dist] then 
				distance_spawn[dist] = append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

		if value==5 then
			local fn=read_disc(next)
			if distance_spawn[dist] then 
				distance_spawn[dist] = append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

		if value>5 and value <10 then
			local fn=read_p_up(value-5, next)
			if distance_spawn[dist] then 
				distance_spawn[dist] = append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

		
		if value==0xa then
			local fn=read_lazer_turret(next)
			if distance_spawn[dist] then 
				distance_spawn[dist] = append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end
	end
end

printh("total_dist::"..dist)
total_dist=dist


level_dat = distance_spawn

