local l1st,l1end=0x2102,
	peek2(0x2100)+0x2101
local l2end=peek2(l1end+1)+l1end+2

function level_iter(start, max)
	local i=start-1
	return function()
		i+=1
		return i<=max and peek(i) or nil
	end
end

local distance_spawn={}

function add_dat(dist, fn) 
	local existing=distance_spawn[dist]
	local to_add=fn
	if (existing) then
		to_add= function()
			fn()
			existing()
		end
		end
		distance_spawn[dist]=to_add
end

-- local next=level_iter(l1st,
--  l1end)
local next=level_iter(l1end+3,l2end)

function nybles_x_8(byte)
	return ((byte&0xf0)>>>4)*8,
		(byte&0xf)*8
end
function nybles(byte)
		return (byte&0xf0)>>>4,
			byte&0xf
end

function noop() end

function read_green(iter)
	local x,ty=nybles_x_8(iter())
	return function()
		local en = create_green_e(x,ty)
		add(mobs, en)
		add(enmys, en)
	end
end

function read_flap(iter)
	local x,ty=nybles_x_8(iter())
	local hp = iter()
	return function()
	local en = create_flap_e(x,ty,hp)
	add(mobs,en)
	add(enmys, en)
	end
end

function read_spin(iter)
	local num,dur=iter(),iter()*4
	return function()
		local en = create_spin_e(
			num, dur)
		add(mobs,en)
		add(enmys, en)
	end
end

function read_disc(iter)
	local num,dur=iter(),iter()*4
	return function()
		local en = create_disc_e(
			num,dur
		)
		en.dur=dur
		add(mobs,en)
		add(enmys,en)
	end
end

function read_p_up(iter,idx)
	local x,y=nybles_x_8(iter())
	return function()
		create_powerup(idx-5, x, y)
	end
end

function read_lazer_turret(iter)
	local x,y=nybles_x_8(iter())
	if x==0 then x=-8 end
	if y==0 then y=-8 end
	if x==120 then x=132 end
	if y==120 then y=132 end
	local tx,ty=nybles_x_8(iter())
	return function() 
		local en = create_lazer_turret_e(
			x,y,tx,ty
		)
		add(enmys,en)
		add(mobs,en)
	end
end
--_,_,ang,countdown,life

function read_static(iter)
	local x,y=nybles_x_8(iter())
	local tx,ty=nybles_x_8(iter())
	local ang=nybles(iter())/16
	local countdown=iter()*4
	local life=iter()*4
	if x==0 then x=-8 end
	if y==0 then y=-8 end
	if x==120 then x=132 end
	if y==120 then y=132 end

	return function() 
		local en = create_static_turret_e(
			x,y,tx,ty,ang,countdown,life
		)

		add(enmys,en)
		add(mobs,en)
	end
end

local funcs={
	read_flap, --1
	read_static, --2
	noop, --3
	read_green, --4
	read_disc,--5
	read_p_up, --6
	read_p_up, --7
	read_p_up, --8
	read_p_up, --9
	read_lazer_turret, --a
	read_spin,--b
}

local dist,finished=0,false
while finished==false do
	local d,val=next(),next()
	if d==nil or val == nil then
		finished=true
	else
		dist+=d*8
		local fn=funcs[val](next, val)
		add_dat(dist, fn)
	end
end

total_dist=dist


level_dat = distance_spawn

printh("len:"..#level_dat)

