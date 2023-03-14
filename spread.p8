pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
	poke(0X5F57,0x10)
	show_collision=false
	states={
		game={
			draw=draw_game,
			update=update_game
		},
		intro={
			draw=draw_level_intro,
			update=update_level_intro
		},
		title={
			draw=draw_title,
			update=update_title
		},
		game_over={
			draw=draw_over,
			update=update_over
		},
		win={
			draw=draw_win,
			update=update_win}
	}
	lightenpal=read_kv_arr[[
	0=0,1=13,2=8,3=1,4=9,5=13,
	6=7,7=7,8=14,9=10,10=7,
	11=7,12=6,13=6,14=15,15=7|
	0=0,1=12,2=14,3=7,4=10,5=7,
	6=7,7=7,8=7,9=7,10=7,11=7,
	12=7,13=7,14=7,15=7]]

	shield_darken_pal=read_kv_arr[[
		6=6,7=7,12=12|
		6=7,7=6,12=12|
		6=6,7=7,12=12|
		6=1,7=6,12=13|
		6=1,7=5,12=5|
		6=0,7=1,12=1|
		6=0,7=0,12=0|
		6=0,7=0,12=0|
		6=0,7=0,12=0
	]]

	spl_dat={
		split[[93,-17,107,6,127,42,
		121,68,121,68,116,92,88,125,
		64,125,64,125,39,126,2,94,3,
		69,3,69,3,49,45,40,65,40,65,
		40,84,40,123,50,121,69,121,69,
		120,94,82,112,60,123,60,123,
		49,129,29,118,17,123,17,123,
		12,125,13,137,13,180]],
		split[[123,-17,124,-3,127,7,
		117,8,117,8,81,12,9,-12,9,20,
		9,20,9,43,118,3,117,37,117,37,
		116,68,8,27,8,63,8,63,8,94,
		117,51,117,80,117,80,117,109,
		8,71,8,100,8,100,8,127,124,
		107,125,119,125,119,126,124,
		119,130,123,136]],
		split[[1,-3,15,3,33,11,43,25,
		43,25,50,36,7,45,5,64,5,64,4,
		78,43,72,47,88,47,88,50,105,
		38,120,21,124,21,124,9,127,
		-10,107,0,99,0,99,12,89,15,89,
		21,93,21,93,35,101,37,121,52,
		123,52,123,67,124,65,99,80,99,
		80,99,93,99,90,125,103,127,
		103,127,114,129,133,118,129,
		107,129,107,125,93,112,100,
		107,92,107,92,100,81,93,80,
		99,68,99,68,103,59,126,64,127,
		53,127,53,128,40,128,29,88,29,
		88,29,30,29,55,4,41,-8]],
		split[[17,-4,25,3,38,9,36,21,
		36,21,34,34,7,37,8,51,8,51,9,
		63,38,57,39,69,39,69,40,83,12,
		81,12,95,12,95,12,105,34,109,
		39,119,39,119,45,131,13,135,
		13,124,13,124,13,110,40,109,
		40,95,40,95,40,83,11,84,11,72,
		11,72,10,60,36,60,36,48,36,48,
		36,35,11,35,8,23,8,23,6,12,18,
		1,24,-5]],
		split[[40,128,56,127,88,126,
		88,108,88,108,88,89,40,103,40,
		84,40,84,40,66,88,82,88,64,88,
		64,88,44,39,55,40,35,40,35,41,
		16,89,29,88,11,88,11,87,-10,
		59,-9,41,-11]]

	}
	init_game()
	_g=_ENV
end




function init_game()
	state=states.game
		level=1
	srand(33)
	spd=1
	shake=0
	mobs,buls,ebuls,enmys,pparts,
	p_ups={},{},{},{},{},{}
	tabs={mobs,buls,
		enmys,ebuls,p_ups}
	p=create_player()
	p:upd()
	shield=create_shield()
	str_shield,str_rapid,str_spread
	=false    ,false    ,false
	invun,flash,score,spread,rapid,
	d,lives,f ,score_mult,shots,
	hits, kills=
	0    ,0    ,0    ,0     ,0,
	0,5    ,-1,1         ,0,
	0   ,0
	add(mobs,p)
	add(mobs,shield)
	stars = create_stars()
	score_mult=1
	score=0
	hi=0
	d=0 

	score_cols=split("12,12,6,6,13")

end

function init_level_intro(n)
	dialog = 1
	intro=1
end

function draw_level_intro()
	cls()
	draw_stars()
	draw_mobs()
	textbox(unpack(dialogs[dialog]))
end

function update_level_intro()
	if btnp(❎) then
		if intro==1 then
			if dialog<7 then 
				dialog +=1
			else
				state=states.game
			end
		end 
	end
end

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
			stime=stime-spd
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

		if lives and lives<2 then

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
	merge(pu, read_assoc(
		"pd=12,ph=10,dy=0.25,life=240")
	)
	printh("Powerup")
	printh(pu)
	
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



function draw_collision(e)
	if not show_collision and 
		not e.show_collision then
		return
	end
	local x,y,w,h=unpack(e:col())
	rect(x,y,w,h,11)
end

-- upd
-- move
-- draw
-- col
function create_mob(s,x,y,w,h)
	local dx,dy,w,h=0,0,w or 1,h or 1

	local mob={
		s=s,
		x=x or 64,
		y=y or -8,
		w=w,
		h=h,
		pw=w*8,
		ph=h*8,
		dx=dx,
		dy=dy,
		upd=function() end,
		move=def_move,
		draw=def_draw,
		col=def_col,
		hurt=def_hurt,
		die=def_die,
	}
	merge(mob,read_assoc("hp=1,escore=100,fra=0,coffx=0,coffy=0,flash=0"))
	setmetatable(mob,{__index=_ENV,
	__tostring= function(self)
		local str=""
		for k,v in pairs(self) do
			if str ~="" then 
				str..="\n"
			end
			str..=k..":"..tostr(v)
		end
		return str
	end
})
	return mob
end

function def_move(_ENV)
		x+=dx*spd
		y+=dy*spd
end

function def_draw(_ENV)
		if flash>0 then
			pal(lightenpal[1])
		end
		if flash>2 then
			pal(lightenpal[2])
		end
		spr(s,x-pw/2,y-ph/2,w,h)
			pal()
		draw_collision(_ENV)
end

function def_col(_ENV)
		local col_width=colw or pw-1
		local col_height=colh or ph-1
		local coffx=coffx or 0
		local coffy=coffy or 0
		local l,t=x+coffx-col_width/2,y+coffy-col_height/2
		return {
			l,
			t,
			l+col_width,
			t+col_height}
end

function def_hurt(_ENV, pow)

				flash=5
				hp-=pow
				if hp <= 0 then
					_g.kills+=1
					die(_ENV)
				else 
					sfx(61)
					add_score(1)
				end 
end

function def_die(_ENV)
	mob_to_ppart(_ENV)
	remove(_ENV)
	float(escore, x, y-10, 13)
	add_score(escore)
	sfx(60)
end




