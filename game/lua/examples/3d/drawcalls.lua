render3d.Initialize()
entities.Panic()

local materials = {}
local function get_random_texture()
	return render.CreateBlankTexture(Vec2() + 32, "return vec4(random(uv*"..math.random().."), random(uv*"..math.random().."), random(uv*"..math.random().."), random(uv*"..math.random().."));")
end

for i = 1, 64 do
	local mat = render.CreateMaterial("model")

	mat:SetAlbedoTexture(get_random_texture())
	mat:SetNormalTexture(get_random_texture())
	mat:SetRoughnessTexture(get_random_texture())
	mat:SetMetallicTexture(get_random_texture())

	materials[i] = mat
end

local i = 1

for x = 0, 20 do
	for y = 0, 20 do
		for z = 0, 20 do

			local child = entities.CreateEntity("visual")
			child:SetPosition(Vec3(x, y, z)*5)
			--child:SetAngles(Ang3(0,0,0):GetRandom())
			--child:SetScale(Vec3(1, 1, 1) * math.randomf(1, 1.5))
			child:SetModelPath("models/cube.obj")
			child:SetMaterialOverride(table.random(materials))
		end
	end
end