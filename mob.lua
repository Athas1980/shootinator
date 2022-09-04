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
	return mob
end

function def_move(self)
		self.x+=self.dx
		self.y+=self.dy
end

function def_draw(self)
		if self.flash>0 then
			pal(lightenpal[1])
		end
		if self.flash>2 then
			pal(lightenpal[2])
		end
		spr(
			self.s,
			self.x-self.pw/2,
			self.y-self.ph/2,
			self.w,
			self.h)
			pal()
		draw_collision(self)
end

function def_col(self)
		local s=self
		local col_width=s.colw or s.pw-1
		local col_height=s.colh or s.ph-1
		local coffx=s.coffx or 0
		local coffy=s.coffy or 0
		local l,t=s.x-col_width/2,s.y+coffy-col_height/2
		return {
			l,
			t,
			l+col_width,
			t+col_height}
end

function def_hurt(self, pow)
				self.flash=5
				self.hp-=pow
				if self.hp <= 0 then
					self:die()
				else 
					sfx(61)
				end 
end

function def_die(self)
	mob_to_ppart(self)
	remove(self)
	score+=self.score*score_mult>>>16
	sfx(60)
end