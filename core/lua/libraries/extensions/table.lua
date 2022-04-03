
do -- negative pairs
	local v
	local function iter(a, i)
		i = i - 1
		v = a[i]
		if v then
			return i, v
		end
	end

	function table.npairs(a)
		return iter, a, #a + 1
	end
end

function table.map(tbl, cb)

	for i,v in ipairs(tbl) do
		tbl[i] = cb(v)
	end

	return tbl
end

function table.rpairs(tbl)
	local sorted = {}

	for key, val in pairs(tbl) do
		table.insert(sorted, {key = key, val = val, rand = math.random()})
	end

	table.sort(sorted, function(a,b) return a.rand > b.rand end)

	local i = 0

	return function()
		i = i + 1
		if sorted[i] then
			return sorted[i].key, sorted[i].val--, sorted[i].rand
		end
	end
end

function table.spairs(tbl, desc)
	local sorted = {}

	for key, val in pairs(tbl) do
		table.insert(sorted, {key = key, val = val})
	end

	if desc then
		table.sort(sorted, function(a,b) return a.key > b.key end)
	else
		table.sort(sorted, function(a,b) return a.key < b.key end)
	end

	local i = 0

	return function()
		i = i + 1
		if sorted[i] then
			return sorted[i].key, sorted[i].val--, sorted[i].rand
		end
	end
end

table.new = table.new or desire("table.new") or function() return {} end
table.clear = table.clear or desire("table.clear") or function(t) for k in pairs(t) do t[k] = nil end end

function table.lowercasedlookup(tbl, key)
	for k,v in pairs(tbl) do
		if k:lower() == key:lower() then
			return v
		end
	end
end

if not table.pack then
    function table.pack(...)
        return {
			n = select("#", ...),
			...
		}
    end
end

if not table.unpack then
	function table.unpack(tbl, start, stop)
		start = start or 1
		stop = stop or tbl.n

		return unpack(tbl, start, stop)
	end
end

do
	local table_concat = table.concat

	function table.concatrange(tbl, start, stop)
		local length = stop-start
		local str = {}
		local str_i = 1
		for i = start, stop do
			str[str_i] = tbl[i] or ""
			str_i = str_i + 1
		end
		return table_concat(str)
	end
end

function table.tolist(tbl, sort)
	local list = {}
	for key, val in pairs(tbl) do
		table.insert(list, {key = key, val = val})
	end

	if sort then table.sort(list, sort) end

	return list
end

function table.sortedpairs(tbl, sort)
	local list = table.tolist(tbl, sort)

	local i = 0

	return function()
		i = i + 1
		if list[i] then
			return list[i].key, list[i].val
		end
	end
end

function table.slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
		sliced[#sliced+1] = tbl[i]
	end

	return sliced
end


function table.shuffle(a, times)
	times = times or 1
	local c = #a

	for _ = 1, c * times do
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
		for _ = 1, offset do
			local val = table.remove(tbl, 1)
			table.insert(tbl, val)
		end
	else
		for _ = 1, math.abs(offset) do
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
		if t[i] == nil then
			return false
		end
	end
	return true
end

function table.reverse(tbl)
	for i = 1, math.floor(#tbl / 2) do
		tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end

	return tbl
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

function table.hasvaluei(tbl, val)
	for k,v in ipairs(tbl) do
		if v == val then
			return k
		end
	end

	return false
end

function table.getkey(tbl, val)
	for k in pairs(tbl) do
		if k == val then
			return k
		end
	end

	return nil
end

function table.getindex(tbl, val)
	for i, v in ipairs(tbl) do
		if i == v then
			return i
		end
	end

	return nil
end

function table.removevalues(tbl, val)
	local index = table.getindex(tbl, val)

	while index ~= nil do
		table.removevalues(tbl, index)
		index = table.getindex(tbl, val)
	end
end

function table.count(tbl)
	local i = 0

	for _ in pairs(tbl) do
		i = i + 1
	end

	return i
end

function table.merge(a, b, merge_aray)
	for k,v in pairs(b) do
		if type(v) == "table" and type(a[k]) == "table" then
			if merge_aray and table.isarray(a[k]) and table.isarray(v) then
				local offset = #a[k]
				for i = 1, #v do
					a[k][i + offset] = v[i]
				end
			else
				table.merge(a[k], v, merge_aray)
			end
		else
			a[k] = v
		end
	end

	return a
end

function table.virtualmerge(tbl, nodes)
	return setmetatable(tbl, {
		__index = function(_, key)
			local found = {}

			for _, node in ipairs(nodes) do
				local val = node[key]

				if val ~= nil then
					if type(val) ~= "table" then
						return val
					else
						table.insert(found, val)
					end
				end
			end

			if #found == 0 then
				return nil
			end

			return table.virtualmerge(found, found)
		end
	})
end


function table.add(a, b)
	for _, v in pairs(b) do
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

function table.print(...)
	local tbl = {...}

	local max_level

	if type(tbl[1]) == "table" and type(tbl[2]) == "number" and type(tbl[3]) == "nil" then
		max_level = tbl[2]
		tbl[2] = nil
	end

	if not serializer or not serializer.GetLibrary("luadata") then
		table.print2(tbl)
		return
	end

	local luadata = serializer.GetLibrary("luadata")
	luadata.SetModifier("function", function(var)
		return ("function(%s) --[==[ptr: %p    src: %s]==] end"):format(table.concat(debug.getparams(var), ", "), var, debug.getprettysource(var, true))
	end)
	luadata.SetModifier("fallback", function(var)
		return "--[==[  " .. tostringx(var) .. "  ]==]"
	end)

	log(luadata.ToString(tbl, {tab_limit = max_level, done = {}}):sub(0, -2))

	luadata.SetModifier("function", nil)
end

do
	local indent = 0
	function table.print2(tbl, blacklist)
		for k,v in pairs(tbl) do
			if (not blacklist or blacklist[k] ~= type(v)) and type(v) ~= "table" then
				log(("\t"):rep(indent))
				local v = v
				if type(v) == "string" then
					v = "\"" .. v .. "\""
				end

				logn(k, " = ", v)
			end
		end

		for k,v in pairs(tbl) do
			if (not blacklist or blacklist[k] ~= type(v)) and type(v) == "table" then
				log(("\t"):rep(indent))
				logn(k, ":")
				indent = indent + 1
				table.print2(v, blacklist)
				indent = indent - 1
			end
		end
	end
end

do -- table copy
	local lookup_table = {}

	local type = type
	local pairs = pairs
	local getmetatable = getmetatable

	local function copy(obj, skip_meta)

		local t = type(obj)

		if t == "number" or t == "string" or t == "function" or t == "boolean" then
			return obj
		end

		if ((t == "table" or (t == "cdata" and structs.GetStructMeta(obj))) and obj.__copy) then
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

function table.concatmember(tbl, key, sep)
	local temp = {}
	for i,v in ipairs(tbl) do
		temp[i] = tostring(v[key])
	end

	return table.concat(tbl, sep)
end

do
	local setmetatable = setmetatable
	local ipairs = ipairs

	local META = {}

	META.__index = META

	META.concat = table.concat
	META.insert = table.insert
	META.remove = table.remove
	META.unpack = table.unpack
	META.sort = table.sort

	function META:pairs()
		return ipairs(self)
	end

	function table.list(count)
		return setmetatable(table.new(count or 1, 0), META)
	end
end

function table.weak(k, v)
	if k and v then
		mode = "kv"
	elseif k then
		mode = "k"
	elseif v then
		mode = "v"
	else
		mode = "kv"
	end

	--return setmetatable({}, {__mode  = mode})

	return {}
end