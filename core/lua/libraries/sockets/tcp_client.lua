local sockets = ... or _G.sockets

local ljsocket = require("ljsocket")

local META = prototype.CreateTemplate("socket", "tcp_client")

function META:assert(val, err)
    if not val then
        self:Error(err)
    end

    return val, err
end

function META:__tostring2()
    return "[" .. tostring(self.socket) .. "]"
end

function META:Initialize(socket)
    self:SocketRestart(socket)
    table.insert(sockets.active, self)
end

function META:SocketRestart(socket)
    self.socket = socket or ljsocket.create("inet", "stream", "tcp")
    if not self:assert(self.socket:set_blocking(false)) then return end
    self.socket:set_option("nodelay", true, "tcp")
    self.socket:set_option("cork", false, "tcp")

    self.tls_setup = nil
    self.connected = nil
    self.connecting = nil
end

function META:SetupTLS()
    if self.tls_setup then return end

    local tls = desire("libtls")
    if not tls then
        return self:Error("unable to find libtls")
    end

    self.tls_setup = true

    local ffi = require("ffi")
    tls.init()

    local tls_client = tls.client()

    local config = tls.config_new()
    tls.config_insecure_noverifycert(config)
    tls.config_insecure_noverifyname(config)
    tls.configure(tls_client, config)

    local function last_error(code, what)
        local err = tls.error(tls_client)
        if err ~= nil then
            return ffi.string(err)
        end
        return "unknown tls "..what.." error (" .. tonumber(code) .. ")"
    end

    function self.socket:on_connect(host, serivce)
        local code = tls.connect_socket(tls_client, self.fd, host)

        if code < 0 then
            return nil, last_error(code, "connect")
        end

        return true
    end

    function self:DoHandshake()
        local ret = tls.handshake(tls_client)

        if ret == tls.e.WANT_POLLOUT or ret == tls.e.WANT_POLLIN then
            return nil, "timeout"
        elseif ret < 0 then
            local err = last_error(ret, "handshake")
            if err ~= "handshake already completed" then
                return nil, err
            end
        end

        self.DoHandshake = nil

        return true
    end

    function self.socket:on_send(data, flags)
        local len = tls.write(tls_client, data, #data)
        if len < 0 then
            if len == tls.e.WANT_POLLOUT or len == tls.e.WANT_POLLIN then
                return nil, "timeout"
            end
            return nil, last_error(len, "write")
        end
        return len
    end

    function self.socket:on_receive(buffer, max_size, flags)
        local len = tls.read(tls_client, buffer, max_size)
        if len < 0 then
            if len == tls.e.WANT_POLLOUT or len == tls.e.WANT_POLLIN then
                return nil, "timeout"
            end
            return nil, last_error(len, "receive")
        end

        if len == 0 then
            return nil, "closed"
        end

        return ffi.string(buffer, len)
    end

    function self.socket:on_close()
        tls.close(tls_client)
    end
end

function META:OnRemove()
    table.removevalue(sockets.active, self)
    self:assert(self.socket:close())
end

function META:Close(reason)
    if reason then print(reason) end
    self:Remove()
end

function META:Connect(host, service)
    if service == "https" then
        self:SetupTLS()
    end

    if self:assert(self.socket:connect(host, service)) then
        self.connecting = true
    end
end

function META:Send(data)

    local ok, err

    if self.socket:is_connected() and not self.connecting then
        ok, err = self.socket:send(data)
    else
        ok, err = false, "timeout"
    end

    if not ok then
        if err == "timeout" then
            self.buffered_send = self.buffered_send or {}
            table.insert(self.buffered_send, data)
            return true
        end

        self:Error(err)
    end

    return ok, err
end

function META:Update()
    if self.connecting then
        self.socket:poll_connect()
        if self.socket:is_connected() then
            print(self)
            if self.DoHandshake then
                local ok, err = self:DoHandshake()

                if not ok then
                    if err == "timeout" then
                        return
                    end

                    if err == "closed" then
                        self:OnClose()
                    else
                        self:Error(err)
                    end
                end

                self.DoHandshake = nil
            end

            self:OnConnect()
            self.connected = true
            self.connecting = false
        end
    elseif self.connected then

        if self.buffered_send then
            while true do
                local data = self.buffered_send[1]

                if not data then break end

                local ok, err = self.socket:send(data)

                if ok then
                    table.remove(self.buffered_send)
                elseif err ~= "timeout" then
                    self:Error("error while processing buffered queue: " .. err)
                end
            end
        end

        local chunk, err = self.socket:receive()

        if chunk then
            self:OnReceiveChunk(chunk)
        else
            if err == "closed" then
                self:OnClose()
            elseif err ~= "timeout" then
                self:Error(err)
            end
        end
    end
end

function META:Error(message, ...)
    local tr = debug.traceback()
    self:OnError(message, tr, ...)
    return false
end

function META:OnError(str) self:Remove() end
function META:OnReceiveChunk(str) end
function META:OnClose() self:Close() end
function META:OnConnect() end

META:Register()

function sockets.TCPClient(socket)
    local self = META:CreateObject()
    self:Initialize(socket)
    return self
end
