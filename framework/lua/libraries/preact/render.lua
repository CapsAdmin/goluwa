local function render(vnode, parentDom, replaceNode)
	if options._root then options._root(vnode, parentDom) end

	local isHydrating = type(replaceNode) == "function"
	local oldVNode

	if not isHydrating then
		oldVNode = replaceNode and replaceNode._children or parentDom._children
	end

	vnode = createElement(Fragment, nil, {vnode})
	local lol = (not isHydrating and replaceNode) or parentDom
	lol._children = vnode
	local commitQueue = {}
	local a

	if not isHydrating and replaceNode then
		a = {replaceNode}
	elseif oldVNode then
		a = nil
	elseif parentDom.firstChild then
		a = parentDom.firstChild and table.copy(parentDom.childNodes)
	end

	local b

	if not isHydrating and replaceNode then
		a = replaceNode
	elseif oldVNode then
		a = oldVNode._dom or parentDom.firstChild
	end

	diff(
		parentDom,
		vnode,
		oldVNode or {},
		{},
		parentDom.ownerSVGElement ~= nil,
		a,
		commitQueue,
		b,
		isHydrating
	)
	commitRoot(commitQueue, vnode)
end

local function hydrate(vnode, parentDom)
	render(vnode, parentDom, hydrate)
end