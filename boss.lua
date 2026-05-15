function add_enemy(e,pos)
	pos=pos or #mobs+1
	add(enmys,e)
	add(mobs,e,pos)
end

function mine(x1,y1,x2,y2)
	local _ENV=create_mob(23,x1,y1)
	local explosion_radius=16
	local exploding=false
	od=draw
	local darken_pal=read_kv_arr(
		"1=1,2=2,3=3,4=4,5=5,6=5,7=6,8=2,9=9,10=9,11=3,12=13,13=13,14=14,15=15|"..
		"1=0,2=0,3=1,4=1,5=1,6=5,7=6,8=2,9=4,10=9,11=3,12=13,13=1,14=8,15=6|"..
		"1=0,2=0,3=1,4=1,5=1,6=1,7=13,8=2,9=4,10=4,11=1,12=13,13=1,14=8,15=13|"..
		"1=0,2=0,3=0,4=0,5=0,6=1,7=5,8=2,9=5,10=5,11=1,12=13,13=0,14=2,15=13|"..
		"1=0,2=0,3=0,4=0,5=0,6=0,7=1,8=0,9=1,10=1,11=0,12=0,13=0,14=1,15=1|"
	)
	local warn_pal=read_kv_arr("6=14,13=8,5=2|6=7,13=8,5=8")
	function upd(_ENV)
		fra+=1
		if exploding then explosion_radius-=1.3 end
		if explosion_radius<2 then remove(_ENV) end
		exploding=fra>200
		if exploding and explosion_radius==16 then
			for m in all(mobs) do
				if m~=_ENV then
					local l,t,r,b=unpack(m:col())
					l,r,t,b=l-x,r-x,t-y,b-y
					if l*l+t*t<256 or l*l+b*b<256 or
					   r*r+t*t<256 or r*r+b*b<256 then
						m:hurt(1)
					end
				end
			end
		end
		wp=nil
		for f in all(split"100,150,175,185,190,192,194,196,198") do
			if abs(fra-f)<4 then wp=warn_pal[1] end
			if abs(fra-f)<2 then wp=warn_pal[2] end
		end
	end
	function draw(_ENV)
		pal(wp)
		if exploding then
			circfill(x,y,explosion_radius,explosion_radius>6 and 7 or 14)
			return
		end
		if fra%8<4 then fillp(0b0011001111001100)
		else fillp(0b1100111100110011) end
		if fra>45 then
			circ(x,y,16,6)
			pal(8,split"0,2,8,14"[(fra%32)\8+1])
		else
			pal(darken_pal[#darken_pal-(fra/1.5)\#darken_pal-1])
		end
		od(_ENV)
		fillp()
	end
	return _ENV
end

function boss()
	local _ENV=create_mob(128,64,-32)
	merge(_ENV,read_assoc(
		"w=6,h=4,dy=1,sn=1,hp=200,pw=48,ph=32"
	))
	sp=128 exp=0 exp2=0 pw=20 cnt=0
	phase=1 maxshots=0 tar_swing_x=64
	sc=0 hist={}
	function upd(_ENV)
		fra+=1
		rage=4-hp/50
		if hp==150 then phase=2 end
		if hp==100 then
			boss_attach(_ENV,-1)
			boss_attach(_ENV,1)
			hp=99 phase=3
		end
		if phase>1 then exp=min(exp+0.125,9) maxshots=4 end
		if phase>2 then exp2=min(exp2+0.5,18) maxshots=10 end
		pw=20+exp+exp
		flash=max(0,flash-1)
		dx=cos(fra/128)/2
		if y<24 then dy=1
		else swinging=true end
		if swinging and not spline then
			tar_swing_x=0
			while tar_swing_x==0 or x+tar_swing_x<24 or x+tar_swing_x>96 do
				tar_swing_x=(rnd(17)\1-8)*8
			end
			tar_swing_y=(rnd(5)\1-2)*16
			if y<32 then tar_swing_y=16 end
			if y>64 then tar_swing_y=-48 end
			if phase==3 then tar_swing_y=32-y end
			local spl_dat={x,y,
				x+0.5*tar_swing_x,min(y,y+tar_swing_y)-8,
				x+0.5*tar_swing_x,min(y,y+tar_swing_y)-8,
				x+tar_swing_x,y+tar_swing_y}
			spline=read_spline(spl_dat)
		elseif spline then
			sc=sc+1/64
			if sc<1 then
				dx=0 dy=0
				merge(_ENV,spline(sc))
			else
				if maxshots==0 then line_shot(_ENV,rage) end
				sc=0 spline=nil
			end
		end
		if fra%120==0 and phase==2 then
			for i=1,5 do add_enemy(mine(rnd(128),rnd(128))) end
		end
		if fra%143==0 and maxshots==0 then line_shot(_ENV,rage) end
		if fra%100==0 or fra%50==10 or fra%100==20 then
			if maxshots>0 then
				create_aim_ebul(_ENV,cnt+1)
				cnt=cnt%maxshots+1
			end
		end
		hist[fra%20]={x,y}
	end
	function draw(_ENV)
		if flash>0 then pal(lightenpal[1]) end
		if flash>2 then pal(lightenpal[2]) end
		sspr(0,64,12,32,x-12-exp,y-15)
		sspr(35,64,12,32,x+exp,y-15)
		sspr(13,64,22,32,x-11,y-15)
		spr(split"134,166,134,146"[fra\30%4+1],x-8,y-8,2,2)
		pal() palt()
		draw_collision(_ENV)
	end
	return _ENV
end

function boss_attach(boss,side)
	local _ENV=create_mob(128,0,0,1.5,4)
	ox,exp,ht=-3,0,{0,0}
	ang=0.75 prefiring=false firing=false
	rot_spd=0 countdown=120 max_countdown=120
	if side==1 then s=132.375 ox=27 end
	hp=50
	od=draw
	function draw()
		lazershot(_ENV)
		for i=0,1,0.3333 do
			spr(142,lerp(boss.x+0.5*boss.pw*side,x,i)-4,lerp(boss.y,y,i)-12)
		end
		od(_ENV)
	end
	function upd(_ENV)
		if boss.hp<=0 then remove(_ENV) return end
		flash=max(0,flash-1)
		countdown=(countdown-1)%max_countdown
		prefiring=countdown<80
		if countdown==80 then sfx(54) end
		if countdown<50 and countdown>20 then
			prefiring=false firing=true
		else firing=false end
		local h=boss.hist[(boss.fra-10)%20]
		ht=h
		exp=min(exp+0.5,18)
		flash=max(0,flash-1)
		x=h[1]+side*(pw*-0.5+boss.pw*0.5+exp)
		y=h[2]
	end
	add_enemy(_ENV,1)
end

function line_shot(e,rage)
	sfx(58,3)
	local _ENV=create_mob(86,e.x,e.y+12)
	pw,ph,f=10,2,5
	function upd(_ENV)
		f+=1
		pw+=rage
		if f>0 then _ENV.dy=min(f/15,1.5)
		else x=e.x end
		if y>130 then remove(_ENV) end
	end
	function draw(_ENV)
		line(x-0.375*pw,y,x+0.375*pw,y,11)
		line(x-0.5*pw,y-1,x-0.375*pw,y-1,11)
		line(x+0.375*pw,y-1,x+0.5*pw,y-1,11)
		for oy=1,8 do
			for i=-0.5*pw,0.5*pw do
				ly=y-oy
				if abs(i)>5 then ly-=1 end
				local cindex=rnd(5)\1+2-oy
				local c=3
				if cindex>=4 then c=11 end
				if cindex>2 then pset(x+i,ly,c) end
			end
		end
		draw_collision(_ENV)
	end
	add(ebuls,_ENV)
end
