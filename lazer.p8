pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
	ang=0
	turn=1/512

	obsticles={
		{
			x1=20,
			y1=10,
			x2=28,
			y2=18,
			colour=11
		},

		{
			x1=40,
			y1=60,
			x2=56,
			y2=66,
			colour=11
		}
	}

	location={64,64}
	
end

function _update60()
	ang=ang+turn
	ang%=1

	if btn(⬆️) then
	location[2] -=1
	end
	if btn(⬇️) then
	location[2] +=1
	end
	if btn(⬅️) then
		location[1] -=1
	end
	if btn(➡️) then
		location[1] +=1
	end
	
end

function _draw()
	cls()
	local x,y=location[1],location[2]
	local ca,sa = cos(ang), sin(ang)
	local offx =ca*128
	local offy =sa*128
	local cx,cy=0,0
	if abs(offx)>abs(offy) then
		cy=1
	else
	 cx=1
	end

	local c=9
	line(x,y,x,y,0)
	for i=0, 128 do
		local v=(i/10 - t()*7)%1
		local partx,party= i, cos(v)*4
		partx,party= ca*partx-sa*party+location[1], sa*partx +ca*party+location[2]
		line(partx,party, 2)
	end

	line(x-cx,y-cy,x-cx+offx,y-cy+offy,14)
	line(x+cx,y+cy,x+cx+offx,y+cy+offy,14)
	line(x,y, x+offx,y+offy,7)

	for i=0, 128, 0.5 do
		local v=(i/10 - t()*7)%1
		local c=9
		if (v>0.45) then
			local partx,party= i, cos(v)*4
			partx,party= ca*partx-sa*party+location[1], sa*partx +ca*party+location[2]
			pset(partx, party, 8)
		end
	end
	
	circfill(location[1]+cos(ang)*4, location[2]+sin(ang)*4,3,1)
	circ(location[1]+cos(ang)*4, location[2]+sin(ang)*4,3,2)
	
	sspr(8,0,11,11,location[1]-5,location[2]-5)

	for i=0,1,1/8 do 
		pset(location[1]+cos(i+ang)*4, location[2]+sin(i+ang)*4,3)
		pset(location[1]+cos(i+ang)*5, location[2]+sin(i+ang)*5,3)
	end
	function calculate_hit(ob) 
		if line_rect_isect(x,y,x+offx,y+offy, ob.x1, ob.y1, ob.x2, ob.y2) then
			ob.colour=8
		else
			ob.colour=11
		end
	end

	foreach(obsticles, calculate_hit)
	foreach(obsticles, drect)
	
	if check==line_rect_isect then
		print("original",0,0,7)
	else
		print("updated",0,0,7)
	end
	print("❎ to change")
end

-- line/rect intersect test by aek.
-- cc0 (but credit appreciated).
-- token optimisation by heracleum
function line_rect_isect(x0, y0, x1, y1, l, t, r, b)
 local xm,ym=x1-x0,y1-y0
 local tl, tr, tt, tb =
  (l - x0) / xm,
  (r - x0) / xm,
  (t - y0) / ym,
  (b - y0) / ym
 return max(0, max(min(tl, tr), min(tt, tb))) <
        min(1, min(max(tl, tr), max(tt, tb)))
end

function drect(ob)
	rect(ob.x1,ob.y1,ob.x2,ob.y2,ob.colour)
end


__gfx__
00000000000cc111000e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007d1551100e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070007d11155110e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000cd11ddd15d1e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000c11dcccd511e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700155dc7cd511e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000511dcccd551e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001d11ddd1d15e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005551511d10e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000111551100e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000001d111000e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000