function create_player()
	sprs=read_kv_arr(
		"muzx=-1,sx=86,pw=7,f1x=-2,f2x=1,coffx=1|"..
		"muzx=-1,sx=93,pw=8,f1x=-2,f2x=2,coffx=1|"..
		"muzx=1,sx=101,pw=11,f1x=-1,f2x=4,coffx=2|"..
		"muzx=-1,sx=112,pw=8,f1x=-2,f2x=2,coffx=1|"..
		"muzx=-1,sx=120,pw=7,f1x=-2,f2x=1,coffx=1"
	)
	local plr=create_mob(1,64,80,2,2)
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

	function plr.upd(_ENV)
		x = mid(4,x,123)
		y = mid(4,y,123)
		if stime>0 then
			stime=stime-1
		end
		if dx<0 then
			mov-=1
		elseif dx>0 then
			mov+=1
		else
			mov-=sgn(mov)
		end
		
		mov=mid(-15,mov,15)
		--choose sprite based on speed
		-- -15+ -> 1
		-- - 5 -> 2
		-- 5 -> 3
		-- 15+ - 4
		
		local idx=split("1,2,2,3,3,3,4,4,5")
		merge(_ENV, sprs[idx[mov\3+5]])
		colw=pw-2*coffx
		soffx=-pw/2

		if lives and lives <2 then

			add(pparts, 
			create_ppart(
				x-4+rnd(8),
				y,
				rnd(0.25)-.05,
				rnd(2)+1,
				20,
				20,
				rnd({5,6,9})))
		end
	end


	function plr.draw(_ENV)
		local offx=-pw/2
		local offy=-ph/2
		local pal, palt, sspr =_g.pal, _g.palt, _g.sspr
		if flash>10 then
			pal(lightenpal[2])
			x+=(f%5-2)*2
			y+=(f%5-2)*2
		elseif flash>0 then
			pal(lightenpal[1])
		end
		local fy=y+6

		local x=x+offx
		local y=y+offy
		local fx1=x+f1x
		local fx2=x+f2x
		--flame frame
		local ffr=_g.flr(f%16/4)
		local fspr=dy<0 and	34 or 33
		_g.sspr(sx, sy,	pw,	ph, x, y)
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
		draw_collision(_ENV)
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
		local x,y=self.x-6,self.y-5
		if invun>0 then
			if invun<40 and (invun/2)%2==0 then
				return
			end
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

function create_powerup(_typ, _x,_y)
	pu=create_mob(_typ+55,_x,_y)
	pu.typ=_typ
	pu.pw=12
	pu.ph=10
	pu.dy=0.25
	pu.life=240
	function pu.draw(_ENV)
		if (life<60 and (f/2)%2 == 0)
			or (life<30 and (f/3)%2 >0)
		then
			return
		end
		if (f\5)%4 == 1 or (f\5)%4 == 3 then
			pal(lightenpal[1])
		end
		if (f\5)%4 == 2 then
			pal(lightenpal[2])
		end

		spr(60,x-8,y-8,1,1,false,false)
		spr(60,x,y-8,1,1,true,false)
		spr(60,x-8,y,1,1,false,true)
		spr(60,x,y,1,1,true,true)
		pal()
		spr(s,x-4,y-4)
		draw_collision(_ENV)
	end

	function pu.upd(_ENV)
		life-=1
		if x >128 or y>160
		or x<-8 or y<-8
		or life<0 then
			remove(_ENV)
		end
	end
	add(p_ups, pu)
	add(mobs, pu)

end