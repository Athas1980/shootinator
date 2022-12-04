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

--single
0a,4,22

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
0a,7,99

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

14,4,f4
00,4,d4
00,4,c4
00,4,a4
00,4,84
14,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
1,5,1
10,5,2
1,5,2
1,5,2
1,5,2
1,5,2
1,5,2
1,5,2
1,5,2
1,5,2
1,5,2
1,5,2
19,4,78
00,4,98
02,4,76
00,4,96
06,4,44
00,4,54
00,4,b4
00,4,d4
03,4,46
00,4,56
00,4,b6
00,4,d6
20,5,2
1,5,2
1,5,2
0,4,7a
0,4,8a
1,5,1
0,5,2
0,4,76
0,4,86
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2

6,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2
1,5,1
0,5,2

0f,4,0e
2,4,2c
2,4,4a
2,4,69
2,4,87
2,4,a5
2,4,c3
2,4,e1

2f,1,24,8
0,1,d4,8
0,1,e4,8
6,1,26,8
0,1,d6,8

]]

--In the end this should just be a sequence of bytes
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
	local spl
	if fn_next()==1 then
		spl=spline
	else
		spl=spline2
	end

	return function()
		add(mobs,	create_enemy("disc",98,-8,spl))
	end
end

function read_p_up(idx, fn_next)
	local byte=fn_next()
	local x,y=((byte&0xf0)>>>4)*8, (byte&0xf)*8
	return function()
		create_powerup(idx, x, y)
	end
end

local dist=0
finished=false
while finished==false do
	local d,value=next(),next()
	if (d==nil or value == nil) then
		finished=true
	else
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
	end
end

printh("total_dist::"..dist)
total_dist=dist


level_dat = distance_spawn

