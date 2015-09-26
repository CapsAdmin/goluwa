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
		local tbl = table.copy(gmod.env.FindMetaTable(meta))

		tbl.Type = meta

		local __index_func
		local __index_tbl

		if type(tbl.__index) == "function" then
			__index_func = tbl.__index
		else
			__index_tbl = tbl.__index
		end

		function tbl:__index(key)
			if key == "__obj" then
				return obj
			end

			if __index_func then
				return __index_func(self, key)
			elseif __index_tbl then
				return __index_tbl[key]
			end
		end

		gmod.objects[meta][obj] = setmetatable({}, tbl)

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

	code = gmod.PreprocessLua(code)

	if not loadstring(code) then vfs.Write("gmod_preprocess_error.lua", code) end

	return code
end)

event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
	if not gmod.dir or not path:startswith(gmod.dir) then return end

	gmod.SetFunctionEnvironment(func)
end)

local function load_entities(base_folder, global, register, create_table)
	for file_name in vfs.Iterate(base_folder.."/") do
		--logn("gmod: registering ",base_folder," ", file_name)
		if file_name:endswith(".lua") then
			gmod.env[global] = create_table()
			include(base_folder.."/" .. file_name)
			register(gmod.env[global], file_name:match("(.+)%."))
		else
			if SERVER then
				if vfs.IsFile(base_folder.."/" .. file_name .. "/init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = base_folder:sub(5) .. "/" .. file_name -- weapons/gmod_tool/stools/
					include(base_folder.."/" .. file_name .. "/init.lua")
					register(gmod.env[global], file_name)
				end
			end

			if CLIENT then
				if vfs.IsFile(base_folder.."/" .. file_name .. "/cl_init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = base_folder:sub(5) .. "/" .. file_name
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

		gmod.env.DCollapsibleCategory.LoadCookies = nil -- DUCT TAPE FIX

		-- load_gamemode will also load entities as shown below
		load_gamemode("sandbox")

		for name in pairs(gmod.gamemodes) do
			vfs.Mount(gmod.dir .. "/gamemodes/"..name.."/entities/", "lua/")
		end

		load_entities("lua/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
		load_entities("lua/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
		load_entities("lua/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)

		gmod.init = true
	end

	gmod.current_gamemode = gmod.gamemodes.sandbox
	gmod.env.GAMEMODE = gmod.current_gamemode

	input.Bind("q", "+menu")
	input.Bind("q", "-menu")

	input.Bind("c", "+menu_context")
	input.Bind("c", "-menu_context")

	input.Bind("tab", "+score", function()
		gmod.env.hook.Run("ScoreboardShow")
	end)

	input.Bind("tab", "-score", function()
		gmod.env.hook.Run("ScoreboardHide")
	end)

	do
		gmod.translation = {}
		gmod.translation2 = {}

		for path in vfs.Iterate("resource/localization/en/",nil,true) do
			local str = vfs.Read(path)
			for _, line in ipairs(str:explode("\n")) do
				local key, val = line:match("(.-)=(.+)")
				if key and val then
					gmod.translation[key] = val:trim()
					gmod.translation2["#" .. key] = gmod.translation[key]
				end
			end
		end
	end

	--[[for dir in vfs.Iterate("addons/") do
		local dir = gmod.dir .. "addons/" ..  dir
		include(dir .. "/lua/autorun/*")
		if CLIENT then include(dir .. "/lua/autorun/client/*") end
		if SERVER then include(dir .. "/lua/autorun/server/*") end
	end]]

	gmod.env.hook.Run("CreateTeams")
	gmod.env.hook.Run("PreGamemodeLoaded")
	gmod.env.hook.Run("OnGamemodeLoaded")
	gmod.env.hook.Run("PostGamemodeLoaded")

	gmod.env.hook.Run("Initialize")

	--gmod.env.hook.Run("OnEntityCreated", player)
	gmod.env.hook.Run("InitPostEntity")

	event.AddListener("Update", "gmod", function()
		--gmod.env.hook.Run("CalcView", )
		--gmod.env.hook.Run("CalcViewModelView", )
		local frac = gmod.env.hook.Run("AdjustMouseSensitivity", 0, 90, 90)
		--gmod.env.hook.Run("CalcMainActivity", )
		--gmod.env.hook.Run("TranslateActivity", )
		--gmod.env.hook.Run("UpdateAnimation", )
		gmod.env.hook.Run("PreRender")
		gmod.env.hook.Run("RenderScene", gmod.env.Vector(render.camera_3d:GetPosition():Unpack()), gmod.env.Angle(render.camera_3d:GetAngles():GetDeg():Unpack()), math.deg(render.camera_3d:GetFOV()))
		gmod.env.hook.Run("DrawMonitors")
		gmod.env.hook.Run("PreDrawSkyBox")
		gmod.env.hook.Run("SetupSkyboxFog")
		gmod.env.hook.Run("PostDraw2DSkyBox")
		gmod.env.hook.Run("PreDrawOpaqueRenderables", false, true)
		gmod.env.hook.Run("PostDrawOpaqueRenderables", false, true)
		gmod.env.hook.Run("PreDrawTranslucentRenderables", false, true)
		gmod.env.hook.Run("PostDrawTranslucentRenderables", false, true)
		gmod.env.hook.Run("PostDrawSkyBox")
		gmod.env.hook.Run("NeedsDepthPass")
		gmod.env.hook.Run("SetupWorldFog")
		gmod.env.hook.Run("PreDrawOpaqueRenderables", false, false)
		--gmod.env.hook.Run("ShouldDrawLocalPlayer", player)
		gmod.env.hook.Run("PostDrawOpaqueRenderables", false, false)
		gmod.env.hook.Run("PreDrawTranslucentRenderables", false, false)
		--gmod.env.hook.Run("DrawPhysgunBeam", player)
		gmod.env.hook.Run("PostDrawTranslucentRenderables", false, false)
		gmod.env.hook.Run("GetMotionBlurValues", 0, 0, 0, 0)
		--gmod.env.hook.Run("PreDrawViewModel")
		--gmod.env.hook.Run("PreDrawViewModel")
		--gmod.env.hook.Run("PostDrawViewModel")
		gmod.env.hook.Run("PreDrawEffects")
		gmod.env.hook.Run("RenderScreenspaceEffects")
		gmod.env.hook.Run("PostDrawEffects")
		gmod.env.hook.Run("PreDrawHUD")
		gmod.env.hook.Run("HUDPaintBackground")
		gmod.env.hook.Run("HUDPaint")
		gmod.env.hook.Run("HUDDrawScoreBoard")
		gmod.env.hook.Run("PostDrawHUD")
		gmod.env.hook.Run("DrawOverlay")
		gmod.env.hook.Run("PostRenderVGUI")
		gmod.env.hook.Run("PostRender")

		gmod.env.hook.Run("Tick")
		gmod.env.hook.Run("Think")

		for k,v in ipairs(gmod.hud_element_list) do
			gmod.env.hook.Run("HUDShouldDraw", v)
		end
	end)
end

return gmod