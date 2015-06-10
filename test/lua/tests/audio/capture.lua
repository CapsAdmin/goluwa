debug.loglibrary("al", {"GenBuffers", "GenSources", "GetError"}, true)
debug.loglibrary("alc", {"GenBuffers", "GenSources", "GetError"}, true)

local mic_out = utility.RemoveOldObject(audio.CreateSource())

local mic_in = audio.CreateAudioCapture()
mic_in:Start()  
mic_in:FeedSource(mic_out)

function mic_in:OnBufferData(data, size)
	for i = 0, size - 1 do
		-- ??
	end
end

mic_out:Play()

event.Delay(0.1, function()

debug.loglibrary("al")
debug.loglibrary("alc")
 
end) 