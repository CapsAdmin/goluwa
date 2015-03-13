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
	
	header = header:gsub("struct SteamWorks_CSteamID %b{} SteamWorks_CSteamID", "uint64_t SteamWorks_CSteamID")
	
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
	
	local lua = {"ffi.cdef[[" .. header .. "]]"}

	table.insert(lua, [[
local lib = ffi.load("steam_api64")
assert(lib.SteamAPI_Init())
local steamworks = {}
	]])
	
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
				local func = "function steamworks." .. friendly .. "." .. info.methodname .. "(" .. args .. ")"
				if #args > 0 then args = ", " .. args end
				func = func .. " return lib.SteamAPI_"..interface.."_" .. info.methodname .. "(steamworks." .. friendly .. "_ptr" .. args .. ")"
				func = func .. " end"
				
				table.insert(lua, func)
			end
		end
	end
	
	table.insert(lua, "return steamworks")
	
	vfs.Write("lua/libraries/ffi/steamworks/init.lua", table.concat(lua, "\n"))
	
	include("libraries/ffi/steamworks/init.lua")
end

steam.BuildSteamWorksHeader()