local insert=table.insert
local assert=assert
local pairs=pairs
local type=type
local find=string.find
local sub=string.sub

local explode=string.explode
function string.replace(s,s2,s3)
	local a=explode(s,s2)
	local str=""
	if #a>1 then
		for i=1,#a-1 do
			str=str..a[i]..s3
		end
		str=str..a[#a]
		return str
	else
		return s
	end
end

local list=nil
function lovemu.listFilesRecursive(path,ext)
	ext=ext or ""
	for _,v in pairs(vfs.Find(path)) do
		if ext~="" then
			local info=explode(v,".")
			local str=""
			for i=2,#info do
				str=str..info[i]
			end
			if #info>1 and ext==str then 
				insert(list,path..v)
			else
				lovemu.listFilesRecursive(path..v.."/",ext)
			end
		else
			if #explode(v,".")>1 then 
				insert(list,path..v)
			else
				lovemu.listFilesRecursive(path..v.."/",ext)
			end
		end
	end
end

function lovemu.listFiles(path,ext)
	list={}
	lovemu.listFilesRecursive(path,ext)
	return list
end