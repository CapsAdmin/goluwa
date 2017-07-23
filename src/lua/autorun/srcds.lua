local startup_parameters = {
	maxplayers = 32,
	map = "gm_construct",
}

local cfg = {
	sv_hibernate_think = 1,
}

local function check_cmd(cmd)
	assert(io.popen("command -v " .. cmd):read("*all") ~= "", cmd .. " command does not exist")
end

commands.Add("gserv", function(line, cmd, arg1, ...)
	check_cmd("tmux")
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

		if not vfs.IsFile(dir .. "gmod/garrysmod/addons/gserv/lua/autorun/server/server_watchdog.lua") then
			vfs.CreateFolders("os", dir .. "gmod/garrysmod/addons/gserv/lua/autorun/server/")
			vfs.Write(dir .. "gmod/garrysmod/addons/gserv/lua/autorun/server/server_watchdog.lua", [[
				timer.Create("server_watchdog", 1, 0, function()
					file.Write("server_watchdog.txt", os.time(), "DATA")
				end)
			]])
		end

		local str = ""
		for k,v in pairs(cfg) do
			str = str .. k .. " " .. v .. "\n"
		end
		vfs.Write(dir .. "gmod/garrysmod/cfg/server.cfg", str)

		-- silence some startup errors
		vfs.Write(dir .. "gmod/garrysmod/cfg/trusted_keys_base.txt", "trusted_key_list\n{\n}\n")
		vfs.Write(dir .. "gmod/garrysmod/cfg/pure_server_minimal.txt", "whitelist\n{\n}\n")
		vfs.Write(dir .. "gmod/garrysmod/cfg/network.cfg", "")
	end)

	if cmd == "start" then
		logn("starting gmod server")
		os.execute("tmux kill-session -t goluwa_srcds 2>/dev/null")
		os.execute("tmux new-session -d -s goluwa_srcds")

		local str = ""

		for k, v in pairs(startup_parameters) do
			str = str .. "+" .. k .. " " .. v .. " "
		end

		os.execute("tmux send-keys -t goluwa_srcds \"" .. dir .. "gmod/srcds_run -game garrysmod " .. str .. "\" C-m")

		event.Timer("gserv_watchdog", 1, 0, function()
			local time = vfs.Read(dir .. "gmod/garrysmod/data/server_watchdog.txt")

			if time then
				time = tonumber(time)
				local diff = os.difftime(os.time(), time)
				if diff > 3 then
					logn("server hasn't responded for more than ", diff ," seconds")
				end
			end
		end)
	elseif cmd == "kill" then
		event.RemoveTimer("gserv_watchdog")
		logn("killing gmod server")
		os.execute("tmux kill-session -t goluwa_srcds 2>/dev/null")
	elseif cmd == "show" then
		logn(io.popen([[tmux capture-pane -t goluwa_srcds; printf "$(tmux show-buffer)\n"]]):read("*all"))
	end
end)

commands.Add("gserv_run", function(line)
	logn("running |", line, "| on srcds")
	os.execute("tmux send-keys -t goluwa_srcds \"" .. line .. "\" C-m")
	event.Delay(0.1, function()
		logn(io.popen([[tmux capture-pane -t goluwa_srcds; printf "$(tmux show-buffer)\n"]]):read("*all"))
	end)
end)

commands.Add("gserv_lua", function(line)
	os.execute("tmux send-keys -t goluwa_srcds \"lua_run " .. line .. "\" C-m")
	event.Delay(0.1, function()
		logn(io.popen([[tmux capture-pane -t goluwa_srcds; printf "$(tmux show-buffer)\n"]]):read("*all"))
	end)
end)