local soundfile = desire("libsndfile")

if not soundfile then return end
local ffi = require("ffi")

local files = {}

local function get_file(ptr)
	return files[ffi.cast("uint32_t *", ptr)[0]]
end

local lol = function(tbl)
	for k,v in pairs(tbl) do
		tbl[k] = function(...) local ret = v(...) print(k, ":", ret, " = ", ...) return ret end
	end
	return tbl
end

local file_io_data = ffi.new("struct SF_VIRTUAL_IO[1]", {{
	get_filelen = function(udata)
		local file = get_file(udata)

		return file:GetSize()
	end,
	seek = function(pos, whence, udata)
		local file = get_file(udata)
		pos = tonumber(pos)

		if whence == 0 then -- set
			file:SetPosition(pos)
		elseif whence == 1 then -- cur
			file:SetPosition(file:GetPosition() + pos)
		elseif whence == 2 then -- end
			file:SetPosition(file:GetSize() + pos)
		end

		return file:GetPosition()
	end,
	read = function(ptr, count, udata)
		local file = get_file(udata)
		count = tonumber(count)

		if file:TheEnd() then return 0 end

		local str = file:ReadBytes(count)

		ffi.copy(ptr, str, #str)

		return #str
	end,
	write = function(ptr, count, udata)
		local file = get_file(udata)
		return file:Write(ffi.string(ptr, count))
	end,
	tell = function(udata)
		local file = get_file(udata)
		return file:GetPosition()
	end
}})

local function on_remove(file)
	table.removevalue(files, file)
end

function soundfile.OpenVFS(file, mode, info)
	table.insert(files, file)
	file.sndfile_udata = ffi.new("uint32_t[1]", #files)
	file:CallOnRemove(on_remove)
	return soundfile.OpenVirtual(file_io_data, mode, info, ffi.cast("void *", file.sndfile_udata))
end