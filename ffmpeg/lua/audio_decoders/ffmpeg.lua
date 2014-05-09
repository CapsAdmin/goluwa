include("libraries/decoder.lua")

audio.AddDecoder("ffmpeg", function(data, length, path_hint)
	local ext = path_hint:match(".+%.(.+)")
	local decoder = assert(ffmpeg.Open(data, {audio_only = true, file_ext = ext})) 
	local data = decoder:ReadAll()
	return data.buffer, data.length, decoder:GetInfo().audio
end)