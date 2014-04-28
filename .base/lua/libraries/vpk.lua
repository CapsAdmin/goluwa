-- vpk reader by https://github.com/animorten

local function read_integer(file, byte_count)
	local bytes = {file:read(byte_count):byte(1, -1)}

	if #bytes < byte_count then
		return
	end

	local result = 0

	for i = 1, #bytes do
		result = result + bytes[i] * 2 ^ ((i - 1) * 8)
	end

	return result
end

local function read_string(file)
	local buffer = {}

	while true do
		local char = file:read(1)

		if char == "\0" then
			break
		elseif not char then
			return
		end

		buffer[#buffer + 1] = char
	end

	return table.concat(buffer)
end

local function iterate_strings(file)
	return function()
		local value = read_string(file)
		return value ~= "" and value or nil
	end
end

local function read_header(file)
	local header = {}

	header.signature = read_integer(file, 4)
	header.version = read_integer(file, 4)
	header.tree_length = read_integer(file, 4)

	if not header.tree_length then
		return nil, "Unexpected end-of-file"
	end

	if header.signature ~= 0x55aa1234 then
		return nil, string.format("Invalid signature 0x%.8x", header.signature)
	end

	if header.version == 2 then
		header.unknown_1 = read_integer(file, 4)
		header.footer_length = read_integer(file, 4)
		header.unknown_3 = read_integer(file, 4)
		header.unknown_4 = read_integer(file, 4)

		if not header.unknown_4 then
			return nil, "Unexpected end-of-file"
		end
	elseif header.version ~= 1 then
		return nil, string.format("Invalid version %d", header.version)
	end

	return header, "Success"
end

local function read_entry(file, extension, directory, name)
	local entry = {}

	entry.path = (directory ~= " " and directory .. "/" or "") .. (name ~= " " and name or "") .. (extension ~= " " and "." .. extension or "")

	entry.crc = read_integer(file, 4)
	entry.preload_bytes = read_integer(file, 2)
	entry.archive_index = read_integer(file, 2)
	entry.entry_offset = read_integer(file, 4)
	entry.entry_length = read_integer(file, 4)
	entry.is_file = true
	
	local terminator = read_integer(file, 2)

	if not terminator then
		return nil, "Unexpected end-of-file"
	end

	if terminator ~= 0xffff then
		return nil, string.format("Invalid entry terminator 0x%.4x", terminator)
	end

	entry.preload_offset = file:seek()

	if file:seek("cur", entry.preload_bytes) ~= entry.preload_offset + entry.preload_bytes then
		return nil, "Skipping preload data failed"
	end

	return entry, "Success"
end

local function read_tree(file)
	local tree = {}

	for extension in iterate_strings(file) do
		for directory in iterate_strings(file) do
			for name in iterate_strings(file) do
				local entry, error_message = read_entry(file, extension, directory, name)

				if not entry then
					return nil, "Parsing entry failed: " .. error_message
				end

				tree[#tree + 1] = entry
			end
			tree[#tree + 1] = {path = directory, is_dir = true}
		end
	end

	return tree, "Success"
end

local function read_footer(file)
	local footer = {}
	return footer, "Success"
end

local function read_file(file)
	local self = {}
	local error_message

	self.header, error_message = read_header(file)

	if not self.header then
		return nil, "Failed parsing header: " .. error_message
	end

	self.tree, error_message = read_tree(file)

	if not self.tree then
		return nil, "Failed parsing tree: " .. error_message
	end

	if self.header.version == 2 then
		self.footer, error_message = read_footer()

		if not self.footer then
			return nil, "Failed parsing footer: " .. error_message
		end
	end

	return self, "Success"
end

local function read_vpk_dir(path)
	check(path, "string")

	local file, error_message = io.open(path, "rb")

	if not file then
		return nil, "Failed opening VPK: " .. error_message
	end

	local self, error_message = read_file(file)
	file:close()

	if not self then
		return nil, "Failed parsing: " .. error_message
	end

	return self, "Success"
end
 
--[[local data = read_vpk_dir("G:/SteamLibrary/SteamApps/Common/GarrysMod/sourceengine/hl2_sound_vo_english_dir.vpk")
local _, data = next(data.tree)

table.print(data)

local file = io.open(("G:/SteamLibrary/SteamApps/Common/GarrysMod/sourceengine/hl2_sound_vo_english_%03d.vpk"):format(data.archive_index), "rb")
file:seek("set", data.entry_offset)
local buffer = file:read(data.entry_length)

local snd = audio.CreateSource(audio.Decode(buffer))
snd:Play()

table.print(snd.decode_info)

io.close(file)]]

event.AddListener("VFSMountFile", "vpk_mount", function(path, mount, ext)
	
	if ext == "vpk" then
		
		if mount then
			local vpk = read_vpk_dir(path)
			local base_info = lfs.attributes(path)
			local exists = {}
			
			local files = {}
			
			for k,v in pairs(vpk.tree) do
				if v.is_file then
					v.archive_path = path:gsub("_dir.vpk$", function(str) return ("_%03d.vpk"):format(v.archive_index) end)
					files[v.archive_path] = files[v.archive_path] or io.open(v.archive_path, "rb")
				end
				exists[v.path] = v
			end
			  
			vfs.Mount({
				id = path, 
				root = "",
				callback = function(type, a, b, c, d, ...)  	
					if type == "attributes" then
						local path = a
						path = path:sub(2) 
						
						if exists[path] then
							local info = exists[path]
							local out = {}
							table.merge(out, base_info)
							
							out.mode = info.is_file and "file" or info.is_dir and "directory"
							out.size = info.entry_length or 0
							
							return out
						end
					elseif type == "find" then
						local path = a
						
						path = path:sub(2) 
						path = path .. "/"

						local out = {}
	
						if path:sub(-1) == "/" then
							path = path .. "."
						end
						
						local dir = path:match("(.+)/")
							
						for k, v in pairs(vpk.tree) do
							if v.path:find(path) and v.path:match("(.+)/") == dir then
								table.insert(out, v.path:match(".+/(.+)") or v.path)
							end 
						end
						
						return out
					elseif type == "file" then
						local type = a
						
						if type == "open" then
							local path = b
							path = path:sub(2) 
							
							local data = exists[path]
							
							if not data then
								return false, "File does not exist"
							end
							
							local file = files[data.archive_path]
							file:seek("set", data.entry_offset)
							 
							return {data = data, file = file, offset = 0}
						elseif type == "seek" then
							--[[local handle = b
							local whence = c
							local offset = d 
							
							handle.offset = math.clamp(handle.offset + bytes, 0, handle.data.entry_length)]]
						elseif type == "read" then
							local handle = b
							local type = c
							local bytes = d

							if type == "bytes" then							
								if handle.offset == handle.data.entry_length then
									return
								end
							
								handle.offset = math.clamp(handle.offset + bytes, 0, handle.data.entry_length)

								local content = handle.file:read(handle.offset)
								
								return content
							end
							
							-- WIP
							-- otherwise just read everything.. 
							return handle.file:read(handle.data.entry_length)
						elseif type == "close" then
							
						end
					end
				end 
			})
		else
			vfs.Unmount({id = path})
			for k,v in pairs(files) do
				io.close(v)
			end
		end
		return true
	end
end)