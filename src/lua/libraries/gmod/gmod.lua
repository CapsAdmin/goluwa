local gmod = _G.gmod or {}

include("preprocess.lua", gmod)

event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
	if path:lower():find("steamapps/common/garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		gmod.SetFunctionEnvironment(func)
	end
end)

function gmod.SetFunctionEnvironment(func)
	if not gmod.env then
		gmod.Initialize()
	end
	setfenv(func, gmod.env)
end

function gmod.AddEvent(what, callback)
	event.AddListener(what, "gmod", function(...) if gmod.env then return callback(...) end end)
end

gmod.objects = gmod.objects or {}

function gmod.WrapObject(obj, meta)
	gmod.objects[meta] = gmod.objects[meta] or {}

	if not gmod.objects[meta][obj] then
		local tbl = table.copy(gmod.GetMetaTable(meta))

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

function gmod.Initialize()
	if not gmod.init then
		render.InitializeGBuffer()

		--steam.MountSourceGame("hl2")
		--steam.MountSourceGame("css")
		--steam.MountSourceGame("tf2")
		steam.MountSourceGame("gmod")

		pvars.Setup("sv_allowcslua", 1)

		-- figure out the base gmod folder
		gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")

		-- setup engine functions
		include("lua/libraries/gmod/environment.lua", gmod)

		vfs.AddModuleDirectory(R(gmod.dir.."/lua/includes/modules/"))

		-- include and init files in the right order

		include("lua/includes/init.lua") --
		include("lua/derma/init.lua") -- the gui
		gmod.env.require("notification") -- this is included by engine at this point

		gmod.LoadGamemode("base")
		gmod.LoadGamemode(CAPS and "sandbox_modded" or "sandbox")

		-- autorun lua files
		include(gmod.dir .. "/lua/autorun/*")
		if CLIENT then include(gmod.dir .. "/lua/autorun/client/*") end
		if SERVER then include(gmod.dir .. "/lua/autorun/server/*") end

		for dir in vfs.Iterate(gmod.dir .. "addons/", true) do
			vfs.AddModuleDirectory(R(dir.."/lua/includes/modules/"))
		end


		--include("lua/postprocess/*")
		include("lua/vgui/*")
		--include("lua/matproxy/*")
		include("lua/skins/*")

		gmod.env.DCollapsibleCategory.LoadCookies = nil -- DUCT TAPE FIX

		for name in pairs(gmod.gamemodes) do
			vfs.Mount(gmod.dir .. "/gamemodes/"..name.."/entities/", "lua/")
		end

		gmod.LoadEntities("lua/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
		gmod.LoadEntities("lua/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
		gmod.LoadEntities("lua/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)

		do
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

		gmod.LoadFonts()

		gmod.init = true
	end
end

function gmod.Run()
	for dir in vfs.Iterate(gmod.dir .. "addons/", true, true) do
		local dir = gmod.dir .. "addons/" ..  dir
		include(dir .. "/lua/includes/extensions/*")
	end

	for dir in vfs.Iterate(gmod.dir .. "addons/", true, true) do
		include(dir .. "/lua/autorun/*")
		if CLIENT then include(dir .. "/lua/autorun/client/*") end
		if SERVER then include(dir .. "/lua/autorun/server/*") end
	end

	gmod.env.gamemode.Call("CreateTeams")
	gmod.env.gamemode.Call("PreGamemodeLoaded")
	gmod.env.gamemode.Call("OnGamemodeLoaded")
	gmod.env.gamemode.Call("PostGamemodeLoaded")

	gmod.env.gamemode.Call("Initialize")
	gmod.env.gamemode.Call("InitPostEntity")
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