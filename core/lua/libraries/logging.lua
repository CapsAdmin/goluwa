local tostringx = _G.tostringx
local tostring_args = _G.tostring_args
local table_concat = table.concat
local select = select

local function formatx(str, ...)
	local args = table.pack(...)

	for i, chunk in ipairs(str:split("%")) do
		if i > 1 then
			if chunk:startswith("s") then args[i] = tostringx(args[i]) end
		end
	end

	return str:format(unpack(args))
end

local base_log_dir = e.USERDATA_FOLDER .. "logs/"
local log_files = {}
local log_file

function get_log_path(name)
	name = name or "console"
	return base_log_dir .. name .. "_" .. jit.os:lower() .. ".txt"
end

function set_log_file(name)
	name = name or "console"

	if not log_files[name] then
		local file = assert(io.open(get_log_path(name), "w"))
		file:setvbuf("no")
		log_files[name] = file
	end

	log_file = log_files[name]
end

function get_log_file(name)
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
	if not log_file then set_log_file() end

	log_file:write(str)

	if log_files.console == log_file and can_print(str) then
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
		if n then level = n end

		return level
	end
end

-- library log
function llog(fmt, ...)
	fmt = tostringx(fmt)
	local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1
	local source = debug.get_pretty_source(level + 1, false, true)
	local main_category = source:match(".+/libraries/(.-)/")
	local sub_category = source:match(".+/libraries/.-/(.-)/") or source:match(".+/(.-)%.lua")

	if sub_category == "libraries" then
		sub_category = source:match(".+/libraries/(.+)%.lua")
	end

	if main_category == "extensions" then main_category = nil end

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
	local source = debug.get_pretty_source(level + 1, true)
	logn(source, ": ", str)
	return fmt, ...
end

function vprint(...)
	logf("%s:\n", debug.getinfo(logsourcelevel() + 1, "n").name or "unknown")

	for i = 1, select("#", ...) do
		local name = debug.getlocal(logsourcelevel() + 1, i)
		local arg = select(i, ...)
		logf(
			"\t%s:\n\t\ttype: %s\n\t\tprty: %s\n",
			name or "arg" .. i,
			type(arg),
			tostring(arg),
			serializer.Encode("luadata", arg)
		)

		if type(arg) == "string" then logn("\t\tsize: ", #arg) end

		if typex(arg) ~= type(arg) then logn("\t\ttypx: ", typex(arg)) end
	end
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