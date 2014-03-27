local vpk = _G.vpk or {}

function vpk.Mount(path)
	local pack = vpk.Open(path)
	  
	vfs.Mount({
		id = path, 
		root = "",
		callback = function(type, a, b, c, d, ...)  		
			if type == "find" then
				local path = a
				
				path = path:sub(2) 
				path = path .. "/"

				return pack:Find(path)
			elseif type == "file" then
				local type = a
				
				if type == "open" then
					local path = b
					path = path:sub(2) 
					
					if not pack:Exists(path) then
						return false, "File does not exist"
					end
					 
					local mode = e.HL_MODE_INVALID
						
					do -- modes
						local str = c
						str = str:lower()
						
						if str:find("w") then
							mode = bit.bor(mode, e.HL_MODE_WRITE)
						end
						
						if str:find("r") then
							mode = bit.bor(mode, e.HL_MODE_READ)
						end
					end
									
					return pack:Open(path, mode)
				elseif type == "read" then
					local handle = b
					local type = c
					local bytes = d

					if type == "bytes" then 
						local buffer, length = pack:Read(handle, bytes)
						
						if length == 0 then return end
						
						return ffi.string(buffer, length)
					end
					
					-- WIP
					-- otherwise just read everything.. 
					return pack:Read(handle)
				elseif type == "close" then
					local handle = a
					
					pack:Close(handle)
				end
			end
		end 
	})
end

function vpk.Unmount(path)
	vfs.Unmount({id = path})
end

vpk.opened = {}

local META = {}
META.__index = META

function META:__tostring()
	return ("vpk[%i]"):format(self.id)
end
 
function vpk.Open(path, mode)
	
	if vpk.opened[path] and vpk.opened[path]:IsValid() then 
		vpk.opened[path]:Remove()
	end
	
	local self = utilities.CreateBaseObject("vpk")
	
	setmetatable(self, META)
	
	path = path:lower()
	
	local type = hl.GetPackageTypeFromName(path)

	local id = ffi.new("unsigned int[1]", 0)
	hl.CreatePackage(type, id)
	self.id = id[0]
	
	hl.BindPackage(self.id)
		hl.PackageOpenFile(path, bit.bor(e.HL_MODE_READ, e.HL_MODE_VOLATILE))
	
		do -- cache all paths (this is fast anyway)
			local paths = {}
			local temp = ffi.new("char[512]")
			
			local item = hl.FolderFindFirst(hl.PackageGetRoot(), "*", e.HL_FIND_ALL)

			while item ~= nil do
				--local type = hl.ItemGetType(item)
				
				hl.ItemGetPath(item, temp, 256)
				
				local str = ffi.string(temp)
				str = str:gsub("\\", "/")
				str = str:gsub("root/", "")
				table.insert(paths, str)

				item = hl.FolderFindNext(hl.PackageGetRoot(), item, "*", e.HL_FIND_ALL)
			end
			
			if item ~= nil then
				hl.StreamClose(pSubItem) 
			end
						
			self.paths = paths
			
			local exists = {}
			
			for k,v in pairs(paths) do
				exists[v] = true
			end
			
			self.exists = exists
		end

	hl.BindPackage(0)
	
	vpk.opened[path] = self

	return self
end

function META:OnRemove()
	hl.BindPackage(self.id)
		hl.PackageClose()
		hl.DeletePackage(self.id)
--	hl.BindPackage(0)
end

function META:Find(path)
	local out = {}
	
	local dir_level = select(2, path:gsub("/", ""))
	
	for k,v in pairs(self.paths) do
		if v:find(path) and select(2, v:gsub("/", "")) == dir_level then
			table.insert(out, v)
		end 
	end
	
	return out
end

-- create a stream for the file for reading
local stream = ffi.new("void *[1]")
local size = ffi.new("unsigned int[1]")

function META:ReadEasy(path)
	hl.BindPackage(self.id)

	-- get the file we're looking for
	local file = hl.FolderGetItemByPath(hl.PackageGetRoot(), path, e.HL_FIND_ALL)
	hl.PackageCreateStream(file, stream)
	
	hl.StreamOpen(stream[0], e.HL_MODE_READ)
							
		hl.ItemGetSize(file, size) 
		
		local buffer = ffi.new("hlByte[?]", size[0])

		hl.StreamRead(stream[0], buffer, size[0])

	hl.StreamClose(file) 
	
	timer.Delay(0, function()
		hl.BindPackage(0)
	end)
	
	return buffer, size[0]
end

function META:Open(path, mode)
	-- get the file we're looking for
	local file = hl.FolderGetItemByPath(hl.PackageGetRoot(), path, e.HL_FIND_ALL)
	hl.PackageCreateStream(file, stream)
	
	hl.StreamOpen(stream[0], mode)
	
	return {file = file, stream = stream[0]}
end

function META:Read(handle, bytes)
	
	if not bytes then
		bytes = self:GetSize(handle)
	end
	
	local buffer = ffi.new("hlByte[?]", bytes)

	bytes = hl.StreamRead(handle.stream, buffer, bytes)
	
	return buffer, bytes
end

function META:GetSize(handle)
	hl.ItemGetSize(handle.file, size) 
	return size[0]
end

function META:Seek(handle, offset, mode)
	mode = mode or e.HL_SEEK_CURRENT
	return hl.StreamSeekEx(handle.stream, offset, mode)
end

function META:Close(handle)
	hl.StreamClose(handle.file) 
end

function META:Exists(path)
	return self.exists[path:lower()]
end

_G.vpk = vpk