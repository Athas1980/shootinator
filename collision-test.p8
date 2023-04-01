pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	extcmd("rec_frames")
	blobs=init_blobs()
	use_partition=true
	partition_size=16
	collision_checks=0
	coll_part={}
	partdim=128/partition_size
	cpu_move=0
	cpu_collide=0
end

function _update60()
	collision_checks=0
	cpu_move=stat(1)
	if use_partition then
		coll_part={}
		for i=1,partition_size*partition_size do
			coll_part[i]={}
		end
		foreach(blobs, move_blob_p)
		cpu_move=(stat(1)-cpu_move)*100
		cpu_collide = stat(1)
		run_collision_p()
		cpu_collide = (stat(1)-cpu_collide)*100
	else
		foreach(blobs, move_blob)
		foreach(blobs, run_collision)
	end
end

function _draw()
	cls()
	
	local cpu_draw=stat(1)
	foreach(blobs, draw_blob)
	print("checks:"..collision_checks,0,0,7)
	print((stat(1)*100).."%")
	print("circs:"..#blobs)
	print("CPU -move:"..cpu_move)
	print("CPU -collide:"..cpu_collide)
	cpu_draw=(stat(1)-cpu_draw)*100
	print("CPU -draw:"..cpu_draw)
end

function draw_blob(blob)
	local colour= blob.collided and 12 or 3
	circfill(blob.x,blob.y, blob.r, colour)
end

function run_collision(blob)
	for target in all(blobs) do
		if target ~= blob then
			has_collided(blob, target)
		end 
	end
end

function run_collision_p(blob)
	for part in all(coll_part) do
		for mob1,_ in pairs(part) do
			for mob2,_ in pairs(part) do
				if mob1 ~=mob2 then
					has_collided(mob1,mob2)
				end
			end
		end
	end
end

function has_collided(a,b)
	collision_checks += 1 
 local r=a.r+b.r
 local x=abs(a.x-b.x)
 if x>r then return false end
 local y=abs(a.y-b.y)
 if y>r then return false end
 collided=(x*x+y*y)<r*r 
	if collided then
		a.collided=true
	end
	return collided
end

function move_blob(blob)
	local newx= blob.x+blob.dx
	local newy= blob.y+blob.dy
	local maxx = 128-blob.r
	local maxy = 128-blob.r

	if newx > maxx or newx < 0 then
		blob.dx = -blob.dx
		newx = blob.x + blob.dx
	end

	if newy > maxy or newy < 0 then
		blob.dy = -blob.dy 
		newy = blob.y + blob.dy
	end 

	blob.x=newx
	blob.y=newy
	blob.collided =false
end

function move_blob_p(blob)
	local x,y,r=blob.x,blob.y,blob.r
	local maxv = 127-r
	local newx= x+blob.dx
	local newy= y+blob.dy


	if newx > maxv or newx < r then
		blob.dx = -blob.dx
		newx = blob.x + blob.dx
	end

	if newy > maxv or newy < r then
		blob.dy = -blob.dy 
		newy = blob.y + blob.dy
	end 

	blob.x=newx
	blob.y=newy
	blob.collided =false
	local top,right,bottom,left= newy+r,newx+r,newy-r,newx-r
	coll_part[box_hash(top, left)][blob]=true
	coll_part[box_hash(top, right)][blob]=true
	coll_part[box_hash(bottom, left)][blob]=true
 coll_part[box_hash(bottom, right)][blob]=true
end

function box_hash(x,y)	return x\partdim+y\partdim*partition_size+1 end



function init_blobs()
	local number=200
	increment=(124*124)/(number+1)
	local blobs={}
	for i=1, number do 
		local rad=rnd(2)\1+1
		rad=2
		local x=rnd(127-rad*2)+rad
		local y=rnd(127-rad*2)+rad
		local pos=i*increment
		add(blobs, {
			x=x,
			y=y,
			r=rad,
			dx=rnd(2)-1,
			dy=0,
			collided=false,
			boxes={}
				})
	end
	return blobs
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
