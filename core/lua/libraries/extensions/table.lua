table.new = desire("table.new") or function() return {} end
table.clear = desire("table.clear") or function(t) for k,v in pairs(t) do t[k] = nil end end

function table.shuffle(a, times)
	times = times or 1
	local c = #a
	
	for i = 1, c * times do
		local ndx0 = math.random(1, c)
		local ndx1 = math.random(1, c)
		
		local temp = a[ndx0]
		a[ndx0] = a[ndx1]
		a[ndx1] = temp
	end
	
    return a
end

function table.scroll(tbl, offset)
	if offset == 0 then return end
	
	if offset > 0 then
		for i = 1, offset do
			local val = table.remove(tbl, 1)
			table.insert(tbl, val)
		end
	else
		for i = 1, math.abs(offset) do
			local val = table.remove(tbl)
			table.insert(tbl, 1, val)
		end
	end
end

-- http://stackoverflow.com/questions/6077006/how-can-i-check-if-a-lua-table-contains-only-sequential-numeric-indices
function table.isarray(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then return false end
	end
	return true
end

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

function table.removevalue(tbl, val)
	for i,v in ipairs(tbl) do
		if v == val then
			table.remove(tbl, i)
			break
		end
	end
end

function table.fixindices(tbl)
	local temp = {}
	
	for k, v in pairs(tbl) do
		table.insert(temp, {v = v, k = tonumber(k) or 0})
		tbl[k] = nil
	end
	
	table.sort(temp, function(a, b) return a.k < b.k end)
	
	for k, v in ipairs(temp) do
		tbl[k] = v.v
	end
	
	return temp
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

function table.add(a, b)
	for i, v in pairs(b) do
		table.insert(a, v)
	end
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
				logf("%s%s = table[%p]\n", tab:rep(indent), key, val)
				logf("%s[\n", tab:rep(indent))
				
				done[val] = tostringx(val)
				indent = indent + 1
				dump(val)
				indent = indent - 1
				
				logf("%s]\n", tab:rep(indent))
			elseif t == "string" then
				local str = tostringx(val)
				if str:find("\n") then
					logf("%s%s = %s,\n", tab:rep(indent), key, str)
				else
					logf("%s%s = %q,\n", tab:rep(indent), key, str)
				end
			else
				logf("%s%s = %s,\n", tab:rep(indent), key, tostringx(val))
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
		
		done = nil
	end
end

do -- table copy
	local lookup_table = {}
	
		-- this is so annoying but there's not much else i can do
	local function has_copy(obj)
		assert(type(obj.__copy) == "function")
	end
	
	local function copy(obj, skip_meta)
	
		local t = type(obj)
	
		if t == "number" or t == "string" or t == "function" or t == "boolean" then
			return obj
		end
		
		if pcall(has_copy, obj) then
			return obj:__copy()
		elseif lookup_table[obj] then
			return lookup_table[obj]
		elseif t == "table" then		
			local new_table = {}
			
			lookup_table[obj] = new_table
					
			for key, val in pairs(obj) do
				new_table[copy(key, skip_meta)] = copy(val, skip_meta)
			end
			
			if skip_meta then			
				return new_table
			end
			
			local meta = getmetatable(obj)
			
			if meta then
				setmetatable(new_table, meta)
			end
			
			return new_table
		end
		
		return obj	
	end

	function table.copy(obj, skip_meta)
		table.clear(lookup_table)
		return copy(obj, skip_meta)
	end
end