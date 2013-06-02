local users = _G.users or {}

users.active_users = users.active_users or {}
	
local ref_count = 1

do -- user meta
	local META

	META = {}
	META.__index = META
	
	META.Type = "user"
	META.ClassName = "user"
	
	class.GetSet(META, "Name", "mingebag")
	class.GetSet(META, "Socket", NULL)
	class.GetSet(META, "UniqueID", "???")
	class.GetSet(META, "ID", -1)
		
	function META:__tostring()
		return string.format("user[%s][%i]", self:GetName(), self:GetID())
	end
	
	function META:IsValid() 
		return true
	end
	
	function META:Remove()
		utilities.MakeNull(self)
		users.active_users[self:GetUniqueID()] = nil
		utilities.SafeRemove(self:GetSocket())
	end	
	
	users.user_meta = META
end

function users.CreateUserFromSocket(socket, data)
	local self = users.active_users[socket:GetIP()] or NULL
	
	if self:IsValid() then
		return self
	end

	self = setmetatable({}, users.user_meta)

	local count = 0
	
	for key, user in pairs(users.GetAll()) do
		if user.real_name == data.name then
			count = count + 1
		end
	end
	
	local name = data.name
	
	if count > 0 then
		name = name .. "(" .. count .. ")"
	end
	
	self:SetName(name)
	self.real_name = data.name
	
	self:SetSocket(socket)
	self:SetUniqueID(socket:GetIP() .. ":" .. socket:GetPort())
	
	socket.__user = self
	
	users.active_users[self.UniqueID] = self
	
	self.ID = ref_count
	
	ref_count = ref_count + 1
	
	return self
end
	
function users.GetUserFromSocket(socket)
	return hasindex(socket) and socket.__user or NULL
end

function users.GetAll()
	return users.active_users
end

return users