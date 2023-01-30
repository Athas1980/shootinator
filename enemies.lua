
function create_enemy(etype,x,y,props)
	local e=_ENV[
	"create_"..etype.."_e"]
	(x,y,props)
	e.flash=0
	add(enmys,e)
	
	return e 
end

function create_disc_e(_x,_y,_spl,_dur)
	local _ENV=create_mob(81,_x,_y)
	
	merge(_ENV, read_assoc("dy=1,sn=1,hp=1,escore=50"))
	sprs=split("81,82,83,84")
	spl=_spl
	dur=_dur
	function upd(_ENV)
		fra +=1
		flash=max(0, flash-1)
		if fra%5==0 then
			sn=sn%4+1
			s=sprs[sn]
		end
		if (fra/dur == 1) then 
			remove(_ENV)
		end
	end
	function move(_ENV)

		merge(_ENV,spl(fra/dur))
	end

	return _ENV
end

function create_flap_e(x1,y1,target_y)

	local e=create_mob(93,x1,y1)
	local props=read_assoc("escore=100,dy=1,sn=1,hp=2,frict=0.98,accel=0.1")
	
	merge(e,props)
	
	local _ENV = e
	sprs=split("93,94,95,94")
	fsprs=split("77,78,79")
	targety=target_y or 32
	pp = 30+rnd(60)
	
	function e.upd(_ENV)
		if y>targety then
			dy=0
		end

		dx+=(p.x+p.pw/2-x)/pp*accel

		for i=1,3 do
			for alt in all(enmys) do
				if alt == self then
					break
				end
				if collided(create_mob(0,x-i*8, y),alt) then
				 	dx+=(3-i)*(accel/2)
				end
				if collided(create_mob(0,x+i*8,y),alt) then
					dx-=(3-i)*(accel/2)
				end
			end
		end

		dx*=frict
		flash=max(0, flash-1)
		fra +=1
		if fra%3==0 then
			fs=rnd(fsprs)
		end
		if fra%7==0 then
			sn=sn%4+1
			s=sprs[sn]
		end
		if y>130 then
			remove(_ENV)
		end
		x=mid(4,120,x)
		--fixme remove randomness
		if rnd()<1/180 then
			create_lazer_ebul(_ENV)
		end
	end
	
	function e.draw(_ENV)
		local ox=x-pw/2
		local oy=y-ph/2
		spr(fs,ox,oy-8)
		if e.flash>0 then
			pal(lightenpal[1])
		end
		if e.flash>2 then
			pal(lightenpal[2])
		end
		
		spr(s,ox,oy)
		pal()
		draw_collision(_ENV)
	end
	return e
end
--- flips all the x points
-- @param pts The points to mirror
-- @return a table with flipped string
function flip_pts_x(pts)
	local output={}
	for i=1,#pts,2 do
		add(output,128-pts[i])
		add(output,pts[i+1])
	end
	return output
end

function create_blob_e(x1,y1,ty1)
	local _ENV=create_mob(106,x1,y1)
	--todo extrac specific enemies
	merge(_ENV, read_assoc(
		"w=2,h=2,dy=1,sn=1,hp=10,pw=16,ph=16"
	))
	sprs=split("106,108,110")
	ty=ty1
	function upd(_ENV)
		fra +=1
		flash=max(0, flash-1)
		if fra%8==0 then
			sn=sn%3+1
			s=sprs[sn]
		end
		dx=cos(fra/64)
		if y<ty then
			dy=1
		else dy=sin(fra/32) end

		if rnd()<1/180 then
			spinshot(_ENV)
		end

	end
	return _ENV
end

-- FIXME logic for this is
-- the same as a disc
function create_spin_e(_x,_y,props)
	local _ENV=create_mob(106,_x,_y)
	shot_times={60,10,10}
	t_idx=1
	local shot_time=shot_times[1]
	
	merge(_ENV, read_assoc(
		"w=2,h=2,dy=1,sn=1,hp=10,pw=16,ph=16"
	))
	sprs=split("96,98,100,102")
	spl,dur=unpack(props)
	
	function upd(_ENV)
		shot_time-=1
		if shot_time<0 then 
			--shoot
			shot_time=shot_times[t_idx]
			t_idx=(t_idx + 1)%#shot_times +1
			create_aim_ebul(_ENV)
		end
		fra +=1
		flash=max(0, flash-1)
		if fra%8==0 then
			sn=sn%3+1
			s=sprs[sn]
		end
		if (fra/dur == 1) then 
			remove(_ENV)
		end



	end

	function move(_ENV)
		merge(_ENV,spl(fra/dur))
	end

	return _ENV
end


