package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")


ffibuild.BuildSharedLibrary(
	"openal",
	"https://github.com/kcat/openal-soft.git",
	"cmake . && make"
)

for lib_name, enum_name in pairs({al = "AL_", alc = "ALC_"}) do

	ffibuild.lib_name = lib_name

	local headers = {
		"alc",
		"alext",
		"al",
		"efx",
	}

	local c_source = [[
		#define AL_ALEXT_PROTOTYPES
	]]

	for _, name in ipairs(headers) do
		c_source = c_source .. "#include \"" .. name .. ".h\"\n"
	end

	local header = ffibuild.BuildCHeader(c_source, "-I./repo/include/AL")

	do
		local args = {}

		for _, name in ipairs(headers) do
			table.insert(args, {"./repo/include/AL/" .. name .. ".h", enum_name})
		end
	end

	local meta_data = ffibuild.GetMetaData(header)
	local header = meta_data:BuildMinimalHeader(function(name) return name:find("^"..lib_name.."%u") end, function(name) return name:find("^" .. enum_name) end, true, true)

	ffibuild.lib_name = "openal"
	local lua = ffibuild.StartLibrary(header)

	ffibuild.lib_name = lib_name

	if lib_name == "al" then
		lua = lua .. [[
local function get_proc_address(func, cast)
	local ptr = CLIB.alGetProcAddress(func)
	if ptr ~= nil then
		return ffi.cast(cast, ptr)
	end
end
]]

		lua = lua .. "library = {\n"
			for func_name, type in pairs(meta_data.functions) do
				local friendly = func_name:match("^"..lib_name.."(%u.+)")
				if friendly then
					lua = lua .. "\t" .. friendly .. " = get_proc_address(\""..func_name.."\", \""..type:GetDeclaration(meta_data, "*", "").."\"),\n"
				end
			end
		lua = lua .. "}\n"
	else
		lua = lua .. "library = " .. meta_data:BuildFunctions("^"..lib_name.."(%u.+)")
	end

	local args = {}

	for _, name in ipairs(headers) do
		table.insert(args, {"./repo/include/AL/" .. name .. ".h", enum_name})
	end

	local enums = meta_data:BuildEnums("^"..enum_name.."(.+)", args)

	lua = lua .. "library.e = " .. enums

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

			for k,v in pairs(user_unavailable) do
				unavailable[v] = true
			end

			local type_pattern = type:upper().."_(.+)"

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
					local param = key:match(name:upper() .. "_(.+)")

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

			lua = lua .. "library." .. type .. "Params = {\n"
				for type, info in pairs(available) do
					lua = lua .. "\t" .. type .. " = {\n"
						lua = lua .. "\t\t" .. "enum = " .. tostring(info.enum) .. ",\n"
						lua = lua .. "\t\t" .. "params = {\n"
						for key, tbl in pairs(info.params) do
							lua = lua .. "\t\t\t" .. key .. " = {\n"
								for key, val in pairs(tbl) do
									lua = lua .. "\t\t\t\t" .. key .. " = " .. tostring(val) .. ",\n"
								end
							lua = lua .. "\t\t\t" .. "},\n"
						end
						lua = lua .. "\t\t" .. "},\n"
					lua = lua .. "\t" .. "},\n"
				end
			lua = lua .. "}\n"

			lua = lua .. "function library.GetAvailable" .. type .. "s()\n\treturn library." .. type .. "Params\nend\n"
		end

		gen_available_params("Effect", {"pitch_shifter", "vocal_morpher", "frequency_shifter"})
		gen_available_params("Filter", {"highpass", "bandpass"})
	end

	for func_name in pairs(meta_data.functions) do
		local friendly = func_name:match("^"..lib_name.."(%u.+)")
		if friendly and friendly:find("^Gen%u%l") then
			local new_name = friendly:sub(0,-2) -- remove the last "s"
			lua = lua ..
[[function library.]]..new_name..[[()
	local id = ffi.new("unsigned int[1]")
	library.]]..friendly..[[(1, id)
	return id[0]
end
]]
		end
	end


	if lib_name == "alc" then
		lua = lua .. [[
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
		lua = lua .. [[
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


	ffibuild.EndLibrary(lua, header)
end