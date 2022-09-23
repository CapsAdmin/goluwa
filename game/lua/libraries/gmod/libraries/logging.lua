local gine = ... or _G.gine

function gine.env.Msg(str)
	repl.Write(str)
end

function gine.env.MsgN(str)
	repl.Write(str)
	repl.Write("\n")
end

function gine.env.MsgC(...)
	local terminal = system.GetTerminal()

	for i = 1, select("#", ...) do
		local val = select(i, ...)

		if type(val) == "table" then
			terminal.ForegroundColor(val.r / 255, val.g / 255, val.b / 255)
		else
			repl.Write(val)
		end
	end
end

function gine.env.ErrorNoHalt(...)
	local args = {...}
	list.insert(args, 2)
	wlog(unpack(args))
end