function create_green_e(x1, y1, ty1)
	local _ENV=create_mob(65,x1,y1)
	merge (_ENV, read_assoc(
		"dy=0.5,w=1,h=1,hp=3,wait=180,wait_dec=0,sn=1,wiggle=2,escore=200"
	))
	ty=ty1
	ix=x
	sprs={65,66}
	fra=rnd(180)\1
	foff=rnd(30)\1
	function upd(_ENV)
		
		fra +=1
		
		flash=max(0, flash-1)
		if fra%11==0 then
			sn=sn%2+1
			s=sprs[sn]
		end
		x=sin((f+foff)/30)*wiggle+ix
		wait-=wait_dec

		if y>=ty and wait_dec==0 then
			dy=0
			wiggle=3
			wait_dec = 1
		end
		if wait <45 then
			wiggle=1.2
		end
		if wait <30 then
			wiggle = 0
		end
		if wait<0 then
			dy=1.5
			wiggle=1.2
		end

		if fra%180 ==1 then
			create_lazer_ebul(_ENV)
		end
		if y>130 then
			remove(_ENV)
		end
	end


	return _ENV
end

function create_launcher_e()
	local e=create_mob(131,128,64,3,2)
	e.hp=10
	olddraw=e.draw
	function e:upd()
		self.fra +=1
		self.flash=max(0, self.flash-1)
	end
	function e:draw()
			palt(0,false)
			palt(14,true)
			olddraw(self)

			local bulpos=116-f%136
			spr(75,bulpos,self.y-4,2,1)
			spr(91,bulpos+16,self.y-5)
			palt(14,true)
			palt(0,true)
			clip(self.x-self.pw/2+5,0,128,128)
			olddraw(self)
			palt()
			pal()
			clip()
	end
	return e
end

function create_skull_e()
	local e=create_mob(71,64,32,2,2)
	return e
end

function create_lazer_turret_e(_x,_y,props)
	local _ENV=create_mob(45,_x,_y,1,1)
	hp=10
	ang=0
	ox=x
	oy=y
	tx,ty=unpack(props)
	rot_spd=0x.01
	countdown=60+rnd(120)\1
	toff=rnd()*10
	olddraw=draw
	prefiring=false
	firing=false
	max_countdown=120

	function move()
		local dir = atan2(tx-ox,ty-oy)
		ox,oy=ox+cos(dir)*.5,oy+sin(dir)*.5
		x,y=ox+8*cos(toff+t()/2),oy+8*sin(toff+t()/4) 
	end
	function upd(_ENV)
		flash=max(0, flash-1)
		local player_ang =
			atan2(p.x-x,p.y-y)
		local ang_diff=player_ang-ang
		if abs(ang_diff)>0.5 then
			ang_diff=-ang_diff
		end
		ang+=rot_spd*sgn(ang_diff)
		ang%=1
		
		countdown=(countdown-1)%max_countdown
		prefiring= countdown<60
		if countdown==60 then
			sfx(54)
		end
		if countdown<30 then
			prefiring=false
			firing=true
		else firing =false
		end
	end

	function draw(_ENV)

		if flash>0 then
			pal(lightenpal[1])
		end
		if flash>2 then
			pal(lightenpal[2])
		end

		local ca,sa= cos(ang), sin(ang)
		local xoff,yoff= ca*200, sa*200
		if (prefiring) then
			--rectfill(0,0,128,128,1)
			
			fillp(abs(xoff)>abs(yoff) and ▥ or ▤)
			if (countdown<40) fillp()
			line(x,y,x+xoff, y+yoff,countdown<45 and 8 or 2 )
			fillp()
		end

		if (firing) then
			local cx,cy=0,0
			if abs(xoff)>abs(yoff) then
				cy=1
			else
				cx=1
			end

			local c=9
			line(x,y,x,y,0)
			
			for i=0, 200 do
				local v=(i/10 - t()*7)%1
				local partx,party= i, cos(v)*4
				partx,party= ca*partx-sa*party+x, sa*partx +ca*party+y
				line(partx,party, 2)
			end

			line(x-cx,y-cy,x-cx+xoff,y-cy+yoff,14)
			line(x+cx,y+cy,x+cx+xoff,y+cy+yoff,14)
			line(x,y, x+xoff,y+yoff,7)
			if line_rect_isect(
				x,y,x+xoff,y+yoff,
				unpack(p:col())) then
					hurt_player()
			end

			for i=0, 128, 0.5 do
				local v=(i/10 - t()*7)%1
				local c=9
				if (v>0.45) then
					local partx,party= i, cos(v)*4
					partx,party= ca*partx-sa*party+x, sa*partx +ca*party+y
					pset(partx, party, 8)
				end
			end
		end
		
		circfill(x+cos(ang)*4, y+sin(ang)*4,3,1)
		sspr(104,16,11,11,x-5,y-5)
		pal()


		draw_collision(_ENV)
	end

	return _ENV
