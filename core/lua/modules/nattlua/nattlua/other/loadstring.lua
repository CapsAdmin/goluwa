local f = _G.loadstring or _G.load
return function(str--[[#: string]], name--[[#: nil | string]])
	if _G.CompileString then
		local var = CompileString(str, name or "loadstring", false)

		if type(var) == "string" then return nil, var, 2 end

		return setfenv(var, getfenv(1))
	end

	return (f--[[# as any]])(str, name)
end
