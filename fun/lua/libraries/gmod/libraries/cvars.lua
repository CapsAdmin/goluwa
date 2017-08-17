local gine = ... or _G.gine

function gine.env.CreateConVar(name, def, flags, help)
	return gine.WrapObject(pvars.Setup(name, tostring(def), nil, help, true), "ConVar")
end

function gine.env.GetConVar_Internal(name)
	local pvar = pvars.GetObject(name)

	if not pvar then
		llog("unknown convar: ", name)
		pvar = pvars.Setup(name, 0)
	end

	if pvar then
		return gine.WrapObject(pvar, "ConVar")
	end
end

function gine.env.ConVarExists(name)
	return pvars.IsSetup(name)
end

local META = gine.GetMetaTable("ConVar")

function META:SetBool(val)
	self.__obj:Set((tonumber(val) and tonumber(val) > 0) and 1 or 0)
end

function META:GetBool()
	local val = self.__obj:Get()
	if tonumber(val) then return tonumber(val) > 0 end
	return not not val
end

function META:SetFloat(val)
	self.__obj:Set(tonumber(val) or 0)
end

function META:GetFloat()
	return tonumber(self.__obj:Get()) or 0
end

function META:GetDefault()
	return self.__obj:GetDefault()
end

function META:GetHelpText()
	return self.__obj:GetHelp()
end

function META:GetName()
	return self.__obj:GetName()
end

function META:SetString(val)
	self.__obj:Set(tostring(val))
end

function META:GetString()
	return tostring(self.__obj:Get())
end

function META:GetInt()
	return math.ceil(tonumber(self.__obj:Get()) or 0)
end
