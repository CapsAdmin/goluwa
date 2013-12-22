for k,v in pairs(render) do	
	if k:sub(0,6) == "Create" then
		local name = k:sub(7)
		_G[name] = render["Create" .. name]
	end
end