for k,v in pairs(entities.GetAll()) do v:Remove() end

render.camera_3d:SetPosition(Vec3(3.8325955867767, 0.8530580997467, 0.19071032106876))
render.camera_3d:SetAngles(Ang3(-0.048060033470392, -2.5193500518799, 0))

local ent = entities.CreateEntity("group")
ent:SetStorableTable({children = {
	{
		children = {},
		self = {
			Name = "",
			GUID = "579e74c3cbf8080621e02b6f9e79c0",
		},
		components = {
			transform = {
				Scale = Vec3(1.000000, 1.000000, 1.000000),
				Rotation = Quat(0.000000, 0.000000, 0.000000, 1.000000),
				Position = Vec3(3.209000, 0.004000, 0.373000),
				Shear = Vec3(0.000000, 0.000000, 0.000000),
				Size = 2,
				GUID = "3bcab96434835c018306186ed35100",
				SkipRebuild = false,
			},
			light = {
				NearZ = 1,
				ShadowCubemap = false,
				Intensity = 1.02,
				FarZ = 32000,
				ProjectFromCamera = false,
				OrthoSize = 0,
				AmbientColor = Color(0.000000, 0.000000, 0.000000, 0.000000),
				FOV = 90,
				ShadowSize = 1024,
				Color = Color(1.000000, 0.530000, 0.000000, 0.000000),
				LensFlare = false,
				GUID = "823f7353bcfe9007283e4981d94b80",
				Shadow = false,
			},
			network = {
				Name = "network",
				GUID = "4dde23205f8b4406c745f9216e2d40",
			},
		},
		config = "light",
	},
	{
		children = {},
		self = {
			Name = "",
			GUID = "16659c5397e7ea0bdab39583f87400",
		},
		components = {
			transform = {
				Scale = Vec3(1.000000, 1.000000, 1.000000),
				Rotation = Quat(0.000000, 0.000000, 0.000000, 1.000000),
				Position = Vec3(6.458000, 1.990000, 3.973000),
				Shear = Vec3(0.000000, 0.000000, 0.000000),
				Size = 30,
				GUID = "6e90bf0d815bdc0a02dca61df5fa00",
				SkipRebuild = false,
			},
			light = {
				NearZ = 1,
				ShadowCubemap = false,
				Intensity = 3.1,
				FarZ = 32000,
				ProjectFromCamera = false,
				OrthoSize = 0,
				AmbientColor = Color(0.000000, 0.000000, 0.000000, 0.000000),
				FOV = 90,
				ShadowSize = 1024,
				Color = Color(1.000000, 1.000000, 1.000000, 0.000000),
				LensFlare = false,
				GUID = "d1b5d557112db8041b65431e278400",
				Shadow = false,
			},
			network = {
				Name = "network",
				GUID = "27c65e3160511807f52b88954f95c0",
			},
		},
		config = "light",
	},
	{
		children = {},
		self = {
			Name = "",
			GUID = "82c80b328a5510021bb66bb03aee60",
		},
		components = {
			transform = {
				Scale = Vec3(1.000000, 1.000000, 1.000000),
				Rotation = Quat(0.000000, 0.000000, 0.000000, 1.000000),
				Position = Vec3(2.000000, 0.000000, 0.000000),
				Shear = Vec3(0.000000, 0.000000, 0.000000),
				Size = 0.05,
				GUID = "da69778bec9dd00c4144760963f480",
				SkipRebuild = false,
			},
			model = {
				BBMin = Vec3(-19.993124, -130.268967, -47.208714),
				BBMax = Vec3(12.520315, 25.837120, 18.778801),
				ModelPath = "models/cerebus/Cerberus_LP.FBX",
				Cull = false,
				GUID = "6b5a156c5e99f801d88544f94690a0",
			},
			network = {
				Name = "network",
				GUID = "5dd0037c0d45448ce97d30bbe6480",
			},
		},
		config = "visual",
	},
	{
		children = {},
		self = {
			Name = "",
			GUID = "579e74c3cbf8080621e02b6f9e79c0",
		},
		components = {
			transform = {
				Scale = Vec3(1.000000, 1.000000, 1.000000),
				Rotation = Quat(0.000000, 0.000000, 0.000000, 1.000000),
				Position = Vec3(3.186000, 0.205397, 0.054610),
				Shear = Vec3(0.000000, 0.000000, 0.000000),
				Size = 2,
				GUID = "3bcab96434835c018306186ed35100",
				SkipRebuild = false,
			},
			light = {
				NearZ = 1,
				ShadowCubemap = false,
				Intensity = 1.02,
				FarZ = 32000,
				ProjectFromCamera = false,
				OrthoSize = 0,
				AmbientColor = Color(0.000000, 0.000000, 0.000000, 0.000000),
				FOV = 90,
				ShadowSize = 1024,
				Color = Color(1.000000, 0.530000, 0.000000, 0.000000),
				LensFlare = false,
				GUID = "823f7353bcfe9007283e4981d94b80",
				Shadow = false,
			},
			network = {
				Name = "network",
				GUID = "4dde23205f8b4406c745f9216e2d40",
			},
		},
		config = "light",
	},
	{
		children = {},
		self = {
			Name = "",
			GUID = "579e74c3cbf8080621e02b6f9e79c0",
		},
		components = {
			transform = {
				Scale = Vec3(1.000000, 1.000000, 1.000000),
				Rotation = Quat(0.000000, 0.000000, 0.000000, 1.000000),
				Position = Vec3(3.195611, -0.205639, 0.043706),
				Shear = Vec3(0.000000, 0.000000, 0.000000),
				Size = 2,
				GUID = "3bcab96434835c018306186ed35100",
				SkipRebuild = false,
			},
			light = {
				NearZ = 1,
				ShadowCubemap = false,
				Intensity = 1.02,
				FarZ = 32000,
				ProjectFromCamera = false,
				OrthoSize = 0,
				AmbientColor = Color(0.000000, 0.000000, 0.000000, 0.000000),
				FOV = 90,
				ShadowSize = 1024,
				Color = Color(1.000000, 0.530000, 0.000000, 0.000000),
				LensFlare = false,
				GUID = "823f7353bcfe9007283e4981d94b80",
				Shadow = false,
			},
			network = {
				Name = "network",
				GUID = "4dde23205f8b4406c745f9216e2d40",
			},
		},
		config = "light",
	},
	{
		children = {},
		self = {
			Name = "",
			GUID = "9f12056f893d9001cd10c83e98f3e0",
		},
		components = {
			transform = {
				Scale = Vec3(1.000000, 1.000000, 1.000000),
				Rotation = Quat(0.000000, 0.000000, 0.000000, 1.000000),
				Position = Vec3(-1.006920, 4.538877, 3.987376),
				Shear = Vec3(0.000000, 0.000000, 0.000000),
				Size = 60,
				GUID = "c013d3d3f6b8d8057f2c109f629800",
				SkipRebuild = false,
			},
			light = {
				NearZ = 1,
				ShadowCubemap = false,
				Intensity = 2.66,
				FarZ = 32000,
				ProjectFromCamera = false,
				OrthoSize = 0,
				AmbientColor = Color(0.000000, 0.000000, 0.000000, 0.000000),
				FOV = 90,
				ShadowSize = 1024,
				Color = Color(1.000000, 1.000000, 1.000000, 0.000000),
				LensFlare = false,
				GUID = "7758c5792b4b240cb9a6fe60650880",
				Shadow = false,
			},
			network = {
				Name = "network",
				GUID = "7ed7e7e3012e380bb50e4ee1a07800",
			},
		},
		config = "light",
	},
},
self = {
	Name = "",
	GUID = "861eddca0ccfd8070b3e127f6b6680",
},
components = {},
config = "group",
})

for _,ent in pairs(ent:GetChildren()) do
	if ent.config == "visual" then
		local mat = render.CreateMaterial("model")
		mat:SetDiffuseTexture(Texture("textures/Cerberus_A.tga"))
		mat:SetNormalTexture(Texture("textures/Cerberus_N.tga")) 
		mat:SetRoughnessTexture(Texture("textures/Cerberus_R.tga"))
		mat:SetMetallicTexture(Texture("textures/Cerberus_M.tga"))
		mat:SetMetallicMultiplier(1)
		mat:SetRoughnessMultiplier(1)
		mat:SetFlipYNormal(true)

		ent:SetMaterialOverride(mat)
	end
end