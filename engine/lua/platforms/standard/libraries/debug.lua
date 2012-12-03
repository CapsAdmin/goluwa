function debug.trace()	
	MsgN("")
    MsgN("Trace: " )
	
	for level = 1, math.huge do
		local info = debug.getinfo(level, "Sln")
		
		if info then
			if info.what == "C" then
				MsgN(level, "\tC function")
			else
				MsgN(string.format("\t%i: Line %d\t\"%s\"\t%s", level, info.currentline, info.name or "unknown", info.short_src or ""))
			end
		else
			break
		end
    end

    MsgN("")
end

function debug.getparams(func)
    local params = {}
	
	for i = 1, math.huge do
		local key = debug.getlocal(func, i)
		if key then
			table.insert(params, key)
		else
			break
		end
	end

    return params
end