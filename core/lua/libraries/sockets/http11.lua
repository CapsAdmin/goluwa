local sockets = ... or _G.sockets

local META = prototype.CreateTemplate("socket", "http/1.1")

META.Base = "tcp_client"
META.Stage = "none"
META.MimeToExtension = {
    ["audio/aac"] = "aac",
    ["application/x-abiword"] = "abw",
    ["application/x-freearc"] = "arc",
    ["video/x-msvideo"] = "avi",
    ["application/vnd.amazon.ebook"] = "azw",
    ["application/octet-stream"] = "bin",
    ["image/bmp"] = "bmp",
    ["application/x-bzip"] = "bz",
    ["application/x-bzip2"] = "bz2",
    ["application/x-csh"] = "csh",
    ["text/css"] = "css",
    ["text/csv"] = "csv",
    ["application/msword"] = "doc",
    ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"] = "docx",
    ["application/vnd.ms-fontobject"] = "eot",
    ["application/epub+zip"] = "epub",
    ["image/gif"] = "gif",
    ["text/html"] = "html",
    ["image/vnd.microsoft.icon"] = "ico",
    ["text/calendar"] = "ics",
    ["application/java-archive"] = "jar",
    ["image/jpeg"] = "jpg",
    ["text/javascript"] = "js",
    ["application/json"] = "json",
    ["audio/midi audio/x-midi"] = "mid",
    ["application/javascript"] = "mjs",
    ["audio/mpeg"] = "mp3",
    ["video/mpeg"] = "mpeg",
    ["application/vnd.apple.installer+xml"] = "mpkg",
    ["application/vnd.oasis.opendocument.presentation"] = "odp",
    ["application/vnd.oasis.opendocument.spreadsheet"] = "ods",
    ["application/vnd.oasis.opendocument.text"] = "odt",
    ["audio/ogg"] = "oga",
    ["video/ogg"] = "ogv",
    ["application/ogg"] = "ogx",
    ["font/otf"] = "otf",
    ["image/png"] = "png",
    ["application/pdf"] = "pdf",
    ["application/vnd.ms-powerpoint"] = "ppt",
    ["application/vnd.openxmlformats-officedocument.presentationml.presentation"] = "pptx",
    ["application/x-rar-compressed"] = "rar",
    ["application/rtf"] = "rtf",
    ["application/x-sh"] = "sh",
    ["image/svg+xml"] = "svg",
    ["application/x-shockwave-flash"] = "swf",
    ["application/x-tar"] = "tar",
    ["image/tiff"] = "tif",
    ["font/ttf"] = "ttf",
    ["text/plain"] = "txt",
    ["application/vnd.visio"] = "vsd",
    ["audio/wav"] = "wav",
    ["audio/webm"] = "weba",
    ["video/webm"] = "webm",
    ["image/webp"] = "webp",
    ["font/woff"] = "woff",
    ["font/woff2"] = "woff2",
    ["application/xhtml+xml"] = "xhtml",
    ["application/vnd.ms-excel"] = "xls",
    ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"] = "xlsx",
    ["application/xml if not readable from casual users (RFC 3023, section 3)"] = "xml",
    ["application/zip"] = "zip",
    ["video/3gpp"] = "3gp",
    ["video/3gpp2"] = "3g2",
    ["application/x-7z-compressed"] = "7z",
    ["application/vnd.microsoft.portable-executable"] = "exe",
}

local legal_uri_characters = {
    ["-"] = true,
    ["."] = true,
    ["_"] = true,
    ["~"] = true,
    [":"] = true,
    ["/"] = true,
    ["?"] = true,
    ["#"] = true,
    ["["] = true,
    ["]"] = true,
    ["@"] = true,
    ["!"] = true,
    ["$"] = true,
    ["&"] = true,
    ["'"] = true,
    ["("] = true,
    [")"] = true,
    ["*"] = true,
    ["+"] = true,
    [","] = true,
    [";"] = true,
    ["=" ] = true,
    ["%" ] = true,
}

-- maybe this should be a helper?
function META:ParseURI(uri)
    local scheme
    local path
    local authority
    local host
    local port

    scheme, path = uri:match("^(%l[%l%d+.-]+):(.+)")

    if not scheme then
        return nil, "unable to parse URI: " .. uri
    end

    if path:startswith("//") then
        path = path:sub(3)

        host, rest = path:match("^(.-)/(.*)$")
        path = rest:gsub("[^%w%-_%.%!%~%*%'%(%)]", function(c)
            if not legal_uri_characters[c] then
                return string.format("%%%02X", c:byte(1,1))
            end
        end)

        if host:find("@", 1, true) then
            local temp = host:split("@")
            authority = temp[1]
            host = temp[2]
        end

        local temp = host:split(":")
        host = temp[1]

        port = temp[2]
    end

    return {
        scheme = scheme,
        path = path,
        authority = authority,
        host = host,
        port = port,
    }
