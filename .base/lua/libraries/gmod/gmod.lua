local gmod = _G.gmod or {}

function gmod.PreprocessLua(code)
	local code, data = utility.StripLuaCommentsAndStrings(code)
	
	code = code:gsub("&&", " and ")
	code = code:gsub("||", " or ")
	code = code:gsub("!=", " ~= ")
	code = code:gsub("!", "not ")
	code = code:gsub("/%*", "--[[")
	code = code:gsub("%*/", "]]")
	code = code:gsub("//", "--")
	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")
	
	code = utility.RestoreLuaCommentsAndStrings(code, data)
	
	if code:find("continue", nil, true) then
		local lex_setup = require("luajit-lang-toolkit.lexer")
		local reader = require("luajit-lang-toolkit.reader")
		
		local ls = lex_setup(reader.string(code), code)
		
		local stack = {}
		
		repeat
			ls:next()
			table.insert(stack, table.copy(ls))
		until ls.token == "TK_eof"
		
		for i, ls in ipairs(stack) do
			if ls.token == "TK_name" and ls.tokenval == "continue" then
				local start
				
				for i = i, 1, -1 do
					local v = stack[i]
					
					if v.token == "TK_do" then
						start = v
						start.stack_pos = i
						break
					end
				end
				
				local stop
				
				local balance = 0
				local found_start
				local return_line
				
				for i = start.stack_pos, #stack do
					local v = stack[i]
					
					if v.token == "TK_do" or v.token == "TK_then" or v.token == "TK_function" then
						balance = balance + 1
						found_start = true
					elseif v.token == "TK_end" then
						balance = balance - 1
					end
					
					if stack[i - 1].token == "TK_return" then
						return_line = stack[i - 1].linenumber
					end
					
					if found_start and balance == 0 then
						stop = v
						break
					end
				end
				
				local lines = code:explode("\n")
				
				if return_line then
					lines[return_line] = " do ".. lines[return_line] .. " end "
				end
				
				if not lines[stop.linenumber]:find("CONTINUE") then
					lines[stop.linenumber] = " ::CONTINUE:: ".. lines[stop.linenumber]
				end
				
				code = table.concat(lines, "\n")
			end
		end
	end
	
	local code, data = utility.StripLuaCommentsAndStrings(code)
	
	code = code:gsub("continue", " goto CONTINUE ")
	
	code = utility.RestoreLuaCommentsAndStrings(code, data)
	
	local ok, err = loadstring(code)
	if not ok then print(err) vfs.Write("gmod_preprocess_error.lua", code) end
		
	return code
end

function gmod.SetFunctionEnvironment(func)
	setfenv(func, gmod.env)
end

gmod.objects = gmod.objects or {}

function gmod.WrapObject(obj, meta)
	gmod.objects[obj.Type] = gmod.objects[obj.Type] or {}
	
	if not gmod.objects[obj.Type][obj] then
		gmod.objects[obj.Type][obj] = setmetatable({__obj = obj}, gmod.env.FindMetaTable(meta))
		obj:CallOnRemove(function(self) if gmod.objects[self.Type] then prototype.MakeNULL(gmod.objects[self.Type][self]) gmod.objects[self.Type][self] = nil end end)
	end
	
	return gmod.objects[obj.Type][obj]
end

function gmod.Initialize()
	include("lua/libraries/gmod/environment.lua", gmod)
	
	steam.MountSourceGame("gmod")
	
	gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")
	
	vfs.AddModuleDirectory(R"lua/includes/modules/")

	event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
		if not path:startswith(gmod.dir) then return end
			
		return gmod.PreprocessLua(code)
	end)

	event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
		if not path:startswith(gmod.dir) then return end
		
		gmod.SetFunctionEnvironment(func)
	end)
	
	include("lua/includes/init.lua")
	include("lua/derma/init.lua")
	
	gmod.env.require("notification")
	
	gmod.gamemodes =  {}
	
	local function load_gamemode(name)
		local info = steam.VDFToTable(vfs.Read("gamemodes/" .. name .. "/" .. name .. ".txt"))
		
		if info.base == "" then info.base = nil end
		
		gmod.env.GM = {FolderName = name}
		if SERVER then include("gamemodes/"..name.."/gamemode/init.lua") end
		if CLIENT then include("gamemodes/"..name.."/gamemode/cl_init.lua") end
		gmod.env.gamemode.Register(gmod.env.GM, name, info.base)
		gmod.gamemodes[name] = gmod.env.GM
		gmod.env.GM = nil
		
		for file_name in vfs.Iterate("gamemodes/"..name.."/entities/entities/") do
			logn("gmod: registering entity ", file_name)
			if file_name:endswith(".lua") then
				gmod.env.ENT = {}
				include("gamemodes/"..name.."/entities/entities/" .. file_name)
				local name = file_name:match("(.+)%.")
				gmod.env.scripted_ents.Register(gmod.env.ENT, name)
			else
				gmod.env.ENT = {}
				if SERVER then include("gamemodes/"..name.."/entities/entities/" .. file_name .. "/init.lua") end
				if CLIENT then include("gamemodes/"..name.."/entities/entities/" .. file_name .. "/cl_init.lua") end
				if next(gmod.env.ENT) then
					gmod.env.scripted_ents.Register(gmod.env.ENT, file_name)
				end
			end
		end
	end
	
	load_gamemode("base")
	load_gamemode("sandbox")
	
	for file_name in vfs.Iterate("lua/entities/") do
		logn("gmod: registering entity ", file_name)
		if file_name:endswith(".lua") then
			gmod.env.ENT = {}
			include("lua/entities/" .. file_name)
			local name = file_name:match("(.+)%.")
			gmod.env.scripted_ents.Register(gmod.env.ENT, name)
		else
			gmod.env.ENT = {}
			if SERVER then include("lua/entities/" .. file_name .. "/init.lua") end
			if CLIENT then include("lua/entities/" .. file_name .. "/cl_init.lua") end
			if next(gmod.env.ENT) then
				gmod.env.scripted_ents.Register(gmod.env.ENT, file_name)
			end
		end
	end
	
	include("lua/vgui/*")

	gmod.current_gamemode = gmod.gamemodes.sandbox
	gmod.env.GAMEMODE = gmod.current_gamemode
	gmod.gamemodes.sandbox:Initialize()
	
	gmod.init = true
end

return gmod