render.AddTextureDecoder("vtflib", function(data, path_hint)
	return vl.LoadImage(data)
end)