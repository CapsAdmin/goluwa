entities.Panic()


render3d.Initialize()
steam.MountSourceGame("hl2")

local list = {}

local function add_dir(dir)
	dir = "models/" .. dir
	for _, name in ipairs(vfs.Find(dir .. "/.+%.mdl")) do
		table.insert(list, dir .. "/" .. name)
	end
end

add_dir("props_junk")
add_dir("props_interiors")
add_dir("props_pipes")
--add_dir("props_c17")
--add_dir("props_foliage")
--add_dir("props_borealis")
--add_dir("props_canal")
add_dir("props_citizen_tech")

local x,y,z = 0,0,0
local spacing = 50 * steam.source2meters

local count = 20

for i = 1, 7500 do
	local path = list[1 + i%#list]
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath(path)

	x = x + spacing

	if x / spacing > count then
		x = 0
		y = y + spacing
	end

	if y / spacing > count then
		y = 0
		z = z + spacing
	end

	ent:SetPosition(Vec3(x,y,z))
end