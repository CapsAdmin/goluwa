local function _catchError(error, vnode, oldVNode, errorInfo)
	local component
	local ctor
	local handled
	local vnode

	while vnode.parent do
		local component = vnode._component

		if component and not component._processingException then
			local ok, err = pcall(function()
				local ctor = component.constructor

				if ctor and ctor.getDerivedStateFromError ~= nil then
					component:setState(ctor:getDerivedStateFromError(error))
					handled = component._dirty
				end

				if component.componentDidCatch ~= nil then
					component:componentDidCatch(error, errorInfo or {})
					handled = component._dirty
				end -- This is an error boundary. Mark it as having bailed out, and wehter it was mid hydration
				if handled then
					component._pendingError = component -- TODO
					return
				end
			end)

			if not ok then wlog(err) end
		end
	end
end

return {_catchError = _catchError}