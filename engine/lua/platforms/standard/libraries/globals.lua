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
end

function hasindex(var)
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

function typex(var)

	if hasindex(var) then
		return var.Type or type(var)
	end

	return type(var)
end

function istype(var, ...)
	for _, str in pairs({...}) do
		if type(var) == str then
			return true
		end
	end

	return false
end

do -- printing
	-- this behavior is only used if MsgN or Msg is defined
	if Msg ~= print then
		old_print = print

		function print(...)
			local count = select("#", ...)

			if count == 0 then MsgN("nil") return end

			local out = ""
			
			for i = 1, count do
				local value = tostring(select(i, ...))
				
				if i ~= count then
					out = out .. value .. ", "
				else
					out = out .. value
				end
			end

			MsgN(out)
		end
	end

	function tostring_args(...)
		local copy = {}
		for i = 1, select("#", ...) do
			table.insert(copy, tostring(select(i, ...)))
		end
		return unpack(copy)
	end

	function string.safeformat(str, ...)
		local count = select(2, str:gsub("(%%)", ""))
		local copy = {}
		for i = 1, count do
			table.insert(copy, tostring(select(i, ...)))
		end
		return string.format(str, unpack(copy))
	end

	function printf(str, ...)
		MsgN(string.safeformat(str, ...))
	end

	function errorf(str, level, ...)
		error(string.format(str, level, ...))
	end

	do
		local last

		function nospam_printf(str, ...)
			local str = string.format(str, unpack(tostring_args({...})))
			if last ~= str then
				MsgN(str)
				last = str
			end
		end
		
		function nospam_print(...)
			local args = {...}
			local count = #args
			nospam_printf(("%s "):rep(count), ...)
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