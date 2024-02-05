pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--enemy tester
--wes

function _init()
	states={
		game={
			draw=draw_game,
			update=update_game
		},
		title={
			draw=draw_title,
			update=update_title
		}
	}
		lightenpal=read_kv_arr(
		"0=0,1=13,2=8,3=1,4=9,5=13,"..
		"6=7,7=7,8=14,9=10,10=7,"..
		"11=7,12=6,13=6,14=15,15=7|"..
		"0=0,1=12,2=14,3=7,4=10,5=7,"..
		"6=7,7=7,8=7,9=7,10=7,11=7,"..
		"12=7,13=7,14=7,15=7"
	)
	shield_darken_pal=read_kv_arr(
			"6=6,7=7,12=12|"..
			"6=7,7=6,12=12|"..
			"6=6,7=7,12=12|"..
			"6=1,7=6,12=13|"..
			"6=1,7=5,12=5|"..
			"6=0,7=1,12=1|"..
			"6=0,7=0,12=0|"..
			"6=0,7=0,12=0|"..
			"6=0,7=0,12=0|"
	)

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
		59,-9,41,-11]]}
	
	splines=read_splines(spl_dat)
	--load sprite sheet music etc
	-- reload(0,0,0x42ff,"shootinator.p8")
	-- cstore(0,0,0x42ff)


	--#include levels.lua
	init_game()
	_g=_ENV
end
#include utils.lua

function add_score()
end

function init_game()
	state=states.game
	srand(33)
	mobs={}
	spd=1
	buls={}
	ebuls={}
	enmys={}
	pparts={}
	p_ups={}
	tabs={mobs,buls,enmys, ebuls, p_ups}
	p=create_player()
	p:upd()
	shield=create_shield()
	str_shield=false
	str_rapid=false
	str_spread=false
	invun=0
	lives=5
	flash=0
	score=0
	spread=0
	rapid=0
	scene=8
	kills=0
	d=10
	total_dist=60
	f=-1
	add(mobs,p)
	add(mobs,shield)
	stars = create_stars()
	score_mult=1
	msg=""

	distance_spawns={}
	init_scene(scene)

end

function add_enemy(e,pos)
	pos = pos or #mobs+1
	add(enmys,e)
	add(mobs,e,pos)
end


