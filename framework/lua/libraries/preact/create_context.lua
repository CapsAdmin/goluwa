local i = 0

local function createContext(defaultValue, contextId)
	contextId = "_cC" .. i
	i = i + 1
	local context = {
		_id = contextId,
		_defaultValue = defaultValue,
	}

	function context:Consumer(props, contextValue)
		return props.children(contextValue)
	end

	function context:Provider(props)
		if self.getChildContext then return props.children end

		local subs = {}
		local ctx = {}
		ctx[contextId] = self
		self.getChildContext = function()
			return ctx
		end
		self.shouldComponentUpdate = function(_props)
			if self.props.value ~= _props.value then
				for _, v in ipairs(subs) do
					enqueueRender(v)

					break
				end
			end
		end
		self.sub = function(c)
			table.insert(subs, c)
			local old = c.componentWillUnmount
			c.componentWillUnmount = function()
				table.removevalue(subs, c)

				if old then old(c) end
			end
		end
	end

	context.Provider._contextRef = context
	context.Consumer.contextType = context
	return context
end