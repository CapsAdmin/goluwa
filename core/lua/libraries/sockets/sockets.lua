local sockets = {}

runfile("tcp_client.lua", sockets)
runfile("tcp_server.lua", sockets)
runfile("http11.lua", sockets)
runfile("download.lua", sockets)

sockets.active = {}

function sockets.Update()
    for _, socket in ipairs(sockets.active) do
        socket:Update()
    end
end

event.Timer("sockets", 1/30, 0, function() sockets.Update() end, nil, function(...) logn(...) return true end)

return sockets