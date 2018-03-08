commands.Add("chatsounds_extract", function(game_id)
	local soundfile = system.GetFFIBuildLibrary("libsndfile")
	local ffi = require("ffi")

	local info = steam.MountSourceGame(game_id)
	local appid = info.filesystem and info.filesystem.steamappid
	if appid == 4000 then
		appid = 220
	end
	if not appid then
		logn("unable to find game " .. game_id)
		return
	end

	local root = R("data/")

	local function write(realm, trigger, read_path, i)
		local dir = root .. "autoadd/" .. realm .. "/"
		local path = dir

		local filename = trigger

		if #filename > 250 then
			filename = "-" .. trigger:sub(0, 250)
		end

		if i then
			path = path .. filename .. "/" .. i .. ".ogg"
		else
			path = path .. filename .. ".ogg"
		end

		vfs.CreateDirectoriesFromPath("os:" .. path)

		if vfs.IsFile(path) then return end

		if filename ~= trigger then
			vfs.Write(dir .. filename .. ".txt", trigger)
		end

		log("converting ", read_path:match(".+/(.+)") , " >> " , path:match(".+autoadd/(.+)") , " - ")

		local info = ffi.new("struct SF_INFO[1]")
		local file = vfs.Open(read_path)
		local file_src = soundfile.OpenVFS(file, soundfile.e.READ, info)

		local err = ffi.string(soundfile.Strerror(file_src))

		if err ~= "No Error." then
			file:Close()
			soundfile.Close(file_src)
			logn("FAIL: [source file] ", err)
			return
		end

		local info = ffi.new("struct SF_INFO[1]", {{
			format = bit.bor(soundfile.e.FORMAT_OGG, soundfile.e.FORMAT_VORBIS),
			samplerate = info[0].samplerate,
			channels = info[0].channels,
		}})

		local file_dst = soundfile.Open(path, soundfile.e.WRITE, info)

		local err = ffi.string(soundfile.Strerror(file_dst))

		if err ~= "No Error." then
			file:Close()
			soundfile.Close(file_dst)
			logn("FAIL: [destination file] ", err)
			return
		end

		local ogg_quality = ffi.new("float[1]", 0.4)

		soundfile.Command(file_dst, soundfile.e.SET_VBR_ENCODING_QUALITY, ogg_quality, ffi.sizeof(ogg_quality))

		local len = 1024 * 1024 * 4
		local buffer = ffi.new("double[?]", len)

		while true do
			local readcount = soundfile.ReadDouble(file_src, buffer, len)
			if readcount == 0 then break end
			soundfile.WriteDouble(file_dst, buffer, readcount)
		end

		soundfile.Close(file_src)
		soundfile.Close(file_dst)
		file:Close()

		logn("OK")
	end

	sockets.Download("https://raw.githubusercontent.com/PAC3-Server/chatsounds/master/data/chatsounds/lists/"..appid..".txt", function(str)
		for realm, triggers in pairs(chatsounds.ListToTable(str)) do
			for trigger, data in pairs(triggers) do
				trigger = trigger:gsub("[^a-z ]", "")
				realm = realm:gsub("[^a-z ]", "")

				if #data == 1 then
					write(game_id .. "_" .. realm, trigger, data[1].path)
				else
					for i, data in ipairs(data) do
						write(game_id .. "_" .. realm, trigger, data.path, i)
					end
				end
			end
		end
	end)
end)

--commands.RunString("chatsounds_extract_list gmod")