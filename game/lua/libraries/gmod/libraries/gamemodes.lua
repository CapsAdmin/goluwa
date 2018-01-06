local gine = ... or _G.gine

gine.gamemodes = gine.gamemodes or {}

function gine.LoadGamemode(name)
	local info = assert(utility.VDFToTable(assert(vfs.Read("gamemodes/" .. name .. "/" .. name .. ".txt"))))
	local name2, info = next(info)

	if info.base == "" then info.base = nil end

	if info.base then
		gine.LoadGamemode(info.base)
	end

	if SERVER then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/init.lua") then
			gine.env.GM = {FolderName = name}
			runfile("gamemodes/"..name.."/gamemode/init.lua")
			gine.env.gamemode.Register(gine.env.GM, name, info.base)
			gine.gamemodes[name] = gine.env.GM
			gine.env.GM = nil
		end
	end

	if CLIENT then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/cl_init.lua") then
			gine.env.GM = {FolderName = name}
			runfile("gamemodes/"..name.."/gamemode/cl_init.lua")
			gine.env.gamemode.Register(gine.env.GM, name, info.base)
			gine.gamemodes[name] = gine.env.GM
			gine.env.GM = nil
		end
	end

	gine.current_gamemode = gine.gamemodes.sandbox
	gine.env.GAMEMODE = gine.current_gamemode
end

function gine.env.DeriveGamemode(name)
	local old_gm = gine.env.GM
	gine.env.GM = {FolderName = name}

	if SERVER then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/init.lua") then
			runfile("gamemodes/"..name.."/gamemode/init.lua")
		end
	end

	if CLIENT then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/cl_init.lua") then
			runfile("gamemodes/"..name.."/gamemode/cl_init.lua")
		end
	end

	gine.env.table.Inherit(old_gm, gine.env.GM)
	gine.env.GM = old_gm
end

function gine.env.gmod.GetGamemode()
	return gine.current_gamemode
end

function gine.env.engine.ActiveGamemode()
	return gine.current_gamemode.FolderName
end
