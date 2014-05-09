include("libraries/decoder.lua")

render.AddTextureDecoder("ffmpeg", function(data, path_hint)
	local ext = path_hint:match(".+%.(.+)")
	local decoder = assert(ffmpeg.Open(data, {video_only = true, file_ext = ext})) 
	return  decoder:Read(), decoder:GetConfig().width, decoder:GetConfig().height
end)