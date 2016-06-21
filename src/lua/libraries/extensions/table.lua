table.new = table.new or desire("table.new") or function() return {} end
table.clear = table.clear or desire("table.clear") or function(t) for k in pairs(t) do t[k] = nil end end

if not table.pack then
    function table.pack(...)
        return {
			n = select("#", ...),
			...
		}
    end
end

if not table.unpack then
	function table.unpack(tbl)
		return unpack(tbl)
	end
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
		if t[i] == nil then return false end
	end
	return true
end

function table.reverse(tbl)
	for i = 1, math.floor(#tbl / 2) do
		tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end
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
	for k in pairs(tbl) do
		if k == val then
			return k
		end
	end

	return nil
end

function table.count(tbl)
	local i = 0

	for _ in pairs(tbl) do
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

	local luadata = serializer.GetLibrary("luadata")
	luadata.SetModifier("function", function(var)
		return ("function(%s) --[==[ptr: %p    src: %s]==] end"):format(table.concat(debug.getparams(var), ", "), var, debug.getprettysource(var))
	end)
	luadata.SetModifier("fallback", function(var)
		return "--[==[  " .. tostringx(var) .. "  ]==]"
	end)

	logn(luadata.ToString(tbl, {tab_limit = max_level, done = {}}))

	luadata.SetModifier("function", nil)
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

	return setmetatable({__mode  = mode})
end