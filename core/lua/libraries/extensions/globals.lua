do
	local pretty_prints = {}
	pretty_prints.table = function(t)
		local str = tostring(t)
		str = str .. " [" .. table.count(t) .. " subtables]"
		-- guessing the location of a library
		local sources = {}

		for _, v in pairs(t) do
			if type(v) == "function" then
				local src = debug.getinfo(v).source
				sources[src] = (sources[src] or 0) + 1
			end
		end

		local tmp = {}

		for k, v in pairs(sources) do
			list.insert(tmp, {k = k, v = v})
		end

		list.sort(tmp, function(a, b)
			return a.v > b.v
		end)

		if #tmp > 0 then str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]" end

		return str
	end
	pretty_prints["function"] = function(self)
		if debug.get_pretty_source then
			return (
				"function[%p][%s](%s)"
			):format(
				self,
				debug.get_pretty_source(self, true),
				list.concat(debug.get_params(self), ", ")
			)
		end

		return tostring(self)
	end

	function tostringx(val)
		local t = type(val)

		if pretty_prints[t] then return pretty_prints[t](val) end

		return tostring(val)
	end
end

function tostring_args(...)
	local copy = list.pack(...)

	for i = 1, copy.n do
		copy[i] = tostringx(copy[i])
	end

	return copy
end

do
	local luadata

	function from_string(str)
		local num = tonumber(str)

		if num then return num end

		luadata = luadata or serializer.GetLibrary("luadata")
		local res, err = luadata.Decode(str, true)

		if res == nil then return str end

		return unpack(res) or str
	end
end

function desire(name)
	local ok, res = pcall(require, name)

	if not ok then
		if VERBOSE then
			res = res:gsub("module .- not found:%s+", "")
			res = res:gsub("error loading module .- from file.-:%s+", "")
			wlog("unable to require %s:\n\t%s", name, res, 2)
		end

		return nil, res
	end

	if not res and package.loaded[name] then return package.loaded[name] end

	return res
end

do -- wait
	local temp = {}

	function wait(seconds)
		local time = system.GetTime()

		if not temp[seconds] or (temp[seconds] + seconds) <= time then
			temp[seconds] = system.GetTime()
			return true
		end

		return false
	end
end

local idx = function(var)
	return var.Type
end

function has_index(var)
	if getmetatable(var) == getmetatable(NULL) then return false end

	local T = type(var)

	if T == "string" then return false end

	if T == "table" then return true end

	if not pcall(idx, var) then return false end

	local meta = getmetatable(var)

	if meta == "ffi" then return true end

	T = type(meta)
	return T == "table" and meta.__index ~= nil
end

function typex(var)
	local t = type(var)

	if
		t == "nil" or
		t == "boolean" or
		t == "number" or
		t == "string" or
		t == "userdata" or
		t == "function" or
		t == "thread"
	then
		return t
	end

	local ok, res = pcall(idx, var)

	if ok and res then return res end

	return t
end