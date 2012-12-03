local ErrorNoHalt = print -- for now

events = events or {} local events = events

EVENT_DESTROY = "??|___EVENT_DESTROY___|??" -- unique what

events.active = {}
events.errors = {}
events.profil = {}
events.destroy_tag = EVENT_DESTROY

events.profiler_enabled = false

function events.AddListener(a, b, c, d, e)
	local type_, unique, func, on_error, priority

	if type(a) == "table" and type(b) == "string" then
		type_ = b
		unique = tostring(a)
		func = a[b]
	elseif type(a) == "string" and b and type(c) == "function" then
		type_ = a
		unique = b
		func = c
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
	check(func, "function")

	events.Remove(type_, unique)
	
	events.active[type_] = events.active[type_] or {}
	table.insert(
		events.active[type_],
		{
			func = func,
			on_error = on_error,
			priority = priority or 0,
			unique = unique,
		}
	)
	
	events.SortByPriority()
end

function events.RemoveListener(a, b)
	local type_, unique

	if type(a) == "table" and type(b) == "string" then
		type_ = b
		unique = tostring(a)
	elseif type(a) == "string" and b then
		type_ = a
		unique = b
	end

	if unique ~= nil and events.active[type_] then
		for key, val in pairs(events.active[type_]) do
			if unique == val.unique then
				table.remove(events.active[type_], key)
			end
		end
	else
		--print(("Tried to remove non existing event '%s:%s'"):format(event, tostring(unique)))
	end
	
	events.SortByPriority()
end

function events.SortByPriority()
	for key, tbl in pairs(events.GetTable()) do
		table.sort(tbl, function(a, b) return a.priority > b.priority end)
	end
end

function events.GetTable()
	return events.active
end


local status, a,b,c,d,e,f,g,h
local time = 0

function events.UserDataCall(udata, type_, ...)	
	if udata:IsValid() then
		local func = udata[type_]
		
		
		if type(func) == "function" then
			local args = {pcall(func, udata, ...)}
			if args[1] then
				table.remove(args, 1)
				return unpack(args)
			else
				if hasindex(udata) and udata.Type and udata.ClassName then
					printf("scripted class %s %q errored: %s", udata.Type, udata.ClassName, args[2])
				else
					printf(args[2])
				end
			end
		end
	end
end

local _event
local _unique
local function OnError(msg)
	MsgN("== EVENT ERROR ==")
	
	for k, v in pairs(debug.traceback():Explode("\n")) do
		local source, msg = v:match("(.+): in function (.+)")
		if source and msg then
			MsgN((k-1) .. "    " .. source:trim() or "nil")
			MsgN("     " .. msg:trim() or "nil")
			MsgN("")
		end
	end
	

	MsgN("")
	local source, msg = msg:match("(.+): (.+)")
	MsgN(source:trim())
	MsgN(msg:trim())
	
	MsgN("")
end

local unique

function events.Call(type, ...)
	if events.active[type] then
		for key, data in ipairs(events.active[type]) do
			if events.profiler_enabled == true then
				events.profil[type] = events.profil[type] or {}
				events.profil[type][data.unique] = events.profil[type][data.unique] or {}

				time = SysTime()
			end

			status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or OnError, ...)

			if a == events.destroy_tag then
				events.Remove(type, data.unique)
				break
			end

			if events.profiler_enabled == true then
				events.profil[type][data.unique].time = (events.profil[type][data.unique].time or 0) + (SysTime() - time)
				events.profil[type][data.unique].count = (events.profil[type][data.unique].count or 0) + 1
			end

			if status == false then		
				if type(data.on_error) == "function" then
					data.on_error(a, type, data.unique)
				else
					events.Remove(type, data.unique)
					printf("event [%q][%q] removed", type, data.unique)
				end

				events.errors[type] = events.errors[type] or {}
				table.insert(events.errors[type], {unique = data.unique, error = a, time = os.date("*t")})
			end

			if a ~= nil then
				return a,b,c,d,e,f,g,h
			end

		end
	end
end

function events.GetErrorHistory()
	return events.errors
end

function events.GetProfilerHistory()
	local new = {}

	for type, event in pairs(events.profil) do
		for unique, _data in pairs(event) do
			if table.Count(_data) ~= 0 and _data.time ~= 0 and _data.count ~= 0 then
				local data = {}

				data.event = type
				data.average =  math.Round((_data.time / _data.count) * 1000, 9)
				local info = debug.getinfo(event.GetTable()[type][unique].func)
				data.event = type
				data.source = info.short_src:gsub("\\", "/")
				data.line_defined = info.linedefined
				data.times_ran = _data.count

				if data.average ~= 0 then
					table.insert(new, data)
				end
			end
		end
	end

	table.SortByMember(new, "average")

	return new
end

function events.SetProfiler(bool)
	check(bool, "boolean")

	events.profiler_enabled = bool
end

function events.DisableAll()
	if events.enabled == false then
		ErrorNoHalt("Hooks are already disabled.")
	else
		events.enabled = true
		events.__backup_events = table.Copy(events.GetTable())
		table.Empty(events.GetTable())
	end
end

function events.EnableAll()
	if events.enabled == true then
		ErrorNoHalt("Hooks are already enabled.")
	else
		events.enabled = false
		table.Merge( events.GetTable(), events.__backup_events )
		events.__backup_events = nil
	end
end

function events.Dump()
	local h=0
	for k,v in pairs(events.GetTable()) do
		Msg("> "..k.." ("..table.Count(v).." events):\n")
		for name,data in pairs(v) do
			h=h+1
			Msg("   \""..name.."\" \t "..tostring(debug.getinfo(data.func).source)..":")
			Msg(" Line:"..tostring(debug.getinfo(data.func).linedefined)..'\n')
		end
		Msg"\n"
	end
	Msg("\n>>> Total events: "..h..".\n")
end

-- ...
hook = events
hook.Remove = events.RemoveListener
hook.Add = events.AddListener