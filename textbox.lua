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