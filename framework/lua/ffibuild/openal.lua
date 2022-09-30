for lib_name, enum_name in pairs({al = "AL_", alc = "ALC_"}) do
	ffibuild.Build(
		{
			name = "openal",
			addon = vfs.GetAddonFromPath(SCRIPT_PATH),
			lua_name = lib_name,
			shared_library_name = "openal",
			linux = [[
				FROM ubuntu:20.04

				ARG DEBIAN_FRONTEND=noninteractive
				ENV TZ=America/New_York
				RUN apt-get update

				RUN apt-get install -y libpulse-dev portaudio19-dev libasound2-dev libjack-dev qtbase5-dev libdbus-1-dev cmake g++ 
				RUN apt-get install -y git

				WORKDIR /src
				RUN git clone https://github.com/kcat/openal-soft.git --depth 1 .
				RUN cmake . && make --jobs 32
			]],
			c_source = [[
			#define AL_ALEXT_PROTOTYPES 1
			#include "AL/alc.h"
			#include "AL/alext.h"
			#include "AL/al.h"
			#include "AL/efx.h"
		]],
			gcc_flags = "-I./include",
			process_header = function(header)
				ffibuild.SetBuildName(lib_name)
				local meta_data = ffibuild.GetMetaData(header)
				return meta_data:BuildMinimalHeader(
					function(name)
						return name:find("^" .. lib_name .. "%u")
					end,
					function(name)
						return name:find("^" .. enum_name)
					end,
					true,
					true
				)
			end,
			build_lua = function(header, meta_data)
				ffibuild.SetBuildName(lib_name)
				-- seems to be windows only
				meta_data.functions.alcReopenDeviceSOFT = nil
				local s = [=[
					local ffi = require("ffi")
					local CLIB = assert(ffi.load("openal"))
					ffi.cdef([[]=] .. header .. [=[]])
				]=]

				if lib_name == "al" then
					s = s .. [[
						local function get_proc_address(func, cast)
							local ptr = CLIB.alGetProcAddress(func)
							if ptr ~= nil then
								return ffi.cast(cast, ptr)
							end
						end
					]]
					s = s .. "local library = {\n"

					for func_name, type in table.sorted_pairs(meta_data.functions, function(a, b)
						return a.key < b.key
					end) do
						local friendly = func_name:match("^" .. lib_name .. "(%u.+)")

						if friendly then
							s = s .. "\t" .. friendly .. " = get_proc_address(\"" .. func_name .. "\", \"" .. type:GetDeclaration(meta_data, "*", "") .. "\"),\n"
						end
					end

					s = s .. "}\n"
				else
					s = s .. "local library = " .. meta_data:BuildLuaFunctions("^" .. lib_name .. "(%u.+)")
				end

				local args = {}

				for _, name in ipairs({"al", "alc", "alext", "efx"}) do
					list.insert(args, {"./include/AL/" .. name .. ".h", enum_name})
				end

				local enums = meta_data:BuildLuaEnums("^" .. enum_name .. "(.+)", args)
				s = s .. "library.e = " .. enums

				if lib_name == "al" then
					local function gen_available_params(type, user_unavailable) -- effect params
						local available = {}
						local unavailable = {
							last_parameter = true,
							first_parameter = true,
							type = true,
							null = true,
						}
						local enums = loadstring("return " .. enums)()

						for k, v in pairs(user_unavailable) do
							unavailable[v] = true
						end

						local type_pattern = type:upper() .. "_(.+)"

						for key, val in pairs(enums) do
							local type = key:match(type_pattern)

							if type then
								type = type:lower()

								if not unavailable[type] then
									available[type] = {enum = val, params = {}}
								end
							end
						end

						for name, data in pairs(available) do
							for key, val in pairs(enums) do
								local param = key:match("^" .. name:upper() .. "_(.+)")

								if param then
									local name = param:lower()

									if param:find("DEFAULT_") then
										name = param:match("DEFAULT_(.+)")
										key = "default"
									elseif param:find("MIN_") then
										name = param:match("MIN_(.+)")
										key = "min"
									elseif param:find("MAX_") then
										name = param:match("MAX_(.+)")
										key = "max"
									else
										key = "enum"
									end

									name = name:lower()
									data.params[name] = data.params[name] or {}
									data.params[name][key] = val
								end
							end
						end

						s = s .. "library." .. type .. "Params = {\n"

						for type, info in table.sorted_pairs(available, function(a, b)
							return a.key < b.key
						end) do
							s = s .. "\t" .. type .. " = {\n"
							s = s .. "\t\t" .. "enum = " .. tostring(info.enum) .. ",\n"
							s = s .. "\t\t" .. "params = {\n"

							for key, tbl in table.sorted_pairs(info.params, function(a, b)
								return a.key < b.key
							end) do
								s = s .. "\t\t\t" .. key .. " = {\n"

								for key, val in table.sorted_pairs(tbl, function(a, b)
									return a.key < b.key
								end) do
									s = s .. "\t\t\t\t" .. key .. " = " .. tostring(val) .. ",\n"
								end

								s = s .. "\t\t\t" .. "},\n"
							end

							s = s .. "\t\t" .. "},\n"
							s = s .. "\t" .. "},\n"
						end

						s = s .. "}\n"
						s = s .. "function library.GetAvailable" .. type .. "s()\n\treturn library." .. type .. "Params\nend\n"
					end

					gen_available_params("Effect", {"pitch_shifter", "vocal_morpher", "frequency_shifter"})
					gen_available_params("Filter", {"highpass", "bandpass"})
				end

				for func_name in table.sorted_pairs(meta_data.functions, function(a, b)
					return a.key < b.key
				end) do
					local friendly = func_name:match("^" .. lib_name .. "(%u.+)")

					if friendly and friendly:find("^Gen%u%l") then
						local new_name = friendly:sub(0, -2) -- remove the last "s"
						s = s .. [[function library.]] .. new_name .. [[()
			local id = ffi.new("unsigned int[1]")
			library.]] .. friendly .. [[(1, id)
			return id[0]
		end
		]]
					end
				end

				if lib_name == "alc" then
					s = s .. [[
		function library.GetErrorString(device)
			local num = library.GetError(device)
			if num == library.e.NO_ERROR then
				return "no error"
			elseif num == library.e.INVALID_DEVICE then
				return "invalid device"
			elseif num == library.e.INVALID_CONTEXT then
				return "invalid context"
			elseif num == library.e.INVALID_ENUM then
				return "invalid enum"
			elseif num == library.e.INVALID_VALUE then
				return "invalid value"
			elseif num == library.e.OUT_OF_MEMORY then
				return "out of memory"
			end
		end
		]]
				elseif lib_name == "al" then
					s = s .. [[
		function library.GetErrorString()
			local num = library.GetError()
			if num == library.e.NO_ERROR then
				return "no error"
			elseif num == library.e.INVALID_NAME then
				return "invalid name"
			elseif num == library.e.INVALID_ENUM then
				return "invalid enum"
			elseif num == library.e.INVALID_VALUE then
				return "invalid value"
			elseif num == library.e.INVALID_OPERATION then
				return "invalid operation"
			elseif num == library.e.OUT_OF_MEMORY then
				return "out of memory"
			end
		end
		]]
				end

				s = s .. "library.clib = CLIB\n"
				s = s .. "return library\n"
				return s
			end,
			translate_path = function(path)
				local name = vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(path))

				if name:starts_with("libopenal") then return "libopenal" end
			end,
		}
	)
end