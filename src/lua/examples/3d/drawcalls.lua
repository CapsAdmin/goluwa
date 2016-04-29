entities.Panic()

commands.RunString("mount gmod")

local materials = {}

for i = 1, 1 do
	materials[i] = render.CreateBlankTexture(Vec2() + 32, "return vec4(random(uv*1), random(uv*2), random(uv*3), random(uv*4));")
end


do
	local parent = parent

	for x = 0, 20 do
	for y = 0, 20 do
	for z = 0, 20 do

		local child = entities.CreateEntity("visual")
		child:SetPosition(Vec3(x, y, z)*2)
		child:SetAngles(Ang3(0,0,0))
		child:SetScale(Vec3(1, 1, 1))
		child:SetModelPath("models/cube.obj")

	--[[local light = entities.CreateEntity("light", child)
		light:SetColor(Color(1,0,0,1))
		light:SetSize(100)
		light:SetIntensity(10)]]

		--[[local mat = render.CreateMaterial("model")

		mat:SetAlbedoTexture(table.random(materials))
		mat:SetNormalTexture(table.random(materials))
		mat:SetRoughnessTexture(table.random(materials))
		mat:SetMetallicTexture(table.random(materials))

		child:SetMaterialOverride(mat)]]


		parent = child
	end
	end
	end
end
do return end

local start = system.GetElapsedTime()

parent:BuildChildrenList()

event.AddListener("Update", "lol", function()
	local t = (system.GetElapsedTime() - start) / 10

	for _, child in ipairs(parent:GetChildrenList()) do
		child:SetAngles(Ang3(t,t,-t))
		t = t * 1.001
	end

end, {priority = -19})