local heightmap = Texture("https://dl.dropboxusercontent.com/u/244444/heightmaps/HeightMap_Projects/HeightMap6.jpg")
local diffuse = Texture("https://dl.dropboxusercontent.com/u/244444/heightmaps/HeightMap_Projects/HeightMap_6BaseTexture.jpg")

local model = render.CreateMeshBuilder()
model:LoadHeightmap(heightmap, heightmap:GetSize()/5, Vec2(128, 128), -200)
model:SmoothNormals()
model:Upload()

local ent = utility.RemoveOldObject(entities.CreateEntity("visual"), "lol")
ent:SetCull(false)
ent:AddMesh(model)
ent:SetDiffuseTexture(diffuse)