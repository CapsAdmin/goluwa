local msgpack = require("luajit-msgpack-pure")
local jit_profiler = require("jit.profile")
local jit_util = require("jit.util")
local jit_vmdef = require("jit.vmdef")
local table_clear = require("table.clear")

local trace_abort_blacklist = {
	["leaving loop in root trace"] = true,
	["error thrown or hook called during recording"] = true,
}

local function start_profiling(b)
	if not b then
		jit_profiler.stop()
	else
		local data

		local file = io.open("zerobrane_statistical.msgpack", "rb")

		if file then
			data = select(2, msgpack.unpack(file:read("*all")))
			file:close()
		else
			data = {}
		end

		local temp = {}
		local temp_i = 1

		jit_profiler.start("l", function(thread, samples, vmstate)
			temp[temp_i] = {jit_profiler.dumpstack(thread, "pl\n", -500), samples}
			temp_i = temp_i + 1
		end)

		return function()
			for i, v in ipairs(temp) do
				local str, samples = v[1], v[2]
				local node = data

				for line in str:gmatch("(.-)\n") do
					local path, num = line:match("(.+):(.+)")

					if path and num then
						node[line] = node[line] or {}

						node[line].children = node[line].children or {}
						node[line].samples = (node[line].samples or 0) + samples

						node = node[line].children
					end
				end
			end

			table_clear(temp)
			temp_i = 1

			local file = assert(io.open("zerobrane_statistical.msgpack", "wb"))
			file:write(msgpack.pack(data))
			file:close()
		end
	end
end

local function start_jit_logging(b)
	if not b then
		jit.attach(function() end)
	else
		local data

		local file = io.open("zerobrane_trace_aborts.msgpack", "rb")

		if file then
			data = select(2, msgpack.unpack(file:read("*all")))
			file:close()
		else
			data = {}
		end

		local temp = {}
		local temp_i = 1

		jit.attach(function(what, trace_id, func, pc, trace_error_id, trace_error_arg)
			if what == "abort" then
				temp[temp_i] = {jit_util.funcinfo(func, pc), trace_error_id, trace_error_arg}
				temp_i = temp_i + 1
			end
		end, "trace")

		jit.on(true)
		jit.flush()

		return function()
			for i, v in ipairs(temp) do
				local info, trace_error_id, trace_error_arg = v[1], v[2], v[3]

				if not trace_abort_blacklist[reason] then
					local path = info.source:match("@(.+)")

					if path then
						local reason = jit_vmdef.traceerr[trace_error_id]

						if type(trace_error_arg) == "number" and reason:find("bytecode") then
							trace_error_arg = string.sub(jit_vmdef.bcnames, trace_error_arg*6+1, trace_error_arg*6+6)
							reason = reason:gsub("(%%d)", "%%s")
						end

						reason = reason:format(trace_error_arg)

						local line = info.currentline or info.linedefined

						data[path] = data[path] or {}
						data[path][line] = data[path][line] or {}
						data[path][line][reason] = (data[path][line][reason] or 0) + 1
					end
				end
			end

			table_clear(temp)
			temp_i = 1

			local file = assert(io.open("zerobrane_trace_aborts.msgpack", "wb"))
			file:write(msgpack.pack(data))
			file:close()
		end
	end
end

local lib = {
	start_jit_logging = start_jit_logging,
	start_profiling = start_profiling,
}

function lib.start()
	lib.profile_save_func = start_profiling(true)
	lib.jit_logging_save_func = start_jit_logging(true)
end

function lib.stop()
	lib.profile_save_func = start_profiling(false)
	lib.jit_logging_save_func = start_jit_logging(false)
end

function lib.save(interval)
	interval = interval or 3

	if (lib.next_save or 0) < os.clock() then
		if lib.profile_save_func then
			lib.profile_save_func()
		end

		if lib.jit_logging_save_func then
			lib.jit_logging_save_func()
		end

		lib.next_save = os.clock() + interval
		return true
	end
end

return lib