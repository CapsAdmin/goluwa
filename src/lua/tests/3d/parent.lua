entities.SafeRemove(LOL_PARENT)

local parent = entities.CreateEntity("visual")

LOL_PARENT = parent

parent:SetModelPath("models/cube.obj")
parent:SetPosition(render.camera_3d:GetPosition())
parent:SetAngles(Ang3(0,0,0))
parent:SetScale(Vec3(1,1,1))


local materials = {}
local dir = "C:/Program Files/Marmoset Toolbag 2/data/mat/textures/"

for _, file_name in pairs(vfs.Find(dir)) do
	local name = file_name:match("(.+)_")
	local type = file_name:match(".+_(.+)%.")

	materials[name] = materials[name]  or {}
	materials[name][type] = dir .. file_name
end


do
	local parent = parent

	for i = 1, 4000 do

		local child = entities.CreateEntity("visual", parent)
		child:SetPosition(Vec3(0, 2, 0))
		child:SetAngles(Ang3(0,0,0))
		child:SetScale(Vec3(1, 1, 1))
		child:SetModelPath("models/cube.obj")


		local mat = render.CreateMaterial("model")

		local info = table.random(materials)

		--mat:SetAlbedoTexture(render.GetWhiteTexture() or Texture(1,1):Fill(function() return math.random(255), math.random(255), math.random(255), 255 end) or Texture("sponza/textures_pbr/Sponza_Ceiling_diffuse.tga"))
		mat:SetAlbedoTexture(Texture(info.d))
		mat:SetNormalTexture(Texture(info.n))
		mat:SetRoughnessTexture(Texture(info.s))
		mat:SetMetallicTexture(Texture(info.g))

		--mat:SetRoughnessMultiplier(y/max)
		--mat:SetMetallicMultiplier(x/max)

		child:SetMaterialOverride(mat)


		parent = child
	end
end

local start = system.GetElapsedTime()

parent:BuildChildrenList()

event.AddListener("Update", "lol", function()
	local t = (system.GetElapsedTime() - start) / 10

	for i, child in ipairs(parent:GetChildrenList()) do
		child:SetAngles(Ang3(t,t,-t))
		t = t * 1.001
	end

end, {priority = -19})