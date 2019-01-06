
local ffi = require("ffi")
local socket = require("bsocket")
local libressl = require("libressl")

local host = "github.com"

local res = ffi.new("struct addrinfo*[1]")

assert(socket.getaddrinfo(host, "https", ffi.new("struct addrinfo", {
    ai_family = e.AF_INET,
    ai_socktype = e.SOCK_STREAM,
    ai_protocol = e.IPPROTO_TCP,
}), res))

-- Create a SOCKET for connecting to server
local client = assert(socket.socket(res[0].ai_family, res[0].ai_socktype, res[0].ai_protocol))
assert(socket.socket_connect(client, res[0].ai_addr, res[0].ai_addrlen))

libressl.tls_init();
local tls = libressl.tls_client();
local config = libressl.tls_config_new();
libressl.tls_config_insecure_noverifycert(config);
libressl.tls_config_insecure_noverifyname(config);
libressl.tls_configure(tls, config);

if libressl.tls_connect_socket(tls, client, host) < 0 then
    print("TLS ERROR: ", ffi.string(libressl.tls_error(tls)))
end


local header = "GET / HTTP/1.1\r\n"..
"Host: "..host.."\r\n"..
"User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0\r\n"..
"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"..
"Accept-Language: nb,nb-NO;q=0.9,en;q=0.8,no-NO;q=0.6,no;q=0.5,nn-NO;q=0.4,nn;q=0.3,en-US;q=0.1\r\n"..
--"Accept-Encoding: gzip, deflate\r\n"..
"DNT: 1\r\n"..
"Connection: keep-alive\r\n"..
"Upgrade-Insecure-Requests: 1\r\n"..
"\r\n"

libressl.tls_write(tls, header, #header);
--socket.socket_send(client, header, #header, 0)

local str = ""
local total_length

while true do
    local buff = ffi.new("char[1024]")
    local len = libressl.tls_read(tls, buff, ffi.sizeof(buff))

    if len <= 0 then
        break
    end

    str = str .. ffi.string(buff, len)

    if not total_length then
        total_length = tonumber(str:match("Content%-Length: (%d+)"))
    end

    if str:endswith("0\r\n\r\n") or (total_length and #str >= total_length) then
        break
    end
end

print(str)