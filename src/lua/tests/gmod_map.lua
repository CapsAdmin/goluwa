local glua = [[
	local luadata = pac.luadata
	local data = {}

	for i, ent in pairs(ents.GetAll()) do
		local mdl = ent:GetModel()

		if mdl and (mdl:find(".mdl", nil, true) or mdl:find(".bsp", nil, true)) and not ent:GetParent():IsPlayer() and not ent:IsPlayer() and ent:GetColor().a > 0 and ent:GetModelScale() and ent:GetModelScale() > 0 then
			table.insert(data, {
				pos = ent:GetPos(),
				ang = ent:GetAngles(),
				mdl = mdl,
				size = ent:GetModelScale(),
				color = ent:GetColor(),
				mat = ent:GetMaterial(),
			})
		end
	end

	luadata.WriteFile("map.txt", data)
]]

vfs.Write(steam.GetGamePath("GarrysMod") .. "garrysmod/lua/goluwa_map.lua", glua)

console.RunString("mount gmod")
console.RunString("mount hl2")
console.RunString("mount css")
console.RunString("mount tf2")
render.InitializeGBuffer()

entities.Panic()

local ent = entities.CreateEntity("visual", entities.GetWorld())
ent:SetModelPath("models/sprops/trans/wheel_b/t_wheel35.mdl")
ent:SetAngles(Deg3(39.990, 0.000, -90.000))

--render.camera_3d:SetAngles(Ang3(0,0,0))
do return end

local data = vfs.Read("data/map.txt")
data = data:gsub("Vector%(", "Vec3(")
data = data:gsub("Angle%(", "Ang3(")
data = serializer.Decode("luadata", data)

for k,v in pairs(data) do
	if v.pos:Distance(Vec3(-8785.78125, 242.22570800781, 699.27935791016)) < 500 or v.mdl:find("bsp") then

	if v.mdl:find("t_wheel35") then
		print(v.ang)
	end

	local ent = entities.CreateEntity("visual", entities.GetWorld())
	ent:SetModelPath(v.mdl)
	ent:SetPosition(v.pos * 0.0254)
	if ent.rotation_init then
		--v.ang.x = -v.ang.x
		ent:SetAngles((v.ang:GetRad() + ent.rotation_init):Normalize())
	else
		ent:SetAngles(v.ang:GetRad())
	end
	--print(v.mdl)
--	if v.mdl:find("owata_oke") then debug.logcalls(true) end
	--print("yes!")

	if v.mdl:find("%.bsp") then
		ent:SetCull(false)
	end


	if v.mat and v.mat ~= "" then
		local mat = render.CreateMaterial("model")
		steam.LoadMaterial("materials/" .. v.mat .. ".vmt", mat)

		v.color = v.color / 255
		v.color.a = (v.color.a / 255) ^ 0.2

		mat:SetColor(v.color)

		if v.color.a < 1 then
			mat:SetTranslucent(true)
		end
		ent:SetMaterialOverride(mat)
	end
	ent:SetSize(v.size)

	end
end