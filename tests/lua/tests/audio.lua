
if false then
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
 
end
    
local distortion = audio.CreateEffect(e.AL_EFFECT_DISTORTION)
distortion:SetParam(e.AL_DISTORTION_LOWPASS_CUTOFF,1000)  
distortion:SetParam(e.AL_DISTORTION_GAIN, 1)  

local reverb = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
reverb:SetParam(e.AL_EAXREVERB_DECAY_TIME, 5)  
reverb:SetParam(e.AL_EAXREVERB_DIFFUSION, 5)  
reverb:SetParam(e.AL_EAXREVERB_GAIN, 1)  

	local music = utilities.RemoveOldObject(Sound("sounds/cantina.ogg"), "cantina")
	table.print(music.decode_info)
	music:Play() 
	music:SetLooping(true)
          
music:AddEffect(distortion)  
music:AddEffect(reverb)   

LOL = music
LOL2 = reverb
 
local voice = utilities.RemoveOldObject(Sound("sounds/what a shame.ogg"), "what a shame")
voice:Play() 
voice:SetGain(0.25)

timer.Create("shame", 1, 0, function()
	voice:Play()

	voice:SetPosition(math.sin(timer.clock()), math.cos(timer.clock()),0)
end) 

timer.Create("pitchy",0,0,function()
	music:SetPitch(1 + math.sin(timer.clock()*10)/30)
	local gain = math.abs(math.sin(os.clock()/10))
	
	--reverb:SetParam(e.AL_EAXREVERB_GAIN, gain)
end)