function init_scene(number)
	distance_spawns={}
	msg=""..number
	for e in all(enmys) do 
		remove(e)
	end
	if scene==1 then
		-- msg="scene 1 - flaps in a row"
		-- add_enemy(flap(16,48,2))
		-- add_enemy(flap(32,48,2))
		-- add_enemy(flap(64,48,2))
		-- add_enemy(flap(112,48,2))
		-- create_powerup(1, 16,64)
		-- create_powerup(2, 32,64)
		-- create_powerup(3, 96,64)
		-- create_powerup(4, 120,64)

	end

	if scene==2 then
		-- msg="scene 2 - flaps in a col"
		-- add_enemy(flap(16,16,2))
		-- add_enemy(flap(64,32,2))
		-- add_enemy(flap(96,56,2))
	end

	if scene==3 then
		msg="scene 3 - discs from right"
		f=0 --reset frame counter only in test cart

		local function spawn1()
				add_enemy( disc(1, 360))
		end
		for i=10,150,10 do
			distance_spawns[i]=spawn1
		end
	end

	if scene==4 then
		msg="scene 4 - discs from left"
		f=0 --reset frame counter only in test cart
		distance_spawns={}
		local function spawn1()
			add_enemy( disc(2, 360))
		end
		for i=10,150,10 do
			distance_spawns[i]=spawn1
		end
	end

	if scene==5 then
		msg="scene 5 - mixed discs"
		f=0 --reset frame counter only in test cart
		distance_spawns={}
		local function spawn1()
			add_enemy( disc(2, 360))
		end
		local function spawn2()
			add_enemy( disc(1, 360))
		end
		for i=10,150,10 do
			if i%20==0 then 
				distance_spawns[i]=spawn1
			else
				distance_spawns[i]=spawn2
			end
		end
	end

	if scene==6 then
		for i=4,124,20 do
			add_enemy( green(i, 32))
		end
	end

	if scene==7 then
		msg="7 spinshot - debug"
			spinshot({x=64,y=64})
	end

	if scene==8 then 
		msg="8 boss?"
		add_enemy( boss(64,-32,24))
		-- add_enemy(mine(82,84))
		-- add_enemy(mine(120,120))
		-- add_enemy(mine(120,96))
		-- add_enemy(mine(20,96))
	end

	if scene==9 then
		msg="9 blob"
		add_enemy( blob(64,-8,64))
	end

	if scene==10 then
		msg="10 blob fight"
		add_enemy( blob(32,-8,10))
		add_enemy( blob(96,-8,20))
		add_enemy( blob(32,-8,64))
		add_enemy( blob(64,-8,70))

		local x=20
		local xplus=20
		function spawn()
			add_enemy( green(x,8))
			if (x+xplus >128 or x+xplus<0) then
				xplus=-xplus
			end
			x=x+xplus
		end
		
		for i=100,1000,100 do
				distance_spawns[i]=spawn
		end
	end

	function unpack_split(arg)
		return unpack(split(arg))
	end
	function empty() end
	--3363
	--3282
	--3278
	local function box_brain2()
		local box=create_mob(0,136,64)
		box.draw=empty
		local lazers={}
		for i=1,4 do
			local lazer = static(unpack_split("136,136,64,64,0.5,0,3"))
			lazer.move=empty
			lazer.hp=3
			add_enemy(lazer)
			add(lazers, lazer)
		end
		local fs,ang,dist,x,y,loff=unpack_split("0,0,102,64,64,0.625")
		function box.upd()
			fs+=1
			if fs<60 then
				dist-=0.71
			end
			if fs>200 and fs<230 then 
				x+=1
			end
			if fs<200 then 
				loff-=0x0.001
			end
			for i=1, #lazers do 
				local lazer = lazers[i]
				local lang = ang+.125+i*0.25
				lazer.x,lazer.y=x+cos(lang)*dist,y+sin(lang)*dist
				-- lazer.y = y+sin(lang)*dist
				lazer.ang= lang+loff+sin(t()*1.5)/100
			end

			if fs>60 then 
				ang=ang-0x.01
			end

		end


		return box
	end

	if scene==11 then
		msg="11 Box "
		f=0

		add(mobs,box_brain2())

	end

	if scene==12 then
		msg="12 Level beginning - removed"
				f=0 --reset frame counter only in test cart
		-- distance_spawns=level_dat
		
		-- distance_spawns = level_dat
		
	end

	if scene==13 then
		msg="13 Lazer turret"
		add_enemy( lazer(0,0,64,64))
		add_enemy( lazer(0,0, 60,60))
		add_enemy( lazer(0,0, 68,68))
	end
end

#include player.lua

function draw_collision(e)
	if not show_collision and 
		not e.show_collision then
		return
	end
	local x,y,w,h=unpack(e:col())
	rect(x,y,w,h,11)
end

#include mob.lua

function create_pbul(x,y,dx)
	dx=dx or 0
	local bul=create_mob(24,x,y)
	bul.pow=1
	bul.dy=-3.2
	bul.h=2
	bul.fra=rnd(27)\1
	function bul:upd()
		self.x +=dx
		self.fra+=1
		self.fra=self.fra%27
		if self.x<-8 or
			self.x>132 or
			self.y<-8 or
			self.y>132 then
				remove(self)
		end
	end
	bul.olddraw=bul.draw
	function bul:draw()
	local f=self.fra\9
		if f==0 then
			pal(12,7)
			pal(13,12)
		elseif f==1 then
		else
			pal(1,12)
			pal(12,7)
			pal(13,7)
		end
		self:olddraw()
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
		local sp=f<4 and 16 or 34
			spr(sp,x+1,y,1,1,false,true)
			spr(sp,x+1,y+8,1,1,false,false)
		
		pal()
	end
	add(mobs,muz)
end


function _update60()
	state.update()
end

function update_game()
	f+=1

	if distance_spawns[f] then
		distance_spawns[f]()
	end

	invun=max(0,invun-1)
		
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
	p.s=10
	p.dx=0
	p.dy=0
	local speed=p.stime>0 and 1 or 1.5
	speed=speed*spd
	if btn(⬆️) then
		p.dy=-speed
	end
	if btn(⬇️) then
		p.dy=speed
	end
	if btn(⬅️) then
		p.dx=-speed
	end
	if btn(➡️) then
		p.dx=speed
	end
	if btn(❎) and p.stime<=0 then
		sfx(63)
		p.stime=12
		if rapid>0 then 
			p.stime=6
		end
		local y=p.y-4
		local x=p.x-2
		if p.can then
			x=x+4
		end
		p.can=not p.can

		create_pbul(x,y-6)
		if spread >0 then 
			create_pbul(x,y,-0.5)
			create_pbul(x,y,0.5)
		end
		create_muz(p.x-1,p.y-12)
	end
	if btnp(🅾️) then 
	--scene_limit
	scene = (scene)%13+1
	init_scene(scene)
	end
