
function create_enemy(etype,x,y,props)
	local e=_ENV[
	"create_"..etype.."_e"]
	(x,y,props)
	e.flash=0
	add(enmys,e)
	
	return e 
end

function create_disc_e(x,y,spl)
	local e=create_mob(81,x,y)
	--todo extrac specific enemies
	e.dy=1
	e.sprs=split("81,82,83,84")
	e.sn=1 --sprite number
	e.hp=1
	e.spl=spl
	e.escore=50
	function e:upd()
		self.fra +=1
		self.flash=max(0, self.flash-1)
		if self.fra%5==0 then
			self.sn=self.sn%4+1
			self.s=self.sprs[self.sn]
		end
		if self.y>130 then
			remove(self)
		end

	end
	function e:move()
		merge(self,self.spl(self.fra/300))
	end

	return e
end

function create_flap_e(x,y,targety)

	local e=create_mob(93,x,y)
	e.escore=100
	--todo extrac specific enemies
	e.dy=1
	e.sprs=split("93,94,95,94")
	e.fsprs=split("77,78,79")
	e.sn=1 --sprite number
	e.hp=2
	e.targety=targety or 32
	e.pp = 30+rnd(60)
	e.frict=0.98
	e.accel=0.1

	function e:upd()
		if self.y>self.targety then
			self.dy=0
		end

		self.dx+=(p.x+p.pw/2-self.x)/self.pp*e.accel

		for i=1,3 do
			for alt in all(enmys) do
				if alt == self then
					break
				end
				if collided(create_mob(0,self.x-i*8, self.y),alt) then
				 	self.dx+=(3-i)*(self.accel/2)
				end
				if collided(create_mob(0,self.x+i*8, self.y),alt) then
					self.dx-=(3-i)*(self.accel/2)
				end
			end
		end

		self.dx=self.dx*self.frict
		self.flash=max(0, self.flash-1)
		self.fra +=1
		if self.fra%3==0 then
			self.fs=rnd(self.fsprs)
		end
		if self.fra%7==0 then
			self.sn=self.sn%4+1
			self.s=self.sprs[self.sn]
		end
		if self.y>130 then
			remove(self)
		end
		self.x=mid(4,120,self.x)
		if rnd()<1/180 then
			create_lazer_ebul(self)
		end
	end
	
	function e:draw()
		local ox=self.x-self.pw/2
		local oy=self.y-self.ph/2
		spr(self.fs,ox,oy-8)
		if e.flash>0 then
			pal(lightenpal[1])
		end
		if e.flash>2 then
			pal(lightenpal[2])
		end
		
		spr(self.s,ox,oy)
		pal()
		draw_collision(self)
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

function create_blob_e(x,y,ty)
	local e=create_mob(106,x,y)
	--todo extrac specific enemies
	e.w=2
	e.h=2
	e.dy=1
	e.sprs=split("106,108,110")
	e.sn=1 --sprite number
	e.hp=10
	e.spl=spl
	e.pw=16
	e.ph=16
	function e:upd()
		self.fra +=1
		self.flash=max(0, self.flash-1)
		if self.fra%8==0 then
			self.sn=self.sn%3+1
			self.s=self.sprs[self.sn]
		end
		self.dx=cos(self.fra/64)
		if self.y<ty then
			self.dy=1
		else self.dy=sin(self.fra/32) end

		if rnd()<1/180 then
			spinshot(self)
		end

	end
	return e
end


function create_spin_e(x,y,ty)
	local e=create_mob(106,x,y)
	--todo extrac specific enemies
	e.w=2
	e.h=2
	e.dy=1
	e.sprs=split("96,98,100,102")
	e.sn=1 --sprite number
	e.hp=10
	e.pw=16
	e.ph=16
	e.spl=spinspline
	
	function e:upd()
		self.fra +=1
		self.flash=max(0, self.flash-1)
		if self.fra%8==0 then
			self.sn=self.sn%3+1
			
			self.s=self.sprs[self.sn]
		end
		if self.y>130 then
			remove(self)
		end

	end

	function e:move()
		merge(self,self.spl(self.fra/900))
	end

	return e
end

function create_green_e(x, y, ty)
	local e=create_mob(65,x,y)
	e.dy=0.5
	e.w=1
	e.h=1
	e.hp=3
	e.ty=ty
	e.ix=x
	e.wait=180
	e.wait_dec=0
	e.sprs={65,66}
	e.fra=rnd(180)\1
	e.sn=1
	e.wiggle=2
	e.foff=rnd(30)\1
	e.escore=200
	function e:upd()

		self.fra +=1
		self.flash=max(0, self.flash-1)
		if self.fra%11==0 then
			self.sn=self.sn%2+1
			self.s=self.sprs[self.sn]
		end
		self.x=sin((f+self.foff)/30)*self.wiggle+self.ix
		self.wait-=self.wait_dec

		if self.y>=self.ty and self.wait_dec==0 then
			self.dy=0
			self.wiggle=3
			self.wait_dec = 1
		end
		if self.wait <45 then
			self.wiggle=1.2
		end
		if self.wait <30 then
			self.wiggle = 0
		end
		if self.wait<0 then
			self.dy=1.5
			self.wiggle=1.2
		end

		if self.fra%180 ==1 then
			create_lazer_ebul(self)
		end
		if self.y>130 then
			remove(self)
		end
	end


	return e
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
	local bul=create_mob(86,e.x,e.y+8)
	bul.f=-5;
	e.flash=20;
	function bul:upd()
		self.f+=1
		if (self.f>0) then
				self.dy=max(self.f/30,2)
		else 
			self.x=e.x
		end
		if self.y>130 then
			remove(self)
		end
	end
	add(ebuls, bul)
	add(mobs, bul)
end

function spinshot(mob)
	sfx(57)
	local speed=1
	local o={
		x=mob.x,
		y=mob.y,
		dx=0,
		dy=0,
		rot=0,
		dir=0.75,
		speed=speed,
		lock=false,
		turn=0.0025,
		move=def_move
	}

	if abs(p.x-mob.x) >= abs(p.y-mob.y) then
		if p.x-mob.x>0 then
			o.dir=0
			o.dx=speed
		else
			o.dir=0.5
			o.dx=-speed
		end
	else 
		if p.y-mob.y>0 then
			o.dir=0.75
			o.dy=speed
		else
			o.dir=0.25
			o.dy=-speed
		end
	end

	function o:draw()
		--0x0.5555
		--0x0.aaaa
		local rot,x,y=self.rot,self.x,self.y
		for i=1,3 do
			local x1=x+cos(rot)*3
			local y1=y+sin(rot)*3
			circ(x1,y1,1,3)
			pset(x1,y1,11)
			rot+=0x0.5555
			if self.lock then 
				pset(self.x, self.y, 8)
			end
			draw_collision(self)
		end
	end
	function o:upd()
		self.rot=(self.rot+0x0.05)%1
		self.player_ang =
			atan2(p.x-self.x,p.y-self.y)
		local ang_diff=self.player_ang-self.dir
		if abs(ang_diff)%1<0.166 then
			self.lock=true
			self.dir+=self.turn*sgn(ang_diff)
			self.dx=cos(self.dir)*self.speed
			self.dy=sin(self.dir)*self.speed
		else
			self.lock = false
		end
		self.dir%=1
		if self.x>130 or self.y>130
		 or self.x<-8 or self.y<-8 then
			remove(self)
		end
	end
	function o:move()
		self.x+=self.dx
		self.y+=self.dy
	end
	function o:col()
		return {self.x-4,self.y-4,self.x+4,self.y+5}
	end
	add(ebuls, o)
	add(mobs, o)
end