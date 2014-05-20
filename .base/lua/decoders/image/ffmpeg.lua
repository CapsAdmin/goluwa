local ffmpeg = require("lj-ffmpeg")

render.AddTextureDecoder("ffmpeg", function(data, path_hint)
	local ext = path_hint:match(".+%.(.+)")
	local ok, decoder = ffmpeg.Open(data, {video_only = true, file_ext = ext})
	if not ok then return ok, decoder end
	return  decoder:Read(), decoder:GetConfig().width, decoder:GetConfig().height
end)