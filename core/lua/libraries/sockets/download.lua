local sockets = ... or _G.sockets

local function posixtime2http(posix_time)
    return require("date")(posix_time):fmt("${http}")
end

local function http2posixtime(http_time)
    return (require("date")(http_time) - require("date").epoch()):spanseconds()
end

local function decode_data_uri(uri)
    local mime, encoding, data = uri:match("data:(.-);(.-),(.+)")
    if encoding == "" then
        encoding = "base64"
    end

    if encoding == "base64" then
        vfs.Write("test." .. META.MimeToExtension[mime], crypto.Base64Decode(data))
    else
        error("unknown encoding " .. encoding)
    end

    return
end

local function find_best_name(http)
    local contestants = {}

    if http.Header["content-disposition"] then
        local file_name = http.Header["content-disposition"]:match("filename=(%b\"\")")
        if file_name then
            file_name = file_name:sub(2, -2)
            table.insert(contestants, {score = math.huge, name = file_name})
        end
    end

    for _, url in ipairs(http.LocationHistory) do
        local score = 0
        local name = vfs.GetFileNameFromPath(url):gsub("%%(%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
        end)

        name = name:gsub("^(.+)%?.+$", "%1")
        local ext = vfs.GetExtensionFromPath(name)
        if #ext > 0 then
            score = score + 10
        end

        score = score - (select(2, name:gsub("%p", "")) or 0)

        table.insert(contestants, {score = score, name = name})
    end

    table.sort(contestants, function(a, b) return a.score > b.score end)

    local name = contestants[1].name

    if http.Header["content-type"] and #vfs.GetExtensionFromPath(name) == 0 then
        local mime = http.Header["content-type"]:match("^(.-);") or http.Header["content-type"]
        name = name .. "." .. http.MimeToExtension[mime] or "dat"

    end

    return name
end

local function move_and_finish(path, on_finish)
    assert(vfs.Rename(path .. ".part", vfs.GetFileNameFromPath(path)))
    on_finish(path)
end

sockets.active_downloads = sockets.active_downloads or {}

function sockets.Download(url, on_finish, on_error, on_chunks, on_header, on_code)
    local http = sockets.HTTPClient()

    local lookup = {url = url, client = http}
    table.insert(sockets.active_downloads, lookup)

    local buffer = {}
    local written_size = 0
    local total_size = math.huge

    function http:OnReceiveStatus(status, reason)
        if status:startswith("4") then
            self:Error(reason)
            return false
        elseif on_code then
            on_code(tonumber(status))
        end
    end

    function http:WriteBody(chunk)
        table.insert(buffer, chunk)
        written_size = written_size + #chunk

        if on_chunks then
            on_chunks(chunk, written_size, total_size, http.friendly_name)
        end
    end

    function http:GetWrittenBodySize()
        return written_size
    end

    function http:GetWrittenBodyString()
        return table.concat(buffer)
    end

    function http:OnReceiveHeader(header)
        http.friendly_name = find_best_name(self)

        total_size = header["content-length"] or total_size

        if on_header then
            on_header(header)
        end
    end

    function http:OnReceiveBody(body)
        on_finish(body)
        table.removevalue(sockets.active_downloads, lookup)
    end

    function http:OnError(reason)
        if on_error then
            on_error(reason)
        else
            llog("sockets.Download(" .. url .. ") failed: " .. reason)
        end
        self:Close()
        table.removevalue(sockets.active_downloads, lookup)
    end

    http:Request("GET", url, header)

    return http
end

