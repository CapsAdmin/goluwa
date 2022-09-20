local addons = {
	"https://github.com/PAC3-Server/notagain",
	--"https://github.com/PAC3-Server/gm-http-discordrelay",
	"https://github.com/CapsAdmin/pac3",
	"https://github.com/PAC3-Server/ServerAssets",
	"https://github.com/PAC3-Server/garrysmod",
}

commands.Add("setup_pac3server_addons", function()
	local git = system.GetCLICommand("git")
	local gmod_path = steam.GetGamePath("GarrysMod")
	assert(steam.GetGamePath("GarrysMod"), "could not find gmod install")
	fs.CreateDirectory("pac3_server/addons/", true)
	fs.Write("pac3_server/addon.json", "this is just to prevent goluwa from loading the addon")
	local goluwa_addons = e.ROOT_FOLDER .. "pac3_server/addons/"
	local gmod_addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"
	fs.CreateDirectory(gmod_addons, true)

	for _, url in ipairs(addons) do
		local name = url:match(".+/(.+)"):lower()

		if fs.get_type(goluwa_addons .. name) ~= "directory" then
			git.clone(url, goluwa_addons .. name)
		end

		local ok, err = fs.link(goluwa_addons .. name, gmod_addons .. name, true)

		if not ok then llog("failed to link " .. name .. ": " .. err) end
	end

	local ok, err = fs.link(e.ROOT_FOLDER, gmod_addons .. "goluwa", true)

	if not ok then llog("failed to link goluwa: " .. err) end
end)

commands.Add("setup_gmod_bridge", function()
	local gmod_path = steam.GetGamePath("GarrysMod")
	assert(gmod_path)
	local gmod_dir = gmod_path .. "garrysmod/"
	fs.RemoveRecursively(gmod_dir .. "backgrounds/")
	fs.CreateDirectory(gmod_dir .. "addons/goluwa_bridge/lua/autorun/", true)
	fs.Write(
		gmod_dir .. "addons/goluwa_bridge/lua/autorun/goluwa_bridge.lua",
		[[
file.Delete("goluwa_bridge.txt")
local next_run = 0
local last_time = 0
hook.Add("RenderScene", "goluwa_bridge", function()
	local time = SysTime()
	if next_run > next_run then return end
	next_run = next_run + 0.1

	if
		system.HasFocus() or
		(
			not GetConVar("sv_allowcslua"):GetBool() or
			not LocalPlayer():IsAdmin()
		)
	then
		return
	end

	local content = file.Read("goluwa_bridge.txt", "DATA")
	if content then
		file.Delete("goluwa_bridge.txt")
		local chunks = content:Split("¥$£@DELIMITER@£$¥")
		for i = #chunks, 1, -1 do
			if chunks[i] ~= "" then
				local func = CompileString(chunks[i], "goluwa_bridge", false)
				if type(func) == "function" then
					local ok, err = pcall(func)
					if not ok then
						ErrorNoHalt(err)
					end
				else
					ErrorNoHalt(func)
				end
				print("ran script from goluwa")
			end
		end
	end
end)
]]
	)
	logn(
		"wrote script to ",
		gmod_dir .. "addons/goluwa_bridge/lua/autorun/goluwa_bridge.lua"
	)
end)

if gmod_path then
	event.AddListener("LuaFileChanged", "gmod_bridge", function(info)
		if
			info.flags.close_write and
			vfs.IsFile(gmod_path .. "garrysmod/addons/goluwa_bridge/lua/autorun/goluwa_bridge.lua")
		then
			local content = vfs.Read(info.path)
			local f = io.open(gmod_path .. "garrysmod/data/goluwa_bridge.txt", "a")
			local path = info.path:lower()

			if path:find("/server/", 1, true) or path:find("/sv_", 1, true) then
				f:write("if CLIENT then return end ")
			elseif path:find("/client/", 1, true) or path:find("/cl_", 1, true) then
				f:write("if SERVER then return end ")
			end

			local current = vfs.Read(gmod_path .. "garrysmod/data/goluwa_bridge.txt")

			if current and current:find(content .. "¥$£@DELIMITER@£$¥", nil, true) then
				return
			end

			f:write(content)
			f:write("¥$£@DELIMITER@£$¥")
			f:close()
		end
	end)
end

