local pvars = _G.pvars or {}

local path = "%DATA%/pvars.txt"
local mode = "luadata"

pvars.vars = {}
pvars.infos = {}

function pvars.Initialize()
	local new = serializer.ReadFile(mode, path) or {}

	for key, val in pairs(pvars.vars) do
		if new[key] == nil then
			new[key] = val
		end
	end

	pvars.vars = new
	pvars.init = true
	serializer.WriteFile(mode, path, pvars.vars)
end

do -- pvar meta
	local META = prototype.CreateTemplate("pvar")

	function META:Get() return pvars.Get(self.key) end
	function META:Set(val) pvars.Set(self.key, val) end
	function META:GetCallback() return pvars.infos[self.key].callback end
	function META:GetDefault() return pvars.infos[self.key].def end
	function META:GetType() return pvars.infos[self.key].typ end

	prototype.Register(META)
end
function pvars.Setup(key, def, callback)
	def = def or table.copy(def)
	typ = typ or type(def)

	pvars.infos[key] = {
		def = table.copy(def),
		typ = typ,
		callback = callback,
	}

	pvars.vars[key] = def

	if type(callback) == "function" then
		event.Delay(function()
			callback(pvars.Get(key))
		end)
	end

	if pvars.init then
		serializer.SetKeyValueInFile(mode, path, key, pvars.vars[key])
	end

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
		return pvars.vars[key] or info.def
	end
end

function pvars.Set(key, val)
	local info = pvars.infos[key]

	if info then
		pvars.vars[key] = val or info.def

		serializer.SetKeyValueInFile(mode, path, key, pvars.vars[key])

		if info.callback then
			info.callback(val)
		end
	end
end

return pvars