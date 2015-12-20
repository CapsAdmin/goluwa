local steam = _G.steam or {}

include("mdl.lua", steam)
include("vmt.lua", steam)
include("bsp.lua", steam)
include("web_api.lua", steam)
include("server_query.lua", steam)
include("mount.lua", steam)
include("steamworks.lua", steam)

--[[local steamfriends = desire("ffi.steamfriends")

if steamfriends then
	for k,v in pairs(steamfriends) do
		if k ~= "Update" and k ~= "OnChatMessage" then
			steam[k] = v
		end
	end

	event.Timer("steam_friends", 0, 0.2, function()
		steamfriends.Update()
	end)

	function steamfriends.OnChatMessage(sender_steam_id, text, receiver_steam_id)
		event.Call("SteamFriendsMessage", sender_steam_id, text, receiver_steam_id)
	end
end]]

function steam.IsSteamClientAvailible()
	return steamfriends
end

function steam.SteamIDToCommunityID(id)
	if id == "BOT" or id == "NULL" or id == "STEAM_ID_PENDING" or id == "UNKNOWN" then
		return 0
	end

	local parts = id:Split(":")
	local a, b = parts[2], parts[3]

	return tostring("7656119" .. 7960265728 + a + (b*2))
end

function steam.CommunityIDToSteamID(id)
	local s = "76561197960"
	if id:sub(1, #s) ~= s then
		return "UNKNOWN"
	end

	local c = tonumber( id )
	local a = id % 2 == 0 and 0 or 1
	local b = (c - 76561197960265728 - a) / 2

	return "STEAM_0:" .. a .. ":" .. (b+2)
end

function steam.VDFToTable(str, lower_or_modify_keys, preprocess)
	if not str or str == "" then return nil, "data is empty" end
	if lower_or_modify_keys == true then lower_or_modify_keys = string.lower end

	str = str:gsub("http://", "___L_O_L___")
	str = str:gsub("https://", "___L_O_L_2___")

	str = str:gsub("//.-\n", "")

	str = str:gsub("___L_O_L___", "http://")
	str = str:gsub("___L_O_L_2___", "https://")

	str = str:gsub("(%b\"\"%s-)%[$(%S-)%](%s-%b{})", function(start, def, stop)
		if def ~= "WIN32" then
			return ""
		end

		return start .. stop
	end)

	str = str:gsub("(%b\"\"%s-)(%b\"\"%s-)%[$(%S-)%]", function(start, stop, def)
		if def ~= "WIN32" then
			return ""
		end
		return start .. stop
	end)


	local tbl = {}

	for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		tbl[#tbl + 1] = uchar
	end

	local in_string = false
	local capture = {}
	local no_quotes = false

	local out = {}
	local current = out
	local stack = {current}

	local key, val

	for i = 1, #tbl do
		local char = tbl[i]

		if (char == [["]] or (no_quotes and char:find("%s"))) and tbl[i-1] ~= "\\" then
			if in_string then

				if key then
					if lower_or_modify_keys then
						key = lower_or_modify_keys(key)
					end

					local val = table.concat(capture, "")

					if preprocess and val:find("|") then
						for k, v in pairs(preprocess) do
							val = val:gsub("|" .. k .. "|", v)
						end
					end

					if val:lower() == "false" then
						val = false
					elseif val:lower() ==  "true" then
						val =  true
					elseif val:find("%b{}") then
						local values = val:match("{(.+)}"):trim():explode(" ")
						if #values == 3 or #values == 4 then
							val = ColorBytes(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]), values[4] or 255)
						end
					elseif val:find("%b[]") then
						local values = val:match("%[(.+)%]"):trim():explode(" ")
						if #values == 3 and tonumber(values[1]) and tonumber(values[2]) and tonumber(values[3]) then
							val = Vec3(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))
						end
					else
						val = tonumber(val) or val
					end

					if type(current[key]) == "table" then
						table.insert(current[key], val)
					elseif current[key] then
						current[key] = {current[key], val}
					else
						if key:find("+", nil, true) then
							for i, key in ipairs(key:explode("+")) do
								if type(current[key]) == "table" then
									table.insert(current[key], val)
								elseif current[key] then
									current[key] = {current[key], val}
								else
									current[key] = val
								end

							end
						else
							current[key] = val
						end
					end

					key = nil
				else
					key = table.concat(capture, "")
				end

				in_string = false
				no_quotes = false
				capture = {}
			else
				in_string = true
			end
		else
			if in_string then
				table.insert(capture, char)
			elseif char == [[{]] then
				if key then
					if lower_or_modify_keys then
						key = lower_or_modify_keys(key)
					end

					table.insert(stack, current)
					current[key] = {}
					current = current[key]
					key = nil
				else
					return nil, "stack imbalance"
				end
			elseif char == [[}]] then
				current = table.remove(stack) or out
			elseif not char:find("%s") then
				in_string = true
				no_quotes = true
				table.insert(capture, char)
			end
		end
	end

	return out
end

function steam.BuildSteamWorksHeader()
	local prepend = "SteamWorks_"
	local blacklist = {
		["CSteamAPIContext"] = true,
		["CCallbackBase"] = true,
		["CCallback"] = true,
		["CCallResult"] = true,
		["CCallResult::func_t"] = true,
		["CCallback::func_t"] = true,
	}
	local json = serializer.ReadFile("json", "steam_api.json")

	local interfaces = {}

	local header = {}
	local i = 1
	local a = function(s, ...) header[i] = s:format(...) i = i + 1 end

	if false then -- consts
		for i, info in ipairs(json.consts) do
			a("static const %s %s = %s;", info.consttype, prepend .. info.constname, info.constval)
		end
	end

	do -- enums
		for group, info in ipairs(json.enums) do
			info.enumname = prepend .. info.enumname:gsub("::", "_")

			a("typedef enum %s {", info.enumname)
			for i,v in ipairs(info.values) do
				a("\t%s = %s%s", v.name, v.value, i == #info.values and "" or ",")
			end
			a("} %s;", info.enumname)
		end
	end

	do -- typedefs
		local done = {}

		for i, info in ipairs(json.typedefs) do
			if not blacklist[info.typedef] then
				info.type = info.type:gsub("%[.-%]", "*")
				if info.type:find("(*)", nil, true) then
					local line = info.type:gsub("%(%*%)", function() return "(*" .. prepend .. info.typedef .. ")" end)
					line = line:gsub("__attribute__%(%(cdecl%)%)", "")
					line = line:gsub("SteamAPICall_t", prepend .. "SteamAPICall_t")
					line = line:gsub("uint32", prepend .. "uint32")

					a("typedef %s;", line)
				else
					if not info.type:startswith("struct") and not info.type:startswith("union") and not pcall(ffi.typeof, info.type) then info.type = prepend .. info.type end

					a("typedef %s %s;", info.type, prepend .. info.typedef)
				end
			end
		end

		for i, info in ipairs(json.structs) do
			if info.struct == "CSteamAPIContext" then
				for i,v in ipairs(info.fields) do
					v.fieldtype = v.fieldtype:gsub("class ", "")
					v.fieldtype = v.fieldtype:sub(0,-3)
					interfaces[v.fieldtype] = v.fieldtype:sub(2)
					v.fieldtype = prepend .. v.fieldtype
					a("typedef struct %s {} %s;", v.fieldtype, v.fieldtype)
				end
			end
		end

		a("typedef struct %s {} %s;", prepend .. "ISteamClient", prepend .. "ISteamClient")
		a("typedef struct %s {} %s;", prepend .. "ISteamGameServer", prepend .. "ISteamGameServer")
		a("typedef struct %s {} %s;", prepend .. "ISteamGameServerStats", prepend .. "ISteamGameServerStats")
		a("typedef struct %s {} %s;", prepend .. "ISteamMatchmakingServerListResponse", prepend .. "ISteamMatchmakingServerListResponse")
		a("typedef struct %s {} %s;", prepend .. "ISteamMatchmakingPlayersResponse", prepend .. "ISteamMatchmakingPlayersResponse")
		a("typedef struct %s {} %s;", prepend .. "ISteamMatchmakingPingResponse", prepend .. "ISteamMatchmakingPingResponse")
		a("typedef struct %s {} %s;", prepend .. "ISteamMatchmakingRulesResponse", prepend .. "ISteamMatchmakingRulesResponse")
	end

	do -- structs
		-- CGame Fix
		for i,v in ipairs(json.structs) do
			if v.struct == "CGameID::(anonymous)" then
				table.remove(json.structs, i)
				table.insert(json.structs, i - 1, v)
				v.struct = "CGameID"
				v.fields[2].fieldtype = "struct GameID_t"
			end
		end

		-- vr:: Fix
		for i,v in pairs(json.structs) do
			if v.struct:find("vr::") then
				json.structs[i] = nil
			end
		end
		table.fixindices(json.structs)

		local function add_fields(info, level)
			for _, field in pairs(info.fields) do
				field.fieldtype = field.fieldtype:gsub("class ", "struct ")
				field.fieldtype = field.fieldtype:gsub("enum ", "")

				local size = field.fieldtype:match("(%[.-%])")
				if size then
					field.fieldtype = field.fieldtype:gsub(" (%[.-%])", "")
					field.fieldname = field.fieldname .. size
				end

				local type, name = field.fieldtype:match("(.+) (.+)")
				if type == "struct" or type == "union" then
					a("%s%s {", ("\t"):rep(level), type)
					local struct = info.struct
					for _, info in pairs(json.structs) do
						if info.struct:startswith(struct) then
							local struct = info.struct:gsub(struct .. "::", "")
							if struct:startswith(name) then
								add_fields(info, level + 1)
								json.structs[_] = nil
							end
						end
					end
					a("%s} %s;", ("\t"):rep(level), field.fieldname)
				else
					if not pcall(ffi.typeof, field.fieldtype) then field.fieldtype = prepend .. field.fieldtype end
					a("%s%s %s;", ("\t"):rep(level), field.fieldtype, field.fieldname)
				end
			end
		end

		for i, info in pairs(json.structs) do
			if not blacklist[info.struct] then
				a("typedef struct %s {", prepend .. info.struct)
				add_fields(info, 1)
				a("} %s;", prepend .. info.struct)
			end
		end
	end

	do -- methods
		for i, info in ipairs(json.methods) do
			if not info.classname:find("::", nil, true) then
				local args = "("

				args = args .. prepend .. info.classname .. "* self"

				if info.params then
					args = args .. ", "
					for i, arg in ipairs(info.params) do
						arg.paramtype = arg.paramtype:gsub("class ", "")
						arg.paramtype = arg.paramtype:gsub("struct ", "")
						if arg.paramtype ~= "const char *" then arg.paramtype = arg.paramtype:gsub("const ", "") end
						arg.paramtype = arg.paramtype:gsub("::", "_")

						if not pcall(ffi.typeof, arg.paramtype) then arg.paramtype = prepend .. arg.paramtype end

						args = args .. ("%s %s%s"):format(arg.paramtype, arg.paramname, i == #info.params and "" or ", ")
					end
				end
				args = args .. ")"

				info.returntype = info.returntype:gsub("class ", "")
				if not pcall(ffi.typeof, info.returntype) then info.returntype = prepend .. info.returntype end

				a("%s SteamAPI_%s_%s%s;", info.returntype, info.classname, info.methodname, args)
			end
		end
	end

	for k,v in pairs(interfaces) do
		a("%s *%s();", prepend .. k, v)
	end

	a("bool SteamAPI_Init();")

	header = table.concat(header, "\n")
	header = header:gsub("_Bool", "bool")
	header = header:gsub("&", "*")

	header = header:gsub("struct "..prepend.."CSteamID %b{} "..prepend.."CSteamID", "uint64_t "..prepend.."CSteamID")

	-- post fix (for callbacks since they don't have json info for their parameters)
	for i = 1, 500 do
		local ok, res = pcall(ffi.real_cdef, header)
		if ok then break end
		local t, line = res:match("declaration specifier expected near '(.-)' at line (.+)")
		line = tonumber(line)
		if t and line then
			local lines = header:explode("\n")
			lines[line] = lines[line]:gsub(t, function() return prepend .. t end)
			header = table.concat(lines, "\n")
		end
	end

	local lua = {}
	table.insert(lua, "--this file has been auto generated")
	table.insert(lua, "local ffi = require('ffi')")
	table.insert(lua, "ffi.cdef[[" .. header .. "]]")
	table.insert(lua, [[
local lib

if jit.os == "Windows" then
	if jit.arch == "x64" then
		lib = ffi.load("steam_api64")
	elseif jit.arch == "x86" then
		lib = ffi.load("steam_api")
	end
else
	lib = ffi.load("libsteam_api")
end

do
	local file = io.open("steam_appid.txt")
	if file then
		io.close(file)
	else
		local file, err = io.open("steam_appid.txt", "w")
		if file then
			file:write("999999")
			io.close(file)
		else
			error("failed to write steam_appid.txt (because it's needed) in cd : " .. err)
		end
	end

end

if not lib.SteamAPI_Init() then
	error("failed to initialize steamworks")
end

local steamworks = {}
	]])

	local steam_id_meta = {}

	for interface in pairs(interfaces) do
		local friendly = interface:sub(2):sub(6):lower()
		table.insert(lua, "steamworks." .. friendly .. " = {}")
		table.insert(lua, "steamworks." .. friendly .. "_ptr = lib." .. interface:sub(2) .. "()")
		for i, info in ipairs(json.methods) do
			if info.classname == interface then
				local args = ""
				if info.params then
					for i, arg in ipairs(info.params) do
						args = args .. ("%s%s"):format(arg.paramname, i == #info.params and "" or ", ")
					end
				end
				local arg_line = args
				local func = "function steamworks." .. friendly .. "." .. info.methodname .. "(" .. args .. ")"
				if #args > 0 then args = ", " .. args end
				if info.returntype == "const char *" then
					func = func .. "local str = lib.SteamAPI_"..interface.."_" .. info.methodname .. "(steamworks." .. friendly .. "_ptr" .. args .. ") if str ~= nil then return ffi.string(str) end"
				else
					func = func .. " return lib.SteamAPI_"..interface.."_" .. info.methodname .. "(steamworks." .. friendly .. "_ptr" .. args .. ")"
				end
				func = func .. " end"

				if info.params and info.params[1].paramtype == prepend .. "CSteamID" then
					info.friendly_interface = friendly
					info.arg_line = arg_line:match(".-, (.+)") or ""
					table.insert(steam_id_meta, info)
				end

				table.insert(lua, func)
			end
		end
	end

	table.insert(lua, "local META = {}")
	table.insert(lua, "META.__index = META")

	for i, info in ipairs(steam_id_meta) do

		local name = info.methodname
		name = name:gsub("User", "")
		name = name:gsub("Friend", "")
		local arg_line = info.arg_line
		if #arg_line > 0 then arg_line =  ", " .. arg_line end
		local func = "function META:" .. name .. "(" .. info.arg_line .. ") return steamworks." .. info.friendly_interface .. "." .. info.methodname .. "(self.id" .. arg_line .. ") end"
		table.insert(lua, func)
	end

	table.insert(lua, "META.__tostring = function(self) return ('[%s]%s'):format(self.id, self:GetPersonaName()) end")
	table.insert(lua, "function steamworks.GetFriendObjectFromSteamID(id) return setmetatable({id = id}, META) end")
	table.insert(lua, "steamworks.steamid_meta = META")

	table.insert(lua, "return steamworks")

	vfs.Write("lua/libraries/ffi/steamworks/init.lua", table.concat(lua, "\n"))

	include("lua/libraries/ffi/steamworks/init.lua")
end

return steam
