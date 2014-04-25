local event = _G.event or {}

e.EVENT_DESTROY = "??|___EVENT_DESTROY___|??" -- unique what

event.active = {}
event.errors = {}
event.profil = {}
event.destroy_tag = e.EVENT_DESTROY

event.profiler_enabled = false

function event.AddListener(a, b, c, d, e)
	local type_, unique, func, on_error, priority, self_arg

	if type(b) == "table" and type(a) == "string" then
		type_ = a
		func = b[a]
		self_arg = b
	elseif type(a) == "string" then
		type_ = a
		func = c
	end
	
	unique = b
	
	if not unique then
		local info = debug.getinfo(3)
		if info.source:sub(1, 1) == "@" then
			unique = info.source
		else
			unique = tostring(info.func) .. info.name
		end
	end
	
	
	if type(d) == "number" then
		priority = d
	elseif type(d) == "function" then
		on_error = d
	end
	
	if type(e) == "number" then
		priority = e
	else
		priority = 0
	end
		
	check(type_, "string")
	--check(func, "function")
		
	event.RemoveListener(type_, unique)
	
	if not func then return end
	
	event.active[type_] = event.active[type_] or {}
	table.insert(
		event.active[type_],
		{
			func = func,
			on_error = on_error,
			priority = priority or 0,
			unique = unique,
			self_arg = self_arg,
		}
	)
	
	event.SortByPriority()
end

function event.RemoveListener(a, b)
	local type_, unique

	if type(b) == "table" and type(a) == "string" then
		type_ = a
		unique = tostring(b)
	elseif type(a) == "string" then
		type_ = a
		unique = b
	end

	if unique ~= nil and event.active[type_] then
		for key, val in pairs(event.active[type_]) do
			if unique == val.unique then
				event.active[type_][key] = nil
			end
		end
	else
		--logn(("Tried to remove non existing event '%s:%s'"):format(event, tostring(unique)))
	end
	
	event.SortByPriority()
end

function event.SortByPriority()
	for key, tbl in pairs(event.active) do
		local new = {}
		for k,v in pairs(tbl) do table.insert(new, v) end
		table.sort(new, function(a, b) return a.priority > b.priority end)
		event.active[key] = new
	end
end

function event.GetTable()
	return event.active
end

local status, a,b,c,d,e,f,g,h
local time = 0

function event.UserDataCall(udata, type_, ...)	
	if udata:IsValid() then
		local func = udata[type_]
		
		
		if type(func) == "function" then
			local args = {xpcall(func, system.OnError, udata, ...)}
			if args[1] then
				table.remove(args, 1)
				return unpack(args)
			else
				if hasindex(udata) and udata.Type and udata.ClassName then
					logf("scripted class %s %q errored: %s", udata.Type, udata.ClassName, args[2])
				else
					logf(args[2])
				end
			end
		end
	end
end

local _event
local _unique
local unique

function event.Call(type, ...)
	if event.debug then
		event.call_count = event.call_count or 0
		print(event.call_count, type, ...)
		event.call_count = event.call_count + 1
	end
	if event.active[type] then
		for key, data in ipairs(event.active[type]) do
			
			if data.self_arg then
				status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or system.OnError, data.self_arg, ...)
			else
				status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or system.OnError, ...)
			end
			
			if a == event.destroy_tag then
				event.RemoveListener(type, data.unique)
			else
				if status == false then		
					if _G.type(data.on_error) == "function" then
						data.on_error(a, type, data.unique)
					else
						event.RemoveListener(type, data.unique)
						logf("event [%q][%q] removed", type, data.unique)
					end

					event.errors[type] = event.errors[type] or {}
					table.insert(event.errors[type], {unique = data.unique, error = a, time = os.date("*t")})
				end

				if a ~= nil then
					return a,b,c,d,e,f,g,h
				end
			end
		end
	end
end

function event.GetErrorHistory()
	return event.errors
end

function event.DisableAll()
	if event.enabled == false then
		logn("events are already disabled.")
	else
		event.enabled = true
		event.__backup_events = table.copy(event.GetTable())
		table.empty(event.GetTable())
	end
end

function event.EnableAll()
	if event.enabled == true then
		logn("events are already enabled.")
	else
		event.enabled = false
		table.merge(event.GetTable(), event.__backup_events)
		event.__backup_events = nil
	end
end

function event.Dump()
	local h=0
	for k,v in pairs(event.GetTable()) do
		logn("> "..k.." ("..table.Count(v).." events):")
		for name,data in pairs(v) do
			h=h+1
			logn("   \""..name.."\" \t "..tostring(debug.getinfo(data.func).source)..":")
			logn(" Line:"..tostring(debug.getinfo(data.func).linedefined))
		end
		logn("")
	end
	logn("")
	logn(">>> Total events: "..h..".")
end

event.events = setmetatable({}, {
	__index = function(_, unique)
		return setmetatable({}, {
			__newindex = function(_, event_name, func)
				event.AddListener(event_name, unique, func)
			end,
		})
	end,
	__newindex = function(_, event_name, func)
		event.AddListener(event_name, nil, func)
	end,
})

return event