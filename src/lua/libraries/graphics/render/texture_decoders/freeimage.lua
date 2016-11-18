local freeimage = desire("freeimage")

if not freeimage then return end

render.AddTextureDecoder("freeimage", function(data, path_hint)
	return freeimage.LoadImage(data)
end)
