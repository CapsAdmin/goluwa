entities.Panic()

render3d.camera:SetPosition(Vec3(-0.8, 5, 4))
--render3d.camera:SetAngles(Ang3(1.0157809257507, -0.41439121961594, 0))

--local world = entities.CreateEntity("world")
--world:SetSunAngles(Ang3(-0.5, -2.5, 0))
--world:GetChildren()[1]:SetShadow(false)
--world:GetChildren()[1]:SetIntensity(1)

local max = 20

local light = entities.CreateEntity("light")
light:SetSize(500)
light:SetIntensity(1)
light:SetPosition(Vec3(3.5,3.5,50))

local materials = {}
local dir = "/media/caps/2E7ED3C27ED3814F/Program Files/Marmoset Toolbag 2/data/mat/textures/"

for _, file_name in pairs(vfs.Find(dir)) do
	local name = file_name:match("(.+)_")
	local type = file_name:match(".+_(.+)%.")

	materials[name] = materials[name]  or {}
	materials[name][type] = dir .. file_name
end

for x = 0, max-1 do
for y = max-1, 0, -1 do
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath("models/sphere.obj")
	ent:SetPosition(Vec3():GetRandom(-0.2,0.2) + Vec3(x, y, 0)/1.8)
	ent:SetSize(0.06 * math.randomf(1,1.45))
	ent:SetAngles(Ang3(90,0,0):GetRandom())


	local mat = render.CreateMaterial("model")

	local info = table.random(materials)

	--mat:SetAlbedoTexture(render.GetWhiteTexture() or render.CreateBlankTexture(Vec2(1,1)):Fill(function() return math.random(255), math.random(255), math.random(255), 255 end) or render.CreateTextureFromPath("sponza/textures_pbr/Sponza_Ceiling_diffuse.tga"))
	if info.d then mat:SetAlbedoTexture(render.CreateTextureFromPath(info.d)) end
	if info.n or info.nd then mat:SetNormalTexture(render.CreateTextureFromPath(info.n or info.nd, false)) end
	if info.s then mat:SetRoughnessTexture(render.CreateTextureFromPath(info.s, false)) end
	if info.g then mat:SetMetallicTexture(render.CreateTextureFromPath(info.g, false)) end
	mat:SetFlipYNormal(true)
	ent:SetUVMultiplier(4)
	--mat:SetRoughnessMultiplier(y/max)
	--mat:SetMetallicMultiplier(x/max)

	ent:SetMaterialOverride(mat)
end
end