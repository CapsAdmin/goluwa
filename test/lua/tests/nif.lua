--local file = vfs.Open(steam.GetGamePath("Skyrim") .. "/Data/Skyrim - Meshes.bsa/meshes/actors/chicken/chicken.nif")
--local file = assert(vfs.Open(steam.GetGamePath("Crysis Wars") .. "/Game/GameData.pak"))
local file = assert(vfs.Open("D:/downloads/libvlc-master.zip"))

local archive = require("ffi.libarchive")

local a = archive.read_new()
archive.read_support_filter_all(a)
archive.read_support_format_raw(a)

local function open(self, udata)
	print("open", self, udata)
	
	return 1
end

local function read(self, udata, buffer)
	local data = file:ReadBytes(1024)
	
	print("read", self, udata, buffer, #data)
		
	buffer[0] = data
			
	return #data
end

local function skip(self, udata, position)
	print("skip", self, udata, position)
	
	file:SetPosition(position)
	
	return 0
end

local function close(self, udata)
	print("close", self, udata)
	
	file:Close()
	
	return 0
end

local r = archive.read_open2(a, nil, nil, read, skip, close)
local entry = archive.entry_new2(a)

print(archive.read_next_header2(a, entry))
print(ffi.string(archive.entry_pathname(entry)), "!!")
print(archive.read_next_header2(a, entry))
--print(ffi.string(archive.entry_pathname(entry)), "!!")
--archive.read_data_skip(a)
do return end
local buffer = ffi.new("uint8_t[1024]", 0)
local size = archive.read_data(a, buffer, 1024)
print(size)

print(#ffi.string(buffer), "!?") 