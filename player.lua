function create_player()
	sprs=read_kv_arr(
		"muzx=-1,sx=86,pw=7,f1x=-2,f2x=1,coffx=1|"..
		"muzx=-1,sx=93,pw=8,f1x=-2,f2x=2,coffx=1|"..
		"muzx=1,sx=101,pw=11,f1x=-1,f2x=4,coffx=2|"..
		"muzx=-1,sx=112,pw=8,f1x=-2,f2x=2,coffx=1|"..
		"muzx=-1,sx=120,pw=7,f1x=-2,f2x=1,coffx=1"
	)
	local plr=create_mob(1,50,100,2,2)
	merge(plr,
		{mov=0,
		stime=0,
		can=false,
		muzy=-12,
		sy=0,
		ph=12,
		coffy=0,
		colh=8,
		soffx=0
		})

	function plr:upd()
		self.x = mid(4,self.x,123)
		self.y = mid(4,self.y,123)
		if self.stime>0 then
			self.stime=self.stime-1
		end
		if self.dx<0 then
			self.mov-=1
		elseif self.dx>0 then
			self.mov+=1
		else
			self.mov-=sgn(self.mov)
		end
		
		self.mov=mid(-15,self.mov,15)
		--choose sprite based on speed
		-- -15+ -> 1
		-- - 5 -> 2
		-- 5 -> 3
		-- 15+ - 4
		
		local idx=split("1,2,2,3,3,3,4,4,5")
		merge(self, sprs[idx[self.mov\3+5]])
		self.colw=self.pw-2*self.coffx
		self.soffx=-self.pw/2
	end


	function plr:draw()
		local offx=-self.pw/2
		local offy=-self.ph/2
		if flash>10 then
			pal(lightenpal[2])
			self.x+=(f%5-2)*2
			self.y+=(f%5-2)*2
		elseif flash>0 then
			pal(lightenpal[1])
		end
		local fy=self.y+6

		local x=self.x+offx
		local y=self.y+offy
		local fx1=x+self.f1x
		local fx2=x+self.f2x
		--flame frame
		local ffr=flr(f%16/4)
		local fspr=self.dy<0 and 
			34 or 33
		sspr(self.sx,
			self.sy,
			self.pw,
			self.ph,
			x,
			y
		)
		pal()

		if ffr~=0 then
			if ffr%2==1 then 
				pal(7,12)
				pal(12,13)
				pal(13,1)
				palt(1,true)
			end 
			if rnd()>0.3 then
				spr(fspr,fx1,fy)
			end
			if rnd()>0.3 then
				spr(fspr,fx2,fy,1,1,true)
			end
			pal()
			palt()
		end
		draw_collision(self)
	end
	return plr
end

function create_shield()
	local sh=create_mob(1,50,100,2,2)
	sh.pw,sh.ph=17,17
	function sh:upd()
		self.x,self.y=p.x,p.y
	end
	function sh:draw()
		local x,y=self.x-5,self.y-5
		if invun>0 then
			pal_idx=(f\3)%(#shield_darken_pal)+1
			spal = shield_darken_pal[pal_idx]
			for i,v in pairs(spal) do
				if v==0 then 
					palt(i, true)
				end
			end
			pal(spal)
			sspr(24,0,10,10,x-4,y-4)
			sspr(24,0,10,10,x+5,y-4,10,10,true,false)
			sspr(24,0,10,10,x-4,y+5,10,10,false,true)
			sspr(24,0,10,10,x+5,y+5,10,10,true,true)
			pal()
			palt()
		else --debug
			--invun = 20
		end
		if invun>0 then 
			draw_collision(self)
		end
	end
	return sh
end

function create_powerup(typ, x,y)
	pu=create_mob(typ+56,x,y)
	pu.typ=typ
	pu.pw=12
	pu.ph=10
	pu.dy=0.25
	function pu:draw()
		if (f\5)%4 == 1 or (f\5)%4 == 3 then
			pal(lightenpal[1])
		end
		if (f\5)%4 == 2 then
			pal(lightenpal[2])
		end

		spr(60,self.x-8,self.y-8,1,1,false,false)
		spr(60,self.x,self.y-8,1,1,true,false)
		spr(60,self.x-8,self.y,1,1,false,true)
		spr(60,self.x,self.y,1,1,true,true)
		pal()
		spr(self.s,self.x-4,self.y-4)
		draw_collision(self)
	end
	add(p_ups, pu)
	add(mobs, pu)

end