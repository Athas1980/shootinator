-- for byte in all(dat) do
--  printh(byte)
-- end
local l1st,l1end=0x2102,
	peek2(0x2100)+0x2102
local l2end=peek2(l1end+1)+l1end

function level_iter(start, max)
	local i=start-1
	return function()
		i+=1
		if (i>max) return nil
		return peek(i)
	end
end

local distance_spawn={}

local function append(f2, f1)
	return function() f1() f2() end
end

setmetatable(distance_spawn,
	{__add = 
	function(ds, tbl)
		local idx,fn = unpack(tbl)
		local existing= ds[idx]
		local to_add=fn
		if (existing) then
			to_add= function()
				fn()
				existing()
			end
			end
		ds[idx]=to_add
		return ds
	end}
)

local next=level_iter(l1end+2,
 l2end)



function nybles_x_8(byte)
	return ((byte&0xf0)>>>4)*8,
		(byte&0xf)*8
end

function read_green(iter)
	local x,ty=nybles_x_8(iter())
	return function()
		add(mobs,create_enemy(
			"green", x, -8, ty))
	end
end

function read_flap(iter)
	local x,ty=nybles_x_8(iter())
	local hp = iter()
	return function()
	local en = create_enemy(
		"flap", x, -8, ty)
	en.hp=hp
	en.escore=hp*100
	add(mobs,en)
	end
end

function read_spin(iter)
	local num,dur=iter(),iter()*4
	return function()
		local en = create_enemy(
			"spin",
			128,-8,
			{splines[num], dur})
		add(mobs,en)
	end
end

function read_disc(iter)
	local num,dur=iter(),iter()*4
	return function()
		local en = create_enemy(
			"disc",98,-8, splines[num]
		)
		en.dur=dur
		add(mobs,en)
	end
end

function read_p_up(idx, iter)
	local x,y=nybles_x_8(iter())
	return function()
		create_powerup(idx, x, y)
	end
end

function read_lazer_turret(iter)
	local x,y=nybles_x_8(iter())
	if x==0 then x=-8	end
	if y==0 then	y=-8	end
	if x==120 then x=132 end
	if y==120 then y=132 end
	local tx,ty=nybles_x_8(iter())
	return function() 
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
	if d==nil or value == nil then
		finished=true
	else
		dist+=d*8
		if value==1 then
			local fn=read_flap(next)
			if distance_spawn[dist] then
				distance_spawn[dist]=
				append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end
		if value==4 then
			local fn=read_green(next)
			if distance_spawn[dist] then 
				distance_spawn[dist]=
				append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

		if value==5 then
			local fn=read_disc(next)
			if distance_spawn[dist] then 
				distance_spawn[dist]=
				append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

		if value>5 and value <10 then
			local fn=read_p_up(value-5, next)
			if distance_spawn[dist] then 
				distance_spawn[dist]=
				append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

		
		if value==0xa then
			local fn=read_lazer_turret(next)
			distance_spawn += {dist, fn}
			-- if distance_spawn[dist] then 
			-- 	_= distance_spawn + {dist,fn}
			-- 	-- append(fn, distance_spawn[dist])
			-- else 
			-- 	distance_spawn[dist]=fn
			-- end
		end

		if value==0xb then
			local fn=read_spin(next)
			if distance_spawn[dist] then 
				distance_spawn[dist]
				=append(fn, distance_spawn[dist])
			else 
				distance_spawn[dist]=fn
			end
		end

	end
end

printh("total_dist::"..dist)
total_dist=dist


level_dat = distance_spawn

