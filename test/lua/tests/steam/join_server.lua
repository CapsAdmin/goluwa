 -- WIP
-- CapsAdmin: On the server it says I've joined with the correct steamid 
-- but if developer mode is on it says: 	S3: Client connected with invalid ticket: UserID: 2
-- I then get rejected here in this script with: 	#GameUI_ServerRejectSteam

local ip, port = "116.38.208.61", 27019 
local app_id = 4000
 
local function wireshark_hex_dump(str)
	logn((str:readablehex():gsub("(.. .. .. .. .. .. .. .. )(.. .. .. .. .. .. .. .. )", "%1\t%2\n")))
end

local CHALLENGE_REQUEST = 0x71
local CHALLENGE_SERVER_RESPONSE = 0x41
local CHALLENGE_CLIENT_RESPONSE = 0x6b

local CONNECTION_REJECTED = 0x39
local CONNECTION_SUCCESS = 0x42

local SINGLE_PACKET = 0xFFFFFFFF
local MAGIC_VERSION = 0x5A4F4933
local PROTOCOL_VERSION = 0x18 --0xf
local PROTOCOL_STEAM = 0x03 -- Protocol type (Steam authentication)
local DISCONNECT_REASON_LENGTH = 1260

-- this was tested on 2 different accounts (connecting to different servers however)

local connect = {
	request = {
		[CHALLENGE_REQUEST] = {
			{"long", SINGLE_PACKET}, -- this is for telling if the packet is split or not
			{"byte", CHALLENGE_REQUEST}, -- get challenge
			
			{"long", 0}, -- wireshark: 0x33277200, 0xc95ea209, 0xa2429f06, 0xa9339601, 0x2291370d, ...
			
			-- padding
			{"string", "0000000000"} -- wireshark: 30 30 30 30 30 30 30 30 30 30 00
		},
		[CHALLENGE_CLIENT_RESPONSE] = {
			{"long", SINGLE_PACKET}, 
			{"byte", CHALLENGE_CLIENT_RESPONSE}, 
			{"byte", PROTOCOL_VERSION}, 
			0x00, 0x00, 0x00, -- is PROTOCOL_STEAM a long?
			{"byte", PROTOCOL_STEAM}, 
			0x00, 0x00, 0x00,
			{"bytes", get = "challenge"},
			
			{"string", "CapsAdmin"}, -- nick
			{"string", ""}, -- password, can be NULL if not provided
			{"string", "14.04.19"}, -- date? matches the date joined at if months are counted from 0
			
			-- these are always the same
			0xf2, 0x00, 
			
			-- these differ from account to account
			0xef, 0x82, 0x1d, 
--			0xf5, 0x6b, 0xc7,
			
			-- these are always the same
			0x01, 0x01, 0x00, 0x10, 0x01, 
			{"bytes", get = function(data) 
				local handle, key = steam.GetAuthSessionTicket(app_id) 
				return key 
			end},			
		};
	},
	response = {
		{"long", "header"},
		{"byte", "type", switch = {
			[CONNECTION_REJECTED] = {
				{"long", "client_challenge"},   
				{"string", "disconnect_reason", length = DISCONNECT_REASON_LENGTH},   
			},
			[CHALLENGE_SERVER_RESPONSE] = {
				{"long", "magic_version", assert = MAGIC_VERSION},
				{"string", "challenge", length = 8}, -- this is server and client challenge combined (in the order long server_challenge, long client_challenge)
				{"byte", "protocol", assert = PROTOCOL_STEAM},
				
				{"byte", "unknown"}, -- wireshark: 00 00
				{"long", "unknown"}, -- wireshark: 00 00 00 01
				
				{"string", "server_steamid", length = 7}, 
				{"boolean", "vac"},
				
				{"string", "padding"}, -- wireshark: 30 30 30 30 30 30 00
			},
			[CONNECTION_SUCCESS] = {
				
			},
		}},
	},
} 

local disconnect = {
	{"long", SINGLE_PACKET},
	{"byte", ("9"):byte()},
}
  
local function send_struct(socket, struct, values) 
	local buffer = Buffer()
	buffer:WriteStructure(struct, values)   
	socket:Send(buffer:GetString())
end

local function read_struct(str, struct)
	return Buffer(str):ReadStructure(struct)
end

do -- socket	 
	local client = sockets.CreateClient("udp", ip, port)
	client.debug = false  

	send_struct(client, connect.request[CHALLENGE_REQUEST])

	function client:OnReceive(str)	
		local data = read_struct(str, connect.response)
					
		if data.type == CONNECTION_REJECTED then -- rejected
			warning("connection rejected: ", data.disconnect_reason)
		elseif data.type == CHALLENGE_SERVER_RESPONSE then -- challenge
			send_struct(self, connect.request[CHALLENGE_CLIENT_RESPONSE], data) 
		elseif data.type == CONNECTION_SUCCESS then -- connection
			warning("connection success")
			self:Remove()
		end
	end
end