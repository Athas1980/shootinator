pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	x=10
	y=64
	r=118
	cr=3
	inner_cr=1
	f=false
	b=126
end

function _draw()
	cls(3)
	print("corner radius:"..cr,0,0,7)
	print("⬆️ to increase")
	print("⬇️ to decrease")
	print("flip:"..tostr(f))
	print("❎ to change")
	box()
end

function _update()
	if btnp(⬆️) then
		cr+=1
	end
	if btnp(⬇️) then
		cr-=1
	end
	if btnp(❎) then
		f=not f
	end
	b=126-cr
	y=64+cr
end

--courtsey of heracleum
-- https://discord.com/channels/215267007245975552/215267007245975552/1000561070915715193
function box()
	for i=0,cr do
		rect(x+i,y-i,r-i,b+i,7)
		maybe_flip()
		end
	for i=0,cr-1 do
		rectfill(x+i+1,y-i,r-i-1,b+i,0)
		maybe_flip()
	end
end

function maybe_flip()
	if f then
		flip()
		flip()
	end
end
__gfx__
0000002a99a77a9920000000eeeeeeee00000000000000000000bbb3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
000929a9aaaaaa9999200000eeeeeeee00003335013b3b100001bb33eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00909a9aa9aaa9aaaa920000eeeeeeee0003a93353b3b3b3100b7b33eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
090999a9999a9a9a7aa90000eeeeeeee000aaa933b3b333bb117bb31eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
029aa9499a999999aaa92000eeeeeeee000aaaa3533310333bbb3313eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
09aa949499aa49499aaa9900eeeeeeee000a11a33310000013333b31eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
29aa49424494944249aaa900eeeeeeee000a17a3500331000013bb13eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
9aa94494224449249a9aa900eeeeeeee000a11a300393330000bbb31eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
9a949449ffff9249ff9aa200eeeeeeee0000113000aa9335000b7bb3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
99494494ff244fff24992900eeeeeeee00000000011aa9335007b7b1eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
98944f42f22244ff22499090eeeeeeee00000000017aa93531017bb3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
89824f2fff777fff77f92900eeeeeeee00000000011aa9335b00bbb1eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
982f49fff7c1cff91c780900eeeeeeee00000000011aa935b300b7b3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
294f99fff7107ff907729000eeeeeeee0000000000aa93333b1007b1eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
984f9ffff7101fff41782900eeeeeeee0000000000393335b3b10713eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
494fffffffc1cfff74f28000eeeeeeee00000000000331013bbbb331eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
0494fff77ffffffff4f00000eeeeeeee000333333100000003b31313eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
0049ffffff7fffffff400000eeeeeeee0028e8ee3331000000313331eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00989ffffffffff4f4400000eeeeeeee02877778ee3310000001bb33eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
000984fffffffffffff00000eeeeeeee087070707ee353100000bb33eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
0000424ffffff0002f200000eeeeeeee0087070788e335b3b10bbbb3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00000024ffffffffff000000eeeeeeee0003888888335b3b3b3b31b3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
0000002244fffffff2000000eeeeeeee0000333333350013331311b3eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00000222244fffff20000000eeeeeeee000000000000000000000133eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
