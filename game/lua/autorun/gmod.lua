local addons = {
	"https://github.com/PAC3-Server/notagain",
	--"https://github.com/PAC3-Server/gm-http-discordrelay",
	"https://github.com/CapsAdmin/pac3",
	"https://github.com/PAC3-Server/ServerAssets",
	"https://github.com/PAC3-Server/garrysmod",
}

local gmod_path = steam.GetGamePath("GarrysMod")

commands.Add("setup_pac3server_addons", function()
	assert(steam.GetGamePath("GarrysMod"), "could not find gmod install")
	assert(system.OSCommandExists("git", "readlink", "ln"), "windows?")

	if not vfs.IsDirectory(e.ROOT_FOLDER .. "pac3_server/addons") then
		vfs.CreateDirectory(e.ROOT_FOLDER .. "pac3_server")
		vfs.CreateDirectory(e.ROOT_FOLDER .. "pac3_server/addons/")
	end

	vfs.Write(e.ROOT_FOLDER .. "pac3_server/addon.json", "this is just to prevent goluwa from loading the addon")

	local goluwa_addons = e.ROOT_FOLDER .. "pac3_server/addons/"

	local gmod_addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"

	if not vfs.IsDirectory(gmod_addons) then
		require("fs").createdir(gmod_addons)
	end

	for _, url in ipairs(addons) do
		local name = url:match(".+/(.+)"):lower()

		if not vfs.IsDirectory(goluwa_addons .. name) then
			os.execute("git clone " .. url .. " " .. goluwa_addons .. name)
		end

		if LINUX then
			if not vfs.Exists(gmod_addons .. name) or io.popen("readlink " .. gmod_addons .. name):read("*all") ~= "" then
				os.remove(gmod_addons .. name)
				os.execute("ln -s " .. goluwa_addons .. name .. " " .. gmod_addons .. name)
				logn("garrysmod/addons/", name, " >>LINK>> ", "goluwa/pac3_server/addons/", name)
			end
		end
	end
end)

commands.Add("setup_gmod_bridge", function()
	assert(gmod_path)

	local gmod_dir = gmod_path .. "garrysmod/"

	os.execute("rm -rf " .. gmod_dir .. "backgrounds/")

	os.execute("mkdir -p " .. gmod_dir .. "addons/goluwa_bridge/lua/autorun/")
	vfs.Write("os:" .. gmod_dir .. "addons/goluwa_bridge/lua/autorun/goluwa_bridge.lua", [[
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
]])
	logn("wrote script to ", gmod_dir .. "addons/goluwa_bridge/lua/autorun/goluwa_bridge.lua")
end)

if gmod_path then
	event.AddListener("LuaFileChanged", "gmod_bridge", function(info)
		if info.flags.close_write and vfs.IsFile(gmod_path .. "garrysmod/addons/goluwa_bridge/lua/autorun/goluwa_bridge.lua") then
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

commands.Add("setup_metastruct_addons", function()
	if not vfs.IsDirectory("os:" .. e.ROOT_FOLDER .. "metastruct_addons") then
		assert(vfs.CreateDirectory("os:" .. e.ROOT_FOLDER .. "metastruct_addons"))
	end

	local repos = {
		{url = "https://github.com/EgrOnWire/ACF.git"},
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
		{url = "https://github.com/CapsAdmin/customisable_thirdperson.git"},
		{url = "https://github.com/CapsAdmin/pac3.git"},
		{url = "https://github.com/danielga/halloween.git"},
		{url = "https://github.com/danielga/luachip.git"},
		{url = "https://github.com/Earu/Hoverbike.git"},
		{url = "https://github.com/edunad/sprayurl.git"},
		{url = "https://github.com/Falcqn/makespherical.git"},
		{url = "https://github.com/Metastruct/advduplicator.git"},
		{url = "https://github.com/Metastruct/copas.git"},
		{url = "https://github.com/Metastruct/enum_loader.git"},
		{url = "https://github.com/Metastruct/eventsystem.git"},
		{url = "https://github.com/Metastruct/fishingmod.git"},
		{url = "https://github.com/Metastruct/gcompute.git"},
		{url = "https://github.com/Metastruct/gm-mediaplayer.git"},
		{url = "https://github.com/Metastruct/gmod-csweapons.git"},
		{url = "https://github.com/Metastruct/improved-stacker.git"},
		{url = "https://github.com/Metastruct/luadev.git"},
		{url = "https://github.com/Metastruct/mgn.git"},
		{url = "https://github.com/Metastruct/moonscript.git"},
		{url = "https://github.com/Metastruct/NeedMoreLegs.git"},
		{url = "https://github.com/Metastruct/playablepiano.git"},
		{url = "https://github.com/Metastruct/simfphys_armed.git"},
		{url = "https://github.com/Metastruct/simfphys_base.git"},
		{url = "https://github.com/notcake/gcodec.git"},
		{url = "https://github.com/notcake/glib.git"},
		{url = "https://github.com/notcake/gooey.git"},
		{url = "https://github.com/notcake/gvote.git"},
		{url = "https://github.com/notcake/quicktool.git"},
		{url = "https://github.com/notcake/vfs.git"},
		{url = "https://github.com/PotcFdk/AntEater.git"},
		{url = "https://github.com/PotcFdk/PlyLab.git"},
		{url = "https://github.com/Python1320/gmod_vstruct.git", submodule = true},
		{url = "https://github.com/thegrb93/StarfallEx.git"},
		{url = "https://github.com/wiox/gmod-keypad.git"},
		{url = "https://github.com/wiremod/advdupe2.git"},
	}

	local dir = e.ROOT_FOLDER .. "metastruct_addons"

	vfs.PushWorkingDirectory(dir)

	os.execute("rm -f addons/")
	os.execute("mkdir -p addons/merged")

	for _, repo in ipairs(repos) do
		local name = repo.url:match(".+/(.-)%.git")
		os.execute("git clone " .. repo.url .. " --depth 1 " .. name)
		vfs.PushWorkingDirectory(name)

		if repo.branch then
			os.execute("git checkout " .. repo.branch)
		end

		if repo.submodule then
			os.execute("git submodule init && git submodule update")
		end

		local location = repo.location or "*"
		os.execute("cp -rl "..location.." ../addons/merged/")

		if repo.npm then
			os.execute("npm install")
		end
		vfs.PopWorkingDirectory()
	end

	vfs.PopWorkingDirectory()
end)