local pvars = _G.pvars or {}

local path = "data/pvars.txt"
local mode = "luadata"

pvars.vars = pvars.vars or {}
pvars.infos = pvars.infos or {}

function pvars.Initialize()
	pvars.vars = serializer.ReadFile(mode, path) or {}
	pvars.init = true
	serializer.WriteFile(mode, path, pvars.vars)
end

function pvars.Save()
	if pvars.init then
		event.Delay(0, function() serializer.WriteFile(mode, path, pvars.vars) end, "save_pvars")
	end
end

do -- pvar meta
	local META = prototype.CreateTemplate("pvar")

	function META:Get() return pvars.Get(self.key) end
	function META:Set(val) pvars.Set(self.key, val) end
	function META:GetCallback() return pvars.infos[self.key].callback end
	function META:GetDefault() return pvars.infos[self.key].def end
	function META:GetType() return pvars.infos[self.key].typ end
	function META:GetHelp() return pvars.infos[self.key].help end

	META:Register()
end
function pvars.Setup(key, def, callback, help)
	def = def or table.copy(def)

	pvars.infos[key] = {
		def = table.copy(def),
		typ = type(def),
		help = help,
		callback = callback,
	}

	local val = def

	local test = pvars.vars[key]

	if test ~= nil then
		val = test
	end

	pvars.vars[key] = val

	if type(callback) == "function" then
		event.Delay(function()
			callback(pvars.Get(key), true)
		end)
	end

	pvars.Save()

	return pvars.GetObject(key)
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
			val = info.def
		end

		return val
	end
end

function pvars.Set(key, val)
	local info = pvars.infos[key]

	if info then
		if val == nil then
			val = info.def
		end

		pvars.vars[key] = val

		pvars.Save()

		if info.callback and not info.in_callback then
			info.in_callback = true
			system.pcall(info.callback, val)
			info.in_callback = nil
		end
	end
end

return pvars
