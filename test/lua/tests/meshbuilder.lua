local heightmap = Texture("http://i.imgur.com/Sc2wB.jpg")  

local model = render.CreateMeshBuilder()
model:LoadHeightmap(heightmap, nil, 256)
model:Upload()

local ent = utility.RemoveOldObject(entities.CreateEntity("visual"), "lol")
ent:SetCull(false)
ent:AddMesh(model)
ent:SetDiffuseTexture(heightmap)
print(model)      