function gmod.env.AddConsoleCommand(name)
	commands.Add(name, function(line, ...)
		gmod.env.concommand.Run(NULL, name, {...}, line)
	end)
end

function gmod.env.RunConsoleCommand(...)
	local str = table.concat({...}, " ")
	if str:find("utime") then return end -- sigh
	logn("gmod cmd: ", str)
	commands.RunCommand(...)
end

local META = gmod.GetMetaTable("Player")

function META:ConCommand(str)
	logn("gmod cmd: ", str)
end