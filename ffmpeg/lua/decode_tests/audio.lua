include("libraries/decoder.lua")

local path = R"videos/casiopea.webm"
local decoder = assert(ffmpeg.Open(path, {audio_only = true})) 
local data = decoder:ReadAll()
local sound = audio.CreateSource(audio.CreateBuffer(data.buffer, data.length, e.AL_FORMAT_STEREO16))

sound:Play()