local freeimage = desire("graphics.ffi.freeimage") -- image decoder

render.AddTextureDecoder("freeimage", function(data, path_hint)
	local format

	if path_hint and path_hint:endswith(".dds") then
		format = freeimage.e.FIF_DDS
	end

	return freeimage.LoadImage(data, nil, format)
end)
