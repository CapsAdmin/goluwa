do
	local file = gmod.env.file

	local search_paths = {
		game = "",
		workshop = "",
		lua = "lua/",
		data = gmod.dir .. "data/",
		download = gmod.dir .. "download/",
		mod = gmod.dir,
		base_path = gmod.dir .. "../bin/",
	}

	function file.Find(path, where)
		local files, folders = {}, {}

		path = path:gsub("%.", ".")
		path = path:gsub("%*", ".*")

		if where == "LUA" then
			for k,v in ipairs(vfs.Find("lua/" .. path, true)) do
				if v:startswith(gmod.dir) then
					if vfs.IsDirectory(v) then
						table.insert(folders, v:match(".+/(.+)"))
					else
						table.insert(files, v:match(".+/(.+)"))
					end
				end
			end
		else
			for k,v in ipairs(vfs.Find(path, true)) do
				if vfs.IsDirectory(v) then
					table.insert(folders, v:match(".+/(.+)"))
				else
					table.insert(files, v:match(".+/(.+)"))
				end
			end
		end

		return files, folders
	end

	function file.Exists(path, where)
		where = where or "data"
		return vfs.Exists(search_paths[where:lower()] .. path)
	end

	function file.IsDir(path, where)
		where = where or "data"
		return vfs.IsDirectory(search_paths[where:lower()] .. path)
	end

	function file.Size(path, where)
		where = where or "data"
		local str = vfs.Read(search_paths[where:lower()] .. path)
		if str then
			return #str
		end
		return 0
	end

	function file.Time(path, where)
		where = where or "data"
		return vfs.GetLastModified(search_paths[where:lower()] .. path) or 0
	end

end

do
	function gmod.env.file.Open(path, how, where)
		where = where or "data"

		if how:find("w") then
			llog("opening ", path, " with ", how, " from ", where)
		end

		local self, err = vfs.Open(search_paths[where:lower()] .. path, how)

		if self then
			return gmod.WrapObject(self, "File")
		else
			--llog(err)
		end
	end

	local META = gmod.GetMetaTable("File")

	function META:Read(length) return self.__obj:ReadBytes(length) end
	function META:Close() return self.__obj:Close() end
	function META:Tell() return self.__obj:Tell() end
	function META:Size() return self.__obj:GetSize() end
	function META:Skip(pos) return self.__obj:SetPos(pos) end
end