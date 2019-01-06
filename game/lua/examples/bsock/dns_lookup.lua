local ffi = require("ffi")

local socket = require("bsocket")
local e = socket.e

local out = ffi.new("struct addrinfo*[1]")

local function print_enum(num, group)
    for k,v in pairs(e) do
        if (not group or k:startswith(group)) and v == num then
            print(k, v)
            return
        end
    end
end

local function print_ai_flags(flags)
    local tbl = {}
    for k,v in pairs(e) do
        if k:startswith("AI_") then
            tbl[k] = v
        end
    end

    logn("flags: ")
    for k,v in pairs(utility.FlagsToTable(flags, tbl)) do logn("\t", k) end
end

assert(socket.getaddrinfo("www.sol.no", nil, ffi.new("struct addrinfo", {
    ai_flags = e.AI_CANONNAME,
}), out))

local res = out[0]

while res ~= nil do
    print("=============")
    local str = ffi.new("char[100]")

    local addr = assert(socket.inet_ntop(res.ai_family, res.ai_addr.sa_data, str, ffi.sizeof(str)))

    print_enum(res.ai_family, "AF_")
    print_enum(res.ai_protocol, "AI_")
    print_enum(res.ai_socktype, "SOCK_")
    print_ai_flags(res.ai_flags)

    print("ip address: " .. ffi.string(addr))

    if res.ai_canonname ~= nil then
        print("cannonical name: " .. ffi.string(res.ai_canonname))
    end

    local hostname = ffi.new("char[200]")
    local servname = ffi.new("char[200]")

    print("getnameinfo: ", socket.getnameinfo(
        res.ai_addr, res.ai_addrlen,
        hostname, ffi.sizeof(hostname),
        servname, ffi.sizeof(servname),
        0
    ))

    print("host name: " .. ffi.string(hostname))
    print("server name: " .. ffi.string(servname))

    res = res.ai_next
end
