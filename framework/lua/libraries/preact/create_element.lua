local vnodeId = 0

local function createVNode(type, props, key, ref, original)
	-- V8 seems to be better at detecting type shapes if the object is allocated from the same call site
	-- Do not inline into createElement and coerceToVNode!
	local id = original

	if id == nil then vnodeId = vnodeId + 1 end

	local vnode = {
		type = type,
		props = props,
		key = key,
		ref = ref,
		_children = nil,
		_parent = nil,
		_depth = 0,
		_dom = nil,
		-- _nextDom must be initialized to undefined b/c it will eventually
		-- be set to dom.nextSibling which can return `null` and it is important
		-- to be able to distinguish between an uninitialized _nextDom and
		-- a _nextDom that has been set to `null`
		_nextDom--[[#: nil]],
		_component--[[#: nil]],
		_hydrating--[[#: nil]],
		constructor--[[#: nil]],
		_original--[[#: id]],
	}

	-- Only invoke the vnode hook if this was *not* a direct copy:
	if original == nil and options.vnode ~= nil then options.vnode(vnode) end

	return vnode
end

local function createElement(type_, props, ...)
	local normalizedProps = {}
	local key
	local ref
	local i

	for i in pairs(props) do
		if i == "key" then
			key = props[i]
		elseif i == "ref" then
			ref = props[i]
		else
			normalizedProps[i] = props[i]
		end
	end

	if select("#", ...) == 1 then
		normalizedProps.children = select(1, ...)
	else
		normalizedProps.children = table.pack(...)
	end

	-- TODO: indexing function
	if type(type_) == "function" and type.defaultProps ~= nil then
		for i in pairs(type_.defaultProps) do
			if normalizedProps[i] == nil then
				normalizedProps[i] = type_.defaultProps[i]
			end
		end
	end

	return createVNode(type_, normalizedProps, key, ref, nil)
end

local function createRef()
	return {
		current = nil,
	}
end

local function Fragment(props)
	return props.children
end

local function isValidElement(vnode)
	return vnode ~= nil and vnode.constructor == nil
end

return {
	createElement = createElement,
	createRef = createRef,
	Fragment = Fragment,
	isValidElement = isValidElement,
}