pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	mobs={}
	for i=1,10 do
		local cm=circ_mob(
		rnd(128),rnd(128),rnd(),rnd())
		local rm=rect_mob(
		rnd(128),rnd(128),rnd(),rnd())
		add(mobs,cm)
		add(mobs,rm)
	end
end

function _update60()
	for m in all(mobs) do
		m:upd()
	end
end

function _draw()
	cls(0)
	for m in all(mobs) do
		m:draw()
	end
end

function create_mob(x1,y1,dx1,dy1)
	local mob={
		x=x1,
		y=y1,
		dx=dx1,
		dy=dy1,
		upd=function(_ENV)
			printh("upd x:"..x.. " y:"..y)
			x=x+dx
			y=y+dy
			if(x>128 or x<0) dx=-dx
			if(y>128 or y<0) dy=-dy
		end
	}
	setmetatable(mob,{__index=_ENV})
	return mob
end

function circ_mob(x1,y1,dx1,dy1)
	local _ENV=create_mob(x1,y1,dx1,dy1)
	function draw(_ENV)
		circfill(x,y,3,11)
	end
	return _ENV
end

function rect_mob(x1,y1,dx1,dy1)
	local _ENV=create_mob(x1,y1,dx1,dy1)
	function draw(_ENV)
		rectfill(x,y,x+3,y+3,14)
	end
	return _ENV
end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
