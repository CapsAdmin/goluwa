local ffi = require("ffi")

local socket = require("bsocket")
local e = socket.e

do
    local out = ffi.new("struct addrinfo*[1]")

    print(socket.getaddrinfo("www.apple.com", "http", ffi.new("struct addrinfo", {
        ai_family = e.AF_INET, -- AF_INET6 works too
        ai_socktype = e.SOCK_STREAM,
        ai_protocol = e.IPPROTO_TCP,
        ai_flags = bit.bor(e.AI_CANONNAME),
    }), out))

    local res = out[0]

    local str = ffi.new("char[100]")

    print(socket.inet_ntop(res.ai_family, res.ai_addr.sa_data, str, ffi.sizeof(str)))

    print("ip: " .. ffi.string(str))
    print("cannonical name: " .. ffi.string(res.ai_canonname))
end