end

function lerp(v,tv,t)
	return v +(tv-v)*t
end

function create_static_turret_e
		(_x,_y,props)
	local _ENV=create_lazer_turret_e
		(_x,_y,props)
	_,_,ang,countdown,life=
		unpack(props)
		max_countdown=countdown
	f,rot_spd=0,0
	function move()
		f+=1
		printh("life:"..life.." f:"..f.."life-120:".."life")
		if f>life then
			remove(_ENV)
		end
		if f<120 then
			x=lerp(x,tx,easeinoutquart(f/120))
			y=lerp(y,ty,easeinoutquart(f/120))
		end
		if f+120>life then
			printh(((120+f-life)/120))
			x=lerp(tx,_x,easeinoutquart((120+f-life)/120))
			y=lerp(ty,_y,easeinoutquart((120+f-life))/120)
		end
	end

	olddraw = draw
	function draw()
		olddraw(_ENV)
		print(tostr(ang*16,true)[6], x,y,7)
	end
	return _ENV
end

function create_lazer_ebul(e)
	sfx(58,3)
	local _ENV=create_mob(86,e.x,e.y+8)
	f=-5;
	e.flash=20;
	function upd(_ENV)
		f+=1
		if (f>0) then
				dy=max(f/60,1.5)
		else 
			x=e.x
		end
		if y>130 then
			remove(_ENV)
		end
	end
	add(ebuls, _ENV)
	add(mobs, _ENV)
end

function create_aim_ebul(e)
	sfx(58,3)
	local _ENV=create_mob(64,e.x,e.y+8)
	colw=2
	colh=2
	sprs = {64,80}
	f=-5;
	e.flash=5;
	sn=0
	
	local ang = atan2(p.x-e.x, p.y-e.y)
	dx,dy=cos(ang)*1.5,sin(ang)*1.5
	function upd(_ENV)
		f+=1

		fra+=1
		if fra%5==0 then
			sn=sn%2+1
			s=sprs[sn]
		end

		-- sp=fra
		-- FIXME need a more
		-- omprehensive out of bounds
		if y>130 then
			remove(_ENV)
		end
	end
	add(ebuls, _ENV)
	add(mobs, _ENV)
end

function spinshot(mob)
	sfx(57)
	local spd=1
	local _ENV=create_mob(0,mob.x,mob.y)
	merge(_ENV, read_assoc(
		"dx=0,dy=0,rot=0,dir=0.75,turn=0.0025"
	))
	x=mob.x
	y=mob.y
	lock=false
	speed=spd
	move=def_move

	if abs(p.x-mob.x) >= abs(p.y-mob.y) then
		if p.x-mob.x>0 then
			dir=0
			dx=spd
		else
			dir=0.5
			dx=-spd
		end
	else 
		if p.y-mob.y>0 then
			dir=0.75
			dy=spd
		else
			dir=0.25
			dy=-spd
		end
	end

	function draw(_ENV)
		--0x0.5555
		--0x0.aaaa
		
		for i=1,3 do
			local x1=x+cos(rot)*3
			local y1=y+sin(rot)*3
			circ(x1,y1,1,3)
			pset(x1,y1,11)
			rot+=0x0.5555
			if lock then 
				pset(x, y, 8)
			end
			draw_collision(_ENV)
		end
	end
	function upd(_ENV)
		rot=(rot+0x0.05)%1
		player_ang =
			atan2(p.x-x,p.y-y)
		local ang_diff=player_ang-dir
		if abs(ang_diff)%1<0.166 then
			lock=true
			dir+=turn*sgn(ang_diff)
			dx=cos(dir)*speed
			dy=sin(dir)*speed
		else
			lock = false
		end
		dir%=1
		if x>130 or y>130
		 or x<-8 or y<-8 then
			remove(_ENV)
		end
	end
	function move(_ENV)
		x+=dx
		y+=dy
	end
	function col()
		return {x-4,y-4,x+4,y+5}
	end
	add(ebuls, _ENV)
	add(mobs, _ENV)
end

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

--[sfx]0100004927492f4927492f492b4927492f6e186c166916661262165f145d125a165716541251144001400140014001400140014001400140014001400140014001400104050000[/sfx]
--[sfx]01000049274a2f4b274b2f4c2b4e27502f7b1874166d1666125f165a14561252164d16491246144001400140014001400140014001400140014001400140014001400104050000[/sfx]
