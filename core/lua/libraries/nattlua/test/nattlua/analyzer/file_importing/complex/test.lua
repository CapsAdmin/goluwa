local types = {}
types.val = 4

function types.get()
	return types.val
end

function types.init()
	types.val = 10
end

return types
