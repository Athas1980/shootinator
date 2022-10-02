pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
	poke(0x5f2d, 1)
	step=0x0.008
	pos=0
	spline = read_spline(split("123,-17,124,-3,127,7,117,8,117,8,81,12,9,-12,9,20,9,20,9,43,118,3,117,37,117,37,116,68,8,27,8,63,8,63,8,94,117,51,117,80,117,80,117,109,8,71,8,100,8,100,8,127,124,107,125,119,125,119,126,124,119,130,123,136"))

	sprite_location = {x=0,y=0}

	ctrl_v = press_watcher(
		ctrl_and_v_down
	)

end

function _update60()
	if ctrl_v() then
		handle_paste()
	end

	if pos>=1-step and step>0 then
		step=-step
	elseif pos<=0 and step<0 then
		step=-step
	end

	pos+=step
	sprite_location = spline(pos)
end

function _draw()
	cls()
	--some points from the curve
	for i=0,1,1/64 do
		local pt = spline(i)
		pset(pt.x, pt.y,1)
	end
	--draw sprite at current location
	spr(1, sprite_location.x, sprite_location.y)
end
-->8
--read spline


--distance vunerable to overflow
function pdist(p1,p2) 
	return ((p2.x-p1.x)^2+(p2.y-p1.y)^2)^0.5
end

--cubic bezier single dimension
function cub_b_p(a,b,c,d,t)
	local tm=1-t
	return tm*tm*tm*a+
		tm*tm*3*t*b+
		tm*3*t*t*c+
		t*t*t*d
end

--cubic bezier x&y
function cub_bez(p1,p2,p3,p4,t)
	return {x=cub_b_p(p1.x,
	p2.x,
	p3.x,
	p4.x,
	t),
	y=cub_b_p(p1.y,
	p2.y,
	p3.y,
	p4.y,
	t)}
end

--read splines
--expected table with multiple
--of 8 entries.
--p1.x,p1.y
function read_spline(points)
	local curves,dists,td={},{},0
	local limits={0}
	for i=1,#points,8 do
		local pts={}
		for j=i,i+8,2 do
			add(pts, {
			x=points[j],
			y=points[j+1]})
		end
		local function c(t)
			return cub_bez(
				pts[1],
				pts[2],
				pts[3],
				pts[4],
				t)
		end
		local d=0
		for j=0x0.1,1,0x0.1 do
			d+=pdist(c(j-0x0.1),c(j))
		end
		add(curves,c)
		add(dists,d)
		td+=d
	end
	
	local l=0
	for d in all(dists) do
		l+=d/td
		add(limits,l)
	end

	limits[#limits]=1
	
	local function spl(t)
		if t==1 then 
			return curves[#curves](1)
		end


		local i,l=1,0
		while t>=l do
			i+=1
			l=limits[i] or 1
		end
		local ol=limits[i-1]
		local fact=1/(l-ol)
		local t2=(t-ol)*fact
		return curves[i-1](t2)
	end
	--return curves
	return spl
end
-->8
--paste



function control_down()
	local lctrl=stat(28,224)
	local rctrl=stat(28,228)
	return lctrl or rctrl
end

function ctrl_and_v_down()
	local v_down=stat(28,25)
	return control_down and v_down
end

function handle_paste()
	printh("pasting")
	local str = stat(4)
	if str[1] == '"' then 
		str=sub(str,2)
	end
	if str[#str] =='"' then
		str=sub(str,1,#str-1)
	end
	spline=read_spline(split(str))
end

-- emits true when watched
-- changes from false to true
function press_watcher(watched)
	local prev={}
	return function()
		local cval=watched()
		local r=cval and not prev[1]
		prev[1]=cval
		return r
	end
end

__gfx__
00000000049aa9400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000049aaaa940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007009a8aa8a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aa8aa8aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070098e99e890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000498888940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000049aa9400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
