render.AddTextureDecoder("freeimage", function(data, path_hint)
	return freeimage.LoadImage(data)
end)
