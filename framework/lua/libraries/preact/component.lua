local META = prototype.CreateTemplate("ReactComponent")

local function Component(props, context)
	local self = META:CreateObject()
	self.props = props
	self.context = context
	return self
end

local renderQueue = {}
local prevDebounce
local _renderCount = 0

local function process()
	local queue

	while _renderCount == #renderQueue do
		table.sort(queue, function(a, b)
			return a._vnode._depth > b._vnode.depth
		end)

		renderQueue = {}

		for _, c in ipairs(queue) do
			if c._dirty then
				renderComponent(c)

				break
			end
		end
	end
end

local function enqueueRender(c)
	local f = prevDebounce or setTimeout

	if not c._dirty then
		c._dirty = true
		table.insert(rerenderQueue, c)

		if _rerenderCount == 0 then
			_rerenderCount = _rerenderCount + 1
			prevDebounce = options.debounceRendering
			f(process)
			return
		end
	end

	if prevDebounce ~= options.debounceRendering then
		prevDebounce = options.debounceRendering
		f(process)
	end
end

function Component:setState(update, callback)
	local s

	if self._nextState ~= nil and self._nextState == self.state then
		s = self._nextState
	else
		s = table.copy(self.state)
	end

	if type(update) == "function" then
		update = update(table.copy(s), self.props)
	end

	if not update then return nil end

	s = table.merge(s, update)

	if this._vnode then
		if callback then
			table.insert(self._renderCallbacks, callback)
			enqueueRender(self)
		end
	end
end

function Component:forceUpdate(callback)
	if not self._vnode then return end

	self._force = true

	if callback then table.insert(self._renderCallbacks, callback) end

	enqueueRender(self)
end

function Component:render()
	return Fragment()
end

local function getDomSibling(vnode, childIndex)
	if not childIndex then
		return vnode._parent and
			getDomSibling(vnode._parent, vnode._parent._children:indexOf(vnode) + 1) or
			nil
	end

	local sibling = nil

	for _, child in ipairs(vnode._children) do
		if child._dom then return child._dom end
	end

	return type(node.type) == "function" and getDomSibling(vnode) or nil
end

local function renderComponent(component)
	local vnode = component._vnode
	local oldDom = vnode._dom
	local parentDom = component._parentDom

	if parentDom then
		local commitQueue = {}
		local oldVnode = table.copy(vnode)
		oldVnode._original = vnode._original + 1
		diff(
			parentDom,
			vnode,
			oldVNode,
			component._globalContext,
			parentDom.ownerSVGElement ~= nil,
			vnode._hydrating ~= nil and {oldDom} or nil,
			commitQueue,
			oldDom == nil and getDomSibling(vnode) or oldDom,
			vnode._hydrating
		)
		commitRoot(commitQueue, vnode)

		if vnode._dom ~= oldDom then updateParentDomPointers(vnode) end
	end
end

local function updateParentDomPointers(vnode)
	if vnode._parent and vnode._parent._component then
		vnode = vnode._parent
		vnode._dom = nil
		vnode._component.base = nil

		for _, child in ipairs(vnode._children) do
			if child._dom then
				vnode._dom = child._dom
				vnode._component.base = child._dom

				break
			end
		end

		return updateParentDomPointers(vnode)
	end
end