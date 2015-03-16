local gmod = ... or gmod

local META = gmod.env.FindMetaTable("ConVar")

function META:GetBool()
	return not not self.__obj:Get()
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

function META:GetString()
	return tostring(self.__obj:Get())
end

function META:GetInt()
	return math.ceil(tonumber(self.__obj:Get()) or 0)
end

function gmod.env.GetConVar(name)
	return gmod.WrapObject(console.GetVariable(name), "ConVar")
end

function gmod.env.CreateConVar(name, def, flags, help)
	return gmod.WrapObject(console.CreateVariable(name, tostring(def), nil, help), "ConVar")
end

function gmod.env.CreateClientConVar(name, def)
	return gmod.WrapObject(console.CreateVariable(name, tostring(def), nil, help), "ConVar")
end

function gmod.env.GetConVarNumber(name)
	return tonumber(console.GetVariable(name)) or 0
end

function gmod.env.GetConVarString(name)
	return tostring(console.GetVariable(name, ""))
end