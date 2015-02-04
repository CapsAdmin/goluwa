local heightmap = Texture("textures/gui/skins/dark.png") 

local model = render.CreateMeshBuilder()
model:LoadHeightmap(heightmap)
model:Upload()

local ent = utility.RemoveOldObject(entities.CreateEntity("visual"), "lol")
ent:SetCull(false)
ent:AddMesh(model)
ent:SetDiffuseTexture(heightmap)
print(model)