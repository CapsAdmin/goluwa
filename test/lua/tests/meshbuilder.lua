local heightmap = Texture("https://github.com/meetar/heightmap-demos/raw/gh-pages/SRTM_US_scaled_1024.jpg")   

local model = render.CreateMeshBuilder()
model:LoadHeightmap(heightmap, heightmap:GetSize(), Vec2(256, 256), -100)
model:SmoothNormals()
model:Upload()

local ent = utility.RemoveOldObject(entities.CreateEntity("visual"), "lol")
ent:SetCull(false)
ent:AddMesh(model)  
ent:SetDiffuseTexture(heightmap)