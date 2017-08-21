package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.BuildSharedLibrary(
	"vulkan",
	"https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers.git",
	"./update_external_sources.sh && mkdir build && cd build && cmake .. && make"
)

local extensions = {
	"EXT",
	"KHR",
	"AMD",
	"NVX",
	"NV",
	"KHX",
	"GOOGLE",
}

local function is_extension(func_name)
	for _, ext in ipairs(extensions) do
		if func_name:sub(-#ext):upper() == ext then
			return #ext
		end
	end
	return false
end

local header = ffibuild.BuildCHeader([[
	#include "vulkan/vulkan.h"
]], "-I./repo/include/")

local meta_data = ffibuild.GetMetaData(header)

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^vk") end, function(name) return name:find("^VK_") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = {\n"

for func_name, func_type in pairs(meta_data.functions) do
	local friendly_name = func_name:match("^vk(.+)")
	if friendly_name and not is_extension(friendly_name) then
		lua = lua .. "\t" .. friendly_name .. " = " .. ffibuild.BuildLuaFunction(func_type.name, func_type) .. ",\n"
	end
end

lua = lua .. "}\n"

do -- utilities
	lua = lua .. "library.util = {}\n"
	lua = lua .. [[function library.util.StringList(tbl)
	return ffi.new("const char * const ["..#tbl.."]", tbl), #tbl
end
function library.util.GLSLToSpirV(type, glsl)
	local glsl_name = os.tmpname() .. "." .. type
	local spirv_name = os.tmpname()

	local temp

	temp = io.open(glsl_name, "wb")
	temp:write(glsl)
	temp:close()

	local msg = io.popen("glslangValidator -V -o " .. spirv_name .. " " .. glsl_name):read("*all")

	temp = io.open(spirv_name, "rb")
	local spirv = temp:read("*all")
	temp:close()

	if msg:find("ERROR") then
		error(msg, 2)
	end

	return {pCode = ffi.cast("uint32_t *", spirv), codeSize = #spirv}
end
function library.Assert(var, res)
	if var == nil and res ~= "VK_SUCCESS" then
		for name, v in pairs(library.e.result) do
			if res == v then
				name = name:gsub("error_", "")
				name = name:gsub("_", " ")
				error("Assertion failed: " .. name, 2)
				break
			end
		end
	end

	return var
end
function library.e(str_enum)
	return ffi.cast("enum GLFWenum", str_enum)
end
library.struct_gc = setmetatable({},{__mode = "k"})
]]
end

do -- macros
	lua = lua .. "library.macros = {}\n"
	lua = lua .. "library.macros.MAKE_VERSION = function(major, minor, patch) return bit.bor(bit.lshift(major, 22), bit.lshift(minor, 12) , patch) end\n"
end

local helper_functions = {}
local object_helper_functions = {}

do -- extensions
	lua = lua .. "local extensions = {}\n"

	for func_name, func_type in pairs(meta_data.functions) do
		local friendly_name = func_name:match("^vk(.+)")
		if friendly_name and is_extension(friendly_name) then
			lua = lua .. "extensions." .. func_name .. " = {ctype = ffi.typeof(\""..func_type:GetDeclaration(meta_data, "*", "").."\")}\n"
		end
	end

	lua = lua .. [[
local function load(func, ptr, ext, decl, name)
	if extensions[ext] and not decl and not name then
		decl = extensions[ext].ctype
	end

	local ptr = func(ptr, ext)

	if ptr ~= nil then
		name = name or ext:match("^vk(.+)")

		local func = ffi.cast(decl, ptr)

		library[name] = func

		return func
	end
end

library.util.LoadInstanceProcAddr = function(...) return load(CLIB.vkGetInstanceProcAddr, ...) end
library.util.LoadDeviceProcAddr = function(...) return load(CLIB.vkGetDeviceProcAddr, ...) end
]]

	object_helper_functions.Instance = object_helper_functions.Instance or {}
	object_helper_functions.Instance.LoadProcAddr = "library.util.LoadInstanceProcAddr"

	object_helper_functions.Device = object_helper_functions.Device or {}
	object_helper_functions.Device.LoadProcAddr = "library.util.LoadDeviceProcAddr"
end

local enum_group_translate = {}

do -- enums
	lua = lua .. "library.e = {\n"
	lua = lua .. [[
	LOD_CLAMP_NONE = 1000.0,
	REMAINING_MIP_LEVELS = 0xFFFFFFFF,
	REMAINING_ARRAY_LAYERS = 0xFFFFFFFF,
	WHOLE_SIZE = 0xFFFFFFFFFFFFFFFFULL,
	ATTACHMENT_UNUSED = 0xFFFFFFFF,
	TRUE = 1,
	FALSE = 0,
	QUEUE_FAMILY_IGNORED = 0xFFFFFFFF,
	SUBPASS_EXTERNAL = 0xFFFFFFFF,
	MAX_PHYSICAL_DEVICE_NAME_SIZE = 256,
	UUID_SIZE = 16,
	MAX_MEMORY_TYPES = 32,
	MAX_MEMORY_HEAPS = 16,
	MAX_EXTENSION_NAME_SIZE = 256,
	MAX_DESCRIPTION_SIZE = 256,
]]

	for basic_type, type in pairs(meta_data.enums) do
		for i, enum in ipairs(type.enums) do
			lua =  lua .. "\t" .. enum.key:match("^VK_(.+)") .. " = ffi.cast(\""..basic_type.."\", \""..enum.key.."\"),\n"
		end
	end

	local grouped_enums = {}

	for basic_type, type in pairs(meta_data.enums) do
		for i, enum in ipairs(type.enums) do

			local key = enum.key
			local decl = basic_type

			if key == "VK_STENCIL_FRONT_AND_BACK" then
				key = "VK_STENCIL_FACE_FRONT_AND_BACK"
			end

			if decl == "enum VkResult" then
				key = key:gsub("^VK_", "VK_RESULT_")
			end

            if decl == "enum VkIndirectCommandsTokenTypeNVX" then
                key = key:gsub("^VK_INDIRECT_COMMANDS_TOKEN_", "VK_INDIRECT_COMMANDS_TOKEN_TYPE_")
            end

			if decl == "enum VkColorSpaceKHR" then
				decl = "enum VkColorspaceKHR"
			end


			local start = ffibuild.ChangeCase(decl:match("^enum Vk(.+)"), "FooBar", "foo_bar")

            for _, ext in ipairs(extensions) do
                start = start:gsub("_"..ext:lower().."$", "")
            end
			start = start:gsub("_flag_bits", "")


			local friendly = key:sub(#start + #"VK_" + 2)

			friendly = friendly:lower()

			for _, ext in ipairs(extensions) do
                friendly = friendly:gsub("_"..ext:lower().."$", "")
            end
			friendly = friendly:gsub("_bit$", "")

			if tonumber(friendly:sub(1, 1)) or ffibuild.IsKeyword(friendly) then
				friendly = '["' .. friendly .. '"]'
			end


			grouped_enums[start] = grouped_enums[start] or {}
			grouped_enums[start][friendly] = "ffi.cast(\""..basic_type.."\", \""..enum.key.."\")"

			if enum.key:find("_BIT") then
				grouped_enums[start].make_enums = "function(flags) if #flags == 0 then return 0 end for i,v in ipairs(flags) do flags[i] = library.e."..start.."[v] end return bit.bor(unpack(flags)) end"
			end

			enum_group_translate[basic_type] = start
		end
	end

	for group_name, enums in pairs(grouped_enums) do
		lua = lua .. "\t" .. group_name .. " = {\n"
		for enum_name, value in pairs(enums) do
			lua = lua .. "\t\t" .. enum_name .. " = " .. value .. ",\n"
		end
		lua = lua .. "\t},\n"
	end
	lua = lua .. "}\n"
end

local flag_translate = {
	["struct VkImageSubresourceRange"] = {
		aspectMask = "enum VkImageAspectFlagBits",
	},
	["struct VkImageSubresourceLayers"] = {
		aspectMask = "enum VkImageAspectFlagBits",
	},
	["struct VkBufferCreateInfo"] = {
		usage = "enum VkBufferUsageFlagBits",
	},
	["struct VkDebugReportCallbackCreateInfoEXT"] = {
		flags = "enum VkDebugReportFlagBitsEXT",
	},
	["struct VkSwapchainCreateInfoKHR"] = {
		imageUse = "enum VkImageUsageFlagBits",
	},
	["struct VkDescriptorSetLayoutBinding"] = {
		stageFlags = "enum VkShaderStageFlagBits",
	},
	["struct VkPipelineRasterizationStateCreateInfo"] = {
		cullMode = "enum VkCullModeFlagBits",
	},
	["struct VkImageMemoryBarrier"] = {
		srcAccessMask = "enum VkAccessFlagBits",
		dstAccessMask = "enum VkAccessFlagBits",
	},
	["struct VkImageCreateInfo"] = {
		usage = "enum VkImageUsageFlagBits",
	},
	["vkCmdPipelineBarrier"] = {
		srcStageMask = "enum VkPipelineStageFlagBits",
		dstStageMask = "enum VkPipelineStageFlagBits",
	},
}

local function translate_arguments(tbl, arg_prefix, struct_type)
	arg_prefix = arg_prefix or "tbl."
	local p = arg_prefix
	local s = ""

	for i, type in ipairs(tbl) do
		if type.name ~= "sType" then
			if type.name:find("Enable$") or type:GetDeclaration() == "VkBool32" then
				s = s .. "\ttbl." .. type.name .. " = "..p.."" .. type.name .. " and 1 or 0\n"
			elseif type.name:find("^pp") and tbl[i - 1] and tbl[i - 1].name:find("Count$") then
				s = s .. "\tif type("..p.."" .. type.name .. ") == \"table\" then\n"
				s = s .. "\t\t"..p.."" .. tbl[i - 1].name .. " = #"..p.."" .. type.name .. "\n"
				s = s .. "\t\t"..p.."" .. type.name .. " = library.util.StringList("..p.."" .. type.name .. ")\n"
				s = s .. "\tend\n"
			else
				local basic_type = type:GetBasicType(meta_data)

				-- too basic, type information gets lost
				if basic_type == "int" then
					local name = type:GetDeclaration()
					if name:find("Flags") then
						if type.prev_type then
							name = type.prev_type:GetDeclaration()
							basic_type = "enum " .. name:gsub("Flags", "FlagBits")
						elseif name:find("Flags") then
							basic_type = "enum " .. name:gsub("Flags", "FlagBits")
						end
					end
				end

				if flag_translate[struct_type] then
					basic_type = flag_translate[struct_type][type.name] or basic_type
				end

				if enum_group_translate[basic_type] then
					if basic_type:find("FlagBits") then
						s = s .. "\tif type("..p.."" .. type.name .. ") == \"table\" then\n"
						s = s .. "\t\t"..p.."" .. type.name .. " = library.e." .. enum_group_translate[basic_type] .. ".make_enums("..p.."" .. type.name .. ")\n"
						s = s .. "\telseif type("..p.."" .. type.name .. ") == \"string\" then\n"
						s = s .. "\t\t"..p.."" .. type.name .. " = library.e." .. enum_group_translate[basic_type] .. "["..p.."" .. type.name .. "]\n"
						s = s .. "\tend\n"
					else
						s = s .. "\tif type("..p.."" .. type.name .. ") == \"string\" then\n"
						s = s .. "\t\t"..p.."" .. type.name .. " = library.e." .. enum_group_translate[basic_type] .. "["..p.."" .. type.name .. "]\n"
						s = s .. "\tend\n"
					end

					if type.name:find("Type$") and tbl[i - 1] and tbl[i - 1].name:find("Count$") then
						local count_var = tbl[i - 1]

						local ok = true

						for i = i + 1, #tbl do
							local type = tbl[i]
							if not type then break end

							if type:GetDeclaration(meta_data):sub(-1) ~= "*" then
								ok = false
								break
							end
						end

						if ok then
							for i = i + 1, #tbl do
								local type = tbl[i]
								if not type then break end

								local basic_type = type:GetBasicType(meta_data)
								local friendly = basic_type:match("^.- Vk(.+)")
								friendly = friendly:gsub("_T", "")
								s = s .. "\tif type("..p.."" .. type.name .. ") == \"table\" then\n"
								s = s .. "\t\tif not "..p..""..count_var.name.." then\n"
								s = s .. "\t\t\t"..p..""..count_var.name.." = #"..p..""..type.name.."\n"
								s = s .. "\t\tend\n"
								s = s .. "\t\t"..p.."" .. type.name .. " = library.s."..friendly.."Array("..p.."" .. type.name .. ")\n"
								s = s .. "\tend\n"
							end
						end
						break
					end
				elseif basic_type:find("^struct ") or basic_type:find("^union ") then
					local friendly = basic_type:match("^.- Vk(.+)")

					if type.name:find("^p") and tbl[i - 1] and tbl[i - 1].name:find("Count$") then
						friendly = friendly:gsub("_T", "")
						s = s .. "\tif type("..p.."" .. type.name .. ") == \"table\" then\n"
						s = s .. "\t\tif not "..p..""..tbl[i - 1].name.." then\n"
						s = s .. "\t\t\t"..p..""..tbl[i - 1].name.." = #"..p.."" .. type.name .. "\n"
						s = s .. "\t\tend\n"
						s = s .. "\t\t"..p.."" .. type.name .. " = library.s."..friendly.."Array("..p.."" .. type.name .. ", "..(type:GetDeclaration():find("*", nil, true) and "false" or "true")..")\n"
						s = s .. "\tend\n"
					elseif not friendly:find("_T$") then
						s = s .. "\tif type("..p.."" .. type.name .. ") == \"table\" then\n"
						s = s .. "\t\t"..p.."" .. type.name .. " = library.s."..friendly.."("..p.."" .. type.name .. ", "..(type:GetDeclaration():find("*", nil, true) and "false" or "true")..")\n"
						s = s .. "\tend\n"
					end
				end
			end
		end
	end
	return s
end

do -- enumerate helpers so you don't have to make boxed count and array values
	for func_name, func_type in pairs(meta_data.functions) do
		if func_name:find("^vkEnumerate") then
			local friendly = func_name:match("^vkEnumerate(.+)")
			local lib = is_extension(friendly) and "library" or "CLIB"

			if lib == "library" then func_name = func_name:match("^vk(.+)") friendly = friendly:sub(0, -4) end

			local parameters, call = func_type:GetParameters(nil, nil, -2)

			if #func_type.arguments ~= 2 then
				call = call .. ", "
			end

			lua = lua .. [[function library.Get]] .. friendly .. [[(]] .. parameters .. [[)
	local count = ffi.new("uint32_t[1]")
	]]..lib..[[.]]..func_name..[[(]] .. call .. [[count, nil)
	if count[0] == 0 then return end

	local array = ffi.new("]] .. func_type.arguments[#func_type.arguments]:GetDeclaration(meta_data):gsub("(.+)%*", "%1[?]") .. [[", count[0])
	local status = ]]..lib..[[.]] .. func_name .. [[(]] .. call .. [[count, array)

	if status == "VK_SUCCESS" then
		local out = {}

		for i = 0, count[0] - 1 do
			out[i + 1] = array[i]
		end

		return out
	end

	return nil, status
end
]]
			helper_functions[func_name] = "library.Get" .. friendly
		end
	end
end

do -- get helpers so you don't have to make a boxed value
	for func_name, func_type in pairs(meta_data.functions) do
		if func_name:find("^vkGet") or func_name:find("^vkAcquire") then
			local ret_basic_type = func_type.return_type:GetBasicType(meta_data)
			if ret_basic_type == "enum VkResult" or ret_basic_type == "void" then
				local type = func_type.arguments[#func_type.arguments]
				if type:GetDeclaration(meta_data):sub(-1) == "*" then
					local friendly = func_name:match("^vk(.+)")
					local lib = is_extension(friendly) and "library" or "CLIB"

					if lib == "library" then func_name = func_name:match("^vk(.+)") friendly = friendly:sub(0, -4) end

					if func_type.arguments[#func_type.arguments - 1]:GetDeclaration(meta_data)  == "unsigned int *" then
						local parameters, call, args = func_type:GetParameters(nil, nil, -2)

						call = call .. ", "


						lua = lua .. [[function library.]] .. friendly .. [[(]] .. parameters .. [[)
]]..translate_arguments(args, "", func_name)..[[
	local count = ffi.new("uint32_t[1]")

	]]..lib..[[.]] .. func_name .. [[(]] .. call .. [[count, nil)

	local array = ffi.new("]] .. func_type.arguments[#func_type.arguments]:GetDeclaration(meta_data):gsub("(.+)%*", "%1[?]") .. [[", count[0])
]]
						if ret_basic_type == "enum VkResult" then
							lua = lua .. [[
	local status = ]]..lib..[[.]] .. func_name .. [[(]] .. call .. [[count, array)

	if status == "VK_SUCCESS" then
		local out = {}

		for i = 0, count[0] - 1 do
			out[i + 1] = array[i]
		end

		return out
	end
	return nil, status
end
]]
						elseif ret_basic_type == "void" then
							lua = lua .. [[
	]]..lib..[[.]] .. func_name .. [[(]] .. call .. [[count, array)

	local out = {}

	for i = 0, count[0] - 1 do
		out[i + 1] = array[i]
	end

	return out
end
]]
						end
					else
						local parameters, call, args = func_type:GetParameters(nil, nil, -1)

						call = call .. ", "

						lua = lua .. [[function library.]] .. friendly .. [[(]] .. parameters .. [[)
]]..translate_arguments(args, "", func_name)..[[
	local box = ffi.new("]] .. type:GetDeclaration(meta_data):gsub("(.+)%*", "%1[1]") .. [[")
]]

						if ret_basic_type == "enum VkResult" then
							lua = lua .. [[
	local status = ]]..lib..[[.]] .. func_name .. [[(]] .. call .. [[box)

	if status == "VK_SUCCESS" then
		return box[0], status
	end

	return nil, status
end
]]
						elseif ret_basic_type == "void" then
							lua = lua .. [[
	]]..lib..[[.]] .. func_name .. [[(]] .. call .. [[box)
	return box[0]
end
]]
						end
					end

					helper_functions[func_name] = "library." .. friendly
				end
			end
		end
	end

	lua = lua .. [[
function library.MapMemory(device, memory, a, b, c, type, func)
	local data = ffi.new("void *[1]")

	local status = CLIB.vkMapMemory(device, memory, a, b, c, data)

	if status == "VK_SUCCESS" then
		if func then
			local ptr = func(ffi.cast(type .. " *", data[0]))
			if ptr then
				data[0] = ptr
			end
			library.UnmapMemory(device, memory)
		end
		return data[0]
	end

	return nil, status
end
	]]

	helper_functions.vkMapMemory = "library.MapMemory"
end

do -- struct creation helpers
	lua = lua .. "library.s = {}\n"
	local done = {}
	for i, info in ipairs(meta_data.enums["enum VkStructureType"].enums) do
		local name = info.key:match("VK_STRUCTURE_TYPE_(.+)")
		local friendly = ffibuild.ChangeCase(name:lower(), "foo_bar", "FooBar")

		if is_extension(friendly) then
            local len = is_extension(friendly)
			friendly = friendly:sub(0, -len-1) .. friendly:sub(-len):upper()
		end

		local struct = meta_data.structs["struct Vk" .. friendly]

		if struct then
			lua = lua .. "function library.s." .. friendly .. "(tbl, table_only)\n"
			lua = lua .. "\ttbl.sType = \"" .. info.key .. "\"\n"
			lua = lua .. translate_arguments(struct.data, "tbl.", "struct Vk" .. friendly)
			lua = lua .. "\treturn table_only and tbl or ffi.new(\"struct Vk" .. friendly .. "\", tbl)\nend\n"
			done[struct] = true
		end
	end

	for _, type in pairs(meta_data.typedefs) do
		local basic_type = type:GetBasicType(meta_data)
		local struct = meta_data.structs[basic_type] or meta_data.unions[basic_type]
		if struct then
			local keyword = struct:GetBasicType()
			local friendly = basic_type:match("^"..keyword.." Vk(.+)")
			if friendly then
				if basic_type:find("^"..keyword.." Vk.+_T$") then
					friendly = basic_type:match("^"..keyword.." Vk(.+)_T$")
					lua = lua .. 'function library.s.'..friendly..'Array(tbl) return ffi.new("'..basic_type..' *[?]", #tbl, tbl) end\n'
				else
					if not done[struct] then
						lua = lua .. "function library.s." .. friendly .. "(tbl, table_only)\n"
						lua = lua .. translate_arguments(struct.data, "tbl.", basic_type)
						lua = lua .. "\treturn table_only and tbl or ffi.new(\""..keyword.." Vk" .. friendly .. "\", tbl)\n"
						lua = lua .. "end\n"
					end
					lua = lua .. "function library.s."..friendly.."Array(tbl)\n"
					lua = lua .. "\tfor i, v in ipairs(tbl) do\n"
					lua = lua .. "\t\ttbl[i] = library.s."..friendly.."(v)\n"
					lua = lua .. "\tend\n"
					lua = lua .. "\treturn ffi.new(\""..basic_type.."[?]\", #tbl, tbl)\n"
					lua = lua .. "end\n"
				end
			end
		end
	end
end

do -- *Create helpers so you don't have to make a boxed value
	for func_name, func_type in pairs(meta_data.functions) do
		local parameters, call, args = func_type:GetParameters(nil, nil, #func_type.arguments - 1)
		if #func_type.arguments ~= 1 then call = call .. ", " end

		if func_name:find("^vkCreate") or func_name:find("^vkAllocate") then
			local friendly = func_name:match("^vk(.+)")
			local lib = is_extension(friendly) and "library" or "CLIB"

			if lib == "library" then func_name = func_name:match("^vk(.+)") friendly = friendly:sub(0, -4) end

			lua = lua .. [[function library.]]..friendly..[[(]]..parameters..[[)]] .. "\n"
			lua = lua .. translate_arguments(args, "", func_name)

			local keep_arg = {}

			if parameters:find("pCreateInfos") then
				keep_arg = "pCreateInfos"
			elseif parameters:find("Info") then
				for _, arg in ipairs(func_type.arguments) do
					if arg.name:find("Info") then
						keep_arg = arg.name
						break
					end
				end
			end

			lua = lua .. [[
	local box = ffi.new("]]..func_type.arguments[#func_type.arguments]:GetDeclaration(meta_data):gsub("(.+)%*", "%1[1]")..[[")
	local status = ]]..lib..[[.]]..func_name..[[(]]..call..[[box)

	if status == "VK_SUCCESS" then
		library.struct_gc[ box ] = ]]..keep_arg..[[

		return box[0], status
	end

	return nil, status
end
]]

			helper_functions[func_name] = "library." .. friendly
		end
	end
end

for func_name, func_type in pairs(meta_data.functions) do
	if not helper_functions[func_name] then
		local parameters, call, args = func_type:GetParameters()
		local friendly = func_name:match("^vk(.+)")
		local lib = is_extension(friendly) and "library" or "CLIB"

		if lib == "library" then func_name = func_name:match("^vk(.+)") friendly = friendly:sub(0, -4) end

		if not helper_functions[func_name] then
			lua = lua .. [[function library.]]..friendly..[[(]]..parameters..[[)]] .. "\n"
			lua = lua .. translate_arguments(args, "", func_name)
			lua = lua .. "\treturn " .. lib .. "." .. func_name .. "(" .. call .. ")\n"
			lua = lua .. "end\n\n"
			helper_functions[func_name] = "library." .. friendly
		end
	end
end

do
	local objects = {}

	for alias, type in pairs(meta_data.typedefs) do
		local basic_type = type:GetBasicType(meta_data)
		local friendly_type_name = basic_type:match("^struct Vk(.+)_T$")
		if friendly_type_name then
			objects[basic_type] = {meta_name = friendly_type_name, declaration = type:GetBasicType(meta_data), functions = {}}
			for func_name, func_type in pairs(meta_data:GetFunctionsStartingWithType(type)) do
				local friendly_name = func_name:match("^vk(.+)")
				friendly_name = friendly_name:gsub(friendly_type_name, "")

				-- INCONSISTENCIES!!!!!
				if friendly_type_name == "CommandBuffer" then
					friendly_name = friendly_name:gsub("Cmd", "")
				end

				if is_extension(friendly_name) then
					local ext_friendly_name = friendly_name:sub(0, -4)
					ext_friendly_name = ext_friendly_name:gsub("^Enumerate", "Get")

					if helper_functions[func_name:match("^vk(.+)")] then
						objects[basic_type].functions[ext_friendly_name] = helper_functions[func_name:match("^vk(.+)")]
					elseif helper_functions[func_name] then
						objects[basic_type].functions[ext_friendly_name] = helper_functions[func_name]
					else
						objects[basic_type].functions[ext_friendly_name] = "function(...) return library."..func_name:match("^vk(.+)").."(...) end"
					end
				else
					if helper_functions[func_name] then
						friendly_name = friendly_name:gsub("^Enumerate", "Get")
						objects[basic_type].functions[friendly_name] = helper_functions[func_name]
					else
						func_type.name = func_name:match("^vk(.+)") -- TODO
						objects[basic_type].functions[friendly_name] = func_type
					end
				end
			end

			if object_helper_functions[friendly_type_name] then
				for func_name, str in pairs(object_helper_functions[friendly_type_name]) do
					objects[basic_type].functions[func_name] = str
				end
			end
		end
	end

	for _, info in pairs(objects) do
		if next(info.functions) then
			lua = lua .. meta_data:BuildLuaMetaTable(info.meta_name, info.declaration, info.functions, nil, nil, "library", true)
		end
	end
end

ffibuild.EndLibrary(lua, header)
