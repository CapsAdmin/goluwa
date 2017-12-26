local gine = _G.gine or {}

runfile("preprocess.lua", gine)
runfile("code_scan.lua", gine)
runfile("cli.lua", gine)

function gine.SetFunctionEnvironment(func)
	setfenv(func, gine.env)
end

function gine.AddEvent(what, callback)
	event.AddListener(what, "gine", function(...) if gine.env then return callback(...) end end)
end

gine.objects = gine.objects or {}

function gine.WrapObject(obj, meta)
	gine.objects[meta] = gine.objects[meta] or {}

	if not gine.objects[meta][obj] then
		local tbl = table.copy(gine.GetMetaTable(meta))

		tbl.Type = meta

		local __index_func
		local __index_tbl

		if type(tbl.__index) == "function" then
			__index_func = tbl.__index
		else
			__index_tbl = tbl.__index
		end

		obj.gine_vars = obj.gine_vars or {}

		function tbl:__index(key)
			if key == "__obj" then
				return obj
			end

			if key == "__vars" then
				return obj.gine_vars
			end

			if __index_func then
				return __index_func(self, key)
			elseif __index_tbl then
				return __index_tbl[key]
			end
		end

		tbl.__gc = nil

		gine.objects[meta][obj] = setmetatable({}, tbl)

		if obj.CallOnRemove then
			obj:CallOnRemove(function()
				if gine.objects[meta] and gine.objects[meta][obj] then
					local obj = gine.objects[meta][obj]
					event.Delay(function() prototype.MakeNULL(obj) end)
					gine.objects[meta][obj] = nil
				end
			end)
		end
	end

	return gine.objects[meta][obj]
end

function gine.GetSet(META, name, def)
	if type(def) ~= "function" then
		local val = def
		def = function() return val end
	end

	META["Set" .. name] = function(self, val)
		self.__obj.gine_vars[name] = val
	end
	META["Get" .. name] = function(self)
		if def and self.__obj.gine_vars[name] == nil then
			return def()
		end
		return self.__obj.gine_vars[name]
	end
end

function gine.GetReverseEnums(pattern)
	local out = {}

	for k, v in pairs(gine.env.gine_enums) do
		local what = k:match(pattern)

		if what then
			out[v] = what:lower()
		end
	end

	return out
end


function gine.GetEnums(pattern)
	local out = {}

	for k, v in pairs(gine.env.gine_enums) do
		local what = k:match(pattern)

		if what then
			out[what:lower()] = v
		end
	end

	return out
end

gine.glua_paths = gine.glua_paths or {}

