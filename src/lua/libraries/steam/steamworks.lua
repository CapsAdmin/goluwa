local ffi = require("ffi")
local steam = ... or steam

if EXTERNAL_DEBUGGER then return end

local steamworks = desire("libsteamworks")

if not steamworks then return end

for k, v in pairs(steamworks) do
	steam[k] = v
end

do
	local META = prototype.CreateTemplate("steam_friend")

	for k,v in pairs(steam.steamid_meta) do
		META[k] = META[k] or v
	end

	function META:CreateBot()
		local bot = clients.Create(tostring(self.id), true)
		bot:SetNick(self:GetPersonaName())
		return bot
	end

	function META:GetAvatarTexture()
		self.avatar_texture = self.avatar_texture or render.CreateTexture()

		if not self.requesting_avatar then
			event.Thinker(function()
				if not self:IsValid() then return false end

				local handle = self:GetLargeAvatar()

				if handle > 0 then
					local w = ffi.new("uint32_t[1]")
					local h = ffi.new("uint32_t[1]")
					steamworks.utils.GetImageSize(handle, w, h)

					local size = w[0] * h[0] * 4
					local buffer = ffi.new("uint8_t[?]", size)

					steamworks.utils.GetImageRGBA(handle, buffer, size)

					self.avatar_texture:Upload({
						buffer = buffer,
						size = Vec2(w[0], h[0])
					})
					return true
				end
			end)
			self.requesting_avatar = true
		end

		return self.avatar_texture
	end

	local str = ffi.new("char[2048]", 0)
	local type = ffi.new("SteamWorks_EChatEntryType[1]")

	function META:GetChatMessage(message_id)
		local length = steam.friends.GetFriendMessage(self.id, message_id, str, 512, type)
		if length > 0 then
			return ffi.string(str), type[0]
		end
	end

	local last = {}

	function META:GetLastChatMessage()
		if steam.friends.GetFriendMessage(self.id, 0, str, 512, type) == 0 then return end

		local i = last[tostring(self.id)] or 0

		while true do
			type[0] = 0

			local length = steam.friends.GetFriendMessage(self.id, i, str, 512, type)

			if type[0] == 0 and length == 0 then break end

			i = i + 1
		end

		last[tostring(self.id)] = i

		return self:GetChatMessage(i - 1)
	end

	--[[[event.Timer("steam_friends", 0.25, 0, function()
		for i, friend in ipairs(steam.GetFriends()) do
			local message = friend:GetLastChatMessage()
			if message then
				if friend.last_message ~= message then
					print(message)
					event.Call("SteamFriendsMessage", friend, message)
				end
				friend.last_message = message
			end
		end
	end)]]

	prototype.Register(META)
end

local active = utility.CreateWeakTable()

function steam.GetFriendObjectFromSteamID(id)
	active[tostring(id)] = active[tostring(id)] or prototype.CreateObject("steam_friend", {id = id})

	return active[tostring(id)]
end

function steam.GetFriends()
	local out = {}

	for i = 0, steam.friends.GetFriendCount(65535) - 1 do
		local id = steam.friends.GetFriendByIndex(i, 65535)
		out[i+1] = steam.GetFriendObjectFromSteamID(id)
	end

	return out
end

function steam.FindFriend(nick)
	for k, v in pairs(steam.GetFriends()) do
		if v:GetPersonaName():find(nick) or v.id == nick then
			return v
		end
	end
end

steam.client = steam.GetFriendObjectFromSteamID(steam.user.GetSteamID())

function steam.GetClient()
	return steam.client
end

if RELOAD then
	local tex = steam.GetFriends()[301]:GetAvatarTexture()

	event.AddListener("PostDrawMenu", "lol", function()
		surface.SetTexture(tex)
		surface.SetColor(1,1,1,1)
		surface.DrawRect(50,50,tex.w,tex.h)
	end)
end