local function assign(obj, props)
	for k, v in pairs(obj) do
		props[k] = v
	end

	return obj
end

local function removeNode(node)
	local parentNode = node.parentNode

	if parentNode then parentNode:removeChild(node) end
end

local function slice(arr, i)
	local ret = {}

	for j = i or 1, #arr do
		ret[#ret + 1] = arr[j]
	end

	return ret
end

return {
	assign = assign,
	removeNode = removeNode,
	slice = slice,
}