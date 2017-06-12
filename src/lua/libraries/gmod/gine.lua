local gine = _G.gine or {}

runfile("preprocess.lua", gine)
runfile("cli.lua", gine)

event.AddListener("PostLoadString", "glua_function_env", function(func, path)
	if path:lower():find("steamapps/common/garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		gine.SetFunctionEnvironment(func)
	end
end)

function gine.SetFunctionEnvironment(func)
	if not gine.env then
		gine.Initialize()
	end
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

		gine.objects[meta][obj] = setmetatable({}, tbl)

		obj:CallOnRemove(function()
			if gine.objects[meta] and gine.objects[meta][obj] then
				local obj = gine.objects[meta][obj]
				event.Delay(function() prototype.MakeNULL(obj) end)
				gine.objects[meta][obj] = nil
			end
		end)
	end

	return gine.objects[meta][obj]
end

function gine.Initialize(skip_addons)
	if not gine.init then
		render3d.Initialize()

		--steam.MountSourceGame("hl2")
		--steam.MountSourceGame("css")
		--steam.MountSourceGame("tf2")
		steam.MountSourceGame("gmod")

		pvars.Setup("sv_allowcslua", 1)

		-- figure out the base gmod folder
		gine.dir = R("garrysmod_dir.vpk"):match("(.+/)")

		-- setup engine functions
		runfile("lua/libraries/gmod/environment.lua", gine)

		vfs.AddModuleDirectory(R(gine.dir.."/lua/includes/modules/"))

		-- include and init files in the right order

		runfile("lua/includes/init.lua") --
		--runfile("lua/includes/init_menu.lua")
		gine.env.require("notification")
		runfile("lua/derma/init.lua") -- the gui

		gine.LoadGamemode("base")
		gine.LoadGamemode("sandbox")

		-- autorun lua files
		runfile(gine.dir .. "/lua/autorun/*")
		if CLIENT then runfile(gine.dir .. "/lua/autorun/client/*") end
		if SERVER then runfile(gine.dir .. "/lua/autorun/server/*") end

		if not skip_addons then
			for dir in vfs.Iterate(gine.dir .. "addons/", true) do
				vfs.AddModuleDirectory(R(dir.."/lua/includes/modules/"))
			end
		end

		runfile("lua/postprocess/*")
		runfile("lua/vgui/*")
		runfile("lua/matproxy/*")
		runfile("lua/skins/*")

		--gine.env.DCollapsibleCategory.LoadCookies = nil -- DUCT TAPE FIX

		for name in pairs(gine.gamemodes) do
			vfs.Mount(gine.dir .. "/gamemodes/"..name.."/entities/", "lua/")
		end

		do
			for path in vfs.Iterate("resource/localization/en/", true) do
				for _, line in ipairs(vfs.Read(path):split("\n")) do
					local key, val = line:match("(.-)=(.+)")
					if key and val then
						gine.translation[key] = val:trim()
						gine.translation2["#" .. key] = gine.translation[key]
					end
				end
			end
		end

		gine.LoadFonts()

		gine.init = true
	end
end

function gine.Run(skip_addons)
	if not skip_addons then
		for dir in vfs.Iterate(gine.dir .. "addons/", true, true) do
			local dir = gine.dir .. "addons/" ..  dir
			runfile(dir .. "/lua/includes/extensions/*")
		end

		for dir in vfs.Iterate(gine.dir .. "addons/", true, true) do
			runfile(dir .. "/lua/autorun/*")
			if CLIENT then runfile(dir .. "/lua/autorun/client/*") end
			if SERVER then runfile(dir .. "/lua/autorun/server/*") end
		end
	end

	gine.LoadEntities("lua/entities", "ENT", gine.env.scripted_ents.Register, function() return {} end)
	gine.LoadEntities("lua/weapons", "SWEP", gine.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
	gine.LoadEntities("lua/effects", "EFFECT", gine.env.effects.Register, function() return {} end)

	gine.env.gamemode.Call("CreateTeams")
	gine.env.gamemode.Call("PreGamemodeLoaded")
	gine.env.gamemode.Call("OnGamemodeLoaded")
	gine.env.gamemode.Call("PostGamemodeLoaded")

	gine.env.gamemode.Call("Initialize")
	gine.env.gamemode.Call("InitPostEntity")
end

commands.Add("ginit", function(line)
	gine.Initialize(line == "1")
	gine.Run(line == "1")
end)

commands.Add("glua", function(line)
	if not gine.env then
		gine.Initialize()
	end
	local func = assert(loadstring(line))
	setfenv(func, gine.env)
	print(func())
end)

return gine
