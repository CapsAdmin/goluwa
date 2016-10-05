local gmod = _G.gmod or {}

function gmod.PreprocessLua(code)
	local code, data = utility.StripLuaCommentsAndStrings(code, function(code, data)
		code = code:gsub("(//.-)\n", function(str)
			str = str:gsub("//", "--")

			-- todo: api
			table.insert(data.singleline_comments, str)
			return "____COMMENT_SINGLELINE_" .. #data.singleline_comments .. "____" .. " "
		end)
		code = code:gsub("(/%*.-%*/)", function(str)
			str = str:gsub("/%*", "--[=======[")
			str = str:gsub("%*/", "]=======]")

			-- todo: api
			table.insert(data.multiline_comments, str)
			return "____COMMENT_MULTILINE_" .. #data.multiline_comments .. "____" .. " "
		end)
		return code
	end)
	code = code:gsub("&&", " and ")
	code = code:gsub("||", " or ")
	code = code:gsub("!=", " ~= ")
	code = code:gsub("!", "not ")
	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")
	code = utility.RestoreLuaCommentsAndStrings(code, data)

	if code:find("continue", nil, true) and not loadstring(code) then
		local lex_setup = require("lang.lexer")
		local reader = require("lang.reader")

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

					if stack[i - 1].token == "TK_return" or stack[i - 1].token == "TK_break" then
						return_line = stack[i - 1].linenumber
					end

					if found_start and balance == 0 then
						stop = v
						break
					end
				end

				local lines = code:split("\n")

				if return_line then
					lines[return_line] = " do ".. lines[return_line] .. " end "
				end

				if not lines[stop.linenumber]:find("CONTINUE") then
					lines[stop.linenumber] = " ::CONTINUE:: ".. lines[stop.linenumber]
				end

				code = table.concat(lines, "\n")
			end
		end

		code, data = utility.StripLuaCommentsAndStrings(code)
		code = code:gsub("continue", " goto CONTINUE ")
		code = utility.RestoreLuaCommentsAndStrings(code, data)
	end

	return code
end

function gmod.SetFunctionEnvironment(func)
	if not gmod.env then
		gmod.Initialize()
	end
	setfenv(func, gmod.env)
end

gmod.objects = gmod.objects or {}
gmod.surface_fonts = gmod.surface_fonts or {}

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

		tbl.__gc = nil

		gmod.objects[meta][obj] = setmetatable({}, tbl)

		obj:CallOnRemove(function()
			if gmod.objects[meta] and gmod.objects[meta][obj] then
				local obj = gmod.objects[meta][obj]
				event.Delay(function() prototype.MakeNULL(obj) end)
				gmod.objects[meta][obj] = nil
			end
		end)
	end

	return gmod.objects[meta][obj]
end

event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
	if not ((gmod.dir and path:startswith(gmod.dir)) or path:find("%.gma")) then return end

	if not code:find("DEFINE_BASECLASS", nil, true) and loadstring(code) then return code end

	code = gmod.PreprocessLua(code)

	if not loadstring(code) then vfs.Write("gmod_preprocess_error.lua", code) end

	return code
end)

event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
	if not (gmod.dir and path:startswith(gmod.dir) or path:find("%.gma")) then return end

	gmod.SetFunctionEnvironment(func)
end)


do
	local easy = {
		["roboto bk"] = "resource/fonts/Roboto-Black.ttf",
		["roboto"] = "resource/fonts/Roboto-Regular.ttf",
		["helvetica"] = "resource/fonts/coolvetica.ttf",
		["times new roman"] = "resource/fonts/coolvetica.ttf",
		["courier new"] = "resource/fonts/coolvetica.ttf",
		["courier"] = "resource/fonts/coolvetica.ttf",
		["arial"] = "resource/fonts/coolvetica.ttf",
		["arial black"] = "resource/fonts/coolvetica.ttf",
		["verdana"] = "resource/fonts/coolvetica.ttf",
		["trebuchet ms"] = "resource/fonts/coolvetica.ttf",
	}

	function gmod.TranslateFontName(name)
		local name = name:lower()

		if easy[name] then
			return easy[name]
		end

		if vfs.IsFile("resource/" .. name .. ".ttf") then
			return "resource/" .. name .. ".ttf"
		end

		if vfs.IsFile("resource/fonts/" .. name .. ".ttf") then
			return "resource/fonts/" .. name .. ".ttf"
		end

		return easy.helvetica
	end
end

function gmod.LoadFonts()
	local screen_res = window.GetSize()

	local fonts = steam.VDFToTable(vfs.Read("resource/SourceScheme.res"), true).scheme.fonts
	table.merge(fonts, steam.VDFToTable(vfs.Read("resource/ChatScheme.res"), true).scheme.fonts)
	table.merge(fonts, steam.VDFToTable(vfs.Read("resource/ClientScheme.res"), true).scheme.fonts)

	for font_name, sub_fonts in pairs(fonts) do
		local candidates = {}

		for i, info in pairs(sub_fonts) do
			if info.yres then
				local x,y = unpack(info.yres:split(" "))
				table.insert(candidates, {info = info, dist = Vec2(tonumber(x), tonumber(y)):Distance(screen_res)})
			end
		end

		table.sort(candidates, function(a, b) return a.dist > b.dist end)
		local info = (candidates[1] and candidates[1].info) or select(2, next(sub_fonts))

		for i, info in pairs(sub_fonts) do
			if type(info.tall) == "table" then
				--table.print(info.tall)
				info.tall = info.tall[1]-- what
			end

			gmod.surface_fonts[font_name:lower()] = surface.CreateFont({
				path = gmod.TranslateFontName(info.name),
				size = info.tall and math.ceil(info.tall * 0.75) or 11,
			})
		end
	end
