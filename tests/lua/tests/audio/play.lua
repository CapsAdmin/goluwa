local music = utilities.RemoveOldObject(audio.CreateSource("sounds/cantina.ogg"))
music:Play() 
music:SetLooping(true)

local distortion = audio.CreateEffect("distortion")
distortion:SetParam("lowpass_cutoff", 1000)  
distortion:SetParam("gain", 1)  
music:AddEffect(distortion)  

local reverb = audio.CreateEffect("eaxreverb", {decay_time = 5, diffusion = 5, gain = 1}) -- whatever floats your boat!
music:AddEffect(reverb)

local voice = utilities.RemoveOldObject(audio.CreateSource("http://chatsoundsforgmod.googlecode.com/svn/trunk/sound/chatsounds/autoadd/deusex/what%20a%20shame.ogg"))
voice:Play() 
voice:SetGain(5)
voice.OnLoad = function(self, info) table.print(info) end

local filter = audio.CreateFilter("lowpass")
filter:SetParam("gainhf", 0.1)  
voice:SetFilter(filter)  

timer.Create("shame", 1, 0, function()
	voice:Play()
	voice:SetPosition(math.sin(timer.clock()), math.cos(timer.clock()),0)
end) 

event.AddListener("OnUpdate", "hmm", function()
	music:SetPitch(1 + math.sin(timer.clock()*10)/30)	
	reverb:SetParam("gain", math.abs(math.sin(os.clock()/10)))
end) 

