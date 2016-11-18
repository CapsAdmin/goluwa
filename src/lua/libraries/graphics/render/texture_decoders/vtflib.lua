local vl = desire("VTFLib")

if not vl then return end

vl.Initialize()

render.AddTextureDecoder("vtflib", function(data, path_hint)
	return vl.LoadImage(data, path_hint)
end)