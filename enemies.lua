
function create_enemy(etype,x,y,props)
	local e=_ENV[
	"create_"..etype.."_e"]
	(x,y,props)
	e.flash=0
	add(enmys,e)
	
	return e 
end

function create_disc_e(_x,_y,_spl)
	local _ENV=create_mob(81,_x,_y)
	
	merge(_ENV, read_assoc("dy=1,sn=1,hp=1,escore=50"))
	sprs=split("81,82,83,84")
	spl=_spl

	function upd(_ENV)
		fra +=1
		flash=max(0, flash-1)
		if fra%5==0 then
			sn=sn%4+1
			s=sprs[sn]
		end
		if y>130 then
			remove(_ENV)
		end

	end
	function move(_ENV)
		merge(_ENV,spl(fra/300))
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


function create_spin_e(_x,_y)
	local _ENV=create_mob(106,_x,_y)
	merge(_ENV, read_assoc(
		"w=2,h=2,dy=1,sn=1,hp=10,pw=16,ph=16"
	))
	sprs=split("96,98,100,102")
	spl=spinspline
	
	function upd(_ENV)
		fra +=1
		flash=max(0, flash-1)
		if fra%8==0 then
			sn=sn%3+1
			s=sprs[sn]
		end
		if y>130 then
			remove(_ENV)
		end

	end

	function move(_ENV)
		merge(_ENV,spl(fra/900))
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

function create_lazer_ebul(e)
	sfx(58,3)
	local _ENV=create_mob(86,e.x,e.y+8)
	f=-5;
	e.flash=20;
	function upd(_ENV)
		f+=1
		if (f>0) then
				dy=max(f/30,2)
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