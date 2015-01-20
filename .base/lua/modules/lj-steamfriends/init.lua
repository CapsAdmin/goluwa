local lib = assert(ffi.load("steamfriends"))

ffi.cdef[[
	const char *steamGetLastError();
	int steamInitialize();
	
	typedef struct
	{
		const char *text;
		const char *sender_steam_id;
		const char *receiver_steam_id;
	}message;
	
	message *steamGetLastChatMessage();
	int steamSendChatMessage(const char *steam_id, const char *text);
	const char *steamGetNickFromSteamID(const char *steam_id);
	const char *steamGetClientSteamID();
	unsigned steamGetFriendCount();
	const char *steamGetFriendByIndex(unsigned i);
	
	typedef struct
	{
		int size;
		unsigned char *buffer;		
	} steam_auth_token;
			
	uint32_t steamGetAuthSessionTicket(void *ticket_buffer, int ticket_size, uint32_t *ticket_buffer_size);
]] 

if lib.steamInitialize() == 1 then
	error(ffi.string(lib.steamGetLastError()))
end

local steamfriends = {}

function steamfriends.Update()
	local msg = lib.steamGetLastChatMessage()

	if msg ~= nil then
		local sender_steam_id = ffi.string(msg.sender_steam_id)
		local receiver_steam_id = ffi.string(msg.receiver_steam_id)
		local text = ffi.string(msg.text)
		
		steamfriends.OnChatMessage(sender_steam_id, text, receiver_steam_id)
	end
end

function steamfriends.OnChatMessage(sender_steam_id, text, receiver_steam_id)

end

function steamfriends.SendChatMessage(steam_id, text)	
	return lib.steamSendChatMessage(steam_id, text)
end

function steamfriends.GetNickFromSteamID(steam_id)	
	return ffi.string(lib.steamGetNickFromSteamID(steam_id))
end

function steamfriends.GetClientSteamID()	
	return ffi.string(lib.steamGetClientSteamID())
end

function steamfriends.GetFriends()	
	local out = {}
	
	for i = 1, lib.steamGetFriendCount() do
		table.insert(out, ffi.string(lib.steamGetFriendByIndex(i - 1)))
	end
	
	return out
end

function steamfriends.GetAuthSessionTicket(app_id)	
	local ticket = ffi.new("char[1024]")
	local size = ffi.new("int[1]")
	
	os.setenv("SteamAppId", tostring(app_id))
	local handle = lib.steamGetAuthSessionTicket(ticket, ffi.sizeof(ticket), size)
	os.setenv("SteamAppId", "")
	
	return handle, ffi.string(ticket, size[0])
end

return steamfriends