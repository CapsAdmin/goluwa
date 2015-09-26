entities.SafeRemove(LOL_PARENT)

local parent = entities.CreateEntity("visual")

LOL_PARENT = parent

parent:SetModelPath("models/cube.obj")
parent:SetPosition(render.camera_3d:GetPosition())
parent:SetAngles(Ang3(0,0,0))
parent:SetScale(Vec3(1,1,1))

do
	local parent = parent

	for i = 1, 2000 do

		local child = entities.CreateEntity("visual", parent)
		child:SetPosition(Vec3(0, 2, 0))
		child:SetAngles(Ang3(0,0,0))
		child:SetScale(Vec3(1, 1, 1))
		child:SetModelPath("models/cube.obj")

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