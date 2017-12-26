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

	pvars.Setup("snd_mute_losefocus", 0, function(val)

	end)

	pvars.Setup("cl_timeout", 30, function(val)

	end)

	pvars.Setup("r_radiosity", 0, function(val)

	end)

	pvars.Setup("developer", 0, function(val)

	end)
end

if SERVER then
	commands.Add("lua_openscript", function(line)
		gine.env.include("lua/" .. line)
	end)
end