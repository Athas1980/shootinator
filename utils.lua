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