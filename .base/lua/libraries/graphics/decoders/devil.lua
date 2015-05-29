local devil = desire("graphics.ffi.devil") -- image decoder 

if not devil then return end

render.AddTextureDecoder("devil", function(data, path_hint)
	return devil.LoadImage(data, path_hint and not path_hint:find(".vtf", nil, true))
end)
