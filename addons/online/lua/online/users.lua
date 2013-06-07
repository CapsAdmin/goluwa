users = users or {}

network.AddEncodeDecodeType("user", function(var, encode)
	if encode then
		return var:GetUniqueID()
	else
		return users.GetByUniqueID(var)
	end
end) 

users.active_users = users.active_users or {}
	
local ref_count = 1

do -- user meta
	local META

	META = {}
	META.__index = META
	
	META.Type = "user"
	META.ClassName = "user"
		
	class.GetSet(META, "UniqueID", "???")
	class.GetSet(META, "ID", -1)
		
	function META:__tostring()
		return string.format("user[%s][%i]", self:GetName(), self:GetID())
	end
	
	function META:IsValid() 
		return true
	end

	function META:GetName()	
		return SERVER and self.socket:GetIPPort() or CLIENT and self:GetUniqueID()
	end
	
	function META:Remove()
		if self.remove_me then return end
		users.active_users[self:GetUniqueID()] = nil
		self.remove_me = true
		self.IsValid = function() return false end
		timer.Simple(0, function() utilities.MakeNULL(self) end)
	end	
		
	users.user_meta = META
end

function User(uniqueid)		
	local self = users.active_users[uniqueid] or NULL

	if self:IsValid() then
		return self
	end

	self = setmetatable({}, users.user_meta)
	ref_count = ref_count + 1
		
	self:SetUniqueID(uniqueid)
	self.ID = ref_count
		
	self.nv = nvars.CreateObject(uniqueid)
	
	users.active_users[self.UniqueID] = self
	
	return self
end

function users.GetByUniqueID(id)
	return users.active_users[self.UniqueID] or NULL
end

function users.GetAll()
	return users.active_users
end