function gine.env.AddConsoleCommand(name)
	if commands.IsAdded(name) then
		llog("gmod tried to add existing command %s", name)
	else
		commands.Add(name, function(line, ...)
			gine.env.concommand.Run(NULL, name, {...}, line)
		end)
	end
end

function gine.env.RunConsoleCommand(...)
	local str = table.concat({...}, " ")
	if str:find("utime") then return end -- sigh
	logn("gine cmd: ", str)
	commands.RunCommand(...)
end

local META = gine.GetMetaTable("Player")

function META:ConCommand(str)
	logn("gine cmd: ", str)
end