end

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

		--steam.MountSourceGame("hl2")
		--steam.MountSourceGame("css")
		--steam.MountSourceGame("tf2")
		steam.MountSourceGame("gmod")
		render.InitializeGBuffer() -- TODO

		gmod.gamemodes = {}

		-- figure out the base gmod folder
		gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")

		-- setup engine functions
		include("lua/libraries/gmod/environment.lua", gmod)

		vfs.AddModuleDirectory(R(gmod.dir.."/lua/includes/modules/"))

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

		do
			gmod.translation = {}
			gmod.translation2 = {}

			for path in vfs.Iterate("resource/localization/en/", true) do
				for _, line in ipairs(vfs.Read(path):split("\n")) do
					local key, val = line:match("(.-)=(.+)")
					if key and val then
						gmod.translation[key] = val:trim()
						gmod.translation2["#" .. key] = gmod.translation[key]
					end
				end
			end
		end

		gmod.current_gamemode = gmod.gamemodes.sandbox
		gmod.env.GAMEMODE = gmod.current_gamemode

		gmod.LoadFonts()

		gmod.init = true
	end
end

function gmod.Run()
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

	for dir in vfs.Iterate("addons/") do
		local dir = gmod.dir .. "addons/" ..  dir
		include(dir .. "/lua/autorun/*")
		if CLIENT then include(dir .. "/lua/autorun/client/*") end
		if SERVER then include(dir .. "/lua/autorun/server/*") end
	end

	gmod.env.hook.Run("CreateTeams")
	gmod.env.hook.Run("PreGamemodeLoaded")
	gmod.env.hook.Run("OnGamemodeLoaded")
	gmod.env.hook.Run("PostGamemodeLoaded")

	gmod.env.hook.Run("Initialize")

	--gmod.env.hook.Run("OnEntityCreated", player)
	gmod.env.hook.Run("InitPostEntity")

	event.AddListener("Update", "gmod", function()
		local tbl = gmod.env.hook.Run("CalcView", gmod.env.LocalPlayer(), gmod.env.EyePos(), gmod.env.EyeAngles(), math.deg(render.camera_3d:GetFOV()), render.camera_3d:GetNearZ(), render.camera_3d:GetFarZ())
		if tbl then
			if tbl.origin then render.camera_3d:SetPosition(tbl.origin.v) end
			if tbl.angles then render.camera_3d:SetRotation(tbl.angles.v) end
			if tbl.fov then render.camera_3d:SetFOV(tbl.fov) end
			if tbl.znear then render.camera_3d:SetNearZ(tbl.znear) end
			if tbl.zfar then render.camera_3d:SetFarZ(tbl.zfar) end
			--if tbl.drawviewer then  end
		end

		--gmod.env.hook.Run("CalcViewModelView", )
		local frac = gmod.env.hook.Run("AdjustMouseSensitivity", 0, 90, 90)
		--gmod.env.hook.Run("CalcMainActivity", )
		--gmod.env.hook.Run("TranslateActivity", )
		--gmod.env.hook.Run("UpdateAnimation", )

		gmod.env.hook.Run("Tick")
		gmod.env.hook.Run("Think")
	end)
	event.AddListener("PreGBufferModelPass", "gmod", function()
		gmod.env.hook.Run("PreRender")
	end)
	event.AddListener("DrawScene", "gmod", function()
		gmod.env.hook.Run("RenderScene", gmod.env.EyePos(), gmod.env.EyeAngles(), math.deg(render.camera_3d:GetFOV()))
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
	end)
	event.AddListener("PostGBufferModelPass", "gmod", function()
		gmod.env.hook.Run("GetMotionBlurValues", 0, 0, 0, 0)
		--gmod.env.hook.Run("PreDrawViewModel")
		--gmod.env.hook.Run("PreDrawViewModel")
		--gmod.env.hook.Run("PostDrawViewModel")
		gmod.env.hook.Run("PreDrawEffects")
	end)

	event.AddListener("GBufferPostPostProcess", "gmod", function()
		gmod.env.hook.Run("PostDrawEffects")
	end)
	event.AddListener("GBufferPrePostProcess", "gmod", function()
		gmod.env.hook.Run("RenderScreenspaceEffects")
		gmod.env.hook.Run("PostRender")
	end)

	event.AddListener("PreDrawGUI", "gmod", function()
		gmod.env.hook.Run("PreDrawHUD")
		gmod.env.hook.Run("HUDPaintBackground")

		for k,v in ipairs(gmod.hud_element_list) do
			gmod.env.hook.Run("HUDShouldDraw", v)
		end
	end)

	event.AddListener("DrawGUI", "gmod", function()
		gmod.env.hook.Run("HUDPaint")
		gmod.env.hook.Run("HUDDrawScoreBoard")
	end)

	event.AddListener("PostDrawGUI", "gmod", function()
		gmod.env.hook.Run("PostDrawHUD")
		gmod.env.hook.Run("DrawOverlay")
		gmod.env.hook.Run("PostRenderVGUI")
	end)
end

commands.Add("ginit", function()
	gmod.Initialize()
	gmod.Run()
end)

commands.Add("glua", function(line)
	if not gmod.env then
		gmod.Initialize()
	end
	local func = assert(loadstring(line))
	setfenv(func, gmod.env)
	print(func())
end)

return gmod