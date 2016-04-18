entities.SafeRemove(LOL_PARENT)

local parent = entities.CreateEntity("visual")

LOL_PARENT = parent

parent:SetModelPath("models/cube.obj")
parent:SetPosition(render.camera_3d:GetPosition())
parent:SetAngles(Ang3(0,0,0))
parent:SetScale(Vec3(1,1,1))

commands.RunString("mount gmod")

local materials = {}

for i = 1, 50 do
	materials[i] = render.CreateBlankTexture(Vec2() + 32, "return vec4(random(uv*1), random(uv*2), random(uv*3), random(uv*4));")
end


do
	local parent = parent

	for i = 1, 20000 do

		local child = entities.CreateEntity("visual", parent)
		child:SetPosition(Vec3(0, 2, 0))
		child:SetAngles(Ang3(0,0,0))
		child:SetScale(Vec3(1, 1, 1))
		child:SetModelPath("models/cube.obj")

		local mat = render.CreateMaterial("model")

		mat:SetAlbedoTexture(table.random(materials))
		mat:SetNormalTexture(table.random(materials))
		mat:SetRoughnessTexture(table.random(materials))
		mat:SetMetallicTexture(table.random(materials))

		child:SetMaterialOverride(mat)


		parent = child
	end
end
do return end
local start = system.GetElapsedTime()

parent:BuildChildrenList()

event.AddListener("Update", "lol", function()
	local t = (system.GetElapsedTime() - start) / 10

	for i, child in ipairs(parent:GetChildrenList()) do
		child:SetAngles(Ang3(t,t,-t))
		t = t * 1.001
	end

end, {priority = -19})