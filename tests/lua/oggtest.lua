local effect = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
effect:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10) 


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

	voice:SetPosition(math.sin(glfw.GetTime()), math.cos(glfw.GetTime()),0)
end) 

timer.Create("pitchy",0,0,function()
	music:SetPitch(1 + math.sin(glfw.GetTime()*10)/30)
	local gain = math.abs(math.sin(os.clock()/10))
	
	effect:SetParam(e.AL_EAXREVERB_GAIN, gain)
	effect:BindToChannel(1)
end)