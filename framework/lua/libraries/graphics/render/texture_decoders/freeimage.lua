local render = ... or _G.render

local freeimage = system.GetFFIBuildLibrary("freeimage")

if not freeimage then return end

render.AddTextureDecoder("freeimage", function(data, path_hint)
	return freeimage.LoadImage(data)
end)
