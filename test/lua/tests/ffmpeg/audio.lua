local ffmpeg = require("lj-ffmpeg")

local path = R"videos/casiopea.webm"
local decoder = assert(ffmpeg.Open(path, {audio_only = true}))
local sound = audio.CreateSource()

sound:SetBufferFormat(e.AL_FORMAT_STEREO16)
sound:SetBufferCount(4)
 
local audio_data = decoder:Read(math.huge)
table.print(audio_data)
sound:FeedBuffer(audio_data[1].buffer, audio_data[1].length)

sound:Play()