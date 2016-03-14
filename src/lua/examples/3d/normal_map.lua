console.RunString"mount css"

entities.Panic()

local light = entities.CreateEntity("light")
light:SetSize(10)

event.AddListener("Update", "test", function()
	light:SetPosition(render.camera_3d:GetPosition())
end)

local i = 1

local function spawn_test(path)
	local tex = Texture(path, false)

	local ent = entities.CreateEntity("visual")
	ent:SetModelPath("models/cube.obj")
	ent:SetPosition(Vec3(4*i,0,0))
	local mat = render.CreateMaterial("model")
	mat:SetAlbedoTexture(render.GetGreyTexture())
	mat:SetNormalTexture(tex)
	ent:SetMaterialOverride(mat)

	do
		local ent = entities.CreateEntity("visual")
		ent:SetModelPath("models/cube.obj")
		ent:SetPosition(Vec3(4*i,-0.75,2))
		ent:SetScale(Vec3(1,0.05,1))
		local mat = render.CreateMaterial("model")
		mat:SetAlbedoTexture(tex)
		ent:SetMaterialOverride(mat)
	end

	i = i + 1

	return mat
end

spawn_test("http://th08.deviantart.net/fs71/PRE/i/2011/280/f/f/normal_wall_1_by_dallasrobinson-d4c4yqd.png"):SetFlipYNormal(true)
spawn_test("http://read.pudn.com/downloads113/sourcecode/windows/other/471455/Normal%20mapping/test_normal_map__.jpg"):SetFlipYNormal(true)
spawn_test("https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Normal_map_example_-_Map.png/1024px-Normal_map_example_-_Map.png")
spawn_test("http://40.media.tumblr.com/00141864a3adb82557f0416f072597ad/tumblr_inline_nmf5di73iE1s90xcn_1280.png"):SetFlipYNormal(true)
spawn_test("http://ssbump-generator.yolasite.com/resources/TestBump2_normal.jpg"):SetFlipYNormal(true)
spawn_test("http://robbylamb.com/Images/Normal_Test.jpg"):SetFlipXNormal(true)


local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cube.obj")
ent:SetPosition(Vec3(0,0,0))