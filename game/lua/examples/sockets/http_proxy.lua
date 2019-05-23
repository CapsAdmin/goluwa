if not PROXY_SERVER then
    local server = sockets.TCPServer()
    server:Host("*", 4123)
    PROXY_SERVER = server
end

function PROXY_SERVER:OnClientConnected(client)
    function client:OnReceiveChunk(str)
        print(client, str)
        local url = str:match("GET %/(%S+) HTTP/1%.")
        print("url:", url)
        if not url or not url:startswith("https://gitlab.com/CapsAdmin/") then
            client:Remove()
            return
        end
        sockets.Download(url, function(body) client:Send(body) end, nil, nil, function(_, raw)
            client:Send(raw)
        end)
    end
end