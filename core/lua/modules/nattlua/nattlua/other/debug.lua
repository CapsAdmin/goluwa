local lib = {}

local function inject_full_path()
	local ok, lib = pcall(require, "jit.util"--[[# as string]]) -- to avoid warning
	if ok and type(lib) == "table" and lib.funcinfo then
		lib._old_funcinfo = lib._old_funcinfo or lib.funcinfo

		function lib.funcinfo(...)
			local ret = {lib._old_funcinfo(...)}
			local info = ret[1]

			if
				info and
				type(info) == "table" and
				type(info.loc) == "string" and
				type(info.source) == "string" and
				type(info.currentline) == "number" and
				info.source:sub(1, 1) == "@"
			then
				info.loc = info.source:sub(2) .. ":" .. info.currentline
			end

			return unpack(ret)
		end
	end
end

function lib.EnableJITDumper()
	if not jit then return end

	if jit.version_num ~= 20100 then return end

	inject_full_path()
	local jutil = require("jit.util"--[[# as string]])
	local vmdef = require("jit.vmdef"--[[# as string]])
	local funcinfo, traceinfo = jutil.funcinfo, jutil.traceinfo
	local type, format = _G.type, string.format
	local stdout, stderr = io.stdout, io.stderr
	local out = stdout
	------------------------------------------------------------------------------
	local startloc, startex

	local function fmtfunc(func--[[#: any]], pc--[[#: any]])
		local fi = funcinfo(func, pc)

		if fi.loc then
			return fi.loc
		elseif fi.ffid then
			return vmdef.ffnames[fi.ffid]
		elseif fi.addr then
			return format("C:%x", fi.addr)
		else
			return "(?)"
		end
	end

	-- Format trace error message.
	local function fmterr(err--[[#: any]], info--[[#: any]])
		if type(err) == "number" then
			if type(info) == "function" then info = fmtfunc(info) end

			err = format(vmdef.traceerr[err], info)
		end

		return err
	end

	-- Dump trace states.
	local function dump_trace(
		what--[[#: any]],
		tr--[[#: any]],
		func--[[#: any]],
		pc--[[#: any]],
		otr--[[#: any]],
		oex--[[#: any]]
	)
		if what == "start" then
			startloc = fmtfunc(func, pc)
			startex = otr and "(" .. otr .. "/" .. (oex == -1 and "stitch" or oex) .. ") " or ""
		else
			if what == "abort" then
				local loc = fmtfunc(func, pc)

				if loc ~= startloc then
					out:write(
						format("[TRACE --- %s%s -- %s at %s]\n", startex, startloc, fmterr(otr, oex), loc)
					)
				else
					out:write(format("[TRACE --- %s%s -- %s]\n", startex, startloc, fmterr(otr, oex)))
				end
			elseif what == "stop" then
				local info = traceinfo(tr)
				local link, ltype = info.link, info.linktype

				if ltype == "interpreter" then
					out:write(format("[TRACE %3s %s%s -- fallback to interpreter]\n", tr, startex, startloc))
				elseif ltype == "stitch" then
					out:write(
						format(
							"[TRACE %3s %s%s %s %s]\n",
							tr,
							startex,
							startloc,
							ltype,
							fmtfunc(func, pc)
						)
					)
				elseif link == tr or link == 0 then
					out:write(format("[TRACE %3s %s%s %s]\n", tr, startex, startloc, ltype))
				elseif ltype == "root" then
					out:write(format("[TRACE %3s %s%s -> %d]\n", tr, startex, startloc, link))
				else
					out:write(
						format(
							"[TRACE %3s %s%s -> %d %s]\n",
							tr,
							startex,
							startloc,
							link,
							ltype
						)
					)
				end
			else
				out:write(format("[TRACE %s]\n", what))
			end

			out:flush()
		end
	end

	jit.attach(dump_trace, "trace")
end

function lib.GlobalLookup()
	local _G = _G
	local tostring = tostring
	local io = io
	local print = function(str--[[#: string]])
		io.write(str, "\n")
	end
	local rawset = rawset
	local rawget = rawget
	local copy = {}
	local setmetatable = setmetatable
	local debug = debug

	for k, v in pairs(_G) do
		copy[k] = v
		_G[k] = nil
	end

	copy._G = copy
	local blacklist = {require = true, _G = true}
	setmetatable(
		_G,
		{
			__index = function(_, key)
				if not blacklist[key] then
					print("_G." .. tostring(key))
					print(debug.traceback():match(".-\n.-\n(.-)\n"))
				end

				return rawget(copy, key)
			end,
			__newindex = function(_, key, val)
				if not blacklist[key] then
					print("_G." .. tostring(key) .. " = " .. tostring(val))
					print(debug.traceback():match(".-\n.-\n(.-)\n"))
				end

				rawset(copy, key, val)
			end,
		}
	)
end

do
	function _G.find_tests()
		for i = 1, math.huge do
			local info = debug.getinfo(i)

			if not info then break end

			local path = info.source

			if path:sub(1, 1) == "@" then
				if path:sub(2):find("test/nattlua/analyzer") then
					print(info.source:sub(2) .. ":" .. info.currentline)
				end
			end
		end
	end
end

return lib