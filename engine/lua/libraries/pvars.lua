local pvars = _G.pvars or {}

local path = "data/pvars.txt"
local mode = "luadata"

pvars.vars = pvars.vars or {}
pvars.infos = pvars.infos or {}

local function set(key, val)
	local info = pvars.infos[key]

	if info then
		if val == nil then
			val = info.default
		end

		if info.list then
			if not table.hasvalue(info.list, val) then
				val = info.default
			end
		elseif info.table then
			if not info.table[val] then
				val = info.default
			end
		end

		if typex(val) ~= info.type then
			val = info.default
		end

		if info.modify then
			val = info.modify(val)
		end

		pvars.vars[key] = val
	end
end

function pvars.Initialize()
	pvars.vars = serializer.ReadFile(mode, path) or {}

	for _, info in pairs(pvars.infos) do
		set(info.key, pvars.vars[info.key])
	end

	pvars.init = true
	serializer.WriteFile(mode, path, pvars.vars)
end

function pvars.Save()
	if pvars.init then
		event.Delay(0, function()
			local vars = {}
			for k, v in pairs(pvars.GetAll()) do
				if v.store then
					vars[k] = pvars.vars[k]
				end
			end
			serializer.WriteFile(mode, path, vars)
		end, "save_pvars")
	end
end

do -- pvar meta
	local META = prototype.CreateTemplate("pvar")

	function META:Get() return pvars.Get(self.key) end
	function META:Set(val) pvars.Set(self.key, val) end
	function META:GetCallback() return pvars.infos[self.key].callback end
	function META:GetDefault() return pvars.infos[self.key].default end
	function META:GetType() return pvars.infos[self.key].type end
	function META:GetHelp() return pvars.infos[self.key].help end

	META:Register()
end

function pvars.Setup2(info)
	info.type = info.type or typex(info.default)

	if info.store == nil then
		info.store = true
	end

	if not info.group then
		local group = info.key:match("^(%S-)_") or "other"
		info.group = group
	end

	if not info.friendly then
		local friendly = info.key
		local group = info.key:match("^(%S-)_")
		if group then
			friendly = info.key:sub(#group + 2)
		end

		info.friendly = friendly:gsub("_", " ")
	end

	pvars.infos[info.key] = info

	set(info.key, pvars.vars[info.key])

	if info.callback then
		event.Delay(function()
			event.Call("PersistentVariableChanged", key, pvars.Get(info.key), val)
			info.callback(pvars.Get(info.key), true)
		end)
	end

	pvars.Save()

	return pvars.GetObject(info.key)
end

function pvars.Setup(key, def, callback, help, dont_save)
	return pvars.Setup2({key = key, default = def, callback = callback, help = help, store = not dont_save})
end

function pvars.GetAll()
	return pvars.infos
end

function pvars.GetObject(key)
	local info = pvars.infos[key]
	if info then
		return prototype.CreateObject("pvar", {key = key})
	end
end

function pvars.IsSetup(key)
	return pvars.infos[key] ~= nil
end

function pvars.Get(key)
	local info = pvars.infos[key]

	if info then
		local val = pvars.vars[key]

		if val == nil then
			val = info.default
		end

		return val
	end
end

function pvars.Set(key, val)
	local info = pvars.infos[key]
	local old = pvars.Get(key)

	set(key, val)

	pvars.Save()

	if info.callback and not info.in_callback then
		info.in_callback = true
		system.pcall(info.callback, pvars.Get(key))
		info.in_callback = nil
	end

	event.Call("PersistentVariableChanged", key, pvars.Get(key), old)

end

function pvars.SetString(key, val)
	local info = pvars.infos[key]

	if info.type == "table" then
		val = serializer.GetLibrary("comma").Decode(val)
	elseif info.type ~= "string" then
		val = serializer.GetLibrary(mode).FromString(val)
	end

	pvars.Set(key, val)
end

function pvars.GetString(key)
	local val = pvars.Get(key)
	local info = pvars.infos[key]

	if info.type == "table" then
		return serializer.GetLibrary("comma").Encode(val)
	end

	return serializer.GetLibrary(mode).Encode(val)
end

return pvars
