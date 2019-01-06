local bsocket = require("bsocket")

do -- server
    local host = nil
    local port = 5001

    local info = assert(bsocket.get_address_info({
        host = nil,
        service = tostring(port),
        family = "inet",
        type = "stream",
        protocol = "tcp",
        flags = {"passive"}, -- fill in ip
    }))[1]

    -- Create a SOCKET for connecting to server
    table.print(info)
    local server = assert(bsocket.socket(info.family, info.socket_type, info.protocol))

    server:set_option("reuseaddr", 1)
    server:set_option("sndbuf", 65536)
    server:set_option("rcvbuf", 65536)

    if jit.os == "OSX" then
        server:set_option("nodelay", 1)
    end

    assert(server:bind(info))
    assert(server:listen())

    local body = "<html><body><h1>hello world</h1></body></html>"

    local header =
    "[HTTP/1.1 200 OK\r\n"..
    "Server: masrv/0.1.0\r\n"..
    "Date: Thu, 28 Mar 2013 22:16:09 GMT\r\n"..
    "Content-Type: text/html\r\n"..
    "Connection: Keep-Alive\r\n"..
    "Content-Length: "..#body.."\r\n"..
    "Last-Modified: Wed, 21 Sep 2011 14:34:51 GMT\r\n"..
    "Accept-Ranges: bytes\r\n" ..
    "\r\n"

    local content = header .. body

    while true do
        local client, err = server:accept()

        if client then
            assert(client:send(content))

            print("client connected ", client)

            local str, err = client:receive()

            if str then
                print(str)
                client:close()
            elseif not bsocket.wouldblock() then
                client:close()
                error(bsocket.lasterror())
            end
        elseif err ~= "Resource temporarily unavailable" then
            error(err)
        end
    end
end