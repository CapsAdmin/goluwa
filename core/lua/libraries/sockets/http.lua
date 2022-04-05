local sockets = ... or _G.sockets

sockets.MimeToExtension = {
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

function sockets.MixinHTTP(META)
    function META:InitializeHTTPParser()
        self.http = {
            raw_header = "",
            raw_body = "",
            stage = "header",
        }
    end

    do
        local function decode_chunked_body(self, body)
            local temp = {}
            local pos = 1

            for i = 1, math.huge do
                if body:sub(pos, pos + #"0\r\n\r\n"):endswith("0\r\n\r\n") then
                    break
                end

                -- find nearest \r\n
                local size_stop, chunk_start = body:find("\r\n", pos, true)
                local size = tonumber(body:sub(pos, size_stop), 16)

                

                if not size then
                    return self:Error("chunk #" .. i .. " has no size?")
                end

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

        function META:WriteHTTP(chunk, is_response)
            local state = self.http

            if state.stage == "header" then

                if not is_response then
                    if #state.raw_header > 4 and not state.raw_header:startswith("HTTP") then
                        return self:Error("header does not start with HTTP (first 10 bytes: " .. state.raw_header:sub(10) .. ")")
                    end
                end

                state.raw_header = state.raw_header .. chunk

                local start, stop = state.raw_header:find("\r\n\r\n", 1, true)

                if start then
                    local header = state.raw_header:sub(1, stop)
                    chunk = state.raw_header:sub(stop+1) -- resume body here
                    state.raw_header = header

                    do
                        local keyvalues = {}

                        for i, line in ipairs(header:split("\r\n")) do
                            if i == 1 then
                                local ok

                                if is_response then
                                    state.method, state.path, state.version = line:match("^(%u+) (%S+) (HTTP/%d+%.%d+)$")
                                    if self:OnHTTPEvent("response") == false then
                                        self:InitializeHTTPParser()
                                        return
                                    end
                                else
                                    state.version, state.code, state.status = line:match("^(HTTP/%d+%.%d+) (%d+) (.+)$")
                                    if self:OnHTTPEvent("status") == false then
                                        self:InitializeHTTPParser()
                                        return
                                    end
                                end

                                if state.version ~= "HTTP/1.1" and state.version ~= "HTTP/1.0" then
                                    return self:Error(tostring(state.version) .. " protocol not supported")
                                end
                            else
                                local keyval = line:split(": ")
                                local key, val = keyval[1], keyval[2]

                                keyvalues[key:lower()] = val
                            end
                        end

                        -- normalize some values
                        do
                            local content_length = tonumber(keyvalues["content-length"])
                            if content_length == 0 then
                                content_length = nil
                            end

                            keyvalues["content-length"] = content_length
                        end

                        keyvalues["connection"] = keyvalues["connection"] and keyvalues["connection"]:lower() or nil
                        keyvalues["content-encoding"] = keyvalues["content-encoding"] or "identity"

                        state.header = keyvalues
                    end

                    if self:OnHTTPEvent("header") == false then
                        self:InitializeHTTPParser()
                        return
                    end

                    state.stage = "body"
                end
            end

            if state.stage == "body" then

                if state.header["transfer-encoding"] == "chunked" then
                    if (not state.received_bytes or not state.to_receive) or state.received_bytes > state.to_receive then
                        local hex_num, rest = chunk:match("^([abcdefABCDEF0123456789]-)\r\n(.+)")
                        
                        if hex_num == "0" then
                            state.chunked_done = true
                        elseif hex_num then
                            local num = tonumber("0x" .. hex_num) or 0
                            self:SetBufferSize(num)
                            state.to_receive = num
                        else
                            state.to_receive = 0
                        end

                        chunk = rest or chunk
                        state.received_bytes = 0
                    end
                    
                    state.received_bytes = (state.received_bytes or 0) + #chunk

                    if state.received_bytes > state.to_receive then
                        local hex_num, rest = chunk:match("^([abcdefABCDEF0123456789]-)\r\n(.+)")

                        if hex_num == "0" or chunk:endswith("0\r\n\r\n") then
                            state.chunked_done = true
                        end
                    end
                end

                state.current_body_chunk = chunk

                if self:OnHTTPEvent("chunk") == false then return end

                self:WriteBody(chunk)

                local body = nil

                if state.header["transfer-encoding"] == "chunked" then
                    if state.chunked_done then
                    body = self:GetWrittenBodyString()
                    end
                elseif state.header["content-length"] and self:GetWrittenBodySize() >= state.header["content-length"] then
                    body = self:GetWrittenBodyString()
                elseif self:GetWrittenBodyString():endswith("0\r\n\r\n") then
                    body = decode_chunked_body(self, self:GetWrittenBodyString())
                    if body == false then return end
                end

                if body then
                    local encoding = state.header["content-encoding"]
                    if encoding ~= "identity" then
                        if encoding == "gzip" then
                            local ok, str = pcall(serializer.Decode, "gunzip", body)

                            if ok == false then
                                return self:Error("failed to parse " .. encoding .. " body: " .. str)
                            end

                            body = str
                        else
                            return self:Error("unknown content-encoding: " .. encoding)
                        end
                    end

                    state.body = body

                    self:OnHTTPEvent("body")
                end
            end

            return true
        end
    end

    function META:WriteBody(data)
        self.http.raw_body = self.http.raw_body .. data
    end

    function META:GetWrittenBodySize()
        return #self.http.raw_body
    end

    function META:GetWrittenBodyString()
        return self.http.raw_body
    end

    function META:OnHTTPEvent(what) end
    --function META:Error(what) return false end
end

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


function sockets.DecodeURI(uri)
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
        host, rest = path:match("^(.-)(/.*)$")
        if rest then
            path = rest:gsub("[^%w%-_%.%!%~%*%'%(%)]", function(c)
                if not legal_uri_characters[c] then
                    return string.format("%%%02X", c:byte(1,1))
                end
            end)
        else
            host = path
            path = "/"
        end

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

function sockets.EncodeURI(tbl)
    local uri = ""

    if tbl.scheme then
        uri = uri .. tbl.scheme .. "://"
    end

    if tbl.authority then
        uri = uri .. tbl.authority .. "@"
    end

    if tbl.host then
        uri = uri .. tbl.host .. "/"
    end

    if tbl.path or tbl.query then
        local str = ""

        if tbl.path then
            str = str .. tbl.path
        end

        if tbl.query then
            str = str .. "?"
            for k, v in pairs(tbl.query) do
                str = str .. k .. "=" .. v .. "&"
            end
            if str:endswith("&") then
                str = str:sub(0,-2)
            end
        end

        str = str:gsub("[^%w%-_%.%!%~%*%'%(%)]", function(c)
            if not legal_uri_characters[c] then
                return string.format("%%%02X", c:byte(1,1))
            end
        end)

        uri = uri .. str
    end

    return uri
end

local function default_header(header, key, val)
    if header[key] == nil then
        header[key] = val
    elseif header[key] == false then
        header[key] = nil
    end
end


local function build_http(tbl)
    local str = ""

    if tbl.method then
        str = str .. tbl.method .. " "
    end

    if tbl.path then
        str = str .. tbl.path .. " "
    end

    str = str .. tbl.protocol

    if tbl.code then
        str = str .. " " .. tbl.code
    end

    if tbl.status then
        str = str .. " " .. tbl.status
    end

    str = str .. "\r\n"

    if tbl.header then
        for k, v in pairs(tbl.header) do
            str = str .. k .. ": " .. tostring(v) .. "\r\n"
        end
    end

    str = str .. "\r\n"

    if tbl.body then
        str = str .. tbl.body
    end

    return str
end

function sockets.HTTPRequest(method, uri, header, body)
    header = header or {}

    default_header(header, "User-Agent", "goluwa/" .. jit.os)
    default_header(header, "Accept", "*/*")
    default_header(header, "Accept-Encoding", "identity")
    do
        local host = uri.host

        if uri.port then
            host = host .. ":" .. uri.port
        end
        default_header(header, "Host", host)
    end
    default_header(header, "Connection", "keep-alive")
    default_header(header, "DNT", "1")

    if body then
        default_header(header, "Content-Length", #body)
        default_header(header, "Content-Type", "application/octet-stream")
    end

    local str = build_http({
        protocol = "HTTP/1.1",
        method = method,
        path = uri.path,
        header = header,
        body = body,
    })

    return str
end

function sockets.HTTPResponse(code, status, header, body)
    header = header or {}

    if body then
        default_header(header, "Content-Length", #body)
    end

    local str = build_http({
        protocol = "HTTP/1.1",
        code = code,
        status = status,
        header = header,
        body = body,
    })

    return str
end

if RELOAD then 
    local client = sockets.HTTPClient()

    client:Request("GET", "https://primes.utm.edu/lists/small/100000.txt")

    function client:OnReceiveStatus(code, status) print(code, status) end
    function client:OnReceiveHeader(header, raw_header) table.print(header) end
    function client:OnReceiveBodyChunk(chunk) print(chunk) end
    function client:OnReceiveBody(body) print(body) end
end