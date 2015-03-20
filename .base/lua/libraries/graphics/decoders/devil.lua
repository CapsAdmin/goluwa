local devil = require("graphics.ffi.devil") -- image decoder 

render.AddTextureDecoder("devil", function(data, path_hint)
	return devil.LoadImage(data, path_hint and not path_hint:find(".vtf", nil, true))
end)
