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