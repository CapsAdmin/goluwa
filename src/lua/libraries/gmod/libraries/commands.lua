function gine.env.AddConsoleCommand(name)
	if commands.IsAdded(name) then
		local found = false

		if CLIENT then
			for k,v in pairs(gine.bindings) do
				if v.cmd == name then
					found = true
				end
			end
		end

		if not found then
			wlog("gmod tried to add existing command %s", name)
		end
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
