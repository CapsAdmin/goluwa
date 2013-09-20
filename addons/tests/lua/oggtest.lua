local effect = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
effect:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10) 
effect:BindToChannel(1)

local snd = utilities.RemoveOldObject(Sound("sounds/cantina.ogg"))
table.print(snd.decode_info)
snd:Play() 
snd:SetChannel(1)
snd:SetLooping(true)
 
local snd = utilities.RemoveOldObject(Sound("sounds/what a shame.ogg"))
snd:Play() 
snd:SetGain(0.25)
snd:SetChannel(1)

timer.Create("shame", 1, 0, function()
	snd:Play()

	snd:SetPosition(math.sin(glfw.GetTime()), math.cos(glfw.GetTime()),0)
end) 