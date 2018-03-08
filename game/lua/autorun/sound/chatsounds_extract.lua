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

	local FILE
	local file_io_data = ffi.new("struct SF_VIRTUAL_IO[1]", {{
		get_filelen = function()
			return FILE:GetSize()
		end,
		seek = function(pos, whence)
			pos = tonumber(pos)

			if whence == 0 then -- set
				FILE:SetPosition(pos)
			elseif whence == 1 then -- cur
				FILE:SetPosition(FILE:GetPosition() + pos)
			elseif whence == 2 then -- end
				FILE:SetPosition(FILE:GetSize() + pos)
			end

			return FILE:GetPosition()
		end,
		read = function(ptr, count)
			count = tonumber(count)

			local str = FILE:ReadBytes(count)

			ffi.copy(ptr, str)

			return #str
		end,
		write = function(ptr, count)
			return FILE:Write(ffi.string(ptr, count))
		end,
		tell = function()
			return FILE:GetPosition()
		end
	}})


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

		logn(path:sub(#e.ROOT_FOLDER + 1))

		local info = ffi.new("struct SF_INFO[1]")
		FILE = vfs.Open(read_path)
		local file_src = soundfile.OpenVirtual(file_io_data, soundfile.e.READ, info, nil)

		local err = ffi.string(soundfile.Strerror(file_src))

		if err ~= "No Error." then
			FILE:Close()
			soundfile.Close(file_src)
			logn("source file: ", err)
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
			FILE:Close()
			soundfile.Close(file_dst)
			logn("destination file: ", err)
			return
		end

		local quality = ffi.new("float[1]", 0.4)
		soundfile.Command(file_dst, soundfile.e.SET_VBR_ENCODING_QUALITY, quality, ffi.sizeof(quality))

		local buffer = ffi.new("double[4096]")

		while true do
			local readcount = soundfile.ReadDouble(file_src, buffer, 4096)
			if readcount == 0 then break end
			soundfile.WriteDouble(file_dst, buffer, readcount)
		end

		soundfile.Close(file_src)
		soundfile.Close(file_dst)
		FILE:Close()
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