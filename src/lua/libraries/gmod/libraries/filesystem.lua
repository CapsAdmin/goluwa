local search_paths = {
	game = "",
	workshop = "",
	lua = "lua/",
	data = gine.dir .. "data/",
	download = gine.dir .. "download/",
	mod = gine.dir,
	base_path = gine.dir .. "../bin/",
}

do
	local file = gine.env.file

	function file.Find(path, where)
		local files, folders = {}, {}

		path = path:gsub("%.", ".")
		path = path:gsub("%*", ".*")

		if where == "LUA" then
			for k,v in ipairs(vfs.Find("lua/" .. path, true)) do
				if v:startswith(gine.dir) then
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

	function file.CreateDir(path, where)
		vfs.OSCreateDirectory(search_paths.data .. path)
	end
end

do
	function gine.env.file.Open(path, how, where)
		where = where or "data"
		path = search_paths[where:lower()] .. path

		--llog("file.Open(%s, %s, %s)", R(path), how, where)

		how = how:gsub("b", "")
		if how == "w" then how = "write" end
		if how == "r" then how = "read" end

		local self, err = vfs.Open(path, how)

		if self then
			return gine.WrapObject(self, "File")
		else
			--llog("file.Open failed: ", err)
		end
	end

	local META = gine.GetMetaTable("File")

	function META:Read(length) return self.__obj:ReadBytes(length) end
	function META:Write(content) return self.__obj:Write(content) end

	function META:Close() return self.__obj:Close() end
	function META:Tell() return self.__obj:GetPosition() end
	function META:Size() return self.__obj:GetSize() end
	function META:Skip(pos) return self.__obj:SetPosition(pos) end
	function META:Seek(pos) return self.__obj:SetPosition(pos) end
	function META:Flush() self.__obj:Flush() end

	function META:ReadLine() return self.__obj:ReadString(nil, nil, string.byte("\n")) end

	function META:ReadByte() return self.__obj:ReadByte() end
	function META:WriteByte(num) return self.__obj:WriteByte(num) end

	function META:ReadBool() return self.__obj:ReadBoolean() end
	function META:WriteBool(num) return self.__obj:WriteBoolean(num) end

	function META:ReadFloat() return self.__obj:ReadFloat() end
	function META:WriteFloat(num) return self.__obj:WriteFloat(num) end

	function META:ReadDouble() return self.__obj:ReadDouble() end
	function META:WriteDouble(num) return self.__obj:WriteDouble(num) end

	function META:ReadLong() return self.__obj:ReadLong() end
	function META:WriteLong(num) return self.__obj:WriteLong(num) end

	function META:ReadShort() return self.__obj:ReadShort() end
	function META:WriteShort(num) return self.__obj:WriteShort(num) end

end
