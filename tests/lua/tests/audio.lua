local mic_out = utilities.RemoveOldObject(Sound())
mic_out:SetChannel(1)

	local mic_in = audio.CreateAudioCapture()
	mic_in:Start()  
	mic_in:FeedSource(mic_out)

	function mic_in:OnBufferData(data, size)
		for i = 0, size - 1 do
			-- ??
		end
	end

mic_out:Play() 
  
local reverb = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
reverb:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10) 

local music = utilities.RemoveOldObject(Sound("sounds/cantina.ogg"))
table.print(music.decode_info)
music:Play() 
music:SetChannel(1)
music:SetLooping(true)
 
local voice = utilities.RemoveOldObject(Sound("sounds/what a shame.ogg"))
voice:Play() 
voice:SetGain(0.25)
voice:SetChannel(1)

timer.Create("shame", 1, 0, function()
	voice:Play()

	voice:SetPosition(math.sin(timer.clock()), math.cos(timer.clock()),0)
end) 

timer.Create("pitchy",0,0,function()
	music:SetPitch(1 + math.sin(timer.clock()*10)/30)
	local gain = math.abs(math.sin(os.clock()/10))
	
	reverb:SetParam(e.AL_EAXREVERB_GAIN, gain)
	reverb:BindToChannel(1)
end)