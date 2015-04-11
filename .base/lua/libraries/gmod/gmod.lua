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
	
	return code
end

function gmod.SetFunctionEnvironment(func)
	setfenv(func, gmod.env)
end

gmod.objects = gmod.objects or {}

function gmod.WrapObject(obj, meta)
	gmod.objects[meta] = gmod.objects[meta] or {}
	
	if not gmod.objects[meta][obj] then
		gmod.objects[meta][obj] = setmetatable({__obj = obj}, gmod.env.FindMetaTable(meta))
		obj:CallOnRemove(function() 
			if gmod.objects[meta] and gmod.objects[meta][obj] then 
				prototype.MakeNULL(gmod.objects[meta][obj]) 
				gmod.objects[meta][obj] = nil 
			end 
		end)
	end
	
	return gmod.objects[meta][obj]
end

event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
	if not gmod.dir or not path:startswith(gmod.dir) then return end
		
	return gmod.PreprocessLua(code)
end)

event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
	if not gmod.dir or not path:startswith(gmod.dir) then return end
	
	gmod.SetFunctionEnvironment(func)
end)

local function load_entities(base_folder, global, register, create_table)
	for file_name in vfs.Iterate(base_folder.."/") do
		logn("gmod: registering ",base_folder," ", file_name)
		if file_name:endswith(".lua") then
			gmod.env[global] = create_table()
			include(base_folder.."/" .. file_name)
			register(gmod.env[global], file_name:match("(.+)%."))
		else
			if SERVER then 
				if vfs.IsFile(base_folder.."/" .. file_name .. "/init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = file_name
					include(base_folder.."/" .. file_name .. "/init.lua") 
					register(gmod.env[global], file_name)
				end
			end
			
			if CLIENT then 
				if vfs.IsFile(base_folder.."/" .. file_name .. "/cl_init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = file_name
					include(base_folder.."/" .. file_name .. "/cl_init.lua")
					register(gmod.env[global], file_name)
				end
			end
		end
	end
	gmod.env[global] = nil
end

local function load_gamemode(name)
	local info = steam.VDFToTable(vfs.Read("gamemodes/" .. name .. "/" .. name .. ".txt"))
	
	if info.base == "" then info.base = nil end
	
	if SERVER then 
		if vfs.IsFile("gamemodes/"..name.."/gamemode/init.lua") then
			gmod.env.GM = {FolderName = name}
			include("gamemodes/"..name.."/gamemode/init.lua") 
			gmod.env.gamemode.Register(gmod.env.GM, name, info.base)
			gmod.gamemodes[name] = gmod.env.GM
			gmod.env.GM = nil
		end
	end
	
	if CLIENT then 
		if vfs.IsFile("gamemodes/"..name.."/gamemode/cl_init.lua") then
			gmod.env.GM = {FolderName = name}
			include("gamemodes/"..name.."/gamemode/cl_init.lua") 
			gmod.env.gamemode.Register(gmod.env.GM, name, info.base)
			gmod.gamemodes[name] = gmod.env.GM
			gmod.env.GM = nil
		end
	end
	
	load_entities("gamemodes/"..name.."/entities/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
	load_entities("gamemodes/"..name.."/entities/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
	load_entities("gamemodes/"..name.."/entities/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)
end

function gmod.Initialize()
	if not gmod.init then
	
		steam.MountSourceGame("gmod")
		render.InitializeGBuffer() -- TODO
		
		gmod.gamemodes =  {}
		
		-- figure out the base gmod folder
		gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")
		
		-- setup engine functions
		include("lua/libraries/gmod/environment.lua", gmod)
		
		vfs.AddModuleDirectory(R"lua/includes/modules/")
		
		include("lua/includes/init.lua")
		
		-- autorun lua files
		if CLIENT then include(gmod.dir .. "/lua/autorun/client/*") end
		if SERVER then include(gmod.dir .. "/lua/autorun/server/*") end
		include(gmod.dir .. "/lua/autorun/*")
		
		-- include the gui
		include("lua/derma/init.lua")
		
		-- this seems to be done in the engine somewhere
		gmod.env.require("notification")
		
		include("lua/skins/*")
		include("lua/vgui/*")
		
		-- load_gamemode will also load entities as shown below
		load_gamemode("base")
		load_gamemode("sandbox")
		
		load_entities("lua/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
		load_entities("lua/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
		load_entities("lua/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)
		
		gmod.init = true
	end
	
	gmod.current_gamemode = gmod.gamemodes.sandbox
	gmod.env.GAMEMODE = gmod.current_gamemode
	
	gmod.env.hook.Call("Initialize", gmod.current_gamemode)
	
	event.Delay(0.1, function()
		gmod.env.hook.Call("PreGamemodeLoaded", gmod.current_gamemode)
		gmod.env.hook.Call("OnGamemodeLoaded", gmod.current_gamemode)
		gmod.env.hook.Call("PostGamemodeLoaded", gmod.current_gamemode)
	end)
	
	event.AddListener("DrawHUD", "gmod", function() 
		gmod.env.hook.Call("PreDrawHUD", gmod.current_gamemode) 
		gmod.env.hook.Call("HUDPaint", gmod.current_gamemode) 
		gmod.env.hook.Call("HUDPaintBackground", gmod.current_gamemode) 
	end)
	
	event.AddListener("PostDrawMenu", "gmod", function()
		gmod.env.hook.Call("PostRenderVGUI", gmod.current_gamemode) 
	end)
	
	event.AddListener("Update", "gmod", function() 
		gmod.env.hook.Call("Think", gmod.current_gamemode) 
		gmod.env.hook.Call("Tick", gmod.current_gamemode) 
	end)
end

return gmod