
local size = 2048*4
local data = ffi.new("unsigned char[?]", size)

 
local effect = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
effect:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10) 
effect:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10) 
effect:BindToChannel(1)

timer.Create("um", 1,0, function()
	local um = math.randomf(-5,5) 
	for i = 0, size-1 do
		data[i] = ((128 + (math.sin((i/size)*500 + ((i/size)^um*100))*100)) * (i/size)) * 0.5
	end     
	
	local sound = Sound(data, size)
	sound:SetEffectChannel(1) 
	sound:SetPitch(1) 
	sound:Play()  
	LOL_SOUND = sound 
end) 
 