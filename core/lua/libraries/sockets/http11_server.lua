local sockets = ... or _G.sockets

local META = prototype.CreateTemplate("socket", "http11_server")

META.Base = "tcp_server"

function META:OnClientConnected(client)
    if self:OnClientConnected(client) == false then
        return false
    end

    sockets.ConnectedTCP2HTTP(client)

    table.insert(self.Clients, client)

    client.OnReceiveHeader = function(client, header)
        self:OnReceiveHeader(client, header)
    end

    client.OnReceiveBody = function(client, body)
        self:OnReceiveBody(client, body)
    end

    client:CallOnRemove(function(client, reason)
        table.removevalue(self.Clients, client)
    end)
end

function META:OnReceiveHeader(client, header) end
function META:OnReceiveBody(client, body) end
function META:OnClientConnected() end

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
        client:Respond("200 OK", nil, [[
            <!DOCTYPE HTML>
            <html>
                <meta charset="utf-8"/>
                <body>
                    #]]..#self.Clients..[[ connections
                </body>
            </html>
        ]])
    end
    THESERVER = server
end

