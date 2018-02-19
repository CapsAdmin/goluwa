local origin = render3d.camera:GetPosition()

for i = 1, 10 do
	local body = entities.CreateEntity("physical")
	body:SetName("those boxes " .. i)

	body:SetModelPath("models/cube.obj")

	--body:SetPhysicsModelPath("models/cube.obj")
	--body:InitPhysicsTriangles()
	body:InitPhysicsBox(Vec3(1, 1, 1))


	--body:SetMass(100)
	body:SetPosition(origin + Vec3(0,0,-100+i*2))
	--body:SetVelocity(Vec3():Random(-10,10))
	body:SetAngularVelocity(Vec3():Random()*10)

	--body:SetSize(2)  -- FIX ME
end