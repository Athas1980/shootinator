-- upd
-- move
-- draw
-- col
mobid=0
function create_mob(s,x,y,w,h)
	local dx,dy,w,h=0,0,w or 1,h or 1
	mobid +=1
	local mob={
		name="[mob:"..mobid.."]",
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
		if (self.name ~= nil) return self.name
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
