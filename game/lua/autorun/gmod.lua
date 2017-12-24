local addons = {
	"https://github.com/PAC3-Server/EasyChat",
	"https://github.com/PAC3-Server/notagain",
	"https://github.com/PAC3-Server/gm-http-discordrelay",
	"https://github.com/CapsAdmin/pac3",
	"https://github.com/PAC3-Server/ServerAssets",
}

commands.Add("setup_gmod_addons", function()
	assert(steam.GetGamePath("GarrysMod"), "could not find gmod install")
	assert(system.OSCommandExists("git", "readlink", "ln"), "windows?")

	if not vfs.IsDirectory(e.ROOT_FOLDER .. "pac3_server/addons") then
		vfs.CreateFolder(e.ROOT_FOLDER .. "pac3_server")
		vfs.CreateFolder(e.ROOT_FOLDER .. "pac3_server/addons/")
	end

	vfs.Write(e.ROOT_FOLDER .. "pac3_server/addon.json", "this is just to prevent goluwa from loading the addon")

	local goluwa_addons = e.ROOT_FOLDER .. "pac3_server/addons/"

	local gmod_addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"

	if not vfs.IsDirectory(gmod_addons) then
		vfs.CreateFolder(gmod_addons)
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
