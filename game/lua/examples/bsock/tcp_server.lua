local ffi = require("ffi")

local socket = require("bsocket")
local e = socket.e

do -- server
    local function setoption(fd, level, key, val)
        val = ffi.new("int[1]", val)
        local len = ffi.sizeof(val)

        return socket.socket_setsockopt(fd, level, key, ffi.cast("void *", val), len)
    end

    local port = 5001
    local host = nil -- binding, can be nil
    local serv = tostring(port)

    local res = ffi.new("struct addrinfo*[1]")
    assert(socket.getaddrinfo(host, serv, ffi.new("struct addrinfo", {
        ai_family = e.AF_INET, -- DOES NOT work in windows: AF_UNSPEC,  AF_UNSPEC == use IPv4 or IPv6, whichever
        ai_socktype = e.SOCK_STREAM,
        ai_protocol = e.IPPROTO_TCP,
        ai_flags = bit.bor(e.AI_PASSIVE), -- fill in my IP for me
    }), res))

    -- Create a SOCKET for connecting to server
    local listen_socket = assert(socket.socket(res[0].ai_family, res[0].ai_socktype, res[0].ai_protocol))
    assert(socket.socket_blocking(listen_socket, false))

    assert(setoption(listen_socket, e.SOL_SOCKET, e.SO_REUSEADDR, 1))
    assert(setoption(listen_socket, e.SOL_SOCKET, e.SO_SNDBUF, 65536))
    assert(setoption(listen_socket, e.SOL_SOCKET, e.SO_RCVBUF, 65536))

    if jit.os == "OSX" then
        assert(setoption(listen_socket, e.SOL_SOCKET, e.TCP_NODELAY, 1))
    end

    assert(socket.socket_bind(listen_socket, res[0].ai_addr, res[0].ai_addrlen))
    assert(socket.socket_listen(listen_socket, e.SOMAXCONN))

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

    event.AddListener("Update", "test", function()
        local client_addr = ffi.new("struct sockaddr_in[1]")
        local client_socket = socket.socket_accept(listen_socket, ffi.cast("struct sockaddr *", client_addr), ffi.new("int[1]", ffi.sizeof(client_addr)))

        if client_socket ~= socket.INVALID_SOCKET then
            local send_result = socket.socket_send(client_socket, content, #content, 0)

            print("client connected ", client_socket)

            assert(socket.socket_blocking(client_socket, false))

            local buffer = ffi.new("char[?]", 16384)
            local result = socket.socket_recv(client_socket, buffer, ffi.sizeof(buffer), 0)

            if result > 0 then
                print(ffi.string(buffer, result))
                socket.socket_close(client_socket)
            elseif not socket.wouldblock() then
                socket.socket_close(client_socket)
                error(socket.lasterror())
            end
        end
    end)
end