end

function _draw()
	state.draw()
end

function draw_game()
	cls(0)
	print("press z to change scene",0,0,7)
	print(msg)
	print("mobs: " ..#mobs)
	print("lives: " .. lives)


	draw_stars()
	draw_pparts()
	draw_mobs()
	
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

-- removes a obj from all of the
-- main tables
function remove(obj)
	for t in all(tabs) do
		del(t, obj)
	end
end

--redefine sgn so sgn(0)=0
function sgn(n)
	return n==0 and 0 or n/abs(n)
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

--distance vunerable to overflow
function dist(p1,p2) 
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


function contains(table,val)
	for e in all(tbl) do
		if e==val then
			return true
		end
	end
	return false
end

function stripe(txt, x, y, cols)
	local w = print(txt,x,y,0)
	for i=1,#cols do
		clip(x,y+i-1,w,1)
		print(txt,x,y,cols[i])
	end
end
-->8
--title
function init_title()
	state=states.title
	f=0
	titley=-9
	fact1=0
	stars=create_stars()
end

function draw_title()
	cls(0)
	draw_stars()
	fillp(▒)
	ovalfill(30,48-titley/2,
	96,74-titley,1)
	fillp()
	fspr(0,96,68,9,30,titley,fact1)
	local ln=50
	print("for years the aliens have helped",0,ln,7)
	ln+=6
	print("humanity. they helped us produce",0,ln,7)
	ln+=6
	print("faster than light travel.",0,ln,7)
	ln+=6
	print("however the alien overlord has",0,ln,7)
	ln+=6
	print("said that the best music humans",0,ln,7)
	ln+=6
	print("ever made was the spice girls",0,ln,7)
	ln+=10
	print("for this insult.",0,ln,7)
	ln+=6
	print("they must be punished!",0,ln,7)
	ln+=18
	print("shootinate them until they die.",0,ln,7)
end

function update_title()
	local fact=min(f,120)/120
	local bounce=easeoutbounce(fact)
	titley=-9+39*bounce
	f+=1
	if f==46 or f==90 then
		sfx(62)
	end
	fact1=easeinoutquart(
		mid(0,(f-120)/60,1))
	if btn(❎) or btn(🅾️) then
		init_game()
	end
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

function fspr2(n,x,y,w,h,fx,fy)
	local w=w or 1
	local h=h or 1
	local pw=w*8
	local ph=h*8
	local fx=fx or false
	local fy=fy or false
	local effectwidth=5
	local min=x-effectwidth-ph
	local max=x+pw
	local dur=100
	local t=0
	return function()
		local pos=min+(max-min)*easeinoutquart(t/dur)
		pal() --default
		spr(n,x,y,w,h,fx,fy)
		for l=1,ph do 
			clip(pos+ph-l,y+l-1,effectwidth,1)
			pal(lightenpal[1]) --mid
			spr(n,x,y,w,h,fx,fy)
			clip(pos+effectwidth/2+ph-l,y+l-1,1,1)
			pal(lightenpal[2]) -- light
			spr(n,x,y,w,h,fx,fy)
			if t>dur then
				t=0
			end
			clip()
			pset(pos,64,4)
		end
		t+=1
	
		pal()
	end
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
#include enemies.lua



-->8
--collision
function check_collision()
	for e in all(enmys) do
		for b in all(buls) do
			if collided(e,b) then
				e:hurt(b.pow)
				remove(b)
				add(mobs,create_pbulc(b.x,b.y))
			end
		end
		
		if collided(e,p) then
			hurt_player()
		end
	end
	for eb in all(ebuls) do 
			if collided(eb,p) and invun<=0 then
			lives-=1
			invun=80
			flash=20
			sfx(59)
			shake=6
		end
	end

	local handlers = {
		function()
			if p.lives <5 then
				p.lives += 1
				float("+1", p.x,p.y-10,14)
			else
				float(2000, p.x,p.y-10,6)
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

function mob_to_ppart(obj)
	
	local sp=obj.s
	local xmin,ymin=(sp%16)*8,(sp\16)*8
	local xmax,ymax=obj.w*8+xmin-1,obj.h*8+ymin-1
	for x=xmin,xmax do
		for y=ymin,ymax do
			colour = sget(x,y)
			--change if transparent
			if colour!=0 then
				dx = rnd(2)-1
				dy = rnd(2)-1
				life=rnd(20)+10
				local p = create_ppart(
					x-xmin+obj.x-obj.pw/2,
					y-ymin+obj.y-obj.ph/2,
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
			x+=dx
			y+=dy
			life-=1
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
function mine(x1,y1,x2,y2)
	local _ENV=create_mob(23,x1,y1)
	local explosion_radius=16
	local exploding = false
	od=draw
	local 	darken_pal=read_kv_arr(
		"1=1,2=2,3=3,4=4,5=5,6=5,7=6,8=2,9=9,10=9,11=3,12=13,13=13,14=14,15=15|"..
		"1=0,2=0,3=1,4=1,5=1,6=5,7=6,8=2,9=4,10=9,11=3,12=13,13=1,14=8,15=6|"..
		"1=0,2=0,3=1,4=1,5=1,6=1,7=13,8=2,9=4,10=4,11=1,12=13,13=1,14=8,15=13|"..
		"1=0,2=0,3=0,4=0,5=0,6=1,7=5,8=2,9=5,10=5,11=1,12=13,13=0,14=2,15=13|"..
		"1=0,2=0,3=0,4=0,5=0,6=0,7=1,8=0,9=1,10=1,11=0,12=0,13=0,14=1,15=1|"
)

local warn_pal=read_kv_arr("6=14,13=8,5=2|6=7,13=8,5=8")
	function upd(_ENV)
		fra +=1
		if exploding then
			explosion_radius -=1.3
		end
		if explosion_radius <2 then
			remove(_ENV)
		end
		exploding = fra >200
		if exploding and explosion_radius==16 then 
			for m in all(mobs) do
				if m ~= _ENV then
					local l,t,r,b=unpack(m:col())
					l,r,t,b=l-x,r-x,t-y,b-y
					if 
						l*l+t*t<256 or
						l*l+b*b<256 or
						r*r+t*t<256 or
						r*r+b*b<256 then
							m:hurt(1)
					end
				end
			end
		end

		wp=nil
		for f in all(split"100,150,175,185,190,192,194,196,198") do

			if abs(fra-f)<4 then
				wp=warn_pal[1]
			end
			if abs(fra-f)<2 then
				wp=warn_pal[2]
			end
		end
	end
	function draw(_ENV)
		pal(wp)
		--if (wp) then pal(wp) else pal() end
		if exploding then
			circfill(x,y,explosion_radius,explosion_radius>6 and 7 or 14)
			return
		end
		if fra%8<4 then 
			fillp(0b0011001111001100)
		else 
			fillp(0b1100111100110011)
		end
		if fra>45 then
			circ(x,y,16,6)
			pal(8, split"0,2,8,14"[(fra%32)\8+1])
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
	--todo extrac specific enemies
	merge(_ENV, read_assoc(
		"w=6,h=4,dy=1,sn=1,hp=200,pw=48,ph=32"
	))
	sp=128
	exp=0
	exp2=0
	pw=20
	cnt = 0
	phase=1
	maxshots=0
	tar_swing_x=64
	sc =0
	hist={}
	

	function upd(_ENV)
		--[[
			closed
			partially opened
			opened
			wings partially opened
			wings opened.
		]]
		fra +=1
		rage=4-hp/50
		if hp==150 then phase=2 end
		if hp==100 then 
			boss_attach(_ENV,-1)
			boss_attach(_ENV,1)
			hp=99
			phase=3
		end
		if phase>1 then exp=min(exp+0.125,9) maxshots=4 end
		-- if exp<9 and fra>190 then exp+=0.125 end
		if phase>2 then exp2=min(exp2+0.5,18) maxshots=10 end
		-- if exp2<18 and fra>360 then exp2+=0.5 end
		pw = 20 + exp + exp
		flash=max(0, flash-1)
		-- if fra%8==0 then
		-- 	sn=sn%3+11-2
		-- 	s=sprs[sn]
		-- end
		dx=cos(fra/128)/2
		if y<24 then
			dy=1
		else swinging=true end

		if(swinging and not spline) then 
			tar_swing_x=0
			while tar_swing_x==0 or x+tar_swing_x<24 or x+tar_swing_x>96 do 
				tar_swing_x=(rnd(17)\1-8)*8
			end
			tar_swing_y=(rnd(5)\1-2)*16
			if y<32 then tar_swing_y =16 end

			-- tar_swing_x += x
			-- tar_swing_y += y
			-- tar_swing_x = x-8
			-- tar_swing_y=y				printh(sc .. " x:" ..spline(sc).x.." y:" ..spline(sc).y)max

			if y<32 then tar_swing_y =16 end
			if y>64 then tar_swing_y =-48 end
			if phase==3 then tar_swing_y=32-y end

			-- tar_swing_x=0
			-- tar_swing_y=0
			local spl_dat={x,y,
			x+0.5*tar_swing_x,min(y, y+tar_swing_y)-8,
			x+0.5*tar_swing_x,min(y, y+tar_swing_y)-8,
			x+tar_swing_x,y+tar_swing_y}
			spline=read_spline(spl_dat)
		else if spline then 
			sc=sc+1/64

			if sc<1 then 
				dx=0
				dy=0
				merge(_ENV, spline(sc))
			else
				if (maxshots ==0) line_shot(_ENV,rage)
				sc=0 
				spline=nil
			end
		end
		end

		if fra%120 == 0 and phase==2 then
			for i = 1,5 do
			add_enemy(mine(rnd(128),rnd(128)))
			end
		end

		if fra%143 == 0 and maxshots == 0 then
			line_shot(_ENV,rage)
		end

		if (fra%100==0 or fra%50==10 or fra%100==20) then
			if (maxshots > 0) then
				create_aim_ebul(_ENV,cnt+1)
				cnt = cnt%maxshots+1
			end
		end
		hist[fra%20]={x,y}
	end
	--od=draw300
	function draw(_ENV)
		
		
		if flash>0 then
			pal(lightenpal[1])
		end
		if flash>2 then
			pal(lightenpal[2])
		end
		sspr(0,64,12,32,x-12-exp,y-15)
		sspr(35,64,12,32,x+exp,y-15)
		sspr(13,64,22,32,x-11,y-15)
		spr(split"134,166,134,146"[fra\30%4+1],x-8,y-8,2,2)
		pal()
		palt()
		draw_collision(_ENV)
	end
	return _ENV
end

function boss_attach(boss,side)
	-- -1 left 1 right
	local _ENV = create_mob(128,0,0,1.5,4)
	ox,exp,ht=-3,0,{0,0}
	ang=0.75
	prefiring=false
	firing=false
	rot_spd =0
	countdown=120
	max_countdown=120
	if side==1 then
		s=132.375
		ox=27
	end

	hp=50
	od=draw
	function draw()
		lazershot(_ENV)
		for i=0,1,0.3333 do
			spr(142, lerp(boss.x+0.5*boss.pw*side,x,i)-4, lerp(boss.y,y,i)-12)
		end
		od(_ENV)

		-- spr(143,lerp(boss.x+boss.pw*side*0.5,x-pw*side,0.3),lerp(boss.y,y,0.3)-12)
		-- spr(143,lerp(boss.x+boss.pw*side*0.5,x,0.6)+4*side*0.6,lerp(boss.y,y,0.6)-12)
	end

	function upd(_ENV)

		--Fixme de duplicate
		flash=max(0, flash-1)
		
		countdown=(countdown-1)%max_countdown
		prefiring= countdown<80
		if countdown==80 then
			sfx(54)
		end
		if countdown<50 and countdown>20 then
			prefiring=false
			firing=true
		else firing =false
		end
		
		local h=boss.hist[(boss.fra-10)%20]
		ht=h
		local tx,ty=h[1],h[2]

		exp=min(exp+0.5,18)

		flash=max(0, flash-1)
		x=h[1]+side*(pw*-0.5+boss.pw*0.5+exp)
		y=h[2]
	end

	add_enemy(_ENV,1)
end

--8118
function line_shot(e,rage)
	sfx(58,3)
	local _ENV=create_mob(86,e.x,e.y+12)
	pw,ph,f=10,2,5
	function upd(_ENV)
		f+=1
		pw +=rage
		if (f>0) then
				_ENV.dy=min(f/15,1.5)
		else 
			x=e.x
		end
		if y>130 then
			remove(_ENV)
		end
	end
	function draw(_ENV)
		line(x-0.375*pw,y,x+0.375*pw,y,11)
		-- line(x-16,y,x+16,y, 11)
		line(x-0.5*pw,y-1,x-0.375*pw,y-1,11)
		line(x+0.375*pw,y-1,x+0.5*pw,y-1,11)
		for oy=1,8 do 
			for i=-0.5*pw,0.5*pw do
				ly=y-oy 
				if abs(i)>5 then
					ly -= 1
				end
				local cindex = rnd(5)\1+2-oy
				local c=3
				if cindex >= 4 then c=11 end
				if cindex >2 then 
					pset(x+i,ly,c)
				end
			end
		end	draw_collision(_ENV)

	end
	add(ebuls, _ENV)
	add(mobs, _ENV)
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
089a7a980001000000000000c7000000050000000000000000000000007776000001000000000000000000acd1a9409cd1a990499d1da940a991dc99a991dc40
089a7a98001d1000000000006070000057500000000000000000000007766660001d1000000000000000000ddd99009ddd99000491d19400099d1c90099ddd00
089a7a9801dcd100000000006c60000057750000000000000000000077622666001c1000000000000000000911940049119400049111940004911a4004911900
0289a98201dcd10000000000000000005777500000000000000000007628826d001c100000000000000000055055005500550005500055000550055005505500
0028982001dcd1000000000000000000577775000000000000000000762882d5001c100000000000000000000000000000000000000000000000000000000000
0002820001dcd100000000000000000057755000000000000000000066622555001c100000000000000000000000000000000000000000000000000000000000
00002000001d100000000000000000000550000000000000000000000666d55001dcd10000000000000000000000000000000000000000000000000000000000
00000000000100000000000000000000000000000000000000000000006d550001dcd10000000000000000000000000000000000000000000000000000000000
00000000000aa000009a9000677776650000000000000000000000000000000001dcd10000000000000000000000000000000000000cc111000e000e00000000
0000000000899800089a9800677776650000000000000000000000000000000001dcd10000000000000000000000000000000000007d1551100e000e00000000
0000000000088000089a9800067766500000000000000000000000000000000001dcd1000000000000000000000000000000000007d11155110e000e00000000
00008000000200000289820006776650000000000000000000000000000000001ddcdd1000000000000000000000000000000000cd11ddd15d1e000e00000000
0000f000000000000028200006776650000000000000000000000000000000001ddcdd1000000000000000000000000000000000c11dcccd511e000e00000000
000aa9000000000000020000067766500000000000800000000008080000000001dcd10000000000000000000000000000000000155dc7cd511e000e00000000
000ff9000000000000000000067766500000000000f000000000090f00000000001d100000000000000000000000000000000000511dcccd551e000e00000000
00049400000000000000000006776650008000000aa900000000a90a0000000000010000000000000000000000000000000000001d11ddd1d15e000e00000000
0000000000000000000000000677665000f000000ff900000000f90f900000000000000000000000007c67000000c0000000000005551511d10e000e00000000
000000001100000000000000067766500aa900000a9900000000a90990000000000000000000000007c700c0000c7c000000000000111551100e000e00000000
000000002200000000000000067766500ff90000f9499000000f99549900000008000000000c00006c700767000c7c00000000000001d111000e000e00000000
000000003300000000000000067766500a990000a90a9000000a90c0a900000088080880c0c7c00c7c0000760000c00000004999eeeeeeeeeeeeeeee00000000
00000000440000000000000006776650a909900a990f990000a990d0f9900000080808087cc7c0c7c0000006000c00000004955500000000000e000e00000000
0000000055000000000000000677665004a9000049a990000004991a9900000008008280c7cc0c7c607007cc00c7c0000049555500000000000e000e00000000
000000006500000000000000067766500499000004990000000049d990000000000000800c0000c007c70c7000c7c0000095555500000000000e000e00000000
000000007600000000000000067766500494000004940000000049194000000000000000000000000076c700000c000000955555eeeeeeeeeeeeeeee00000000
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
00000009400000000000000509400000000000000000000000000000000000000011111111011111005550000000555000055000555055000000000055555550
000000009a9aa0000000a9a9a9a90000000a9a9a0000000017716611116616710000002a99a77a992000000000000000000000000000bbb30077760000999800
000000009999900000009999999900000009999900000000776d1177771166d7000929a9aaaaaa999920000000003335013b3b100001bb330776666009988880
00000077111110057777111111117777100111117700000061d1771cc1661d1600909a9aa9aaa9aaaa9200000003a93353b3b3b3100b7b337765566d99822888
00000767677660061616166166166161600677766600000066171cc77c116166090999a9999a9a9a7aa90000000aaa933b3b333bb117bb317650076d98200982
00000776766d600661611111111116166007666d660000006170b7710b011616029aa9499a999999aaa92000000aaaa3533310333bbb33137650076d98200982
00007967766d600666177777777771666007666d66900000617073107ab0161609aa949499aa49499aaa9900000a11a33310000013333b31766776dd88899822
000076966dd6606661766666666667166606ddd66960000017071930a19b016129aa49424494944249aaa900000a17a3500331000013bb1306666dd008888220
0007676928d100171771661111661671d101728296660000160a19b0a19301619aa94494224449249a9aa900000a11a300393330000bbb31006ddd0000822200
0007966282d10017776d1177771166d7d1017628266600001600a0330a3330619a949449ffff9249ff9aa2000000113000aa9335000b7bb30000000000000000
0076692826d1001761d1771cc1661d16d101766282696000161101030500b36199494494ff244fff2499290000000000011aa9335007b7b11100000000000000
0077628266d1001766171cc77c116166d1017666289660006160880130b3311d98944f42f22244ff2249909000000000017aa93531017bb32200000000000000
0766728266d10017617b07710b011616d101766628266600616876800b31371689824f2fff777fff77f9290000000000011aa9335b00bbb13311000000000000
0776628275100076617a70107ab016166d101756282666006616883b131371d6982f49fff7c1cff91c78090000000000011aa935b300b7b34411000000000000
076162875d10007617a1ab001a9b01616d1017d52826160061716603b377171d294f99fff7107ff9077290000000000000aa93333b1007b15511000000000000
76181285dd10007616a193b01a93b0616d1017dd582181d017661166771176d1984f9ffff7101fff417829000000000000393335b3b107136551100000000000
718e8285dd100076160a5033aa3030616d1017dd5828e8107d66d11111176d6d494fffffffc1cfff74f2800000000000000331013bbbb331766d510000000000
76181285dd100076161001030500b3616d1017dd582181d017716611116616710494fff77ffffffff4f00000000333333100000003b313138221100000000000
76616285dd1000766161108e30b3311d6d1017dd582616d0776d1177771166d70049ffffff7fffffff4000000028e8ee33310000003133319944510000000000
761812825d100076616108778b313716dd1017d5182181d061d1771cc1661d1600989ffffffffff4f440000002877778ee3310000001bb33a994510000000000
718981261510007666161088031371d66d1017516218981066171cc77c006166000984fffffffffffff00000087070707ee353100000bb33b331100000000000
7618162661d1001761716600b377171dd1017611626181506171077110a006160000424ffffff0002f2000000087070788e335b3b10bbbb3cdd1100000000000
0661666261d1001717661166771176d1d101766126661d0061710a310a19061600000024ffffffffff0000000003888888335b3b3b3b31b3dd11000000000000
0ddddd6621d100177d66d11111176d6dd10176626dddd5001710a1930a19b0610000002244fffffff20000000000333333350013331311b3ee88210000000000
06666d6662d60000d66d1d6d6d61d6dd10076662666d65001610a19b0a19306100000222244fffff20000000000000000000000000000133ff6dd10000000000
006666d6626d00000dd166d6d6d61dd00006666266ddd00016110a3310ab3161eeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0066655d62d6000000d66dddddd6dd50000655626d6610001611010301033b61eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00d65115d26d000000d5dd1111dd555000051152dd6d10006160e88e3010311deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00d5677662d6000000d55100000d55100006776266d5100061687008eb313716eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00d55162222d000000e22200000e2220000222222dd5100066168888131371d6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00d22028888000000008800000008800000888888022200061716603b377171deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00088000000000000000000000000000000000000008800017661166771176d1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000000000000000000000000000000000000000000007d66d11111176d6deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
01222122002210222101222100129aa1222212200211222109aa9201112221022221000000000000000000045944941044444444424444444444544444444444
12aa424a11a4229a92129a921129aa22aaaa2aa22a229a92109aa922129a9219aaa2100000000000000000495440400049444444440444444445094444944494
2a99a2aa22aa29aaa929aaa9229aa2119aa92aa92a29aaa92019aaa229aaa92aa9aa200000f00000000000044500000041144444404e44444445014444444444
2a9221aa44aa2aa2aa2aa2aa49aaa9002aa22aaa9a2aa4aa2012a9aa2aa2aa4a929a20000f000400000000004000000045111444044411014450144444444444
24aa92aaaaaa2a929a2a929a2a92aa202aa22a9aaa2a414a212aa29a2a929a2aa9aa2000f4441840000000040000000044441199051100044441444445444244
1229a2aa44aa2aa2aa2aa2aa22229a902aa22a2aaa2aa4aa212a92222aa2aa2aaaa42000ff44444e000000544000000054444a00001004114444445444444444
2a99a2aa22aa29aaa929aaa921012aa29aa92a22aa2aaaaa219a210129aaa92aa9aa200004444100000404459400000049449011000411114494424441444444
29aa424a11a4229a92129a92100029a2aaaa2a202a2a424a22aa2000129a9219a29a200005005000014944954000000044490100000115544445544450144494
02222122002212222101222100001221222212000211212201221000112221122122100000000000000000000000000444490100000011444444424500144444
000000000000000008e80e0000000000000000000000000000000000000000000000000000000000100000000000004944440000004014444444445001424444
60000600006000008e7e8e8000000000000000000000000000000000000000000000000000000000400000000000000449410000449000114444450014444444
6d006dd006dd0000e7e8878000000000000000000000000000000000000000000000000000000000940000000000000049112004990110044499500144444444
6d22d4d22d4d22008e80878000000000000000000000000000000000000000000000000000000000400000000000000491144500001211444444455524445444
06dd494dd494ddd000000e0000000000000000000000000000000000000000000000000000000000440000000000005411410516141191444444424444444442
06d2849449482d500000000000000000000000000000000000000000000000000000000000000000945000400004044544111494124191114444424444444444
06288849948882500000000000000000000000000000000000000000000000000000000000000000554404940149449544424444144149194444444444444444
17716611116616711771661111661671000007776700000044944444444444440000000144000000004944294024442444444444444444444444444444444444
776d1177771166d7776d1177771166d7000776767666000044444414444544440000000144000000000004900044290049444444444444444444499944444444
61d1771cc1661d1661d1771cc1661d16007767666666600044444444444444440000004441400000000000000000900041002454444445444444449444455544
66171cc77c11616666171cc77c0061660776766676666d0045444444444444540000001444000000000000000000000045902244444444444555444444445011
6170b7710b0116166171077110a00616076766766666dd0044444444444424440000002449000000000000000000000044900124449444445101944945444544
617073107ab0161661710a310a190616767666222666d55044444944414444440000094444000000000000000000000044490002491444445009444451924444
17071930a19b01611710a1930a19b061776672888266d55044444444444444440000041244400000000000000000000044449901211144444994444449444444
160a19b0a19301611610a19b0a1930617676628882d6d55044454444444444140000944442140000000000000000000044424900111004444444445444449444
1600a0330a33306116110a3310ab31617766628882ddd55044444444144444440000412444490000000000000000000044444590122224444444451942444424
161101030500b3611611010301033b61767666222dddd55044444444444444540000044421400000000000000000000044444549000055444494451194444444
6160880130b3311d6160e88e3010311d0766666dddddd50049444444445444440000004444900000000000000000000044444445999900444444451009442444
616876800b31371661687008eb313716066666666ddd550044444414444444410000009442000000000000000000000042244444421290044444245009444444
6616883b131371d666168888131371d60066ddddddd5500044444444444414440000004441000000000000000000000044444444442459444444451164444444
61716603b377171d61716603b377171d000d55555555000044444444444444490000041444000000000000000009000044444444444444444444451644449694
17661166771176d117661166771176d1000005555500000041444454444444440000004410000000094000000092440044544494444544449444449444449111
7d66d11111176d6d7d66d11111176d6d000000000000000044444444445444440000004410000000924494004244420444444444444444444445444444444919
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
000b00001477011670366700c670316600d6402d6403a6700d650336400d630236302363010730086300e730076200d7200c720066100b7100b7100a710046100871007710077200261001610016100161001610
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

