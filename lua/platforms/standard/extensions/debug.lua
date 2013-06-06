function debug.trace()	
    logn("Trace: " )
	
	for level = 1, math.huge do
		local info = debug.getinfo(level, "Sln")
		
		if info then
			logf("\t%i: Line %d\t\"%s\"\t%s", level, info.currentline, info.name or "unknown", info.short_src or "")
		else
			break
		end
    end
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