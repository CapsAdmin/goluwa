_R = debug.getregistry()
F = string.format

do -- check
	local level = 3

	local function CheckCustom(var, method, ...)
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
		CheckCustom(var, _G.type, ...)
	end
end

function istype(var, ...)
	for _, str in pairs({...}) do
		if type(var) == str then
			return true
		end
	end

	return false
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

function istypex(var, ...)
	for _, str in pairs({...}) do
		if typex(var) == str then
			return true
		end
	end

	return false
end

function table.lastkeyvalue(tbl)
	local key, val

	for k, v in pairs(tbl) do
		key = k ~= nil and k or key
		val = v ~= nil and v or val
	end

	return key, val
end

old_print = print

function print(...)
	local args = {...}
	local count = table.lastkeyvalue(args) or table.count(args)

	if count == 0 then MsgN("nil") return end

	local new = ""
	local two_or_more = count >= 2

	for i=1, count do
		local value = tostring(args[i] or nil)
		
		if two_or_more then
			new = new .. value .. ", "
		else
			new = new .. value
		end
	end

	MsgN(new)
end

function tostring_args(tbl, force_count)
	local copy = {}
	for i=1, force_count or table.count(tbl) do
		local value = tbl[i] == nil and "nil" or tbl[i]
		table.insert(copy, tostring(value))
	end
	return copy
end

function string.safeformat(str, ...)
	local count = select(2, str:gsub("(%%)", ""))
	return string.format(str, unpack(tostring_args({...}, count)))
end

function printf(str, ...)
	MsgN(string.safeformat(str, ...))
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

function errorf(str, level, ...)
	error(string.format(str, level, ...))
end

do
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