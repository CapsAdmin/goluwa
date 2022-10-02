local tostringx = _G.tostringx
local tostring_args = _G.tostring_args
local list_concat = list.concat
local select = select
local logfile = _G.logfile or {}
logfile.files = {}

do
	local base_log_dir = e.USERDATA_FOLDER .. "logs/"
	fs.create_directory(base_log_dir)

	function logfile.GetOutputPath(name)
		return base_log_dir .. name .. "_" .. jit.os:lower() .. ".txt"
	end
end

function logfile.SetOutputName(name)
	if not logfile.files[name] then
		local file = assert(io.open(logfile.GetOutputPath(name), "w"))
		file:setvbuf("no")
		logfile.files[name] = file
	end

	logfile.current = logfile.files[name]
end

function logfile.GetOutputFile()
	return logfile.current
end

logfile.SetOutputName("console")

do
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

	function logfile.RawLog(str)
		logfile.GetOutputFile():write(str)

		if logfile.files.console == logfile.GetOutputFile() and can_print(str) then
			if repl and repl.started and repl.StyledWrite then
				repl.StyledWrite(str)
			else
				io.write(str)
				io.flush()
			end
		end
	end
end

function logfile.Log(...)
	logfile.RawLog(list_concat(tostring_args(...)))
	return ...
end

function logfile.LogNewline(...)
	logfile.RawLog(list_concat(tostring_args(...)) .. "\n")
	return ...
end

function logfile.Print(...)
	logfile.RawLog(list_concat(tostring_args(...), ",\t") .. "\n")
	return ...
end

do
	local function format(str, ...)
		local args = list.pack(...)

		for i, chunk in ipairs(str:split("%")) do
			if i > 1 then
				if chunk:starts_with("s") then args[i] = tostringx(args[i]) end
			end
		end

		return str:format(unpack(args))
	end

	function logfile.LogFormat(str, ...)
		logfile.RawLog(format(str, ...))
		return ...
	end

	function logfile.ErrorFormat(str, level, ...)
		error(format(str, ...), level)
	end
end

function logfile.LogSection(type, b)
	event.Call("LogSection", type, b)
end

do
	local level = 1

	function logfile.SourceLevel(n)
		if n then level = n end

		return level
	end
end

-- library log
function logfile.LibraryLog(fmt, ...)
	fmt = tostringx(fmt)
	local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1
	local source = debug.get_pretty_source(level + 1, false, true)
	local main_category = source:match(".+/libraries/(.-)/")
	local sub_category = source:match(".+/libraries/.-/(.-)/") or source:match(".+/(.-)%.lua")

	if sub_category == "libraries" then
		sub_category = source:match(".+/libraries/(.+)%.lua")
	end

	if main_category == "extensions" then main_category = nil end

	local str = fmt:safe_format(...)

	if not main_category or not sub_category or main_category == sub_category then
		return logf(
			"[%s] %s\n",
			main_category or
				sub_category or
				vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(source)),
			str
		)
	else
		return logf("[%s][%s] %s\n", main_category, sub_category, str)
	end

	return str
end

-- warning log
function logfile.WarningLog(fmt, ...)
	fmt = tostringx(fmt)
	local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1
	local str = fmt:safe_format(...)
	local source = debug.get_pretty_source(level + 1, true)
	logn(source, ": ", str)
	return fmt, ...
end

function logfile.VariablePrint(...)
	logf("%s:\n", debug.getinfo(logfile.SourceLevel() + 1, "n").name or "unknown")

	for i = 1, select("#", ...) do
		local name = debug.getlocal(logfile.SourceLevel() + 1, i)
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

	function logfile.LogFormatNoSpam(str, ...)
		local str = string.format(str, ...)
		local t = system.GetElapsedTime()

		if not last[str] or last[str] < t then
			logn(str)
			last[str] = t + 3
		end
	end

	function logfile.LogNewlineNoSpam(...)
		logfile.LogFormatNoSpam(("%s "):rep(select("#", ...)), ...)
	end
end

return logfile