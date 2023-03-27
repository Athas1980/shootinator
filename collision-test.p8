pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	blobs=init_blobs()
	use_partition=true
	partition_size=16
	collision_checks=0
	coll_part={}
	partdim=128/partition_size
end

function _update60()
	collision_checks=0
	if use_partition then
		coll_part={}
		for i=1,partition_size*partition_size do
			coll_part[i]={}
		end
		foreach(blobs, move_blob_p)
		run_collision_p()
	else
		foreach(blobs, move_blob)
		foreach(blobs, run_collision)
	end
end

function _draw()
	cls()
	foreach(blobs, draw_blob)
	print("checks:"..collision_checks,0,0,7)
	print(stat(1))
end

function draw_blob(blob)
	local colour= blob.collided and 12 or 3
	rectfill(blob.x,blob.y, blob.x+blob.w-1, blob.y+blob.h-1, colour)
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

function has_collided(mob1,mob2)
	local collided = not (
		  mob1.x+mob1.w<mob2.x or
				mob1.y+mob1.h<mob2.y or
				mob2.x+mob2.w<mob1.x or
				mob2.y+mob2.h<mob1.y)
	if collided then mob1.collided=true end
	collision_checks += 1 
end

function move_blob(blob)
	local newx= blob.x+blob.dx
	local newy= blob.y+blob.dy
	local maxx = 128-blob.w
	local maxy = 128-blob.h

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
	local newx= blob.x+blob.dx
	local newy= blob.y+blob.dy
	local maxx = 128-blob.w
	local maxy = 128-blob.h

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
	coll_part[box_hash(blob.x, blob.y)][blob]=true
	coll_part[box_hash(blob.x+blob.w-1, blob.y)][blob]=true
	coll_part[box_hash(blob.x, blob.y+blob.h-1)][blob]=true
 coll_part[box_hash(blob.x+blob.w, blob.y+blob.h-1)][blob]=true
end

function box_hash(x,y)	return x\partdim+y\partdim*partition_size+1 end



function init_blobs()
	local number=100
	increment=(124*124)/(number+1)
	local blobs={}
	for i=1, number do 
		local pos=i*increment
		add(blobs, {
			x=pos%124,
			y=pos\124,
			w=4,
			h=4,
			dx=rnd(2)-1,
			dy=rnd(2)-1,
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
