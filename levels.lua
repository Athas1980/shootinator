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
spawn_tab={}
function add_en(dist, func, ...)
	local existing=spawn_tab[dist]
		or {}
	add(existing, 
		{"en", func, {...}})
		spawn_tab[dist] = existing
end

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

local next=level_iter(l1st,
 l1end)
-- local next=level_iter(l1end+3,l2end)

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
		local en = green(x,ty)
		add(mobs, en)
		add(enmys, en)
	end
end

function read_flap(iter)
	local x,ty=nybles_x_8(iter())
	local hp = iter()
	return function()
	local en = flap(x,ty,hp)
	add(mobs,en)
	add(enmys, en)
	end
end

function read_spin(iter)
	local num,dur=iter(),iter()*4
	return function()
		local en = spin(
			num, dur)
		add(mobs,en)
		add(enmys, en)
	end
end

function read_disc(iter)
	local num,dur=iter(),iter()*4
	return function()
		local en = disc(
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
	local tx,ty=nybles_x_8(iter())
	return function() 
		local en = lazer(x,y,tx,ty)

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
	printh("countdown:" .. countdown .. " life:"..life)
	return function() 
		local en = static(
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


local types=multisplit([[
en,flap,x:nib*8,ty:nib*8,hp:byte
en,static,x:nib*8,y:nib*8,tx:nib*8,ty:nib*8,ang:nib/16,_:nib_unused,cd:byte*4,life:byte*4
noop,
en,green,x:nib*8,ty:nib*8
en,disc,num:byte,dur:byte*4
pup,create_powerup,x:nib*8,y:nib*8
pup,create_powerup,x:nib*8,y:nib*8
pup,create_powerup,x:nib*8,y:nib*8
pup,create_powerup,x:nib*8,y:nib*8
en,lazer,x:nib*8,y:nib*8,tx:nib*8,ty:nib*8
en,spin,num:byte,dur:byte*4
]],"\n,")

local next=level_iter(l1st,
 l1end)

function read_type(type, iter, idx)
	if type[1]=="noop" then
		return
	end
	local class=type[1]
	local func_name=type[2]
	local str=func_name
	local func=_ENV[func_name]
	assert(func != nil, func_name)
	local params={}
	if class=="pup" then
		add(params, idx-5)
	end
	local i=3
	while i<=#type do
		local byte=iter()
		local pname,ptype=
			unpack(split(type[i],":"))

		local function transform_nib(
			name, nib, subtype)
			if sub(subtype,-6)=="unused"
			then return end
			if sub(subtype,-2)=="*8" then
				nib*=8
			end
			if sub(subtype,-3)=="/16" then
				nib/=16
			end
			str..=","..name..":"..nib
			add(params, nib)
		end

		local function transform_byte(
			name, byte, subtype)
			if sub(subtype,-6)=="unused"
			then return end

			if sub(subtype,-2)=="*4" then
				byte*=4
			end
			if sub(subtype,-2)=="*6" then
				byte*=6
			end
			add(params, byte)
			str..=","..name..":"..byte
		end

		if sub(ptype,1,3)=="nib" then
			--reading a nybble need to
			--read both
			local nib1,nib2 = nybles(byte)
			transform_nib(pname,
				nib1, ptype
			)
			i+=1
			pname,ptype=unpack(split(type[i],":"))
			transform_nib(pname,
				nib2, ptype
			)
		end
		if sub(ptype,1,4)=="byte" then
			transform_byte(pname,
			byte, ptype)
		end
		i+=1
	end

	local details={
		class=class,
		typ=func_name,
		func=func,
		params=params
	}
	setmetatable(details, {
		__tostring=function()
			return str end})
			printh(details)
			return details
end

local dist,finished=0,false
while finished==false do
	local d,val=next(),next()
	if d==nil or val == nil then
		finished=true
	else
		dist+=d*8
		local type=types[val]
		assert(type ~= nil, "val:"..val.." gave nil type")

		local existing=spawn_tab[dist]
		or {}
		add(existing,
			read_type(type, next, val))
		spawn_tab[dist] = existing
	end
end


total_dist=dist


level_dat = distance_spawn

