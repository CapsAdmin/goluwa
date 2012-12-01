local ErrorNoHalt = print -- for now

hook = hook or {} local hook = hook

HOOK_DESTROY = "??|___HOOK_DESTROY___|??" -- unique what

hook.active = {}
hook.errors = {}
hook.profil = {}
hook.destroy_tag = HOOK_DESTROY

hook.profiler_enabled = false

function hook.Add(a, b, c, d, e)
	local event, unique, func, on_error, priority

	if type(a) == "table" and type(b) == "string" then
		event = b
		unique = tostring(a)
		func = a[b]
	elseif type(a) == "string" and b and type(c) == "function" then
		event = a
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

	check(event, "string")
	check(func, "function")

	hook.Remove(event, unique)
	
	hook.active[event] = hook.active[event] or {}
	table.insert(
		hook.active[event],
		{
			func = func,
			on_error = on_error,
			priority = priority or 0,
			unique = unique,
		}
	)
	
	hook.SortByPriority()
end

function hook.Remove(a, b)
	local event, unique

	if type(a) == "table" and type(b) == "string" then
		event = b
		unique = tostring(a)
	elseif type(a) == "string" and b then
		event = a
		unique = b
	end

	if unique ~= nil and hook.active[event] then
		for key, val in pairs(hook.active[event]) do
			if unique == val.unique then
				table.remove(hook.active[event], key)
			end
		end
	else
		--print(("Tried to remove non existing hook '%s:%s'"):format(event, tostring(unique)))
	end
	
	hook.SortByPriority()
end

function hook.SortByPriority()
	for key, tbl in pairs(hook.GetTable()) do
		table.sort(tbl, function(a, b) return a.priority > b.priority end)
	end
end

function hook.GetTable()
	return hook.active
end


local status, a,b,c,d,e,f,g,h
local time = 0

function hook.UserDataCall(udata, event, ...)	
	if udata:IsValid() then
		local func = udata[event]
		
		
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
	MsgN("== HOOK ERROR ==")
	
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

function hook.Call(event, ...)
	if hook.active[event] then
		for key, data in ipairs(hook.active[event]) do
			if hook.profiler_enabled == true then
				hook.profil[event] = hook.profil[event] or {}
				hook.profil[event][data.unique] = hook.profil[event][data.unique] or {}

				time = SysTime()
			end

			status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or OnError, ...)

			if a == hook.destroy_tag then
				hook.Remove(event, data.unique)
				break
			end

			if hook.profiler_enabled == true then
				hook.profil[event][data.unique].time = (hook.profil[event][data.unique].time or 0) + (SysTime() - time)
				hook.profil[event][data.unique].count = (hook.profil[event][data.unique].count or 0) + 1
			end

			if status == false then		
				if type(data.on_error) == "function" then
					data.on_error(a, event, data.unique)
				else
					hook.Remove(event, data.unique)
					printf("hook [%q][%q] removed", event, data.unique)
				end

				hook.errors[event] = hook.errors[event] or {}
				table.insert(hook.errors[event], {unique = data.unique, error = a, time = os.date("*t")})
			end

			if a ~= nil then
				return a,b,c,d,e,f,g,h
			end

		end
	end
end

function hook.GetErrorHistory()
	return hook.errors
end

function hook.GetProfilerHistory()
	local new = {}

	for event, hooks in pairs(hook.profil) do
		for unique, _data in pairs(hooks) do
			if table.Count(_data) ~= 0 and _data.time ~= 0 and _data.count ~= 0 then
				local data = {}

				data.event = event
				data.average =  math.Round((_data.time / _data.count) * 1000, 9)
				local info = debug.getinfo(hook.GetTable()[event][unique].func)
				data.hook = event
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

function hook.SetProfiler(bool)
	check(bool, "boolean")

	hook.profiler_enabled = bool
end

function hook.DisableAll()
	if hook.enabled == false then
		ErrorNoHalt("Hooks are already disabled.")
	else
		hook.enabled = true
		hook.__backup_hooks = table.Copy(hook.GetTable())
		table.Empty(hook.GetTable())
	end
end

function hook.EnableAll()
	if hook.enabled == true then
		ErrorNoHalt("Hooks are already enabled.")
	else
		hook.enabled = false
		table.Merge( hook.GetTable(), hook.__backup_hooks )
		hook.__backup_hooks = nil
	end
end

function hook.Dump()
	local h=0
	for k,v in pairs(hook.GetTable()) do
		Msg("> "..k.." ("..table.Count(v).." hooks):\n")
		for name,data in pairs(v) do
			h=h+1
			Msg("   \""..name.."\" \t "..tostring(debug.getinfo(data.func).source)..":")
			Msg(" Line:"..tostring(debug.getinfo(data.func).linedefined)..'\n')
		end
		Msg"\n"
	end
	Msg("\n>>> Total hooks: "..h..".\n")
end