if not vfs.IsFile("steam_api.json") then
	error("please put steam_api.json in your data folder (" .. R("data/") .. "steam_api.json")
end

local ffi = require("ffi")
local prepend = "SteamWorks_"
local blacklist = {
	["CSteamAPIContext"] = true,
	["CCallbackBase"] = true,
	["CCallback"] = true,
	["CCallResult"] = true,
	["CCallResult::func_t"] = true,
	["CCallback::func_t"] = true,
}
local json = vfs.Read("steam_api.json")

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

				local typedef = info.typedef
				typedef = typedef:gsub("::SteamCallback_t", "")

				a("typedef %s %s;", info.type, prepend .. typedef)
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

	--a("typedef struct %s {} %s;", prepend .. "ISteamClient", prepend .. "ISteamClient")
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

			if not pcall(ffi.typeof, info.returntype) then
				if info.returntype:startswith("struct") then
					info.returntype = "struct " .. prepend .. info.returntype:gsub("^struct ", "")
				else
					info.returntype = prepend .. info.returntype
				end
			end

			a("%s SteamAPI_%s_%s%s;", info.returntype, info.classname, info.methodname, args)
		end
	end
end

for k,v in pairs(interfaces) do
	a("%s *%s();", prepend .. k, v)
end

a("bool SteamAPI_RestartAppIfNecessary(uint32_t);")
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
		local lines = header:split("\n")
		lines[line] = lines[line]:gsub(t, function() return prepend .. t end)
		header = table.concat(lines, "\n")
	end
end

local ok, err = ffi.cdef(header)

if not ok then
	local line = tonumber(err:match("line (%d+)"))
	if line then
		local lines = header:split("\n")
		for i = line - 5, line + 5 do
			logn(i, ": " .. lines[i], i == line and "<<<<" or "")
		end
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

local appid

do
	local file = io.open("steam_appid.txt")

	if file then
		appid = tonumber(file:read("*all"))
		io.close(file)
	else
		local file, err = io.open("steam_appid.txt", "w")
		if file then
			file:write("480")
			io.close(file)
			appid = 480
		else
			error("failed to write steam_appid.txt! (it's needed) in cd : " .. err)
		end
	end
end

if appid == 480 then
	print("steamworks.lua: using dummy appid ('Spacewar' the steamworks example)")
	print("steamworks.lua: you have to modify ./steam_appid.txt to change it")
end

local steamworks = {}

if not lib.SteamAPI_Init() then
	error("failed to initialize steamworks")
end


steamworks.client_ptr = lib.SteamClient()
if steamworks.client_ptr == nil then error("SteamClient() returns NULL") end
steamworks.pipe_ptr = lib.SteamAPI_ISteamClient_CreateSteamPipe(steamworks.client_ptr)
if steamworks.pipe_ptr == nil then error("SteamAPI_ISteamClient_CreateSteamPipe() returns NULL") end
steamworks.steam_user_ptr = lib.SteamAPI_ISteamClient_ConnectToGlobalUser(steamworks.client_ptr, steamworks.pipe_ptr)
if steamworks.steam_user_ptr == nil then error("SteamAPI_ISteamClient_ConnectToGlobalUser() returns NULL") end

]])

local steam_id_meta = {}