function create_pbul(_x,_y,dx)
	dx=dx or 0
	local bul=create_mob(17,_x,_y)
	local _ENV = bul
	pow=1
	dy=-2
	fra=rnd(27)\1
	function upd(_ENV)
		self=_ENV
		x+=dx*spd
		fra+=1
		fra=fra%27
		if x<-8 or	x>132 
		or	y<-8 or	y>132 then
				remove(self)
		end
	end
	bul.olddraw=draw
	function draw()
		local f=fra\9
		if f==0 then
			pal(12,7)
			pal(13,12)
		elseif f==1 then
		else
			pal(1,12)
			pal(12,7)
			pal(13,7)
		end
		bul:olddraw()
		pal()
	end
	add(mobs,bul)
	add(buls,bul)
end

function create_pbulc(_x,_y)
	local _ENV=create_mob(5,_x,_y)
	function upd()
		s=fra+5
		if s>8 then
			remove(_ENV)
		end
		fra+=1
	end
	return _ENV
end

function create_muz(x,y) 
	local muz=create_mob(16,x,y)
	merge(muz,
		{
			mf=0,
			f=0,
			pw=8,
			ph=16,
			offx=x-p.x,
			offy=y-p.y
		})
	local _ENV=muz
	
	function upd(_ENV)
		mf+=1
		f=mf\2
		if f>2 then
			remove(_ENV)
		end
	end
	
	function draw()
		local x=p.x+offx-pw/2
		local y=p.y+offy-ph/2

		local muz_pal=read_kv_arr[[
			10=7,9=7,8=7,2=12|
			10=7,9=7,8=12,2=13|
			10=7,9=12,8=13,2=1|
			10=7,9=12,8=13,2=1|
			10=7,9=12,8=13,2=1
		]]

		pal(muz_pal[mf])
		if f<4 then
			spr(16,x,y,1,1,false,true)
			spr(16,x,y+8,1,1)
		else 
			spr(34,x+1,y,1,1,false,true)
			spr(34,x+1,y+8,1,1,false,false)
		end
		
		pal()
	end
	add(mobs,muz)
end



function _update60()
	state.update()
end

function spawn(sp)
	local mob = sp.func(
		unpack(sp.params))
	if sp.class == "en" then
		add(enmys,mob)
		add(mobs,mob)
	end

end

function update_game()
	f+=1
	if not distance_blocked then
		d+=1
	end
	if score>hi and f%7==1 
		and hi>0
	then 
		add(score_cols, deli(score_cols),1)
	end
	invun=max(0,invun-1)
	spread=max(0,spread-1)
	rapid=max(0,rapid-1)


	input()
	for m in all(mobs) do
		m:upd()
		m:move()
	end
	flash=max(flash-1,0)
	check_collision()
	update_pparts()
end

function input()
	local _ENV = p
	s=10
	dx=0
	dy=0
	local speed=stime>0 and 1.25 or 1.875
	if btn(⬆️) then
		dy=-speed
	end
	if btn(⬇️) then
		dy=speed
	end
	if btn(⬅️) then
		dx=-speed
	end
	if btn(➡️) then
		dx=speed
	end
	if dx~=0 and dy~=0 then
		dx*=0.707
		dy*=0.707
	end
	if btn(❎) and stime<=0 then
		sfx(63)
		stime=13
		if rapid>0 then
			stime=6
		end
		local bully=y-4
		local bullx=can and x+2 or x-2
		can=not can

		create_pbul(bullx,bully)
		_g.shots+=1
		if spread >0 then 
			create_pbul(bullx,bully,-0.5)
			create_pbul(bullx,bully,0.5)
		end
		create_muz(p.x-1,p.y-12)
	end
	if btn(🅾️) then 
		if btn(⬅️) and str_spread then
			_g.spread += 240
			_g.str_spread =false
			sfx(55)
		end
		if btn(➡️) and str_rapid then
			_g.rapid += 240
			_g.str_rapid = false
			sfx(55)
		end
		if btn(⬆️) and str_shield then
			_g.invun += 120
			_g.str_shield =false
			sfx(55)
		end
	end
end

function _draw()
	state.draw()
end

