-- upd
-- move
-- draw
-- col
function create_mob(s,x,y,w,h)
	local dx,dy,w,h=0,0,w or 1,h or 1

	local mob={
		s=s,
		x=x or 64,
		y=y or 64,
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
		hp=1,
		score=100,
		fra=0,
		coffx=0,
		coffy=0,
		flash=0
	}
	setmetatable(mob,{__index=_ENV})
	return mob
end

function def_move(_ENV)
		x+=dx
		y+=dy
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
		local l,t=x-col_width/2,y+coffy-col_height/2
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
					die(_ENV)
				else 
					sfx(61)
				end 
end

function def_die(_ENV)
	mob_to_ppart(_ENV)
	remove(_ENV)
	score+=score*score_mult>>>16
	sfx(60)
end