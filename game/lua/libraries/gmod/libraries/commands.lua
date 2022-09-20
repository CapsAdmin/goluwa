function gine.env.AddConsoleCommand(name)
	if commands.IsAdded(name) then
		local found = false

		if CLIENT then
			for k, v in pairs(gine.bindings) do
				if v.cmd == name then found = true end
			end
		end

		if not found then wlog("gmod tried to add existing command %s", name, 2) end
	else
		commands.Add(name, function(line)
			line = line or ""
			gine.env.concommand.Run(NULL, name, line:split(" "), line)
		end)
	end
end

local function cmd(str)
	if str:find("utime", nil, true) then return end -- sigh
	logn("gine cmd: ", str)
	local ok, err = pcall(commands.RunCommandString, str, true)

	if not ok then logn(err) end
end

function gine.env.RunConsoleCommand(...)
	cmd(table.concat({...}, " "))
end

local META = gine.GetMetaTable("Player")

function META:ConCommand(str)
	str = str:gsub("\"", "")
	cmd(str, " ")
end