function gine.IsGLuaPath(path, gmod_dir_only)
	if path:lower():find("garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		return true
	end

	if not gmod_dir_only then
		for i,v in ipairs(gine.glua_paths) do
			if path:startswith(v) then
				return true
			end
		end
	end

	return false
end

gine.addons = gine.addons or {}
gine.package_loaders = {}

function gine.Initialize(gamemode)
	gamemode = gamemode or "sandbox"

	event.AddListener("PreLoadFile", "glua", function(path)
		if gine.IsGLuaPath(path, true) and (path:lower():find("garrysmod/garrysmod/lua/", nil, true) or path:lower():find("garrysmod/garrysmod/gamemodes/")) then
			local redirect = e.ROOT_FOLDER .. "garrysmod/garrysmod/"
			if vfs.IsDirectory(redirect) then
				local new_path = path:lower():gsub("^(.-garrysmod/garrysmod/)", redirect)
				if new_path:lower() ~= path:lower() and vfs.IsFile(new_path) then
					return new_path
				end
			end

			return
		end

		return event.destroy_tag
	end)

	event.AddListener("PreLoadString", "glua_preprocess", function(code, path)
		if gine.IsGLuaPath(path) then
			local ok, msg = pcall(gine.PreprocessLua, code)

			if not ok then
				logn(msg)
				return
			end

			code = msg

			if not loadstring(code) then vfs.Write("glua_preprocess_error.lua", code) end

			if not gine.init then
				return "commands.RunString('gluacheck "..path.."')"
			end

			return code
		end
	end)

	event.AddListener("PostLoadString", "glua_function_env", function(func, path)
		if gine.IsGLuaPath(path) then
			gine.SetFunctionEnvironment(func)
		end
	end)

	if not gine.init then
		steam.MountSourceGame("gmod")

		pvars.Setup("sv_allowcslua", 1)

		-- figure out the base gmod folder
		gine.dir = R("garrysmod_dir.vpk"):match("(.+/)")

		runfile("lua/libraries/gmod/material.lua", gine)

		-- setup engine functions
		runfile("lua/libraries/gmod/environment.lua", gine)

		do
			local dir = "os:" .. R(gine.dir.."/lua/includes/modules/")
			vfs.AddPackageLoader(function(path)
				return vfs.LoadFile(dir .. "/" .. path .. ".lua")
			end, gine.package_loaders)
		end

		-- include and init files in the right order

		gine.init = true

		if not skip_addons then
			local function mount(full_path)
				if full_path:match(".+/(.+)"):startswith("__") then return end

				table.insert(gine.addons, full_path)

				vfs.Mount(full_path)
				local dir = R(full_path.."/lua/includes/modules/")
				if dir then
					dir = "os:" .. dir
					vfs.AddPackageLoader(function(path)
						return vfs.LoadFile(dir .. "/" .. path .. ".lua")
					end, gine.package_loaders)
				end
				table.insert(gine.glua_paths, full_path)

				if vfs.IsDirectory(full_path .. "addons") then
					for dir in vfs.Iterate(full_path .. "addons/", true) do
						if vfs.IsDirectory(dir) then
							mount(dir .. "/")
						end
					end
				end
			end

			for _, info in ipairs(vfs.disabled_addons) do
				if info.gmod_addon then
					mount(info.path)
				end
			end

			for dir in vfs.Iterate(gine.dir .. "addons/", true) do
				dir = R(dir.."/lua/includes/modules/")
				if dir then
					dir = "os:" .. dir
					vfs.AddPackageLoader(function(path)
						return vfs.LoadFile(dir .. "/" .. path .. ".lua")
					end, gine.package_loaders)
				end
			end
		end

		runfile("lua/includes/init.lua")

		if CLIENT then
			--runfile("lua/includes/init_menu.lua")
			gine.env.require("notification")
			runfile("lua/derma/init.lua") -- the gui
		end

		gine.LoadGamemode("base")

		if gamemode ~= "base" then
			gine.LoadGamemode(gamemode)
		end

		-- autorun lua files
		runfile(gine.dir .. "/lua/autorun/*")
		if CLIENT then runfile(gine.dir .. "/lua/autorun/client/*") end
		if SERVER then runfile(gine.dir .. "/lua/autorun/server/*") end

		if CLIENT then
			runfile("lua/postprocess/*")
			runfile("lua/vgui/*")
			runfile("lua/matproxy/*")
			runfile("lua/skins/*")
		end

		--gine.env.DCollapsibleCategory.LoadCookies = nil -- DUCT TAPE FIX

		for name in pairs(gine.gamemodes) do
			vfs.Mount(gine.dir .. "/gamemodes/"..name.."/entities/", "lua/")
		end

		if CLIENT then
			for path in vfs.Iterate("resource/localization/en/", true) do
				for _, line in ipairs(vfs.Read(path):split("\n")) do
					local key, val = line:match("(.-)=(.+)")
					if key and val then
						gine.translation[key] = val:trim()
						gine.translation2["#" .. key] = gine.translation[key]
					end
				end
			end

			gine.LoadFonts()
		end
	end
end

function gine.Run(skip_addons)

	if not skip_addons then
		for _, path in ipairs(gine.addons) do
			runfile(path .. "lua/includes/extensions/*")
		end

		for dir in vfs.Iterate(gine.dir .. "addons/", true, true) do
			local dir = gine.dir .. "addons/" ..  dir
			runfile(dir .. "/lua/includes/extensions/*")
		end

		for _, path in ipairs(gine.addons) do
			runfile(path .. "lua/autorun/*")
			if CLIENT then runfile(path .. "lua/autorun/client/*") end
			if SERVER then runfile(path .. "lua/autorun/server/*") end
		end

		for dir in vfs.Iterate(gine.dir .. "addons/", true, true) do
			runfile(dir .. "/lua/autorun/*")
			if CLIENT then runfile(dir .. "/lua/autorun/client/*") end
			if SERVER then runfile(dir .. "/lua/autorun/server/*") end
		end
	end

	gine.LoadEntities("lua/entities", "ENT", gine.env.scripted_ents.Register, function() return {} end)
	gine.LoadEntities("lua/weapons", "SWEP", gine.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)

	if CLIENT then
		gine.LoadEntities("lua/effects", "EFFECT", gine.env.effects.Register, function() return {} end)
	end

	gine.env.gamemode.Call("CreateTeams")
	gine.env.gamemode.Call("PreGamemodeLoaded")
	gine.env.gamemode.Call("OnGamemodeLoaded")
	gine.env.gamemode.Call("PostGamemodeLoaded")

	gine.env.gamemode.Call("Initialize")
	gine.env.gamemode.Call("InitPostEntity")

	if CLIENT and CAPS then
--		system.GetFFIBuildLibrary("opengl", true).Disable("GL_SCISSOR_TEST")

		if gine.env.notagain then
			gine.env.LocalPlayer():SetNWBool("rpg", true)

			gine.env.LocalPlayer():SetHealth(250)
			gine.env.LocalPlayer():SetMaxHealth(250)

			gine.env.LocalPlayer():SetNWFloat("jattributes_max_stamina", 85)
			gine.env.LocalPlayer():SetNWFloat("jattributes_stamina", 85)

			gine.env.LocalPlayer():SetNWFloat("jattributes_max_mana", 185)
			gine.env.LocalPlayer():SetNWFloat("jattributes_mana", 185)

			gine.env.avatar.SetPlayer(gine.env.LocalPlayer(), "https://cdn.discordapp.com/attachments/273575417401573377/290168526709194752/ZKxp1lm.png",192,200,2)
		end
	end
end

commands.Add("ginit=string[sandbox],boolean", function(gamemode, skip_addons)
	utility.PushTimeWarning()
	gine.Initialize(gamemode, skip_addons)
	utility.PopTimeWarning("gine.Initialize", 0)

	utility.PushTimeWarning()
	gine.Run(skip_addons)
	utility.PopTimeWarning("gine.Run", 0)
end)

event.AddListener("KeyInput", function(key, press)
	if key == "q" and press then
		commands.RunString("ginit")
	end
end)

commands.Add("glua=arg_line", function(code)
	if not gine.env then
		gine.Initialize()
	end
	local func = assert(loadstring(code))
	setfenv(func, gine.env)
	print(func())
end)

if CAPS then
	event.Delay(0, function()
		--commands.RunString("ginit base,1")
	end)
end

return gine
