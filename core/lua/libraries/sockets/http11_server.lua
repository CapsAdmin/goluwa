local sockets = ... or _G.sockets
local META = prototype.CreateTemplate("socket", "http11_server")
META.Base = "tcp_server"

function META:OnClientConnected(client)
	if self:OnClientConnected2(client) == false then return false end

	sockets.ConnectedTCP2HTTP(client)
	list.insert(self.Clients, client)
	client.OnReceiveResponse = function(client, method, path)
		return self:OnReceiveResponse(client, method, path)
	end
	client.OnReceiveHeader = function(client, header)
		return self:OnReceiveHeader(client, header)
	end
	client.OnReceiveBody = function(client, body)
		return self:OnReceiveBody(client, body)
	end

	client:CallOnRemove(function(client, reason)
		if self:IsValid() then list.remove_value(self.Clients, client) end
	end)
end

function META:OnReceiveResponse(client, method, path) end

function META:OnReceiveHeader(client, header) end

function META:OnReceiveBody(client, body) end

function META:OnClientConnected2() end -- idk what to do here
META:Register()

function sockets.HTTPServer(socket)
	local self = META:CreateObject()
	self:Initialize(socket)
	self.Clients = {}
	return self
end

if RELOAD then
	local server = utility.RemoveOldObject(sockets.HTTPServer(), "http_server")
	print(server:Host("*", 1234))

	function server:OnReceiveHeader(client, header)
		client:Respond(
			"200 OK",
			nil,
			[[
            <!DOCTYPE HTML>
            <html>
                <meta charset="utf-8"/>
                <body>
                    #]] .. #self.Clients .. [[ connections
                </body>
            </html>
        ]]
		)
	end

	THESERVER = server
end