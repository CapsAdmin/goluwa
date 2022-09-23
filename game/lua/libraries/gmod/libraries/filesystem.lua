local search_paths = {
	game = "",
	workshop = "",
	lua = "lua/",
	lcl = "lua/",
	data = "os:" .. gine.dir .. "data/",
	download = "os:" .. gine.dir .. "download/",
	mod = "os:" .. gine.dir,
	base_path = "os:" .. gine.dir .. "../bin/",
}

local function resolve_path(path, where)
	if not path then error("path is nil", 3) end

	where = where or "data"
	local search_path = search_paths[where:lower()]

	if not search_path then
		wlog("%q is not a valid search path! defaulting to GAME", where)
		search_path = search_paths.game
	end

	path = search_path .. path
	return path, where
end

do
	local file = gine.env.file

	function file.Find(path, where)
		local files, folders = {}, {}
		path = path:gsub("%.", "%%.")
		path = path:gsub("%*", ".*")

		if where == "LUA" then
			for k, v in ipairs(vfs.Find("lua/" .. path, true)) do
				if gine.IsGLuaPath(v) then
					if vfs.IsDirectory(v) then
						list.insert(folders, v:match(".+/(.+)"))
					else
						list.insert(files, v:match(".+/(.+)"))
					end
				end
			end
		elseif where == "DATA" then
			for k, v in ipairs(vfs.Find("data/" .. path, true)) do
				if vfs.IsDirectory(v) then
					list.insert(folders, v:match(".+/(.+)"))
				else
					list.insert(files, v:match(".+/(.+)"))
				end
			end
		else
			for k, v in ipairs(vfs.Find(path, true)) do
				if vfs.IsDirectory(v) then
					list.insert(folders, v:match(".+/(.+)"))
				else
					list.insert(files, v:match(".+/(.+)"))
				end
			end
		end

		return files, folders
	end

	function file.Delete(path)
		vfs.Delete(search_paths.data .. path)
	end

	function file.Exists(path, where)
		path, where = resolve_path(path, where)
		return vfs.Exists(path)
	end

	function file.IsDir(path, where)
		path, where = resolve_path(path, where)
		return vfs.IsDirectory(path)
	end

	function file.Size(path, where)
		path, where = resolve_path(path, where)
		local str = vfs.Read(path)

		if str then return #str end

		return 0
	end

	function file.Time(path, where)
		path, where = resolve_path(path, where)
		return vfs.GetLastModified(path) or 0
	end

	function file.CreateDir(path, where)
		vfs.CreateDirectory(search_paths.data .. path)
	end
end

do
	function gine.env.file.Open(path, how, where)
		path, where = resolve_path(path, where)
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

	function META:Read(length)
		return self.__obj:ReadBytes(length)
	end

	function META:Write(content)
		return self.__obj:Write(content)
	end

	function META:Close()
		return self.__obj:Close()
	end

	function META:Tell()
		return tonumber(self.__obj:GetPosition())
	end

	function META:Size()
		return tonumber(self.__obj:GetSize())
	end

	function META:Skip(pos)
		return self.__obj:SetPosition(pos)
	end

	function META:Seek(pos)
		return self.__obj:SetPosition(pos)
	end

	function META:Flush()
		self.__obj:Flush()
	end

	function META:ReadLine()
		return self.__obj:ReadString(nil, nil, string.byte("\n"))
	end

	function META:ReadByte()
		return self.__obj:ReadByte()
	end

	function META:WriteByte(num)
		return self.__obj:WriteByte(num)
	end

	function META:ReadBool()
		return self.__obj:ReadBoolean()
	end

	function META:WriteBool(num)
		return self.__obj:WriteBoolean(num)
	end

	function META:ReadFloat()
		return self.__obj:ReadFloat()
	end

	function META:WriteFloat(num)
		return self.__obj:WriteFloat(num)
	end

	function META:ReadDouble()
		return self.__obj:ReadDouble()
	end

	function META:WriteDouble(num)
		return self.__obj:WriteDouble(num)
	end

	function META:ReadLong()
		return self.__obj:ReadLong()
	end

	function META:WriteLong(num)
		return self.__obj:WriteLong(num)
	end

	function META:ReadShort()
		return self.__obj:ReadShort()
	end

	function META:WriteShort(num)
		return self.__obj:WriteShort(num)
	end
end