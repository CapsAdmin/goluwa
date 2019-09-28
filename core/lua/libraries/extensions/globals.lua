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
			table.insert(tmp, {k = k, v = v})
		end

		table.sort(tmp, function(a,b) return a.v > b.v end)
		if #tmp > 0 then
			str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
		end


		return str
	end

	pretty_prints["function"] = function(self)
		if debug.getprettysource then
			return ("function[%p][%s](%s)"):format(self, debug.getprettysource(self, true), table.concat(debug.getparams(self), ", "))
		end
		return tostring(self)
	end

	function tostringx(val)
		local t = type(val)

		if pretty_prints[t] then
			return pretty_prints[t](val)
		end

		return tostring(val)
	end
end

function tostring_args(...)
	local copy = table.pack(...)

	for i = 1, copy.n do
		copy[i] = tostringx(copy[i])
	end

	return copy
end

do
	local rawset = rawset
	local rawget = rawget
	local getmetatable = getmetatable
	local newproxy = newproxy

	if pcall(require, "table.gcnew") then
		local function gc(s)
			local tbl = s.tbl
			rawset(tbl, "__gc_proxy", nil)

			local new_meta = getmetatable(tbl)

			if new_meta then
				local __gc = rawget(new_meta, "__gc")
				if __gc then
					__gc(tbl)
				end
			end
		end

		-- 52 compat
		function setmetatable(tbl, meta)
			if meta and rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
				local proxy = _OLD_G.setmetatable(table.gcnew(), {__gc = gc})
				proxy.tbl = tbl

				rawset(tbl, "__gc_proxy", proxy)
			end

			return _OLD_G.setmetatable(tbl, meta)
		end
	else
		local function gc(s)
			local tbl = getmetatable(s).__div
			rawset(tbl, "__gc_proxy", nil)

			local new_meta = getmetatable(tbl)

			if new_meta then
				local __gc = rawget(new_meta, "__gc")
				if __gc then
					__gc(tbl)
				end
			end
		end

		-- 52 compat
		function setmetatable(tbl, meta)
			if meta and rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
				local proxy = newproxy(true)
				rawset(tbl, "__gc_proxy", proxy)

				getmetatable(proxy).__div = tbl
				getmetatable(proxy).__gc = gc
			end

			return _OLD_G.setmetatable(tbl, meta)
		end
	end
end
do -- logging
	local tostringx = _G.tostringx
	local tostring_args = _G.tostring_args
	local table_concat = table.concat
	local select = select

	local function formatx(str, ...)
		local args = table.pack(...)

		for i, chunk in ipairs(str:split("%")) do
			if i > 1 then
				if chunk:startswith("s") then
					args[i] = tostringx(args[i])
				end
			end
		end

		return str:format(unpack(args))
	end

	local base_log_dir = e.USERDATA_FOLDER .. "logs/"

	local log_files = {}
	local log_file

	function getlogpath(name)
		name = name or "console"

		return base_log_dir .. name .. "_" .. jit.os:lower() .. ".txt"
	end

	function setlogfile(name)
		name = name or "console"

		if not log_files[name] then
			local file = assert(io.open(getlogpath(name), "w"))
			file:setvbuf("no")

			log_files[name] = file
		end

		log_file = log_files[name]
	end

	function getlogfile(name)
		name = name or "console"

		return log_files[name]
	end

	local count = 0
	local last_count_length = 0

	fs.create_directory(base_log_dir)

	local suppress_print = false

	local function can_print(str)
		if suppress_print then return end

		if event then
			suppress_print = true

			if event.Call("ReplPrint", str) == false then
				suppress_print = false
				return false
			end

			suppress_print = false
		end

		return true
	end

	local function raw_log(str)
		if not log_file then
			setlogfile()
		end

		log_file:write(str)

		if log_files.console == log_file then
			if repl and repl.started and repl.StyledWrite then
				repl.StyledWrite(str)
			else
				io.write(str)
				io.flush()
			end
		end
	end

	function log(...)
		raw_log(table_concat(tostring_args(...)))
		return ...
	end

	function logn(...)
		raw_log(table_concat(tostring_args(...)) .. "\n")
		return ...
	end

	function print(...)
		raw_log(table_concat(tostring_args(...), ",\t") .. "\n")
		return ...
	end

	function logf(str, ...)
		raw_log(formatx(str, ...))
		return ...
	end

	function errorf(str, level, ...)
		error(formatx(str, ...), level)
	end

	function logsection(type, b)
		event.Call("LogSection", type, b)
	end

	do
		local level = 1
		function logsourcelevel(n)
			if n then
				level = n
			end
			return level
		end
	end

	-- library log
	function llog(fmt, ...)
		fmt = tostringx(fmt)

		local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1

		local source = debug.getprettysource(level + 1, false, true)
		local main_category = source:match(".+/libraries/(.-)/")
		local sub_category = source:match(".+/libraries/.-/(.-)/") or source:match(".+/(.-)%.lua")

		if sub_category == "libraries" then
			sub_category = source:match(".+/libraries/(.+)%.lua")
		end

		if main_category == "extensions" then
			main_category = nil
		end

		local str = fmt:safeformat(...)

		if not main_category or not sub_category or main_category == sub_category then
			return logf("[%s] %s\n", main_category or sub_category, str)
		else
			return logf("[%s][%s] %s\n", main_category, sub_category, str)
		end

		return str
	end

	-- warning log
	function wlog(fmt, ...)
		fmt = tostringx(fmt)

		local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1

		local str = fmt:safeformat(...)
		local source = debug.getprettysource(level + 1, true)

		logn(source, ": ", str)

		return fmt, ...
	end
end

do
	local luadata

	function fromstring(str)
		local num = tonumber(str)
		if num then return num end
		luadata = luadata or serializer.GetLibrary("luadata")
		return unpack(luadata.Decode(str, true)) or str
	end
end

function vprint(...)
	logf("%s:\n", debug.getinfo(logsourcelevel() + 1, "n").name or "unknown")

	for i = 1, select("#", ...) do
		local name = debug.getlocal(logsourcelevel() + 1, i)
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

	if not res and package.loaded[name] then
		return package.loaded[name]
	end

	return res
end

do -- nospam
	local last = {}

	function logf_nospam(str, ...)
		local str = string.format(str, ...)
		local t = system.GetElapsedTime()

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

	function wait(seconds)
		local time = system.GetTime()
		if not temp[seconds] or (temp[seconds] + seconds) <= time then
			temp[seconds] = system.GetTime()
			return true
		end
		return false
	end
end

local idx = function(var) return var.Type end

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

	if ok and res then
		return res
	end

	return t
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


function istype(var, ...)
	for _, str in pairs({...}) do
		if typex(var) == str then
			return true
		end
	end

	return false
end

if RELOAD then

end