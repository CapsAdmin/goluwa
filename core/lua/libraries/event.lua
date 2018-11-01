local event = _G.event or {}

event.active = event.active or {}
event.destroy_tag = {}

e.EVENT_DESTROY = event.destroy_tag

local function sort_events()
	for key, tbl in pairs(event.active) do
		local new = {}
		for _, v in pairs(tbl) do table.insert(new, v) end
		table.sort(new, function(a, b) return a.priority > b.priority end)
		event.active[key] = new
	end
end

function event.AddListener(event_type, id, callback, config)
	if type(event_type) == "table" then
		config = event_type
	end

	if not callback and type(id) == "function" then
		callback = id
		id = nil
	end

	config = config or {}

	config.event_type = config.event_type or event_type
	config.id = config.id or id
	config.callback = config.callback or callback
	config.priority = config.priority or 0

	-- useful for initialize events
	if config.id == nil then
		config.id = {}
		config.remove_after_one_call = true
	end

	config.print_str = config.event_type .. "->" .. tostring(config.id)

	event.RemoveListener(config.event_type, config.id)

	event.active[config.event_type] = event.active[config.event_type] or {}

	table.insert(event.active[config.event_type], config)

	sort_events()

	if event_type ~= "EventAdded" then
		event.Call("EventAdded", config)
	end
end

event.fix_indices = {}

function event.RemoveListener(event_type, id)

	if type(event_type) == "table" then
		id = id or event_type.id
		event_type = event_type or event_type.event_type
	end

	if id ~= nil and event.active[event_type] then

		if event_type ~= "EventRemoved" then
			event.Call("EventRemoved", event.active[event_type])
		end

		for index, val in pairs(event.active[event_type]) do
			if id == val.id then
				event.active[event_type][index] = nil

				event.fix_indices[event_type] = true

				break
			end
		end
	else
		--logn(("Tried to remove non existing event '%s:%s'"):format(event, tostring(unique)))
	end
end

function event.Call(event_type, a_, b_, c_, d_, e_)
	local status, a,b,c,d,e

	if event.active[event_type] then
		for index = 1, #event.active[event_type] do
			local data = event.active[event_type][index]
			if not data then break end

			if data.self_arg then
				if data.self_arg:IsValid() then
					if data.self_arg_with_callback then
						status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, a_, b_, c_, d_, e_)
					else
						status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, data.self_arg, a_, b_, c_, d_, e_)
					end
				else
					event.RemoveListener(event_type, data.id)

					event.active[event_type][index] = nil
					sort_events()
					llog("[%q][%q] removed because self is invalid", event_type, data.unique)
					return
				end
			else
				status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, a_, b_, c_, d_, e_)
			end
			
			if a == event.destroy_tag or data.remove_after_one_call then
				event.RemoveListener(event_type, data.id)
			else
				if status == false then
					if type(data.on_error) == "function" then
						data.on_error(a, event_type, data.id)
					else
						event.RemoveListener(event_type, data.id)
						llog("[%q][%q] removed", event_type, data.id)
					end
				end

				if a ~= nil then
					return a,b,c,d,e
				end
			end
		end
	end

	if event.fix_indices[event_type] then
		table.fixindices(event.active[event_type])
		event.fix_indices[event_type] =  nil

		sort_events()
	end
end

do -- helpers
	function event.CreateRealm(config)
		if type(config) == "string" then
			config = {id = config}
		end
		return setmetatable({}, {
			__index = function(_, key, val)
				for i, data in ipairs(event.active[key]) do
					if data.id == config.id then
						return config.callback
					end
				end
			end,
			__newindex = function(_, key, val)
				if type(val) == "function" then
					config = table.copy(config)
					config.event_type = key
					config.callback = val
					event.AddListener(config)
				elseif val == nil then
					config = table.copy(config)
					config.event_type = key
					event.RemoveListener(config)
				end
			end,
		})
	end
end

return event
