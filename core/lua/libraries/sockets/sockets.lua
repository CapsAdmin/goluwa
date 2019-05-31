local sockets = {}

runfile("tcp_client.lua", sockets)
runfile("tcp_server.lua", sockets)
runfile("udp_client.lua", sockets)
runfile("udp_server.lua", sockets)
runfile("websocket_client.lua", sockets)
runfile("http11_client.lua", sockets)
runfile("download.lua", sockets)

sockets.active = {}

function sockets.Update()
    for _, socket in ipairs(sockets.active) do
        if socket.Update then
            socket:Update()
        end
    end
end

event.Timer("sockets", 1/30, 0, function() sockets.Update() end, nil, function(...) logn(...) return true end)

return sockets