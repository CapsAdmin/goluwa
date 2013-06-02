do -- check
	local level = 3

	local function check_custom(var, method, ...)
		local name = debug.getinfo(level, "n").name
		local func = debug.getinfo(level, "f").func
		local types = {...}
		local allowed = ""
		local typ = method(var)

		local matched = false

		for key, value in ipairs(types) do
			if #types ~= key then
				allowed = allowed .. value .. " or "
			else
				allowed = allowed .. value
			end

			if typ == value then
				matched = true
			end
		end

		local arg = "???"

		for i=1, math.huge do
			local key, value = debug.getlocal(2, i)
			-- I'm not sure what to do about this part with vars that have no refference
			if value == var then
				arg = i
			break end
		end

		if not matched then
			error(("bad argument #%s to '%s' (%s expected, got %s)"):format(arg, name, allowed, typ), level+1)
		end
	end

	function check(var, ...)
		check_custom(var, _G.type, ...)
	end
	
	function checkx(var, ...)
		check_custom(var, _G.typex, ...)
	end
end

function hasindex(var)
	if getmetatable(var) == getmetatable(NULL) then return false end

	local T = type(var)
	
	if T == "string" then
		return false
	end
	
	if T == "table" then
		return true
	end
	
	local meta = getmetatable(var)
	
	if meta == "ffi" then return true end
	
	T = type(meta)
		
	return T == "table" and meta.__index ~= nil
end

local idx = function(var) return var.Type end

function typex(var)
	
	if getmetatable(var) == getmetatable(NULL) then return "null" end

	if hasindex(var) then
		-- why does ffi throw error when trying to index instead of nil?
		local ok, res = pcall(idx, var)
		if ok then
			return res or type(var)
		else
			---print(type(var), var)
			--error(res)
		end
	end

	return type(var)
end

function istype(var, ...)
	for _, str in pairs({...}) do
		if typex(var) == str then
			return true
		end
	end

	return false
end

do -- printing
	local pretty_prints = {}
	
	pretty_prints.table = function(t)
		local str = tostring(t)
				
		str = str .. " [" .. table.count(t) .. " subtables]"
		
		-- guessing the location of a library
		local sources = {}
		for k,v in pairs(t) do	
			if type(v) == "function" then
				local src = debug.getinfo(v).short_src
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
		return pretty_prints[t] and pretty_prints[t](val) or tostring(val)
	end

	-- this behavior is only used if MsgN or Msg is defined
	if Msg ~= print then
		local suppress = false
		function print(...)
		
			if trace_print and not suppress then
				suppress = true
				debug.trace()
				suppress = false
			end
		
			local count = select("#", ...)

			if count == 0 then MsgN("nil") return end

			local out = ""
			
			for i = 1, count do
				local value = tostringx(select(i, ...))
				
				if i ~= count then
					out = out .. value .. ", "
				else
					out = out .. value
				end
			end
			
			out = out:gsub("(\t)", "    ")
			
			if MsgN then
				out = out .. "\n"
				
				for line in out:gmatch("(.-)\n") do
					MsgN(line)
				end
			else
				Msg(out)
			end
		end
	else
		local suppress_print = false

		local function on_print(...)
			if suppress_print then return end
			
			if event then 
				suppress_print = true
				
				if event.Call("OnPrint", table.concat({tostring_args(...)}, ", ")) == false then
					suppress_print = false
					return false
				end
				
				suppress_print = false
			end
			
			return true
		end
		
		print = function(...) if on_print(...) then return Msg(...) end end
	end

	function tostring_args(...)
		local copy = {}
		for i = 1, select("#", ...) do
			table.insert(copy, tostringx(select(i, ...)))
		end
		return unpack(copy)
	end

	function string.safeformat(str, ...)
		local count = select(2, str:gsub("(%%)", ""))
		local copy = {}
		for i = 1, count do
			table.insert(copy, tostringx(select(i, ...)))
		end
		return string.format(str, unpack(copy))
	end

	function printf(str, ...)
		print(string.safeformat(str, ...))
	end

	function errorf(str, level, ...)
		error(string.format(str, level, ...))
	end

	do
		local last = {}
	

		function nospam_printf(str, ...)
			local str = string.format(str, tostring_args(...))
			local t = os.clock()
			
			if not last[str] or last[str] < t then
				MsgN(str)
				last[str] = t + 3
			end
		end
		
		function nospam_print(...)
			nospam_printf(("%s "):rep(select("#", ...)), ...)
		end
	end

end

do -- negative pairs
	local v
	local function iter(a, i)
		i = i - 1
		v = a[i]
		if v then
			return i, v;
		end
	end

	function npairs(a)
		return iter, a, #a + 1;
	end
end