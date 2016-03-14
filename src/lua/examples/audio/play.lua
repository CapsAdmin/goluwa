local music = audio.CreateSource("sounds/cantina.ogg")
music:Play()
music:SetLooping(true)

local distortion = audio.CreateEffect("distortion")
distortion:SetParam("lowpass_cutoff", 1000)
distortion:SetParam("gain", 1)
music:AddEffect(distortion)

local reverb = audio.CreateEffect("eaxreverb", {decay_time = 5, diffusion = 5, gain = 1}) -- whatever floats your boat!
music:AddEffect(reverb)

local voice = audio.CreateSource("http://chatsoundsforgmod.googlecode.com/svn/trunk/sound/chatsounds/autoadd/deusex/what%20a%20shame.ogg")
voice:Play()
voice:SetGain(5)
voice.OnLoad = function(self, info) table.print(info) end

local filter = audio.CreateFilter("lowpass")
filter:SetParam("gainhf", 0.1)
voice:SetFilter(filter)

event.AddListener("Update", "hmm", function()
	local time = system.GetTime()

	voice:SetPosition(math.sin(time), math.cos(time),0)
	music:SetPitch(1 + math.sin(time*10)/30)
	reverb:SetParam("gain", math.abs(math.sin(os.clock()/10)))
end)