-- caps@caps-MS-7798:~/Downloads/sdk$ grep -rn ./ -e "INTERFACE_VERSION \""
local versions = {
	STEAMUSER_INTERFACE_VERSION = "SteamUser019",
	STEAMUGC_INTERFACE_VERSION = "STEAMUGC_INTERFACE_VERSION010",
	STEAMVIDEO_INTERFACE_VERSION = "STEAMVIDEO_INTERFACE_V002",
	STEAMUNIFIEDMESSAGES_INTERFACE_VERSION = "STEAMUNIFIEDMESSAGES_INTERFACE_VERSION001",
	STEAMHTMLSURFACE_INTERFACE_VERSION = "STEAMHTMLSURFACE_INTERFACE_VERSION_004",
	STEAMGAMESERVER_INTERFACE_VERSION = "SteamGameServer012",
	STEAMUTILS_INTERFACE_VERSION = "SteamUtils009",
	STEAMGAMECOORDINATOR_INTERFACE_VERSION = "SteamGameCoordinator001",
	STEAMCONTROLLER_INTERFACE_VERSION = "SteamController005",
	STEAMREMOTESTORAGE_INTERFACE_VERSION = "STEAMREMOTESTORAGE_INTERFACE_VERSION014",
	STEAMGAMESERVERSTATS_INTERFACE_VERSION = "SteamGameServerStats001",
	STEAMFRIENDS_INTERFACE_VERSION = "SteamFriends015",
	STEAMPARENTALSETTINGS_INTERFACE_VERSION = "STEAMPARENTALSETTINGS_INTERFACE_VERSION001",
	STEAMMATCHMAKING_INTERFACE_VERSION = "SteamMatchMaking009",
	STEAMMATCHMAKINGSERVERS_INTERFACE_VERSION = "SteamMatchMakingServers002",
	STEAMAPPLIST_INTERFACE_VERSION = "STEAMAPPLIST_INTERFACE_VERSION001",
	STEAMINVENTORY_INTERFACE_VERSION = "STEAMINVENTORY_INTERFACE_V002",
	STEAMHTTP_INTERFACE_VERSION = "STEAMHTTP_INTERFACE_VERSION002",
	STEAMAPPS_INTERFACE_VERSION = "STEAMAPPS_INTERFACE_VERSION008",
	STEAMMUSICREMOTE_INTERFACE_VERSION = "STEAMMUSICREMOTE_INTERFACE_VERSION001",
	STEAMMUSIC_INTERFACE_VERSION = "STEAMMUSIC_INTERFACE_VERSION001",
	STEAMUSERSTATS_INTERFACE_VERSION = "STEAMUSERSTATS_INTERFACE_VERSION011",
	STEAMSCREENSHOTS_INTERFACE_VERSION = "STEAMSCREENSHOTS_INTERFACE_VERSION003",
	STEAMNETWORKING_INTERFACE_VERSION = "SteamNetworking005",
	STEAMAPPTICKET_INTERFACE_VERSION = "STEAMAPPTICKET_INTERFACE_VERSION001",
}

for interface in pairs(interfaces) do
	local friendly = interface:sub(2):sub(6):lower()
	table.insert(lua, "steamworks." .. friendly .. " = {}")

	if interface == "ISteamClient" then
		table.insert(lua, "do")
	else

		local version = versions[interface:sub(2):upper() .. "_INTERFACE_VERSION"] or ""

		if interface == "ISteamUtils" then
			table.insert(lua, "steamworks." .. friendly .. "_ptr = lib.SteamAPI_ISteamClient_Get" .. interface .. "(steamworks.client_ptr, steamworks.pipe_ptr, '"..version.."')")
		else
			table.insert(lua, "steamworks." .. friendly .. "_ptr = lib.SteamAPI_ISteamClient_Get" .. interface .. "(steamworks.client_ptr, steamworks.steam_user_ptr, steamworks.pipe_ptr, '"..version.."')")
		end

		table.insert(lua, "if steamworks." .. friendly .. "_ptr == nil then\n\t print('steamworks.lua: failed to load "..friendly.." " .. version .."')\nelse")
	end
	for i, info in ipairs(json.methods) do
		if info.classname == interface then
			local args = ""
			if info.params then
				for i, arg in ipairs(info.params) do
					args = args .. ("%s%s"):format(arg.paramname, i == #info.params and "" or ", ")
				end
			end
			local arg_line = args
			local func = "\tfunction steamworks." .. friendly .. "." .. info.methodname .. "(" .. args .. ")"
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
	table.insert(lua, "end")
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
lua = table.concat(lua, "\n")

local path = "os:" .. e.ROOT_FOLDER .. "data/ffibuild/steamworks/steamworks.lua"
vfs.Write(path, lua)
runfile(path)
