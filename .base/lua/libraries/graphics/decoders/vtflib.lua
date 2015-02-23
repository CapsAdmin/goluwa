local vl = require("lj-vtflib") -- HLLib

render.AddTextureDecoder("vtflib", function(data, path_hint)
	local buffer, w, h, format = vl.LoadImage(data)
	
	if format == vl.e.IMAGE_FORMAT_RGBA8888 then
		format = "rgba"
	else
		format = "rgb"
	end
		
	return buffer, w, h, {format = {upload_format = format, internal_format = format.."8", mip_map_levels = 8}}
end)