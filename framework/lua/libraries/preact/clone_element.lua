local createVNode = runfile("create_element.lua").createVNode

local function cloneElement(vnode, props, ...)
	local normalizedProps = table.copy(vnode.props)
	local key
	local ref
	local i

	for key in pairs(props) do
		if key == "key" then
			key = props[key]
		elseif key == "ref" then
			ref = props[key]
		else
			normalizedProps[key] = props[key]
		end
	end

	if select("#", ...) == 1 then
		normalizedProps.children = select(1, ...)
	else
		normalizedProps.children = table.pack(...)
	end

	return createVNode(vnode.type, normalizedProps, key or vnode.key, ref or vnode.ref)
end