spawn_tab={}
local rows=split(
 split(spawn_dat,"|",false)[level],
 "\n",false)
local dist=0
for row in all(rows) do
 local f=split(row,",")
 if #f>1 then
  dist+=f[1]
  local p={}
  for i=4,#f do add(p,f[i]) end
  local e=spawn_tab[dist]or{}
  add(e,{class=f[2],
   func=_ENV[f[3]],params=p})
  spawn_tab[dist]=e
 end
end
total_dist=dist