local repos = {
	{url = "git@github.com:EgrOnWire/ACF.git"},
	{url = "git@github.com:CFC-Servers/fin2.git"},
	{url = "git@github.com:danielga/xcomms.git"},
	{url = "git@github.com:Metastruct/glua_utilities.git", npm = true},
	{url = "git@github.com:Metastruct/outfitter.git", branch = "dev"},
	{url = "git@github.com:Metastruct/RxLua.git"},
	{url = "git@github.com:Metastruct/Sit-Anywhere.git"},
	{url = "git@github.com:Metastruct/translation.git"},
	{url = "git@github.com:Metastruct/weapon_physcannon2.git"},
	{url = "git@github.com:Metastruct/wire.git"},
	{url = "git@gitlab.com:metastruct/aowl.git"},
	{url = "git@gitlab.com:metastruct/fast_addons.git"},
	{url = "git@gitlab.com:metastruct/metastruct.git"},
	{url = "git@gitlab.com:metastruct/MetaWorks-metastruct.git"},
	{url = "git@gitlab.com:metastruct/modules.git"},
	{url = "git@gitlab.com:metastruct/qbox.git"},
	{url = "git@gitlab.com:metastruct/srvaddons.git", location = "*/*"},
	{url = "git@gitlab.threekelv.in:metastruct-security/msascripts.git"},
	{url = "git@gitlab.threekelv.in:metastruct-security/msasurfacenet.git"},
	{url = "git@gitlab.threekelv.in:metastruct-security/msavehicles.git"},
	{url = "git@gitlab.threekelv.in:PotcFdk/MetaWorks.git"},
	{url = "git@github.com:CapsAdmin/customisable_thirdperson.git"},
	{url = "git@github.com:CapsAdmin/pac3.git"},
	{url = "git@github.com:danielga/halloween.git"},
	{url = "git@github.com:danielga/luachip.git"},
	{url = "git@github.com:Earu/Hoverbike.git"},
	{url = "git@github.com:edunad/sprayurl.git"},
	{url = "git@github.com:Falcqn/makespherical.git"},
	{url = "git@github.com:Metastruct/advduplicator.git"},
	{url = "git@github.com:Metastruct/copas.git"},
	{url = "git@github.com:Metastruct/enum_loader.git"},
	{url = "git@github.com:Metastruct/eventsystem.git"},
	{url = "git@github.com:Metastruct/fishingmod.git"},
	{url = "git@github.com:Metastruct/gcompute.git"},
	{url = "git@github.com:Metastruct/gm-mediaplayer.git"},
	{url = "git@github.com:Metastruct/gmod-csweapons.git"},
	{url = "git@github.com:Metastruct/improved-stacker.git"},
	{url = "git@github.com:Metastruct/luadev.git"},
	{url = "git@github.com:Metastruct/mgn.git"},
	{url = "git@github.com:Metastruct/moonscript.git"},
	{url = "git@github.com:Metastruct/NeedMoreLegs.git"},
	{url = "git@github.com:Metastruct/playablepiano.git"},
	{url = "git@github.com:Metastruct/simfphys_armed.git"},
	{url = "git@github.com:Metastruct/simfphys_base.git"},
	{url = "git@github.com:notcake/gcodec.git"},
	{url = "git@github.com:notcake/glib.git"},
	{url = "git@github.com:notcake/gooey.git"},
	{url = "git@github.com:notcake/gvote.git"},
	{url = "git@github.com:notcake/quicktool.git"},
	{url = "git@github.com:notcake/vfs.git"},
	{url = "git@github.com:PotcFdk/AntEater.git"},
	{url = "git@github.com:PotcFdk/PlyLab.git"},
	{url = "git@github.com:Python1320/gmod_vstruct.git", submodule = true},
	{url = "git@github.com:thegrb93/StarfallEx.git"},
	{url = "git@github.com:wiox/gmod-keypad.git"},
	{url = "git@github.com:wiremod/advdupe2.git"},
}

commands.Add("setup_metastruct_addons", function()
	local git = system.GetCLICommand("git")
	local npm = system.GetCLICommand("npm")
	fs.CreateDirectory("metastruct_addons")
	fs.PushWorkingDirectory("metastruct_addons")
	fs.RemoveRecursively("addons")
	fs.CreateDirectory("addons/merged", true)

	for _, repo in ipairs(repos) do
		local name = repo.url:match(".+/(.-)%.git")

		if fs.get_type(name) ~= "directory" then
			fs.PushWorkingDirectory(name)
			git.reset("--hard")
			git.clean("-fxd")
			git.pull()
			fs.PopWorkingDirectory()
		else
			git.clone(repo.url, "--depth 1", name)
		end

		fs.PushWorkingDirectory(name)

		if repo.branch then git.checkout(repo.branch) end

		if repo.submodule then
			git.submodule("init")
			git.submodule("update")
		end

		if repo.npm then npm.install() end

		local location = repo.location or "*"

		if repo.npm then location = "dist/*" end

		for _, path in ipairs(fs.get_files_recursive(location)) do
			fs.CreateDirectory(path:match("(.+)/"), true)
			fs.link(path, "../addons/merged/")
		end

		fs.PopWorkingDirectory()
	end

	fs.PopWorkingDirectory()
end)