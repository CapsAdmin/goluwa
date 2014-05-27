local freeimage = require("lj-freeimage") -- image decoder 

render.AddTextureDecoder("freeimage", function(data, path_hint)
	return freeimage.LoadImage(data)
end)
