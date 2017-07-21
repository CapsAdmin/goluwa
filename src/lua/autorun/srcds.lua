local function check_cmd(cmd)
	assert(io.popen("command -v " .. cmd):read("*all") ~= "", cmd .. " command does not exist")
end

commands.Add("gserv", function(line, ...)
	check_cmd("tmux") -- not used yet?
	check_cmd("tar")

	local dir = e.DATA_FOLDER .. "srcds/"

	-- create the srcds directory in goluwa/data/srcds
	vfs.CreateFolder("os:" .. dir)

	-- download steamcmd
	resource.Download("http://media.steampowered.com/client/steamcmd_linux.tar.gz", function(path)

		-- if steamcmd.sh does not exist then we need to extract it
		if not vfs.IsFile(dir .. "steamcmd.sh") then
			os.execute("tar -xvzf " .. vfs.GetAbsolutePath(path) .. " -C " .. dir)
		end

		-- if srcds_run does not exist install gmod
		if not vfs.IsFile(dir .. "gmod/srcds_run") then
			os.execute(dir .. "steamcmd.sh +login anonymous +force_install_dir " .. dir .. "gmod +app_update 4020 validate +quit")
		end

		os.execute(dir .. "gmod/srcds_run -game garrysmod +maxplayers 32 +map gm_construct")
	end)
end)