function sockets.DownloadToPath(url, path, on_finish, on_error, on_progress, on_header)
    on_finish = on_finish or function(path) print("finished downloading " .. path) end
    on_error = on_error or function(reason) print("error ", reason) end
    on_progress = on_progress or function(bytes, size)
        if size == math.huge then
            size = "unknown"
        end
        print("progress: " .. bytes .. "/" .. size)
    end
    on_header = on_header or function(header)

    end

    local etag = vfs.GetAttribute(path..".part", "socket_download_etag") or vfs.GetAttribute(path, "socket_download_etag")
    local total_size = vfs.GetAttribute(path ..".part", "socket_download_total_size") or vfs.GetSize(path) or 0

    local file
    local written_size = 0
    local current_size = vfs.GetSize(path .. ".part") or 0
    local progress_size = math.huge

    if current_size > total_size then
        etag = nil
        current_size = 0
        vfs.Delete(path ..".part")
    elseif current_size == total_size and total_size > 0 then
        move_and_finish(path, on_finish)
        return
    end

    local header = {}

    if etag and not total_size then
        header["If-None-Match"] = etag
    end

    if current_size > 0 then
        header["range"] = "bytes=" .. current_size .. "-"
    end

    local http = sockets.HTTPClient()

    local lookup = {url = url, client = client}
    table.insert(sockets.active_downloads, lookup)

    event.Call("DownloadStart", url)

    http:Request("GET", url, header)

    function http:OnReceiveStatus(status, reason)
        if status:startswith("4") then
            event.Call("DownloadStop", url, nil, "recevied code " .. status)
            return false
        else
            event.Call("DownloadCodeReceived", url, tonumber(status))
        end
    end

    function http:WriteBody(chunk)
        event.Call("DownloadChunkReceived", url, chunk)
        file:Write(chunk)
        written_size = written_size + #chunk
        on_progress(tonumber(file:GetPosition()), tonumber(total_size), http.friendly_name)
    end

    function http:GetWrittenBodySize()
        return written_size
    end

    function http:GetWrittenBodyString()
        file:PushPosition(0)
        local data = file:ReadAll()
        file:PopPosition()
        return data or ""
    end

    function http:OnReceiveHeader(header)
        http.friendly_name = find_best_name(self)

        if vfs.IsFile(path) and etag == header.etag then
            on_finish(path)
            self:Close()
            return false
        else
            file = vfs.Open(path .. ".part", "read_write")
            current_size = file:GetSize()
            file:SetPosition(current_size)
            if current_size == 0 then
                vfs.SetAttribute(path .. ".part", "socket_download_total_size", header["content-length"])
                total_size = header["content-length"]
            end
        end

        if header.etag then
            vfs.SetAttribute(path .. ".part", "socket_download_etag", header.etag)
            vfs.SetAttribute(path, "socket_download_etag", header.etag)
        end

        on_header(header)

        event.Call("DownloadHeaderReceived", url, header)
    end

    function http:OnReceiveBody(body)
        file:Flush()
        file:Close()
        move_and_finish(path, on_finish)

        table.removevalue(sockets.active_downloads, lookup)

        event.Call("DownloadStop", url, body)
    end

    function http:OnError(reason)
        on_error(reason)
        self:Close()
        table.removevalue(sockets.active_downloads, lookup)
    end

    return http
end

function sockets.StopDownload(url)
    for i = #sockets.active_downloads, 1, -1 do
        local v = sockets.active_downloads[i]

        if v.url == url then
            v.client:Close()
            table.remove(sockets.active_downloads, i)
        end
    end
end

if RELOAD then
    local function download(url, on_finish)
        event.Call("DownloadStart", url)
        local client
        client = sockets.Download(
            url,
            function(data)
                event.Call("DownloadStop", client, data)
                if on_finish then
                    on_finish(data)
                end
            end,
            function(reason)
                llog(client.url, " failed to download: ", reason)
                event.Call("DownloadStop", client, nil, reason)
            end,
            function(chunk, written_size, total_size, friendly_name)
                event.Call("DownloadChunkReceived", client, chunk)
            end,
            function(header)
                event.Call("DownloadHeaderReceived", client, header)
            end,
            function(code)
                event.Call("DownloadCodeReceived", client, tonumber(code))
            end
        )
        client.url = url
    end

    download("https://upload.wikimedia.org/wikipedia/commons/c/cc/ESC_large_ISS022_ISS022-E-11387-edit_01.JPG")
end