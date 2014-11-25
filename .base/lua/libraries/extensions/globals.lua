do -- verbose print
	function vprint(...)		
		logf("%s:\n", debug.getinfo(2, "n").name or "unknown")
		
		for i = 1, select("#", ...) do
			local name = debug.getlocal(2, i)
			local arg = select(i, ...)
			logf("\t%s:\n\t\ttype: %s\n\t\tprty: %s\n", name or "arg" .. i, type(arg), tostring(arg), serializer.Encode("luadata", arg))
			if type(arg) == "string" then
				logn("\t\tsize: ", #arg)
			end
			if typex(arg) ~= type(arg) then
				logn("\t\ttypx: ", typex(arg))
			end
		end
	end
end

function warning(format, ...)
	format = tostringx(format)
	
	local str = format:safeformat(...)
	local source = debug.getprettysource(2, true)

	logn(source, ": ", format)

	return format, ...
end	
	
do -- nospam
	local last = {}

	function logf_nospam(str, ...)
		local str = string.format(str, ...)
		local t = os.clock()
		
		if not last[str] or last[str] < t then
			logn(str)
			last[str] = t + 3
		end
	end
	
	function logn_nospam(...)
		logf_nospam(("%s "):rep(select("#", ...)), ...)
	end
end

do -- wait
	local temp = {}
	
	function wait(seconds, frames)
		local time = system.GetTime()
		if not temp[seconds] or (temp[seconds] + seconds) < time then
			temp[seconds] = system.GetTime()
			return true
		end
		return false
	end
end

do -- check
	local level = 3

	local function check_custom(var, method, ...)
		local name = debug.getinfo(level, "n").name
		
		local types = {...}
		local allowed = ""
		local typ = method(var)

		local matched = false

		for key, expected in ipairs(types) do
			if typ == expected then
				matched = true
			end
		end

		if not matched then
			local arg = ""

		for i = 1, 32 do
			local key, value = debug.getlocal(level, i)
				-- I'm not sure what to do about this part with vars that have no reference
				if value == var then				
					if #arg > 0 then
						arg = arg .. " or #" .. i
					else
						arg = arg .. "#" ..i
					end
				end
				
				if not key then
					break
				end
			end
		
			local allowed = ""
					
			for key, expected in ipairs(types) do
				if #types ~= key then
					allowed = allowed .. expected .. " or "
				else
					allowed = allowed .. expected
				end
			end
			
			error(("bad argument %s to '%s' (%s expected, got %s)"):format(arg, name, allowed, typ), level + 1)
		end
	end

	function check(var, ...)
		check_custom(var, _G.type, ...)
	end
	
	function checkx(var, ...)
		check_custom(var, _G.typex, ...)
	end
end

local idx = function(var) return var.TypeX or var.Type end

function hasindex(var)
	if getmetatable(var) == getmetatable(NULL) then return false end

	local T = type(var)
	
	if T == "string" then
		return false
	end
	
	if T == "table" then
		return true
	end
	
	if not pcall(idx, var) then return false end
	
	local meta = getmetatable(var)
	
	if meta == "ffi" then return true end
	
	T = type(meta)
		
	return T == "table" and meta.__index ~= nil
end

function typex(var)
	
	if getmetatable(var) == getmetatable(NULL) then return "null" end

	if hasindex(var) then
		-- why does ffi throw error when trying to index instead of nil?
		local ok, res = pcall(idx, var)
		if ok and res and getmetatable(var) then
			return res
		end
	end

	return type(var)
end

function istype(var, t)
	if 
		t == "nil" or
		t == "boolean" or
		t == "number" or
		t == "string" or
		t == "userdata" or
		t == "function" or
		t == "thread" or
		t == "table" or
		t == "cdata"
	then
		return type(var) == t
	end
	
	return typex(var) == t
end

local pretty_prints = {}

pretty_prints.table = function(t)
	local str = tostring(t)
			
	str = str .. " [" .. table.count(t) .. " subtables]"
	
	-- guessing the location of a library
	local sources = {}
	for k,v in pairs(t) do	
		if type(v) == "function" then
			local src = debug.getinfo(v).source
			sources[src] = (sources[src] or 0) + 1
		end
	end
	
	local tmp = {}
	for k,v in pairs(sources) do
		table.insert(tmp, {k=k,v=v})
	end
	
	table.sort(tmp, function(a,b) return a.v > b.v end)
	if #tmp > 0 then 
		str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
	end
	
	
	return str
end

function tostringx(val)
	local t = type(val)
	
	if t == "table" and getmetatable(val) then return tostring(val) end
	
	return pretty_prints[t] and pretty_prints[t](val) or tostring(val)
end

function tostring_args(...)
	local copy = {}
	
	for i = 1, select("#", ...) do
		table.insert(copy, tostringx(select(i, ...)))
	end
	
	return copy
end

function istype(var, ...)
	for _, str in pairs({...}) do
		if typex(var) == str then
			return true
		end
	end

	return false
end

do -- negative pairs
	local v
	local function iter(a, i)
		i = i - 1
		v = a[i]
		if v then
			return i, v
		end
	end

	function npairs(a)
		return iter, a, #a + 1
	end
end