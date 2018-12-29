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

        for i, url in ipairs(urls) do
            cbs[i] = http.Download(url):Then(function(...)
                resolve(url, ...)
            end):Catch(function(reason)
                table.insert(fails, "failed to download " .. url .. ": " .. reason .. "\n")
                if #fails == #urls then
                    local reason = ""
                    for _, str in ipairs(fails) do
                        reason = reason .. str
                    end
                    reject(reason)
                end
            end):Subscribe("header", function(header)
                if header["content-length"] > 0 then
                    for _, cb in ipairs(cbs) do
                        if cb ~= cbs[i] then
                            cb:Stop()
                        end
                    end
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
    function http.Get(url, callback, timeout, user_agent, binary, debug)
        return sockets.Request({
            url = url,
            callback = callback,
            method = "GET",
            timeout = timeout,
            user_agent = user_agent,
            receive_mode = binary and "all",
            debug = debug
        })
    end
end

function http.Post(url, post_data, callback, timeout, user_agent, binary, debug)
	if type(post_data) == "table" then
		post_data = sockets.TableToHeader(post_data)
	end

	return sockets.Request({
		url = url,
		callback = callback,
		method = "POST",
		timeout = timeout,
		post_data = post_data,
		user_agent = user_agent,
		receive_mode = binary and "all",
		debug = debug
	})
end

return http