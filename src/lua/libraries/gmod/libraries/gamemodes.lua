local gmod = ... or gmod

gmod.gamemodes = gmod.gamemodes or {}

function gmod.LoadGamemode(name)
	local info = steam.VDFToTable(vfs.Read("gamemodes/" .. name .. "/" .. name .. ".txt"))
	local name2, info = next(info)

	if info.base == "" then info.base = nil end

	if info.base then
		gmod.LoadGamemode(info.base)
	end

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

	gmod.current_gamemode = gmod.gamemodes.sandbox
	gmod.env.GAMEMODE = gmod.current_gamemode
end

function gmod.env.DeriveGamemode(name)
	local old_gm = gmod.env.GM
	gmod.env.GM = {FolderName = name}

	if SERVER then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/init.lua") then
			include("gamemodes/"..name.."/gamemode/init.lua")
		end
	end

	if CLIENT then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/cl_init.lua") then
			include("gamemodes/"..name.."/gamemode/cl_init.lua")
		end
	end

	gmod.env.table.Inherit(old_gm, gmod.env.GM)
	gmod.env.GM = old_gm
end

function gmod.env.gmod.GetGamemode()
	return gmod.current_gamemode
end

function gmod.env.engine.ActiveGamemode()
	return gmod.current_gamemode.FolderName
end