local http = _G.http or {}

do
    local start = callback.WrapKeyedTask(function(self, url)
        local socket = sockets.Download(url, self.callbacks.resolve, self.callbacks.reject, self.callbacks.chunks, self.callbacks.header)
        self.on_stop = function() if socket:IsValid() then socket:Remove() end end
    end, 20, function(what, cb, key, queue)
        if what == "push" then
            llog("queueing %s (too many active downloads %s)", key, #queue)
        end
    end)

    function http.Download(url)
        return start(url)
    end
end

do
    local start = callback.WrapKeyedTask(function(self, key, urls)
        local resolve = self.callbacks.resolve
        local reject = self.callbacks.reject

        local cbs = {}
        local fails = {}

        local function fail(url, reason)
            table.insert(fails, "failed to download " .. url .. ": " .. reason .. "\n")
            if #fails == #urls then
                local reason = ""
                for _, str in ipairs(fails) do
                    reason = reason .. str
                end
                reject(reason)
            end
        end

        for i, url in ipairs(urls) do
            cbs[i] = http.Download(url):Then(function(...)
                resolve(url, ...)
            end):Catch(function(reason)
                fail(url, reason or "no reason")
            end):Subscribe("header", function(header)
                if header["content-length"] and header["content-length"] > 0 then
                    for _, cb in ipairs(cbs) do
                        if cb ~= cbs[i] then
                            cb:Stop()
                        end
                    end
                else
                    fail(url, "download length is 0")
                end
            end)
        end

        return true
    end)

    function http.DownloadFirstFound(urls)
        return start(table.concat(urls), urls)
    end
end

do
    function http.Get(url, callback, timeout, binary, debug)
        return sockets.Request({
            method = "GET",
            url = url,
            callback = callback,
        })
    end
end

function http.Post(url, body, callback)
	 sockets.Request({
        method = "POST",
		url = url,
		callback = callback,
		body = body,
	})
end

if RELOAD then
    --print("!?")
    --http.DownloadFirstFound({"https://dl.dafont.com/dl/?f=helveticaaDAWDAWD", "https://dl.dafont.com/dl/?f=helvetica"}):Then(function(url, data)
        ---print("?!?!")
    --end)

    sockets.Download("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/extras/roboto italic")
end

return http