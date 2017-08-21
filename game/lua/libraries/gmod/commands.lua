commands.Add("hostname", function(line)
	network.SetHostName(line)
end)

if CLIENT then
	commands.Add("lua_openscript_cl", function(line)
		gine.env.include("lua/" .. line)
	end)
end

if SERVER then
	commands.Add("lua_openscript", function(line)
		gine.env.include("lua/" .. line)
	end)
end