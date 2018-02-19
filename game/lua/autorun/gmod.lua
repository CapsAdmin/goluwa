local addons = {
	"https://github.com/PAC3-Server/EasyChat",
	"https://github.com/PAC3-Server/notagain",
	"https://github.com/PAC3-Server/gm-http-discordrelay",
	"https://github.com/CapsAdmin/pac3",
	"https://github.com/PAC3-Server/ServerAssets",
	"https://github.com/PAC3-Server/garrysmod",
}

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
	local gmod_dir = steam.GetGamePath("GarrysMod")

	assert(gmod_dir)

	gmod_dir = gmod_dir .. "garrysmod/"

	os.execute("rm -rf " .. gmod_dir .. "backgrounds/")

	os.execute("mkdir -p " .. gmod_dir .. "addons/zerobrane_bridge/lua/autorun/")
	vfs.Write("os:" .. gmod_dir .. "addons/zerobrane_bridge/lua/autorun/zerobrane_bridge.lua", [[
local next_run = 0
local last_time = 0
hook.Add("RenderScene", "zerobrane_bridge", function()
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

	local content = file.Read("zerobrane_bridge.txt", "DATA")
	if content then
		local chunks = content:Split("¥$£@DELIMITER@£$¥")
		for i = #chunks, 1, -1 do
			if chunks[i] ~= "" then
				local func = CompileString(chunks[i], "zerobrane_bridge", false)
				if type(func) == "function" then
					local ok, err = pcall(func)
					if not ok then
						ErrorNoHalt(err)
					end
				else
					ErrorNoHalt(func)
				end
			end
		end
		file.Delete("zerobrane_bridge.txt")
	end
end)
]])
	vfs.Write("os:" .. e.ROOT_FOLDER .. "data/ide/gmod_path", gmod_dir)
end)

commands.Add("setup_metastruct_addons", function()
	if not vfs.IsDirectory(e.ROOT_FOLDER .. "metastruct_addons") then
		vfs.CreateDirectory(e.ROOT_FOLDER .. "metastruct_addons")
	end

	vfs.Write(e.ROOT_FOLDER .. "metastruct_addons/build.sh", [[
#!/bin/sh

#remove linked folder
rm -f addons/
mkdir -p addons/merged

svn checkout svn://svn.metastruct.net/srvaddons __srvaddons
cp -rl __srvaddons/*/* addons/merged/

svn checkout svn://svn.metastruct.net/Metastruct2 __metastruct
cp -rl __metastruct/Metastruct2/* addons/merged/

git clone git@gitlab.threekelv.in:PotcFdk/MetaWorks.git
cp -rl MetaWorks/* addons/merged/

git clone https://github.com/Metastruct/luadev
cp -rl luadev/* addons/merged/

git clone https://github.com/Metastruct/gm-mediaplayer
cp -rl gm-mediaplayer/* addons/merged/

git clone https://github.com/Metastruct/translation
cp -rl translation/* addons/merged/

git clone https://github.com/Metastruct/outfitter
cd outfitter
git checkout dev
npm install
cd ..
cp -rl outfitter/dist/* addons/merged/

	]])
end)