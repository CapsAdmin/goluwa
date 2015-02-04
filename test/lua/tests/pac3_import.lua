steam.MountSourceGame("tf2")

--local save = vfs.Read("data/pac3/finished/robots/metal slug.txt")
--local save = vfs.Read("data/pac3/finished/vehicles/hover car.txt")
--local save = vfs.Read("data/pac3/finished/vehicles/ufo.txt")
--local save = vfs.Read("data/pac3/maps/hayashi cave wip.txt")
local save = vfs.Read("data/pac3/maps/pfeifen.txt")
--local save = vfs.Read("data/pac3/maps/hayashi combine.txt") 
--local save = vfs.Read("data/remillia.txt")
save = save:gsub("Vector%(", "Vec3(")
save = save:gsub("Angle%(", "Ang3(")
local tbl = serializer.Decode("luadata", save)

local scale = 0.0254

local translate = {
	Model = "ModelPath",
	UniqueID = "GUID",
	model = "clientside",
	Material = "DiffuseTexturePath",
}

local function iterate(tbl, parent)
	local ent = entities.CreateEntity(translate[tbl.self.ClassName] or tbl.self.ClassName, parent)

	for k,v in pairs(tbl.self) do
		k = translate[k] or k
		
		if ent["Set" .. k] then
			if k == "Color" then
				v = ColorBytes(v:Unpack())
			elseif k == "Position" then
				v = v * scale
			elseif k == "Angles" then 
				v:Rad() 
			end
			ent["Set" .. k](ent, v)
		end
	end
	
	
	for k,v in pairs(tbl.children) do
		iterate(v, ent)
	end
end

if tbl.self then tbl = {tbl} end

prototype.SafeRemove(pac3_outfit)
pac3_outfit = entities.CreateEntity("visual")
pac3_outfit:SetName("pac3 outfit")
pac3_outfit:RemoveChildren()

--[[
ffi.cdef("int fastlz_decompress(const void* input, int length, void* output, int maxout);")
local decompress = ffi.load("fastlz").fastlz_decompress

local data = vfs.Read("data/advdupe2/woho.txt") 
local size = #data

local out = ffi.new("uint8_t[?]", size * 2)
logn("compression level = ", bit.rshift(data:sub(1,1):byte(), 5))
logn("compression size = ", size)
data = ffi.cast("const void *", data)
decompress(data, size, out, ffi.sizeof(out))

print(#ffi.string(out))

for k,v in pairs(vfs.Find("E:/Garrysmod Server/sigh/garrysmodw/data/permaprops/gm_endlessocean/", nil, true)) do
	local save = vfs.Read(v)
	save = save:gsub("Vector%(", "Vec3(")
	save = save:gsub("Angle%(", "Ang3(")
	local tbl = serializer.Decode("luadata", save)	
	if next(tbl) then
		local ent = entities.CreateEntity("visual", pac3_outfit)
		ent:SetColor(ColorBytes(unpack(tbl.col)))
		ent:SetModelPath(tbl.mdl)
		ent:SetAngles(tbl.ang:Rad())
		ent:SetPosition(tbl.pos * scale)
	end
end
]]

for k,v in pairs(tbl) do
	iterate(v, pac3_outfit)
end