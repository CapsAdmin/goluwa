local surface = ...

for k,v in pairs(_G.surface) do
	surface[k] = v
end

function surface.GetTextureID(path)
	return Texture("materials/" .. path .. ".vtf")
end