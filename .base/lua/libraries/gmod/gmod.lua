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
end

function gmod.Initialize()
	if not gmod.init then
	
		steam.MountSourceGame("gmod")
		render.InitializeGBuffer() -- TODO
		
		gmod.gamemodes = {}
		
		-- figure out the base gmod folder
		gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")
		
		-- setup engine functions
		include("lua/libraries/gmod/environment.lua", gmod)
		
		vfs.AddModuleDirectory(R"lua/includes/modules/")
				
		-- include and init files in the right order
		
		include("lua/includes/init.lua") -- 
		include("lua/derma/init.lua") -- the gui
		gmod.env.require("notification") -- this is included by engine at this point
		
		load_gamemode("base")
		
		-- autorun lua files
		include(gmod.dir .. "/lua/autorun/*")
		if CLIENT then include(gmod.dir .. "/lua/autorun/client/*") end
		if SERVER then include(gmod.dir .. "/lua/autorun/server/*") end
		
		--include("lua/postprocess/*")
		include("lua/vgui/*")
		--include("lua/matproxy/*")
		include("lua/skins/*")
		
		-- load_gamemode will also load entities as shown below
		load_gamemode("sandbox")
		
		for name in pairs(gmod.gamemodes) do
			load_entities("gamemodes/"..name.."/entities/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
			load_entities("gamemodes/"..name.."/entities/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
			load_entities("gamemodes/"..name.."/entities/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)
		end
		
		load_entities("lua/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
		load_entities("lua/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
		load_entities("lua/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)
		
		gmod.init = true
	end
	
	gmod.current_gamemode = gmod.gamemodes.sandbox
	gmod.env.GAMEMODE = gmod.current_gamemode
	
	gmod.env.hook.Call("CreateTeams", gmod.current_gamemode)
	gmod.env.hook.Call("PreGamemodeLoaded", gmod.current_gamemode)
	gmod.env.hook.Call("OnGamemodeLoaded", gmod.current_gamemode)
	gmod.env.hook.Call("PostGamemodeLoaded", gmod.current_gamemode)
	
	gmod.env.hook.Call("Initialize", gmod.current_gamemode)
	
	--gmod.env.hook.Call("OnEntityCreated", gmod.current_gamemode, player)
	gmod.env.hook.Call("InitPostEntity", gmod.current_gamemode)

	event.AddListener("Update", "gmod", function() 
		--gmod.env.hook.Call("CalcView", gmod.current_gamemode, )
		--gmod.env.hook.Call("CalcViewModelView", gmod.current_gamemode, )
		local frac = gmod.env.hook.Call("AdjustMouseSensitivity", gmod.current_gamemode, 0, 90, 90)
		--gmod.env.hook.Call("CalcMainActivity", gmod.current_gamemode, )
		--gmod.env.hook.Call("TranslateActivity", gmod.current_gamemode, )
		--gmod.env.hook.Call("UpdateAnimation", gmod.current_gamemode, )
		gmod.env.hook.Call("PreRender", gmod.current_gamemode) 
		gmod.env.hook.Call("RenderScene", gmod.current_gamemode, gmod.env.Vector(render.camera_3d:GetPosition():Unpack()), gmod.env.Angle(render.camera_3d:GetAngles():GetDeg():Unpack()), math.deg(render.camera_3d:GetFOV())) 
		gmod.env.hook.Call("DrawMonitors", gmod.current_gamemode) 
		gmod.env.hook.Call("PreDrawSkyBox", gmod.current_gamemode) 
		gmod.env.hook.Call("SetupSkyboxFog", gmod.current_gamemode) 
		gmod.env.hook.Call("PostDraw2DSkyBox", gmod.current_gamemode) 
		gmod.env.hook.Call("PreDrawOpaqueRenderables", gmod.current_gamemode, false, true) 
		gmod.env.hook.Call("PostDrawOpaqueRenderables", gmod.current_gamemode, false, true) 
		gmod.env.hook.Call("PreDrawTranslucentRenderables", gmod.current_gamemode, false, true) 
		gmod.env.hook.Call("PostDrawTranslucentRenderables", gmod.current_gamemode, false, true) 
		gmod.env.hook.Call("PostDrawSkyBox", gmod.current_gamemode) 
		gmod.env.hook.Call("NeedsDepthPass", gmod.current_gamemode) 
		gmod.env.hook.Call("SetupWorldFog", gmod.current_gamemode)
		gmod.env.hook.Call("PreDrawOpaqueRenderables", gmod.current_gamemode, false, false)
		--gmod.env.hook.Call("ShouldDrawLocalPlayer", gmod.current_gamemode, player)
		gmod.env.hook.Call("PostDrawOpaqueRenderables", gmod.current_gamemode, false, false)
		gmod.env.hook.Call("PreDrawTranslucentRenderables", gmod.current_gamemode, false, false)
		--gmod.env.hook.Call("DrawPhysgunBeam", gmod.current_gamemode, player)
		gmod.env.hook.Call("PostDrawTranslucentRenderables", gmod.current_gamemode, false, false)
		gmod.env.hook.Call("GetMotionBlurValues", gmod.current_gamemode, 0, 0, 0, 0)
		--gmod.env.hook.Call("PreDrawViewModel", gmod.current_gamemode)
		--gmod.env.hook.Call("PreDrawViewModel", gmod.current_gamemode)
		--gmod.env.hook.Call("PostDrawViewModel", gmod.current_gamemode)
		gmod.env.hook.Call("PreDrawEffects", gmod.current_gamemode)
		gmod.env.hook.Call("RenderScreenspaceEffects", gmod.current_gamemode)
		gmod.env.hook.Call("PostDrawEffects", gmod.current_gamemode)
		gmod.env.hook.Call("PreDrawHalos", gmod.current_gamemode)
		gmod.env.hook.Call("PreDrawHUD", gmod.current_gamemode)
		gmod.env.hook.Call("HUDPaintBackground", gmod.current_gamemode)
		gmod.env.hook.Call("HUDPaint", gmod.current_gamemode)
		gmod.env.hook.Call("DrawDeathNotice", gmod.current_gamemode, 0.85, 0.04)
		gmod.env.hook.Call("HUDDrawScoreBoard", gmod.current_gamemode)
		gmod.env.hook.Call("PostDrawHUD", gmod.current_gamemode)
		gmod.env.hook.Call("DrawOverlay", gmod.current_gamemode)
		gmod.env.hook.Call("PostRenderVGUI", gmod.current_gamemode)
		gmod.env.hook.Call("PostRender", gmod.current_gamemode)
	
		gmod.env.hook.Call("Tick", gmod.current_gamemode) 
		gmod.env.hook.Call("Think", gmod.current_gamemode)
		
		for k,v in ipairs(gmod.hud_element_list) do
			gmod.env.hook.Call("HUDShouldDraw", gmod.current_gamemode, v)
		end
	end)
end

return gmod