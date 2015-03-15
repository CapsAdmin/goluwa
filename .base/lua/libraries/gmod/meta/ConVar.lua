local gmod = ... or gmod

local META = gmod.env.FindMetaTable("ConVar")
META.__index = META

function META:GetBool()
	return not not self.var
end

function META:GetFloat()
	return tonumber(self.var) or 0
end

function META:GetDefault()
	return self.default
end

function META:GetHelpText()
	return self.help or ""
end

function META:GetName()
	return self.name
end

function META:GetString()
	return tostring(self.var)
end

function META:GetInt()
	return math.ceil(tonumber(self.var) or 0)
end

function gmod.env.GetConVar(name)
	local var = console.GetVariable(name)

	return var and setmetatable({name = name, var = var}, META) or nil
end


function gmod.env.CreateConVar(name, def, flags, help)
	console.CreateVariable(name, tostring(def), nil, help)

	return gmod.env.GetConVar(name)
end