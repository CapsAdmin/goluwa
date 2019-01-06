
local bsocket = require("bsocket")
local host = "github.com"
local socket = assert(bsocket.socket("inet", "stream", "tcp"))

local SSL = require("libressl")
do
    local ffi = require("ffi")
    SSL.tls_init()
    local tls = SSL.tls_client()
    local config = SSL.tls_config_new()
    SSL.tls_config_insecure_noverifycert(config)
    SSL.tls_config_insecure_noverifyname(config)
    SSL.tls_configure(tls, config)

    function socket:on_connect(host, serivce)
        if SSL.tls_connect_socket(tls, self.fd, host) < 0 then
            return nil, ffi.string(SSL.tls_error(tls))
        end
        return true
    end

    function socket:on_send(data, flags)
        local len = SSL.tls_write(tls, data, #data)
        if len < 0 then
            return nil, ffi.string(SSL.tls_error(tls))
        end
        return len
    end

    function socket:on_receive(buffer, max_size, flags)
        local len = SSL.tls_read(tls, buffer, max_size)
        if len < 0 then
            return nil, ffi.string(SSL.tls_error(tls))
        end
        return ffi.string(buffer, len)
    end
end

assert(socket:connect(host, "https"))

assert(socket:send(
    "GET / HTTP/1.1\r\n"..
    "Host: "..host.."\r\n"..
    "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0\r\n"..
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"..
    "Accept-Language: nb,nb-NO;q=0.9,en;q=0.8,no-NO;q=0.6,no;q=0.5,nn-NO;q=0.4,nn;q=0.3,en-US;q=0.1\r\n"..
    --"Accept-Encoding: gzip, deflate\r\n"..
    "DNT: 1\r\n"..
    "Connection: keep-alive\r\n"..
    "Upgrade-Insecure-Requests: 1\r\n"..
    "\r\n"
))

local total_length
local str = ""

while true do
    local chunk = assert(socket:receive())

    if not chunk then
        break
    end

    str = str .. chunk

    if not total_length then
        total_length = tonumber(str:match("Content%-Length: (%d+)"))
    end

    if str:endswith("0\r\n\r\n") or (total_length and #str >= total_length) then
        break
    end
end

print(str)