commands.Add("hostname", function(line)
	network.SetHostName(line)
end)

if CLIENT then
	commands.Add("lua_openscript_cl", function(line)
		gine.env.include("lua/" .. line)
	end)

	pvars.Setup("volume", 1, function(val)
		audio.SetListenerGain(val)
	end)
end

if SERVER then
	commands.Add("lua_openscript", function(line)
		gine.env.include("lua/" .. line)
	end)
end