function draw_game()
	cls(0)
	if shake>0 then
		if f%2==0 then
			camera(rnd(4)-2,rnd(4)-2)
		end
		shake-=1
	else 
		camera()
	end
	if flash > 5 then
		if flash >15 then
			fillp(▒)
		else fillp(░) end
		rectfill(0,0,128,128,2)
		fillp()
		circfill(64,64,90-flash,0)
		circ(64,64,90-flash,8)
		
	end

	draw_stars()
	draw_pparts()
	stripe("d",125,30,split("7,7,6,13,5"))
	stripe("s",125,36,split("7,7,6,13,5"))
	stripe("t",125,42,split("7,7,6,13,5"))
	clip()
	--spr(85,125,20,1,2)
	rect(unpack(split("125,50,127,127,1")))
	draw_mobs()
	
	for i=1,5 do
		--local s=9
		if i<lives+1 then
			spr(9,(i*8)-8,0)
		end
		
	end
	local sc="sc: "..tostr(score,0x2)
	clip(0,0,0,0)
	
	local w=print(sc,0,0)
	stripe(sc,100-w,0,score_cols)
 clip(0,0,0,0)
	
	if hi ~= 0 then 
		local hi_formatted="hi: "..tostr(hi,0x2)
		local w=print(hi_formatted,0,0)
		stripe(hi_formatted,100-w,6,split("13,13,5,1,1"))
	end

	clip()
	darkened_spr(str_shield,58,113,0) -- print(2,121,0,7)
	darkened_spr(str_spread,57,104,8) -- print(3,99,10,7)
	darkened_spr(str_rapid, 59,120,8) -- print(1,123,17)
	pal()
	local col=1
	if str_shield 
	or str_spread
	or str_rapid then
		col=7
	end
	print("🅾️", 114,10,col)

	-- print(#enmys, 64,64,7)
	
--	
--	print(#mobs,0,0,7)
--	print(#buls)
--	print(#enmys)
-- print(shots, 0,0,7)
-- print(hits)
-- print(kills)
-- print(lives)
end

function darkened_spr(light, sp, x, y)
	if not light then 
		pal(split"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1")
	end
	spr(sp, x, y)
	pal()
end

function draw_mobs()
	for m in all(mobs) do
		m:draw()
	end
end

function draw_stars()
	for i=1,#stars[1],2 do
		pset(stars[1][i], (stars[1][i+1]+f/2)%128,1)
	end
	for i=1,#stars[2],2 do
		pset(stars[2][i], (stars[2][i+1]+f/1.25)%128,13)
	end
	for i=1,#stars[3],2 do
		y=(stars[2][i+1]+f*1.25)%128
		if y%1<0.5 then
			pset(stars[3][i],y-1,2)
		end
		pset(stars[3][i],y,6)
	end
end
-->8
--tools

--merges associative tables
function merge(t1,t2)
	for k,v in pairs(t2) do
		t1[k]=v
	end
	return t1
end

--reads multiple assoc tables
function read_kv_arr(str)
	local tbls=split(str,"|")
	for k,v in pairs(tbls) do
		tbls[k]=read_assoc(v)
	end
	return tbls
end

--splits sequences of sequences
--chars should contain the split
--order
function multisplit(str, chars)
	--split by first char
	local tab=split(str,chars[1])
	for key,val in ipairs(tab) do
		if #chars>1 then
			--replace value with
			--multisplit of remain chars
			tab[key]=
				multisplit(val,sub(chars,2))
		end
	end
	return tab
end

--reads a single comma seperated
--key-value string
function read_assoc(str)
		local tab={}
		local kvs=split(str,",")
		for kv in all(kvs) do
			local k,v=unpack(
				split(kv,"="))
			tab[k]=v
		end
	return tab
end

--redefine sgn so sgn(0)=0
function sgn(n)
	if n==0 then
		return 0
	end
	return n/abs(n)
end

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



function read_splines(spl_dat)
	local splines={}
	for i=1,#spl_dat do
		add(splines, read_spline(spl_dat[i]))
		add(splines, read_spline(flip_pts_x(spl_dat[i])))
	end
	return splines
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
			return {x=0,y=0}
		end

		local i,l=1,0
		while t>=l do
			i+=1
			l=limits[i]
			if l == nil then
				break
			end
		end
		local ol=limits[i-1]
		local fact=1/(l-ol)
		local t2=(t-ol)*fact
		return curves[i-1](t2)
	end
	--return curves
	return spl
end



-- removes a obj from all of the
-- main tables
function remove(obj)
	for t in all(tabs) do
		del(t, obj)
	end
end



function create_stars()
	local l0={}
	local l1={}
	local l2={}
	for i=1,128 do
		add(l0,rnd(128))
	end
	for i=1,60 do
		add(l1,rnd(128))
	end
	for i=1,32 do
		add(l2,rnd(128))
	end
	return {l0,l1,l2}
end

function stripe(txt, x, y, cols)
	local w = print(txt,x,y,0)
	for i=1,#cols do
		clip(x,y+i-1,w,1)
		print(txt,x,y,cols[i])
	end
	clip()
end
--Add to score
function add_score(num)
	score+=num>>>16
end
-->8
--title
function init_title()
	state=states.title
	f=0
	titley=-9
	fact1=0
	stars=create_stars()
	ti=1
	texts={
		{},
		{
[[fOR YEARS THE ALIENS HAVE
helped HUMANITY. THEY HELPED
US BUILD FASTER-THAN-LIGHT
TRAVEL. THEY GAVE US FUSION
POWER.

HOWEVER THE ᶜbALIEN OVERLORDᶜ7
HAS SAID THAT THE BEST art
HUMANS EVER MADE WAS 
THE spice girls!]],8,55,7},
			{
[[
fOR THIS INSULT THEY
MUST BE PUNISHED.

ᶜcshootinateᶜ7 THEM
UNTIL THEY ᶜ8dieᶜ7
]], 20,60,7}}
	text={}
end

function draw_title()
	cls(0)
	draw_stars()
	fillp(▒)
	ovalfill(30,48-titley/2,
	96,74-titley,1)
	fillp()
	fspr(0,96,68,9,30,titley,fact1)

	unpack_print(texts[ti])
	print("press x to start",30,122,8)
	if ti>2 then 
		print("⬅️",0,122,7)
	end
	if ti>1 and ti<#texts then
		print("➡️",120,122,7)
	end
end

function unpack_print(tbl)
	print(unpack(tbl))
end

function update_title()
	local fact=min(f,120)/120
	local bounce=easeoutbounce(fact)
	titley=-9+39*bounce
	f+=1
	if f==46 or f==90 then
		sfx(62)
	end
	if f==46 then 
		ti=2
	end

	fact1=easeinoutquart(
		mid(0,(f-120)/60,1))
	if btn(❎) or btn(🅾️) then
		init_game()
	end

	if btn(⬅️) and ti>1 then
		ti-=1
	end
	if btn(➡️) and ti>1 then
		ti+=1
	end
	ti= mid(2,ti,#texts)
end

function fspr(sx,sy,sw,sh,
	dx,dy,
	fact,ew)
	local ew=ew or 15 --effect width
	local mini=-ew
	local maxi=sw+sh
	local pos=mini+(maxi-mini)*fact
	pal()
	sspr(sx,sy,sw,sh,dx,dy)
	clip(dx,dy,sw,sh)
	for lne=0,sh-1 do
		pal(lightenpal[1])
		local lpos=pos-lne
		pset(lpos+dx,lne+41,8)
		local l=max(sx+lpos,sx)
		local dl=max(dx+lpos,dx)
		local w=min(ew+lpos,ew)
		sspr(l,sy+lne,w,1,dl,dy+lne)
		pal(lightenpal[2])
		if lpos>0.5*ew then
			sspr(l+0.5*ew,sy+lne,1,1,dl+0.5*ew,dy+lne)
		end
	end
	pal()
	clip()
end

function easeinoutquart(t)
	if t<.5 then
		return 8*t^4
	else
		t-=1
		return (1-8*t^4)
	end
end

--https://www.lexaloffle.com/bbs/?tid=40577
function easeoutbounce(t)
	local n1=7.5625
	local d1=2.75
	
	if (t<1/d1) then
		return n1*t*t;
	elseif(t<2/d1) then
		t-=1.5/d1
	return n1*t*t+.75;
	elseif(t<2.5/d1) then
		t-=2.25/d1
	return n1*t*t+.9375;
	else
		t-=2.627/d1
		return n1*t*t+.984375;
	end
end


-->8
--enemies

function disc(_spl,_dur)
	local _ENV=create_mob(81)
	
	merge(_ENV, read_assoc("dy=1,sn=1,hp=1,escore=50"))
	sprs=split("81,82,83,84")
	spl=splines[_spl]
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

function flap(x1,target_y,_hp)

	local e=create_mob(93,x1,-8)
	local props=read_assoc("escore=100,dy=1,sn=1,hp=2,frict=0.98,accel=0.1")

	
	merge(e,props)
	
	local _ENV = e
	e.hp = _hp
	e.escore = 100*_hp 
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

function blob(x1,y1,ty1)
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
function spin(_spl,_dur)
	local _ENV=create_mob(106)
	shot_times={60,10,10}
	t_idx=1
	local shot_time=shot_times[1]
	
	merge(_ENV, read_assoc(
		"w=2,h=2,dy=1,sn=1,hp=10,pw=16,ph=16"
	))
	sprs=split("96,98,100,102")
	spl,dur=splines[_spl],_dur
	
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
		if fra%4==0 then
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


function green(x1, ty1)
	local _ENV=create_mob(65,x1)
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

-- function launcher()
-- 	local e=create_mob(131,128,64,3,2)
-- 	e.hp=10
-- 	olddraw=e.draw
-- 	function e:upd()
-- 		self.fra +=1
-- 		self.flash=max(0, self.flash-1)
-- 	end
-- 	function e:draw()
-- 			palt(0,false)
-- 			palt(14,true)
-- 			olddraw(self)

-- 			local bulpos=116-f%136
-- 			spr(75,bulpos,self.y-4,2,1)
-- 			spr(91,bulpos+16,self.y-5)
-- 			palt(14,true)
-- 			palt(0,true)
-- 			clip(self.x-self.pw/2+5,0,128,128)
-- 			olddraw(self)
-- 			palt()
-- 			pal()
-- 			clip()
-- 	end
-- 	return e
-- end

function skull()
	local e=create_mob(71,64,32,2,2)
	return e
end

function lazer(_x,_y,tx,ty)
	if _x==0 then _x=-8 end
	if _y==0 then _y=-8 end
	if _x==120 then _x=132 end
	if _y==120 then _y=132 end
		local _ENV=create_mob(45,_x,_y,1,1)
	hp=10
	ang=0
	ox=x
	oy=y
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

function static
		(_x,_y,tx,ty,_ang,_countdown,_life)
		printh(_countdown)
		printh(_life)
	local _ENV=lazer(_x,_y,tx,ty)
		ang,countdown,life=_ang,_countdown,_life
		max_countdown=countdown
	f,rot_spd=0,0
	function move()
		f+=1
		if f>life then
			remove(_ENV)
		end
		if f<120 then
			x=lerp(x,tx,easeinoutquart(f/120))
			y=lerp(y,ty,easeinoutquart(f/120))
		end
		if f+120>life then
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






-->8
--collision
function check_collision()
	for e in all(enmys) do
		for b in all(buls) do
			if collided(e,b) then
				e:hurt(b.pow)
				remove(b)
				add(mobs,create_pbulc(b.x,b.y))
				hits+=1
				impact_pparts(b.x,b.y)
			end
		end
		
		if collided(e,p) then
			hurt_player()
		end
	end
	for eb in all(ebuls) do 
			if collided(eb,p) then
				hurt_player()
		end
	end
	
	local handlers = {
		function()
			if p.lives <5 then
				lives += 1
				float("+1", p.x,p.y-10,14)
			else
				add_score(2000)
				float(2000, p.x,p.y-10,6)
			end
		end,
		function()
			if str_spread then
				spread+=240
			else 
				str_spread=true
			end
		end,
		function()
			if str_shield then
				invun+=60
			else 
				str_shield=true
			end
		end,
		function()
			if str_rapid then
				rapid+=240
			else
				str_rapid=true
			end
		end
	}

	for powerup in all(p_ups) do
			if collided(powerup, p) then
				
				sfx(56)
				remove(powerup)
				if(handlers[powerup.typ]) then
					handlers[powerup.typ]()
				end
			end
	end
	
end

function hurt_player()
	if invun>0 then return end
	lives-=1
	invun=80
	flash=20
	sfx(59)
	shake=6
	if lives<0 then
		init_over()
		return
	end
	
end

function collided(mob1,mob2)
	--left, top, right, bottom
	local m1l,m1t,m1r,m1b=unpack(
		mob1:col())
	local m2l,m2t,m2r,m2b=unpack(
		mob2:col())
		
	return not (
		m1r<m2l or
		m2r<m1l or
		m1b<m2t or
		m2b<m1t
	)
end
-->8
--effects

--pixel particles
function update_pparts()
	for p in all(pparts) do
		if not p.update() then
			del(pparts,p)
		end
	end
end

function draw_pparts()
	for p in all(pparts) do
		p.draw()
	end
end

function mob_to_ppart(_ENV)
	
	local sp=s
	local xmin,ymin=(sp%16)*8,(sp\16)*8
	local xmax,ymax=w*8+xmin-1,h*8+ymin-1
	for _x=xmin,xmax do
		for _y=ymin,ymax do
			colour = sget(_x,_y)
			--change if transparent
			if colour!=0 then
				dx = rnd(2)-1
				dy = rnd(2)-1
				life=rnd(20)+10
				local p = create_ppart(
					_x-xmin+x-pw/2,
					_y-ymin+y-ph/2,
					dx,dy,life,life,colour
					)
				add(pparts,p)
			end
		end
	end
end

function float(txt,x,y,col)
	local len = print(txt,0,-100,0)
	local left = mid(0, x-len/2,128-len)
	local life=30
	add(pparts, {
		update = function()
			y=y-0.5
			life=life-1
			return life>0
		end,
		draw = function ()
			print(txt, left-1,y,0)
			print(txt, left+1,y,0)
			print(txt, left,y-1,0)
			print(txt, left,y+1,0)
			print(txt, left,y,col)
		end
	})
end

function impact_pparts(x,y)
	for i=1,6 do 
		local dir=rnd(0.4)+0.55
		local sp=rnd()+1
		local dx,dy=cos(dir)*sp,sin(dir)*sp
		add(pparts,
			create_ppart(
				x,y,dx,dy,rnd(10)+5,128,12))
	end
end

function create_ppart(
	x,
	y,
	dx,
	dy,
	life,
	tot_life,
	colour)

	return {
		update = function()
			dy=dy*0.95
			dx=dx*0.95
			x+=dx*spd
			y+=dy*spd
			life-=spd
			if (life<0) return false
			if (x<0 or x>128) return false
			if (y>128) return false
			return true
		end,
		draw = function()
			if life>tot_life/2 then
				circfill(x,y,1,colour)
			else
				pset(x,y,colour)
			end
		end
	}
end
-->8
--ui/dialog

function textbox(t, speaker)

	-- local x=x or 2
	-- local y=y or 96
	-- local w=w or 124
	-- local h=h or 30
	-- local r=x+w-1
	-- local b=y+h-1
	
	-- rectfill(x,y,r,b,0)
	-- line(x+2,y,r-2,y,7)
	-- line(r,y+2)
	-- line(r,b-2)
	-- line(r-2,b)
	-- line(x+2,b)
	-- line(x,b-2)
	-- line(x,y+2)
	-- line(x+2,y)
	
	rectfill(2,96,125,125,0)
	line(2+2,96,123,96,7)
	line(125,98)
	line(125,123)
	line(123,125)
	line(4,125)
	line(2,123)
	line(2,98)
	line(4,96)
	
	local sprx=5+speaker*94
	local sp=136+speaker*3
	local tx=speaker ==0 and 32 or 5

	spr(sp, sprx,99,3,3)
	print(t, tx,99)
	print("\#0❎",110,123)
end



function init_win()
	music(-1,1000)
	sfx(25, 2)
	hi,spd=max(score,hi),1
	dset(0,hi)
	f=-1
	over_f=0
	state=states.win
	memcpy(0x8000, 0x6000, 0x2000)
end




function draw_win()
	clip()
	memcpy(0x6000,0x8000,0x2000)
	palt(0,false)
	for i=1,500 do
		local x,y=rnd(128),rnd(128)
		local c=mpget(x,y)
		--printh("x:"..x.." y:"..y.." c:"..c)
		pset(x,y, c)
	end
	memcpy(0x8000, 0x6000, 0x2000)
	local accuracy = tostr(flr((hits/shots)*1000)/10)
	

	local results = {
		"stage 1 finished",
		"……………………",
		"",
		"sHOTS FIRED : "..shots,
		"kILLS       : "..kills,
		"hITS        : "..hits,
		"aCCURACY    : "..accuracy.."%",
		"",
		"sCORE       :"..tostr(score,0x2),
		"tOTAL sCORE :"..tostr(score,0x2),
		
	}

	for i=1,#results do
		-- print(results[i], max(128*i-over_f*8,24), 20+i*6, 7 )
		local x,y=max(128*i-over_f*8,24), 20+i*6
		for j=0,8 do
			local ox=j%3-1
			local oy=j\3-1
			print(results[i],x+ox,y+oy,0)
		end
		stripe(results[i], x, y,split("7,7,6,13,5"))
	end
end

function mpget(x,y)
	local spr=mget(x\8,y\8)
	local sx,sy=(spr % 16) * 8+x%8, (spr \ 16) * 8+y%8
	return sget(sx,sy)
end

function init_over()
	music(21)
	hi=max(hi,score)
	dset(hi)
	state=states.game_over
	f=-1
	over_f=1
end

function draw_over()
	cls()
	if over_f < 60 then
		draw_game()
	end
	print("game over", 40,40,7)
end

function update_over()
	over_f+=1
	if btn(❎) or btn(🅾️) then
		if (over_f>60) init_game()
	end
end

function update_win() 
	update_over()
	if over_f==30 then
		sfx(24,3)
	end
end

__gfx__
00008e700e0e0000020200000000006c76600000dc777ccddc777ccd1dc7cdd10111111008008000000000008080000800800000800080000080080000808000
1dc09a70e8e880002020200000006c7707000000ddc7cddddcc7ccdd1cc7cc1101c7c1000900900000000000f0f0000f00f000009000f00000f00f0000f0f000
28e0a770e888200020002000000c00c0000000000dc7cd00cdc7cdc0c1d7d1ccc71d107c097c900000000000a0a0000a00a0000a9000a90000a00f0000a0a000
3b70b77008820000020200000067c000000000000dc7cd0000c7c0000c1d10c0dc0000cda7ccd9000000000a90f000a900f0000f9000f90000a00a0000f0a900
49a0c67000200000002000000c7000000000000000dcd000000c0000000000000000000091cdd9000000000f909900f90099000a900099000a900a900a90a900
5d70d670000000000000000006cc000000000000000d0000000000000000000000000000091190000000000995a9009955a900f99555499009955a900995a900
6770ef700000000000000000c7000000000000000000000000000000000000000000000005005000000000097ca940997ca990a907c10a90a99c7990a99c7900
7770f77000000000000000006cc00000000000000000000000000000000000000000000000000000000000accda94a9ccda99a990cd60f99a99dcd90a99dcc40
089a7a980001000000000000c7000000050000000000000000000000000000000000000000000000000000acd1a9409cd1a990499d1da940a991dc99a991dc40
089a7a98001d100000000000607000005750000000000000000000000000000000000000000000000000000ddd99009ddd99000491d19400099d1c90099ddd00
089a7a9801dcd100000000006c6000005775000000000000000000000000000000000000000000000000000911940049119400049111940004911a4004911900
0289a98201dcd1000000000000000000577750000000000000000000000000000000000000000000000000055055005500550005500055000550055005505500
0028982001dcd1000000000000000000577775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002820001dcd1000000000000000000577550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002000001d10000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa000009a900067777665000000000000000000000000000000000000000000000000000000000000000000000000000cc111000e000e00000000
0000000000899800089a980067777665000000000000000000000000000000000000000000000000000000000000000000000000007d1551100e000e00000000
0000000000088000089a98000677665000000000000000000000000000000000000000000000000000000000000000000000000007d11155110e000e00000000
00008000000200000289820006776650000000000000000000000000000000000000000000000000000000000000000000000000cd11ddd15d1e000e00000000
0000f000000000000028200006776650000000000000000000000000000000000000000000000000000000000000000000000000c11dcccd511e000e00000000
000aa900000000000002000006776650000000000080000000000808000000000000000000000000000000000000000000000000155dc7cd511e000e00000000
000ff9000000000000000000067766500000000000f000000000090f000000000000000000000000000000000000000000000000511dcccd551e000e00000000
00049400000000000000000006776650008000000aa900000000a90a0000000000000000000000000000000000000000000000001d11ddd1d15e000e00000000
0000000000000000000000000677665000f000000ff900000000f90f900000000000000000000000007c67000000c0000000000005551511d10e000e00000000
000000000000000000000000067766500aa900000a9900000000a90990000000000000000000000007c700c0000c7c000000000000111551100e000e00000000
000000000000000000000000067766500ff90000f9499000000f99549900000008000000000c00006c700767000c7c00000000000001d111000e000e00000000
000000000000000000000000067766500a990000a90a9000000a90c0a900000088080880c0c7c00c7c0000760000c00000004999eeeeeeeeeeeeeeee00000000
00000000000000000000000006776650a909900a990f990000a990d0f9900000080808087cc7c0c7c0000006000c00000004955500000000000e000e00000000
0000000000000000000000000677665004a9000049a990000004991a9900000008008280c7cc0c7c607007cc00c7c0000049555500000000000e000e00000000
000000000000000000000000067766500499000004990000000049d990000000000000800c0000c007c70c7000c7c0000095555500000000000e000e00000000
000000000000000000000000067766500494000004940000000049194000000000000000000000000076c700000c000000955555eeeeeeeeeeeeeeee00000000
00000000000b300000000000002220000022220000222200002222000000bb33333000000000bb333330000000e7778777787770008800000008800000008800
0088880000baa300000bb000002a9200002a9204002a9200402a9200000733333333330000073333333331000e8ed6d8d6d686dd089980000008800000089980
08e22e8000ba930000ba930042a1912402a19124421919244219142000b33bb3b33333300733833b5138333008e866686666866d089998000089980000899980
082ee28000b99500b3ba953542a9942442a9942042a9942402a994240733833b51383330bb39883313988335e888dddd8dddd8dd008999800089980008999800
082ee280b3135135b313513502a9942042a9942002a9942002a99424bb39883313988335b538143b538143350828d5d8d5d585d50099a98008999980089a9900
08e22e80233113522331135200294200002942000029420000294200b538143b538143353b38883b5388835102825d585d5d8d5d00977990089aa980099aa900
0088880020333502203335020082280000e22e000082280000e22e003b38883b538883513335853b535853500025558555585550009aa9000097a90000977900
000000008003500880035008022002200880088002200220088008803335853b5358535033535b33b33535100000000000000000000990000009900000099000
0000000000966600007666000076690000799600770000000200002033535b33b335351033535b13b33535100000000000000000000110000001100000011000
000000000995556007555560075559900759956070600000080000803b333333333551003b333333333551000000000000000000050550500005500000055000
00088800755c1556765cc556755cd556755cc55660d000008e8008e8333353333555110033335333355511000882000000000000055665500056650000566500
008eee8065c1115699c1119965cccd5665c77d56d0d0000087800878003656576766000000365657676633009998200000000000045665400556655000566500
008e7e806511115699c1119965dccc5d65c77d5d555000008780087800000657676700000036065767673300aaa9820000000000045665400566665000566500
008eee806551155d6551156d655dc55d655dd55d0000000087800878000600070007000000366777757730009998200000000000005665000406604005666650
0008880006555990065555d0099555d0065995d0077000000e0000e0000667707570000000033333333300000882000000000000001661000416614006166160
000000000066d9000066dd000096dd0000699d007000000000000000000333333330000000000033300000000000000000000000000990000009900004099040
0000000a900000000000aa050000000000000000000000000000000000aa05000066d1777767777700000000007bb000007bb00000000000007bb00000000000
0000000a900500000000a990500000000000050000000000000000000a9a050006000d17777677770077b000073335000733b500000730000733b50bb0000000
000000a9990500000000a9990500000000aa00500000aa0005555000a99a050006000d1676767676073335000b3335007333350000733500733335b33b733000
0000009999050000000099990500000000a9990500aa990000000500999905000d000d16666d76c60b3315bbbb331500b33315bbb5331500b33315b315331500
05555099990500000000999905099999000999905a994000aaaaa05099990500d00000d16d6d7dcc0b311b339b311500b3311b3395311500b3311b3395311500
0000059aa95000000000999aa09999940009999aa9994000a999990aa9990500d00000d1d6d6d6c600555b3a94555bb005555b3a94555bb005555b3794555bb0
00a999ae89999900055509ae89999940000099ae89940500099999ae89905000d00000d1ddddcccd00007ba7694bb33500007ba6994bb33500007b79994bb335
a9999ae888499999500a9ae88849900500005ae88840500000099ae888499000d00000d1dd6c566d000733760041b3350007337a4441b33500b735900441b335
99999a88824999440a999a888249055000050a888245000000009a8882499990d00000d1cccd56dd000b33990041b315000b33990041b3150b3333900441b315
0099999824999400a9999998249050000050a998249900000000099824999994100000d1d5c556d5000b339424215550000b3394002155500b33319424215550
00000594495000009999990449050000050a9994499990000000509440944444100000d1ddccc6dd000b314442410000000b31444221000000b5114442413350
00005099990555500000050999900000050a9945099990000005099995000000100000615d5ddc5d007bb55424557bb0000bb554225577b00007b55424557bb0
0000509999000000000005099990000000a9940050099400000509999055555501000615d5d1dcd50733350b451733350073350b45357335000b335b45373335
0000509994000000000005099940000000940000055044000005099940000000010006155551dccc0b33150b511b331500b3350b5315b315000b315b531b3315
0000500940000000000000509940000000000000000500000005099400000000010006155551d5550b3115005555311500b31505b315315000005505b3153115
00000009400000000000000509400000000000000000000000050940000000000011111111011111005550000000555000055000555055000000000055555550
eeeeeeddddddddddddeeeeeeee66d17777677777776717eeeeeeddddd111eeee0000002a99a77a992000000000000000000000000000bbb3eeeeeeeeeeeeeeee
eeeddd6dddd777dddddddeeee6000d17777677777776717ee66d00000000111e000929a9aaaaaa999920000000003335013b3b100001bb33eeeeeeeeeeeeeeee
eedd66dddd73335dddddddeee6000d167676767676767616600000000000000100909a9aa9aaa9aaaa9200000003a93353b3b3b3100b7b33eeeeeeeeeeeeeeee
eed6777dd73bb335ddddddeeed000d16666d76c6666d76166000000000000001090999a9999a9a9a7aa90000000aaa933b3b333bb117bb31eeeeeeeeeeeeeeee
eed6ddddd7b33355ddddd5eed00000d16d6d7dcc6d6d7d1cd000000000000001029aa9499a999999aaa92000000aaaa3533310333bbb3313eeeeeeeeeeeeeeee
ed6dddddd7335530ddddd55ed00000d1d6d6d6c6d6d6d6161ddd00000000666109aa949499aa49499aaa9900000a11a33310000013333b31eeeeeeeeeeeeeeee
ed6dd777dd63330ddddd5d5ed00000d1ddddcccdddddcc1d7111ddddddd6111129aa49424494944249aaa900000a17a3500331000013bb13eeeeeeeeeeeeeeee
eddd7dddddd550dddd5ddd5ed00000d1dd6c566ddd6c561d77661111111155519aa94494224449249a9aa900000a11a300393330000bbb31eeeeeeeeeeeeeeee
edddddddddddddddd5d5d55ed00000d1cccd56ddcccd561d77766dddcdd5d5519a949449ffff9249ff9aa2000000113000aa9335000b7bb3eeeeeeeeeeeeeeee
ddddd5555555555555555555100000d1d5c556d5d5c556157766d6ddc5dd555199494494ff244fff2499290000000000011aa9335007b7b1eeeeeeeeeeeeeeee
dd5550220222022202255555100000d1ddccc6ddddccc61d67766dd6ccc5d55e98944f42f22244ff2249909000000000017aa93531017bb3eeeeeeeeeeeeeeee
d5222211111111111122225d100000615d5ddc5d5d5ddc1d766dd6dcd5cd111189824f2fff777fff77f9290000000000011aa9335b00bbb1eeeeeeeeeeeeeeee
500001cccccccccccc102225e1000615d5d1dcd5d5d1dc1577777dc555cdddd1982f49fff7c1cff91c78090000000000011aa935b300b7b3eeeeeeeeeeeeeeee
ed22221111111111112200dee10006155551dccc5551d1cc7766d6c6666ccc51294f99fff7107ff9077290000000000000aa93333b1007b1eeeeeeeeeeeeeeee
eeddd02220222022202dddeee10006155551d5555551d15e777cccc6ddd5dc51984f9ffff7101fff417829000000000000393335b3b10713eeeeeeeeeeeeeeee
eeeeeddddddddddddddeeeeeee11111111e11111110111ee7766c6ddd5dd5c51494fffffffc1cfff74f2800000000000000331013bbbb331eeeeeeeeeeeeeeee
eeeeeeddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77766dddcdd5d5510494fff77ffffffff4f00000000333333100000003b31313eeeeeeeeeeeeeeee
eeeddd6dddd777dddddddeeeeeeeeeeeeeeeeeeeeeeeeeee7766d6ddc5dd55510049ffffff7fffffff4000000028e8ee3331000000313331eeeeeeeeeeeeeeee
eedd66dddd73335dddddddeeeeeeeeeeeeeeeeeeeeeeeeee67766dd6ccc5d55e00989ffffffffff4f440000002877778ee3310000001bb33eeeeeeeeeeeeeeee
eed66677d73bb335ddddddeeeeeeeeeeeeeeeeeeeeeeeeee766dd6dcd5cd1111000984fffffffffffff00000087070707ee353100000bb33eeeeeeeeeeeeeeee
eed6ddddd7b33355ddddd5eeeeeeeeeeeeeeeeeeeeeeeeee17777dc555cdddd10000424ffffff0002f2000000087070788e335b3b10bbbb3eeeeeeeeeeeeeeee
ed6dddddd7335530dddddddeeeeeeeeeeeeeeeeeeeeeeeee7166d6c6666cc11100000024ffffffffff0000000003888888335b3b3b3b31b3eeeeeeeeeeeeeeee
ed6dd777dd63330ddddd5d5eeeeeeeeeeeeeeeeeeeeeeeeee711111111111c5e0000002244fffffff20000000000333333350013331311b3eeeeeeeeeeeeeeee
eddd6dddddd500dddd5ddd5eeeeeeeeeeeeeeeeeeeeeeeeeee66c6ddd5dd5cee00000222244fffff20000000000000000000000000000133eeeeeeeeeeeeeeee
edddddddddddddddd5d5d55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ddddd55555555555555dd555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dd5550222202220222055555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d5222211111111111122025deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
522201cccccccccccc102225eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ed20221111111111112222deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeddd22022202220222dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
01222122002210222101222100129aa1222212200211222109aa9201112221022221000000000000000000045944941044444444424444444444544444444444
12aa424a11a4229a92129a921129aa22aaaa2aa22a229a92109aa922129a9219aaa2100000000000000000495440400049444444440444444445094444944494
2a99a2aa22aa29aaa929aaa9229aa2119aa92aa92a29aaa92019aaa229aaa92aa9aa200000f00000000000044500000041144444404e44444445014444444444
2a9221aa44aa2aa2aa2aa2aa49aaa9002aa22aaa9a2aa4aa2012a9aa2aa2aa4a929a20000f000400000000004000000045111444044411014450144444444444
24aa92aaaaaa2a929a2a929a2a92aa202aa22a9aaa2a414a212aa29a2a929a2aa9aa2000f4441840000000040000000044441199051100044441444445444244
1229a2aa44aa2aa2aa2aa2aa22229a902aa22a2aaa2aa4aa212a92222aa2aa2aaaa42000ff44444e000000544000000054444a00001004114444445444444444
2a99a2aa22aa29aaa929aaa921012aa29aa92a22aa2aaaaa219a210129aaa92aa9aa200004444100000404459400000049449011000411114494424441444444
29aa424a11a4229a92129a92100029a2aaaa2a202a2a424a22aa2000129a9219a29a200005005000014944954000000044490100000115544445544450144494
02222122002212222101222100001221222212000211212201221000112221122122100000000000000000000000000444490100000011444444424500144444
00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000004944440000004014444444445001424444
00000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000449410000449000114444450014444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000940000000000000049112004990110044499500144444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000491144500001211444444455524445444
00000000000000000000000000000000000000000000000000000000000000000000000000000000440000000000005411410516141191444444424444444442
00000000000000000000000000000000000000000000000000000000000000000000000000000000945000400004044544111494124191114444424444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000554404940149449544424444144149194444444444444444
00000000000000000000000000000000000000000000000044944444444444440000000144000000004944294024442444444444444444444444444444444444
00000000000000000000000000000000000000000000000044444414444544440000000144000000000004900044290049444444444444444444499944444444
00000000000000000000000000000000000000000000000044444444444444440000004441400000000000000000900041002454444445444444449444455544
00000000000000000000000000000000000000000000000045444444444444540000001444000000000000000000000045902244444444444555444444445011
00000000000000000000000000000000000000000000000044444444444424440000002449000000000000000000000044900124449444445101944945444544
00000000000000000000000000000000000000000000000044444944414444440000094444000000000000000000000044490002491444445009444451924444
00000000000000000000000000000000000000000000000044444444444444440000041244400000000000000000000044449901211144444994444449444444
00000000000000000000000000000000000000000000000044454444444444140000944442140000000000000000000044424900111004444444445444449444
00000000000000000000000000000000000000000000000044444444144444440000412444490000000000000000000044444590122224444444451942444424
00000000000000000000000000000000000000000000000044444444444444540000044421400000000000000000000044444549000055444494451194444444
00000000000000000000000000000000000000000000000049444444445444440000004444900000000000000000000044444445999900444444451009442444
00000000000000000000000000000000000000000000000044444414444444410000009442000000000000000000000042244444421290044444245009444444
00000000000000000000000000000000000000000000000044444444444414440000004441000000000000000000000044444444442459444444451164444444
00000000000000000000000000000000000000000000000044444444444444490000041444000000000000000009000044444444444444444444451644449694
00000000000000000000000000000000000000000000000041444454444444440000004410000000094000000092440044544494444544449444449444449111
00000000000000000000000000000000000000000000000044444444445444440000004410000000924494004244420444444444444444444445444444444919
__label__
58008000080080000800800008008000080080000001000000000000000007770000000000000000000000000000000000000000000000000001111000000000
0900900009009000090090000900901009009000000000000000000000000c0c1000000000000000000000000000000000000000000000000011100100000000
097c9000097c9000097c9000097c9000097c9000000000000000000000000c0c0000000000000000000000000000000000000000000000000111001110000000
a7ccd900a7ccd900a7ccd900a7ccd900a7ccd9000000000000000000000006060000000000000000000000000000000000000000000000000110000110000000
91cdd90091cdd90091cdd90091cdd90091cdd900000100000000000000000ddd0000000000000000000000000000000000000000000000000100000010000000
09119000091190000911900009119000091190000000000000000000000000000000000000000000000000000000000000000000000000000101001110000000
05005000050050000500500005005000050050000000000000100000000000000000000000001000000000000000000000000010000000000011101100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000001111100011100
00000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000101110010011000110001000
000000000000000000000000000000d0000000000000000000000000d00000000000000000000000000000000000000000000000111110110011010110010000
00000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000111101110011000110111000
0000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000010000100001111100111000
00000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000100000000000000010000000000d0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000020000000000000000000000
00000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000060000000000000000000000
00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100
0000000000000000000000000000000000000000000000000000000000001c100000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000001c7c10001000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000001c7c10000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000001c7c10000000000000000000001000000000000000000000000000000000000000000
000000000000000000000000000001000000000000000000000000000001c7c1000000000000000000000000000000000000000000000000d000000000000000
0000000000000000000000000000000000000000000000000000000000001c100000000000000000000000000000000000000000000000000000000000000770
00000000000000000000000000000000000000000000000000000000000001000100000000000000000000000000000000000000000000000000000000000707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000606
00000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000d0d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000666
00000000000d0000000000000000000000000000000000d00000000000000000060000000000000000000000000000000000000000000000000000000000000d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000550
00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000060
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000d0
00000000000000000000000000600000000000000000000000d00000000000000000000000000000000000000000001000000000000000000000000000000050
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000
00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
0000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000100000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
00000d000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000b0
000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
00000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
0000000000000000000000000000000000100000000000000000000000000800080000000000000d0000000000000000000000000000000000000000000000b0
00000000000000000000000000000000000000000000000000000000000009000f000000000000000000000000000000600000000000000000000000000000b0
000000000000000000000000000000000000000001000000000000000000a9000a900000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000f9000f900000000000000000000d00000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000a90009900000000000000000000000000000000000000000000000000000000000b0
00000000000000000000000000000000000000000000000000000000000f995554990000000000000000000000000000000000000000000100000000000000b0
00000000000000000000000000000000000000000000000000000000000a907c10a90000000000000000000000100000000000000000000000000000000000b0
00000000000000000000000000000000d0000000000000000000000000a990cd60f99010010000000000000000000000000000000001000000000000000000b0
00000000000000000000000000000000000000000000000000000000000499d1da940000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000491d19400000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000491119400000000000000000000100000000000000000000060000000000000000b0
00000000000000000000000000000000000000000000000000000000000055000550000000000000100d000000001000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000aa000aa00000000000000000000000000000000000000010000000000000000000b0
000000000000006000000000000000000000000000000000000000000008998089980000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000010000000000000000000000880008800000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000200000200000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000b0
000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
00000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000b0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000d0000000000000000000000000b0
0000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
0000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000b0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000200000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000b0
00000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000010000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000b0
0000000000000000000000000000000000000000000000000000000100000000000000d0000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000020000001000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000600000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000d00000001000000000000000000000000000000000000000000000000000000000000000000000b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
e6e7f6f7eeefe7f7e7e6f7f7e7cecff7e7f6f7e6fefff6ecedf7f6e7e6dedfe7f7f6cccde7f7f7fcfde7f6eeeff7f7e6e6e7dcddf6e6e6f7f7e6e7feffe7e6e7e7e6f6f7eeefe7e6e7f7e6e7f7f7e6cef7ecedf6fefff7e7e6cef7e7f7eff6e7e7fcfde7f7e7f6f6f7f6f6e7e6cecfe6e7f7f6ecedf7e6f7e6e7e6eee7dedff7
e6e7f7fcfdf6e7e6e7e6e7f7f7e7f7e6e6f7e7f6cccde6e7eeefe6e7e7efcee7e6e7cecfdcdde7e7feffe7f7e6e6e6e7e6f7dedff7f7f7e7f7e6cccde7e6e6e6f7e6f7e7e6f7eff7e6f7dcddf7f6f7f7e7f7e7f7eee7e6e7e7e7e7e7f7ecede7e7e6f7e7e7e7e6e7cecfe6e7f6fcfde6e6e7f7eff7f7f6f7dedff7eef7e6e6e7
fd010104481404481404840a04880a04c80204c60204c40105094801050948010509480105094801050948010509480f04220004430004620004830a04f20004d30004c40004a60004860a06990a07990a08990a09991404180004380004580004781404f40004d40004c40004a40004841404180004380004580004780a0988
1404f40004d40004c40004a40004841405016001050160010501600105016001050160010501600105016001050160010501600105016001050160010501600105016001050160200502480105024801050248010502480105024801050248010502480105024801050248010502480105024820050364010503ff010503ff00
047600049601050364010503640004760004960105036401050464010504640105046401050464010504640604440004540004b40004d40304460004560004b60004d620050232010502320105023200047a00048a01050148000502320004760004860105014800050232010501480005023201050148000502320105014800
05023201050148000502320105014800050232010501480005023201050148000502320105014800050232010501480005023206050148000502320105014800050232010501480005023201050148000502320f040e02042c02044a0204690204870204a50204c30204e12f0124080001d4080001e408060126080001d60838
00010b03c0020503c0020503c0020503c0020503c0150b04c0020504c0020504c0020504c0020504c0600b03a00004220004430004620004830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
270c00200c053041120425204252184530411204252042520c053041120425204252184530411204252042520c053041120425204252184530411204252042520c0530a2120a2520a252184530a2121845318453
310300000c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c554185550c5540c555
d70c00200421204212042150421204222042250422204222042320423204235042320424204245042420424204252042520425504252042520425504252042520a2510a2520a2550a2520a2520a2550a2520a255
d70c00200425204252042550425204252042550425204252042520425204255042520425204255042520425204252042520425504252042520425504252042520a2510a2520a2550a2520a2520a2550a2520a255
270c00200c053041120425204252184530411204252042520c053041120425204252184530411204252042520c053051120525205252184530611206252062520c05307212072520725218453082120825208252
d70c00200425204252042550425204252042550425204252042520425204255042520425204255042520425205251052520525505252062510625506252062520725107252072550725208251082550825208255
4318000021552215522155221552215522155221552215521f5521f5521f5521f5521f5521f5521f5521f5521c5521c5521c5521c5521c5521c5521c5521c5521a5521a5321a5521a5321a5521a5321755217552
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
611000001d5311d5411d5311d5212655026541265312652125550255412553125521135001350013500135001d5311d5401d5301d520265502654026530265202554025520255402552013500135001350013500
011000001d5311d5411d5311d52126550265412653126521255502554125531255212355023540235202350022550225402252022500235502354023520235002555125541255312552113500135001350013500
011000001c5501c5401c5301c50026540265402653026520245502454024530245202354023530235202350021550215402153021500245602455024540245300000000000000000000000000000000000000000
011000001324304020000000407010045000000405004020102430402000000040501002500000040500402013243100200000004070100450000004050100201024310040000000405010025000000405004020
011000001c7511c7401c7301c725237502372523750237251c7511c7401c7301c725237502372523750237251c7511c7401c7301c725247502472524750247251c7511c7401c7301c72526750267252875128740
011000001c5501c5401c5301c52024550245402453024520235502354023530235202355023540235302352020550205402053020520215502154021530215202555425540255402553000500005000050000500
011000001c7511c7401c7301c725237502372523750237251c7511c7401c7301c725237502372523750237251c7511c7401c7301c725247502472524750247251c7511c7401c7301c72526750267252875028740
01100000132430b02600000010700104600000040500a020102430402600000010500102600000040500a020132431002600000010700104600000040500a020102431004600000010500102600000040500a020
011000002290022914229312295516900229142293122955169002291422945259012397023970239702390022970229702297022900239702397023950239002597025970259702597513900139001390013900
270c00200c053151131525215254184531511315252152540c053151131525213254184531511215252152540c0530c1120c2520c254184530c1120c2520c2540c0530e2120e2520e25418453132121325213254
3d180020210522102424052240322402428052260322602424052260522603226024270522603226022260142405224052240322402426052260142405224054210522105221032210241f0521f0521f0321f024
2f0c00201c2511c2521c2521020201200102001c2521c25501200102001c2521c25501200102001c2521c25518200182001a2521a252112001020018232182351a2321a2351c2321c2351a2321a2351823217215
2f0c00201c2511c2521c2521020201200102001c2521c25501200102001c2521c25501200102001c2521c25518200182001a2521a25211200102001c2321c2351f2321f235232322323521232212351f2321f215
2f0c0020152521525215252102020120010200152521525501200102001525215255012001020015252152551820018200132521325211200102001c2001c2001f2001f200232002320021200212001f2001f200
770c00200c033092240922409224180330922409224092240c033092240922409224180330922409224092240c033092240922409224180330922409224092240c03307224180330722418033072240722407224
1f050000131501315015150151501c1501c1501c1501c1501c1401c1401c1301c1301c1201c1201c1101c11000100001000010000100001000010000100001000010000100001000010000100001000010000100
d524000015352153241835218332183241c3521a3321a324183521a3521a3321a3241b3521a3321a3221a314187341a7321a7121a7141b7341a7121a7121a714187141a7121a7121a7141b7141a7121a7121a714
d524000015352153241835218332183241c3521a3321a324183521a3521a3321a3241b3521a3321a3221a314187341a7321a7121a7141b7341a7121a7121a714187141a7121a7121a7141b7141a7121a7121a714
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04050000095320a5720b5320b5720c5520e532105723b141341312d131261111f1311a12116111121310d13109111061210050000500005000050000500005000050000500005000050000500005000050000500
010c00001105117051200503300100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
00060000007000d750187502a750187502a7503375033700337403370033730337003372033700337103270032700007000070000700007000070000700007000070000700007000070000700007000070000700
0101000023276282762a2562b2462b2462b03621026180260e0260d0260b0160d016150261e036240462903629026260261a0260f0260f0260f026110261602620026280262b0362a036230261e0161a00600006
0a0200003b3502c35034350213502b350143502135007300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000306503065017150191501d150202502315026150291502915024250241502215014650146501b1501825017150151500000000000000000000000000082500b2500d2500e25010250112501225013250
080400002c6400d640166200f74024610246101262004620186000a77000600077500473000600037500a70000600006000060000600006000060000600006000060000600006000060000600006000060000600
7a060000276700d620166000060000600166000060000600186000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
7a060000276600d620166500060000600166500060000600186000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100003c1203a1203512033120301202b1202712024120221201d1101b11018110161101611013110111100f1100c1100a1100a110071100511003110031100311000110001100011000110001100011000110
__music__
01 0a4d4344
01 0a0d4344
00 0b0d4344
00 0f0d4344
00 0f0d4344
00 0f0d4344
00 0e0d4344
06 11120b44
01 13144344
00 13144344
00 13424344
00 13424344
00 13154344
00 13164344
00 13154344
00 13174344
00 00024344
00 00034344
00 00034344
00 04054344
02 13064344
00 1b424344

