if not steam.IsSteamClientAvailible() then
	warning("steam friends extension not available")
return end

chatsounds.Initialize()

local subject

event.AddListener("SteamFriendsMessage", "steam_friends", function(sender_steam_id, txt, receiver_steam_id)
	if txt == "" then return end
	if txt:sub(1, 2) == ">>" then return end

	local ply = clients.GetByUniqueID(sender_steam_id)
	
	if sender_steam_id == steam.GetClientSteamID() then
		sender_steam_id = receiver_steam_id
	end
	
	subject = sender_steam_id
	event.Delay(0.1, function() subject = nil end)
	
	if ply:IsValid() then
		if txt:sub(1, 1) == "!" then
			console.RunString(txt:sub(2),nil,nil,true)
		end
		
		chat.ClientSay(ply, txt, true)
	end
	
	STEAM_FRIENDS_SUBJECT = clients.GetByUniqueID(subject)
end)

event.AddListener("ConsolePrint", "steam_friends", function(line)
	if subject then
		steam.SendChatMessage(subject, ">> " .. line)
	end
end)

for i, steam_id in pairs(steam.GetFriends()) do
	local ply = clients.Create(steam_id, true)
	ply:SetNick(steam.GetNickFromSteamID(ply:GetUniqueID()))
end

local ply = clients.Create(steam.GetClientSteamID(), true)
ply:SetNick(steam.GetNickFromSteamID(ply:GetUniqueID()))

console.AddCommand("kill", function() 
	if STEAM_FRIENDS_SUBJECT and STEAM_FRIENDS_SUBJECT:IsValid() then
		steam.SendChatMessage(STEAM_FRIENDS_SUBJECT:GetUniqueID(), "☠ " .. STEAM_FRIENDS_SUBJECT:GetNick())	
	end 
end)

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	local url = txt:match("(http%S+)")
	
	if url then	
		if url:find("youtube") then
			local id = url:match("%?v=(.+)")
			
			if id then 
				id = id:match("(.-)&") or id
				
				youtube_query(sockets.EscapeURL(id))
				return
			end
		else
			sockets.Get(url, function(data)
				local title = data.content:match("<title>(.-)</title>") or url:match(".+/(.+)")
				
				if title and STEAM_FRIENDS_SUBJECT and STEAM_FRIENDS_SUBJECT:IsValid() then
					steam.SendChatMessage(STEAM_FRIENDS_SUBJECT:GetUniqueID(), title)
				end
			end)
		end
	elseif txt:sub(1, 1) ~= "!" then 
		chatsounds.Say(client, txt, seed)
		return 
	end
end)  

--[==[ffi.cdef[[
typedef struct NOTIFYICONDATA {
  unsigned long cbSize;
  void *hWnd;
  unsigned int uID;
  unsigned int uFlags;
  unsigned int uCallbackMessage;
  void *hIcon;
  char szTip[64];
  unsigned long dwState;
  unsigned long dwStateMask;
  char szInfo[256];
  union {
    unsigned int uTimeout;
    unsigned int uVersion;
  };
  char szInfoTitle[64];
  unsigned long dwInfoFlags;
  void *guidItem;
  void *hBalloonIcon;
} NOTIFYICONDATA, *PNOTIFYICONDATA;

int Shell_NotifyIconW(int dwMessage, NOTIFYICONDATA *lpdata);
]]

local lib = ffi.load("Shell32.dll")

local struct = ffi.new("NOTIFYICONDATA[1]")

ffi.fill(struct[0], 0)

struct[0].cbSize = ffi.sizeof("NOTIFYICONDATA")
struct[0].uID = 1231
struct[0].hWnd = nil
struct[0].szTip = "hello"
struct[0].szInfo = "hello"

lib.Shell_NotifyIconW(0, struct) ]==]