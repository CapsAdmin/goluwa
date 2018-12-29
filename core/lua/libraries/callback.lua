local callback = _G.callback or {}

do
    local meta = {}
    meta.__index = meta

    meta.Type = "callback"

    function meta:__tostring()
        return string.format("callback: %p", self)
    end

    function meta:Start()
        if self.start_on_callback then
            return
        end
        self:on_start()
        return self
    end

    function meta:Stop()
        if self.on_stop then
            self:on_stop()
        end
    end

    local function done(self)
        for _, cb in ipairs(self.funcs.done) do
            cb()
        end
    end

    function meta:Resolve(...)
        if self.is_resolved then
            logn(self, "attempted to resolve resolved promise")
            logn(self.debug_trace)
            return
        end

        if not self.funcs.resolved[1] then
            logn(self, " unhandled resolve: ", ...)
            logn(self.debug_trace)
        end

        for _, cb in ipairs(self.funcs.resolved) do
            local ok, err = pcall(cb, ...)
            if not ok then
                return self:Reject(err)
            end
        end

        done(self)

        self.is_resolved = true

        return self
    end

    function meta:Reject(...)
        if not self.funcs.rejected[1] then
            logn(self, " unhandled reject: ", ...)
            logn(self.debug_trace)
        end

        for _, cb in ipairs(self.funcs.rejected) do
            cb(...)
        end

        done(self)

        return self
    end

    function meta:Resolved(callback)
        table.insert(self.funcs.resolved, callback)

        if self.start_on_callback then
            self.start_on_callback = nil
            self:Start()
        end

        return self
    end

    function meta:Rejected(callback)
        table.insert(self.funcs.rejected, callback)
        return self
    end

    function meta:Done(callback)
        table.insert(self.funcs.done, callback)
        return self
    end

    meta.Then = meta.Resolved
    meta.Catch = meta.Rejected

    function meta:Subscribe(what, callback)
        self.funcs[what] = self.funcs[what] or {}
        table.insert(self.funcs[what], callback)
        return self
    end

    local function on_index(t, key)
        local self = t.self

        return function(...)
            if key == "resolve" then
                return self:Resolve(...)
            elseif key == "reject" then
                return self:Reject(...)
            elseif self.funcs[key] then
                for _, cb in ipairs(self.funcs[key]) do
                    local ok, err = pcall(cb, ...)
                    if not ok then
                        return self:Reject(err)
                    end
                end
            end
        end
    end

    function callback.Create(on_start)
        local self = setmetatable({}, meta)

        self.on_start = on_start
        self.funcs = {resolved = {}, rejected = {}, done = {}}

        self.callbacks = setmetatable({self = self}, {__index = on_index})
        self.debug_trace = debug.traceback()

        return self
    end
end

function callback.WrapKeyedTask(create_callback, max, queue_callback, start_on_callback)
    local callbacks = {}

    local total = 0
    local queue = {}
    max = max or math.huge

    local function add(key, ...)
        local args = {...}
        if not callbacks[key] or callbacks[key].is_resolved then
            callbacks[key] = callback.Create(function(self)
                create_callback(self, key, unpack(args))
            end)

            callbacks[key].start_on_callback = start_on_callback

            if total >= max then
                table.insert(queue, callbacks[key])
                callbacks[key].key = key
                if queue_callback then
                    queue_callback("push", callbacks[key], key, queue)
                end
            else
                callbacks[key]:Start()

                if max then
                    callbacks[key]:Done(function()
                        total = total - 1

                        if total < max then
                            local cb = table.remove(queue)
                            if cb then
                                if queue_callback then
                                    queue_callback("pop", cb, cb.key, queue)
                                end
                                cb:Start()
                            end
                        end
                    end)

                    total = total + 1
                end
            end
        end

        return callbacks[key]
    end

    return add
end

function callback.WrapTask(create_callback)
    return function(...)
        local args = {...}
        local cb = callback.Create(function(self)
            create_callback(self, unpack(args))
        end)
        cb:Start()
        return cb
    end
end

return callback