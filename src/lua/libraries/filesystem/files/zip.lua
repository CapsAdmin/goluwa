if LINUX then return end

local vfs = (...) or _G.vfs

local zip = require("minizip.init")

local CONTEXT = {}

CONTEXT.Name = "zip"

local function split_path(path_info)
	local archive_path, relative = path_info.full_path:match("(.+%..-)/(.*)")

	if not archive_path and not relative then
		error("not a valid archive path", 2)
	end

	if archive_path:endswith("/") then
		archive_path = archive_path:sub(0, -2)
	end

	local temp = assert(vfs.Open("os:" .. archive_path))
	--[[local temp, err = vfs.Open("os:" .. archive_path)

	if not temp and err == "no such file exists" then
		-- WHAT ABOUT DIRECTOIRES WITH DOTS IN THEM
		archive_path, relative = path_info.full_path:match("(.-%..-)/(.*)")
		if archive_path:endswith("/") then
			archive_path = archive_path:sub(0, -2)
		end

		temp = assert(vfs.Open("os:" .. archive_path))
	else
		error(err)
	end]]

	local signature = temp:ReadBytes(4)

	if signature ~= "\x50\x4b\x03\x04" then
		temp:Close()
		error("not a valid zip file: expected signature '\x50\x4b\x03\x04' got " .. signature)
	end

	temp:Close()

	return archive_path, relative
end

function CONTEXT:IsFile(path_info)
	local archive_path, relative = split_path(path_info)

	local archive = zip.open(archive_path, "r")

	for info in archive:files() do
		if info.filename == relative then
			archive:close()
			return true
		end
	end

	archive:close()
end

function CONTEXT:IsFolder(path_info)
	local archive_path, relative = split_path(path_info)
	local archive = zip.open(archive_path, "r")

	for info in archive:files() do
		if info.filename:find(relative, nil, true) then
			archive:close()
			return true
		end
	end
	archive:close()

	return false
end

function CONTEXT:GetFiles(path_info)
	local archive_path, relative = split_path(path_info)
	local out = {}

	local archive = zip.open(archive_path, "r")

	local dir = relative:match("(.*/)")
	local done = {}

	for info in archive:files() do
		local path = info.filename

		if path:endswith("/") then
			path = path:sub(0, -2)
		end

		if path:find(relative, nil, true) and (not dir or path:match("(.*/)") == dir) then
			-- path is just . so it needs to be handled a bit different
			--print(path)
			if not dir then
				if not done[path] then
					path = path:match("(.-)/") or path
					table.insert(out, path)
					done[path] = true
				end
			else
				table.insert(out, path:match(".+/(.+)") or path)
			end
		end
	end

	archive:close()

	return out
end

function CONTEXT:Open(path_info, mode, ...)
	local archive_path, relative = split_path(path_info)
	local file

	if self:GetMode() == "read" then
		local archive = zip.open(archive_path, "r")

		local found = false
		for info in archive:files() do
			if info.filename == relative then
				found = true
				break
			end
		end

		if not found then
			archive:close()
			error("file not found in archive")
		end


		self.info = archive:get_file_info()
		archive:open_file()

		self.archive = archive
	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	return self.archive:read(bytes)
end

function CONTEXT:SetPosition(pos)
	self.archive:set_offset(math.clamp(pos, 0, self:GetSize()))
end

function CONTEXT:GetPosition()
	return self.archive:tell()
end

function CONTEXT:Close()
	self.archive:close()
	self:Remove()
end

function CONTEXT:GetSize()
	return self.info.uncompressed_size
end

function CONTEXT:GetLastModified()
	return self.info.dosDate
end

vfs.RegisterFileSystem(CONTEXT)