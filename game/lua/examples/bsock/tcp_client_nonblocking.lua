local bsocket = require("bsocket")
local socket = bsocket.socket("inet", "stream", "tcp")
socket:set_blocking(false)
socket:connect("www.lunduke.com", "http")

event.AddListener("Update", "test", function()
    if socket:is_connected() then
        assert(socket:send(
            "GET / HTTP/1.1\r\n"..
            "Host: www.lunduke.com\r\n"..
            "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0\r\n"..
            "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"..
            "Accept-Language: nb,nb-NO;q=0.9,en;q=0.8,no-NO;q=0.6,no;q=0.5,nn-NO;q=0.4,nn;q=0.3,en-US;q=0.1\r\n"..
            --"Accept-Encoding: gzip, deflate\r\n"..
            "DNT: 1\r\n"..
            "Connection: keep-alive\r\n"..
            "Upgrade-Insecure-Requests: 1\r\n"..
            "\r\n"
        ))
        local str = ""
        local total_length
        event.AddListener("Update", "test2", function()
            local chunk, err = socket:receive()

            if chunk then
                str = str .. chunk

                if not total_length then
                    total_length = tonumber(str:match("Content%-Length: (%d+)"))
                end

                if #str >= total_length then
                    print(str)
                    return e.EVENT_DESTROY
                end
            end
        end)
        return e.EVENT_DESTROY
    end
end)