end

local function default_header(header, key, val)
    if header[key] == nil then
        header[key] = val
    elseif header[key] == false then
        header[key] = nil
    end
end

function META:Request(method, url, header, body)
    header = header or {}

    local uri = self:assert(self:ParseURI(url))
    if not uri then return end

    if not self:assert(self.socket:set_option("nodelay", true, "tcp")) then return end
    --assert(self.socket:set_option("quickack", true, "tcp"))
    self:Connect(uri.host, uri.scheme)

    do
        local host = uri.host
        if uri.port then
            host = host .. ":" .. uri.port
        end

        header = header or {}
        default_header(header, "User-Agent", "goluwa/" .. jit.os)
        default_header(header, "Accept", "*/*")
        default_header(header, "Accept-Encoding", "identity")
        default_header(header, "Host", host)
        default_header(header, "Connection", "keep-alive")
        default_header(header, "DNT", "1")

        if body then
            default_header(header, "Content-Length", #body)
            default_header(header, "Content-Type", "application/octet-stream")
        end

        local str = ""

        for k, v in pairs(header) do
            str = str .. k .. ": " .. v .. "\r\n"
        end

        str = str .. "\r\n"

        if body then
            str = str .. body
        end

        self:Send(method .. " /"..uri.path.." HTTP/1.1\r\n" .. str)
    end

    self.RequestMethod = method
    self.RequestHeader = header
    self.RequestBody = body
    self.RequestURI = uri
    self.LocationHistory = self.LocationHistory or {url}
    self.HeaderHistory = self.HeaderHistory or {}

    self.Stage = "connecting"
end

function META:OnConnect()
    self.Stage = "header"
    self.RawHeader = ""
    self.RawBody = ""
end

function META:DecodeChunkedBody(body)
    local temp = {}
    local pos = 1

    for i = 1, math.huge do
        if body:sub(pos, pos + #"0\r\n\r\n"):endswith("0\r\n\r\n") then
            break
        end

        -- find nearest \r\n
        local size_stop, chunk_start = body:find("\r\n", pos, true)
        local size = tonumber(body:sub(pos, size_stop), 16)

        pos = size_stop + 2

        temp[i] = body:sub(pos, pos + size - 1)

        pos = pos + size

        local eoc = body:sub(pos, pos + 1)

        if eoc ~= "\r\n" then
            return self:Error("chunk #" .. i .. " reports a size of " .. size .. " bytes but is not terminated with \\r\\n")
        end

        pos = pos + 2
    end

    return table.concat(temp)
end

-- POST /webhook HTTP/1.1
-- HTTP/1.1 200 OK

function META:OnReceiveChunk(chunk)
    if self.Stage == "header" then
        if not self.FromClient and #self.RawHeader > 4 and not self.RawHeader:startswith("HTTP") then
            return self:Error("header does not start with HTTP (" .. self.RawHeader:sub(10) .. ")")
        end

        self.RawHeader = self.RawHeader .. chunk

        local start, stop = self.RawHeader:find("\r\n\r\n", 1, true)

        if start then
            local header = self.RawHeader:sub(1, stop)
            chunk = self.RawHeader:sub(stop+1) -- resume body here

            self.RawHeader = header

            do
                local keyvalues = {}

                for i, line in ipairs(header:split("\r\n")) do
                    if i == 1 then
                        if self.FromClient then
                            local method, path, version = line:match("^(%u+) (%S+) (HTTP/%d+%.%d+)$")

                            if version ~= "HTTP/1.1" then
                                return self:Error(version .. " protocol not supported")
                            end

                            self.Code = code
                            self.Status = status

                            if self:OnReceiveRESTMethod(method, path) == false then
                                return
                            end
                        else
                            local version, code, status = line:match("^(HTTP/%d+%.%d+) (%d+) (.+)$")

                            if version ~= "HTTP/1.1" then
                                return self:Error(version .. " protocol not supported")
                            end

                            if not code:startswith("2") and not code:startswith("3") then
                                return self:Error(code .. " " .. status, code, status)
                            end

                            self.Code = code
                            self.Status = status

                            if self:OnReceiveStatus(code, status) == false then
                                return
                            end
                        end
                    else
                        local keyval = line:split(": ")
                        local key, val = keyval[1], keyval[2]

                        keyvalues[key:lower()] = val
                    end
                end

                self.Header = keyvalues

                -- normalize some values
                do
                    local content_length = tonumber(keyvalues["content-length"])
                    if content_length == 0 then
                        content_length = nil
                    end

                    self.Header["content-length"] = content_length
                end

                self.Header["connection"] = self.Header["connection"] and self.Header["connection"]:lower() or nil
                self.Header["content-encoding"] = self.Header["content-encoding"] or "identity"
            end

            if self.Code and self.Code ~= "304" and self.Code:startswith("3") and self.Header["location"] then

                if self:OnReceiveRedirectHeader(self.Header) == false then
                    return
                end

                self:assert(self.socket:close())
                self:SocketRestart()

                local location = self.Header["location"]

                if location:startswith("/") then
                    location = self.RequestURI.scheme .. "://" .. (self.RequestHeader.Host or self.RequestURI.host) .. location
                else
                    self.RequestHeader.Host = nil
                end

                table.insert(self.LocationHistory, location)
                table.insert(self.HeaderHistory, self.Header)

                self:Request(self.RequestMethod, location, self.RequestHeader, self.RequestBody)
                return
            end

            self.Stage = "body"

            if self:OnReceiveHeader(self.Header) == false then
                return
            end

            if self.Header["connection"] == "close" then
                return self:Close()
            end
        end
    end

    if self.Stage == "body" then
        if self:OnReceiveBodyChunk(chunk) == false then
            return
        end

        self:WriteBody(chunk)

        local body = nil

        if self.Header["content-length"] and self:GetWrittenBodySize() >= self.Header["content-length"] then
            body = self:GetWrittenBodyString()
        elseif self:GetWrittenBodyString():endswith("0\r\n\r\n") then
            body = self:DecodeChunkedBody(self:GetWrittenBodyString())
        end

        if body then
            local encoding = self.Header["content-encoding"]
            if encoding ~= "identity" then
                if encoding == "gzip" then
                    local ok, str = pcall(serializer.Decode, "gunzip", body)

                    if not ok then
                        return self:Error("failed to parse " .. encoding .. " body: " .. str)
                    end

                    body = str
                else
                    print("unknown content-encoding: " .. encoding)
                end
            end

            self.Body = body

            self:OnReceiveBody(body)

            self:Close()
        end
    end
end

function META:WriteBody(data)
    self.RawBody = self.RawBody .. data
end

function META:GetWrittenBodySize()
    return #self.RawBody
end

function META:GetWrittenBodyString()
    return self.RawBody
end

function META:OnReceiveBody()

end

function META:OnReceiveHeader()

end

function META:OnReceiveRedirectHeader()

end

function META:OnReceiveBodyChunk()

end

function META:OnReceiveStatus()

end

function META:OnReceiveRESTMethod()

end

META:Register()

function sockets.HTTPClient(socket)
    local self = META:CreateObject()
    self:Initialize(socket)
    return self
end

function sockets.ConnectedTCP2HTTP(obj)
    setmetatable(obj, prototype.GetRegistered("socket", "http/1.1"))
    obj:OnConnect()
    obj.connected = true
    obj.connecting = false
    obj.FromClient = true
end

function sockets.Request(tbl)
    local a,b,c = event.Call("SocketRequest", tbl)
	if a ~= nil then
		return a,b,c
	end

    local client = sockets.HTTPClient()

    client:Request(tbl.method or "GET", tbl.url, tbl.header, tbl.post_data)

    client.OnReceiveStatus = function(_, code, status)
        if tbl.code_callback then
            tbl.code_callback(tonumber(code), status)
        end
    end

    client.OnReceiveHeader = function(_, header)
        if tbl.header_callback then
            tbl.header_callback(header)
        end
    end

    client.OnReceiveChunk = function(_, chunk)
        if tbl.on_chunks then
            tbl.on_chunks(chunk, length, header)
        end
    end

    client.OnReceiveBody = function(_, body)
        tbl.callback({
            body = self.Body,
            header = self.Header,
            code = tonumber(self.Code)
        })
    end

    client.OnError = function(_, err, tr)
        if tbl.error_callback then
            tbl.error_callback(err)
        else
            llog("sockets.Request: " .. err)
            logn(tr)
        end
    end
end

if RELOAD then
    sockets.Request({
        url = "https://news.ycombinator.com/item?id=19291558",
        callback = function(tbl) table.print(tbl) end,
    })
end