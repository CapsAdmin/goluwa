local bsock = require("bsocket_ffi")
local e = bsock.e

if bsock.initialize then
    assert(bsock.initialize())
end

local ffi = require("ffi")

local function capture_flags(what)
    local flags = {}
    local reverse = {}
    for k, v in pairs(e) do
        if k:startswith(what) then
            k = k:sub(#what + 1):lower()
            reverse[v] = k
            flags[k] = v
        end
    end
    return {
        lookup = flags,
        reverse = reverse,
        strict_reverse = function(key)
            if not key then
                error("invalid " .. what:sub(0, -2) .. " flag: nil")
            end
            if not reverse[key] then
                error("invalid "..what:sub(0, -2).." flag: " .. key, 2)
            end
            return reverse[key]
        end,
        strict_lookup = function(key)
            if not key then
                error("invalid " .. what:sub(0, -2) .. " flag: nil")
            end
            if not flags[key] then
                error("invalid "..what:sub(0, -2).." flag: " .. key, 2)
            end
            return flags[key]
        end
    }
end

local SOCK = capture_flags("SOCK_")
local AF = capture_flags("AF_")
local IPPROTO = capture_flags("IPPROTO_")
local AI = capture_flags("AI_")
local SOL = capture_flags("SOL_")
local SO = capture_flags("SO_")
local TCP = capture_flags("TCP_")

local function table_to_flags(flags, valid_flags, operation)
	if type(flags) == "string" then
		flags = {flags}
    end
    operation = operation or bit.band

	local out = 0

	for k, v in pairs(flags) do
		local flag = valid_flags[v] or valid_flags[k]
		if not flag then
            error("invalid flag " .. tostring(v), 2)
		end

		out = operation(out, tonumber(flag))
	end

	return out
end

local function flags_to_table(flags, valid_flags, operation)
    if not flags then return valid_flags.default_valid_flag end
    operation = operation or bit.band

	local out = {}

	for k, v in pairs(valid_flags) do
		if operation(flags, v) > 0 then
			out[k] = true
		end
	end

	return out
end

local M = {}

local function addrinfo_to_table(res)
    local info = {}

    local str = ffi.new("char[256]")
    local addr = assert(bsock.inet_ntop(res.ai_family, res.ai_addr.sa_data, str, ffi.sizeof(str)))

    if res.ai_canonname ~= nil then
        info.canonical_name = ffi.string(res.ai_canonname)
    end

    info.ip = ffi.string(addr)

    info.family = AF.reverse[res.ai_family]
    info.socket_type = SOCK.reverse[res.ai_socktype]
    info.protocol = IPPROTO.reverse[res.ai_protocol]
    info.flags = flags_to_table(res.ai_flags, AI.lookup, bit.band)
    info.addrinfo = res

    return info
end

function M.get_address_info(data)


    local hints

    if data.socket_type or data.protocol or data.flags then
        hints = ffi.new("struct addrinfo", {
            ai_socktype = data.socket_type and SOCK.strict_lookup(data.socket_type) or nil,
            ai_protocol = data.protocol and IPPROTO.strict_lookup(data.protocol) or nil,
            ai_flags = data.flags and table_to_flags(data.flags, AI.lookup, bit.bor) or nil,
        })
    end

    local out = ffi.new("struct addrinfo*[1]")
    local ok, err = bsock.getaddrinfo(data.host, data.service, hints, out)
    if not ok then return ok, err end

    local tbl = {}

    local res = out[0]

    while res ~= nil do
        table.insert(tbl, addrinfo_to_table(res))

        res = res.ai_next
    end

    return tbl
end

do
    local meta = {}
    meta.__index = meta

    function meta:__tostring()
        return string.format("socket[%s-%s-%s][%s]", self.family, self.type, self.protocol, self.fd)
    end

    function M.socket(family, type, protocol)
        local fd, err = bsock.socket(AF.strict_lookup(family), SOCK.strict_lookup(type), IPPROTO.strict_lookup(protocol))

        if not fd then return fd, err end

        return setmetatable({
            fd = fd,
            family = family,
            type = type,
            protocol = protocol,
            blocking = true,
        }, meta)
    end

    function meta:close()
        return bsock.socket_close(self.fd)
    end

    function meta:set_blocking(b)
        local ok, err = bsock.socket_blocking(self.fd, b)
        if not ok then return ok, err end
        self.blocking = b
        return ok, err
    end

    function meta:set_option(key, val, level)
        level = level or "socket"

        if type(val) == "boolean" then
            val = ffi.new("int[1]", val and 1 or 0)
        elseif type(val) == "number" then
            val = ffi.new("int[1]", val)
        elseif type(val) ~= "cdata" then
            error("unknown value type: " .. type(val))
        end

        local env = SO
        if level == "tcp" then
            env = TCP
        end

        return bsock.socket_setsockopt(self.fd, SOL.strict_lookup(level), env.strict_lookup(key), ffi.cast("void *", val), ffi.sizeof(val))
    end

    function meta:connect(host, port)
        local res

        if type(host) == "table" and host.addrinfo then
            res = host
        else
           local res_, err = M.get_address_info({
                host = host,
                service = port,
                family = self.family,
                socket_type = self.type,
                protocol = self.protocol
            })
           if not res_ then
                return res_, err
           end
           if not res_[1] then
                return nil, "unable to lookup hostname (table returned has no entries)"
           end
           res = res_[1]
        end

        local ok, err = bsock.socket_connect(self.fd, res.addrinfo.ai_addr, res.addrinfo.ai_addrlen)

        if not ok then
            return ok, err
        end

        if self.on_connect then
            return self:on_connect(host, port)
        end

        return true
    end

    function meta:bind(host, port)
        local res

        if type(host) == "table" and host.addrinfo then
            res = host
        else
           res = M.get_address_info({host = host, service = port, family = self.family, socket_type = self.type, protocol = self.protocol})[1]
        end

        return bsock.socket_bind(self.fd, res.addrinfo.ai_addr, res.addrinfo.ai_addrlen)
    end

    function meta:listen(max_connections)
        max_connections = max_connections or e.SOMAXCONN
        return bsock.socket_listen(self.fd, max_connections)
    end

    function meta:accept()
        local address = ffi.new("struct sockaddr_in[1]")
        local fd, err = bsock.socket_accept(self.fd, ffi.cast("struct sockaddr *", address), ffi.new("unsigned int[1]", ffi.sizeof(address)))

        if fd ~= bsock.INVALID_SOCKET then
            local client = setmetatable({
                fd = fd,
                family = "unknown",
                type = "unknown",
                protocol = "unknown",
                blocking = true,
            }, meta)

            return client
        end

        return nil, bsock.lasterror()
        end

    function meta:is_connected()
        local ip, port = self:get_peer_name()
        local ip2, port2 = self:get_name()
        if ip and ip2 then
            return port ~= 0 and port2 ~= 0
        end
    end

    function meta:get_peer_name()
        local data = ffi.new("struct sockaddr_in")
        local len = ffi.new("unsigned int[1]", ffi.sizeof(data))

        local ok, err = bsock.socket_getpeername(self.fd, ffi.cast("struct sockaddr *", data), len)
        if not ok then return ok, err end

        return ffi.string(bsock.inet_ntoa(data.sin_addr)), bsock.ntohs(data.sin_port)
    end

    function meta:get_name()
        local data = ffi.new("struct sockaddr_in")
        local len = ffi.new("unsigned int[1]", ffi.sizeof(data))

        local ok, err = bsock.socket_getsockname(self.fd, ffi.cast("struct sockaddr *", data), len)
        if not ok then return ok, err end

        return ffi.string(bsock.inet_ntoa(data.sin_addr)), bsock.ntohs(data.sin_port)
    end

    function meta:send(data, flags)
        if self.on_send then
            return self:on_send(data, flags)
        end
        local len, err = bsock.socket_send(self.fd, data, #data, flags or 0)
        if not len then
            return len, err
        end

        if len > 0 then
            return len
        end
    end

    function meta:receive(size, flags)
        size = size or 64000
        local buff = ffi.new("char[?]", size)

        if self.on_receive then
            return self:on_receive(buff, size, flags)
        end

        local len, err = bsock.socket_recv(self.fd, buff, ffi.sizeof(buff), flags or 0)
        if not len then
            return len, err
        end

        if len > 0 then
            return ffi.string(buff, len)
        end

        return nil, err
    end
end

function M.bind(host, port)
    if host == "*" then host = nil end
    local addrinfo, err = M.get_address_info({
        host = host,
        service = tostring(port),
        family = "inet",
        type = "stream",
        protocol = "tcp",
        flags = {"passive"}, -- fill in ip
    })

    if not addrinfo then return addrinfo, err end

    for _, info in ipairs(addrinfo) do
        if info.family == "inet" then
            local server, err = M.socket(info.family, info.socket_type or "stream", info.protocol)
            if not server then return server, err end

            server:set_option("reuseaddr", 1)

            local ok, err = server:bind(info)
            if not ok then return ok, err end

            server:set_option("sndbuf", 65536)
            server:set_option("rcvbuf", 65536)

            return server
        end
    end
end

function M.istimeout(res, err)
    if res ~= nil then return false end

    return
        err == nil or
        err == "blocking" or
        err == "Resource temporarily unavailable" or
        err == "A non-blocking socket operation could not be completed immediately. (10035)"
end

return M