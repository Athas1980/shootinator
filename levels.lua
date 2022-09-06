local level = [[01,4,48
14,4,48
14,4,84
0a,4,88
0a,4,c8
02,4,c6
02,4,c4
0a,4,22
0f,4,22
00,4,43
00,4,62
00,4,83
0a,4,f2
00,4,d3
00,4,c4
00,4,a6
00,4,86
14,4,18
00,4,38
00,4,58
00,4,78
14,4,f4
00,4,d4
00,4,c4
00,4,a4
00,4,84
14,4,18
00,4,38
00,4,58
00,4,78
14,4,f4
00,4,d4
00,4,c4
00,4,a4
00,4,84
19,4,78
00,4,98
02,4,76
00,4,96
06,4,44
00,4,54
00,4,b4
00,4,d4
03,4,46
00,4,56
00,4,b6
00,4,d6]]

--In the end this should just be a sequence of bytes
--so it can be converted later
local dat={}
for row in all(split(level,"\n")) do
 local bytes = split(row,",",false)
 for byte in all(bytes) do
  add(dat, tonum("0x"..byte))
 end
end
-- for byte in all(dat) do
--  printh(byte)
-- end

function level_iter()
 local i=0 --for fred
 return function()
     i+=1 return list[i]
 end
end

local distance_spawn={}

local next=level_iter()

local function append(f2, f1)
  return function() f1() f2() end
end

local dist=0
while finished==false do
 value=next()
 if (value == nil) then
  finished=true
 else
   local d=next()
   if value==4 then
    add(distance_spawn,read_green(next))
   end
  end
 end
end

function read_green(fn_next)
 
end

