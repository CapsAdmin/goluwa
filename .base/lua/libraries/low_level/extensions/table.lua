table.new = require("table.new")
table.clear = require("table.clear")

-- 12:34 - <mniip> http://codepad.org/cLaX7lVn
function table.multiremove(tbl, locations)
	
	if locations[1] then
		local off = 0
		local idx = 1
		
		for i = 1, #tbl do
			while i + off == locations[idx] do
				off = off + 1
				idx = idx + 1
			end
			
			tbl[i] = tbl[i + off]
		end
	end
	
	return tbl
end

function table.fixindices(tbl)
	local temp = {}
	local i = 1
	for k, v in pairs(tbl) do
		temp[i] = v
		tbl[k] = nil
		i = i + 1
	end
	
	for k, v in ipairs(temp) do
		tbl[k] = v
	end
end

function table.hasvalue(tbl, val)
	for k,v in pairs(tbl) do
		if v == val then
			return k
		end
	end

	return false
end

function table.getkey(tbl, val)
	for k,v in pairs(tbl) do
		if k == val then
			return k
		end
	end

	return nil
end

function table.count(tbl)
	local i = 0
	
	for k,v in pairs(tbl) do
		i = i + 1
	end

	return i
end

function table.merge(a, b)
	for k,v in pairs(b) do
		if type(v) == "table" and type(a[k]) == "table" then
			table.merge(a[k], v)
		else	
			a[k] = v
		end
	end

	return a
end

function table.random(tbl)
	local key = math.random(1, table.count(tbl))
	local i = 1
	for _key, _val in pairs(tbl) do
		if i == key then
			return _val, _key
		end
		i = i + 1
	end
end

do -- table logn
	local dump
	local done = {}
	local indent = 0
	local tab = "\t"
	
	local max_level = math.huge
	
	dump = function(tbl)
		for key, val in pairs(tbl) do
			local t = typex(val)
			
			if t == "table" and not done[val] and indent < max_level then
				logf("%s%s = table[%p]", tab:rep(indent), key, val)
				logf("%s[", tab:rep(indent))
				
				done[val] = tostringx(val)
				indent = indent + 1
				dump(val)
				indent = indent - 1
				
				logf("%s]", tab:rep(indent))
			elseif t == "string" then
				logf("%s%s = \"%s\",", tab:rep(indent), key, tostringx(val))
			else
				logf("%s%s = %s,", tab:rep(indent), key, tostringx(val))
			end
		end 
	end
	
	function table.print(...)
		local tbl = {...}
		
		indent = 0
		done = {}
				
		if type(tbl[1]) == "table" and type(tbl[2]) == "number" and type(tbl[3]) == "nil" then
			max_level = tbl[2]
			tbl[2] = nil
		else
			max_level = math.huge
		end
		
		dump(tbl)
	end
end

do -- table copy
	local lookup_table = {}
	
	local function copy(obj, skip_meta)
	
		if hasindex(obj) and obj.Copy then
			return obj:Copy()
		elseif lookup_table[obj] then
			return lookup_table[obj]
		elseif type(obj) == "table" then
			local new_table = {}
			
			lookup_table[obj] = new_table
					
			for key, val in pairs(obj) do
				new_table[copy(key, skip_meta)] = copy(val, skip_meta)
			end
			
			return skip_meta and new_table or setmetatable(new_table, getmetatable(obj))
		else
			return obj
		end
	end

	function table.copy(obj, skip_meta)
		lookup_table = {}
		return copy(obj, skip_meta)
	end
end