local callback = _G.callback or {}

do
	local meta = {}
	meta.__index = meta

	--meta.Type = "callback"
	function meta:__tostring()
		return string.format("callback: %p", self)
	end

	function meta:Start()
		if not self.on_start then return end

		if self.start_on_callback then return end

		self:on_start()
		return self
	end

	function meta:Stop()
		if self.on_stop then self:on_stop() end
	end

	local function done(self)
		for _, cb in ipairs(self.funcs.done) do
			cb()
		end
	end

	function meta:Resolve(...)
		if self.is_resolved or self.is_rejected then
			logn(
				self,
				"attempted to resolve " .. (
						self.is_resolved and
						"resolved" or
						"rejected"
					) .. " promise"
			)
			logn(self.debug_trace)
			return
		end

		if not self.funcs.resolved[1] and self.warn_unhandled then
			logn(self, " unhandled resolve: ", ...)
			logn(self.debug_trace)
		end

		for _, cb in ipairs(self.funcs.resolved) do
			local ok, err, err2 = system.pcall(cb, ...)

			if not ok then return self:Reject(err) end

			if ok and err == false and type(err2) == "string" then
				return self:Reject(err2)
			end
		end

		done(self)
		self.is_resolved = true
		return self
	end

	local handled = false

	function meta:Reject(...)
		if self.is_resolved then
			--logn(self, "attempted to resolve resolved promise")
			--logn(self.debug_trace)
			return
		end

		handled = false

		if self.children then
			for _, cb in ipairs(self.children) do
				cb:Reject(...)
			end
		end

		for _, cb in ipairs(self.funcs.rejected) do
			cb(...)
			handled = true
		end

		if not handled and self.warn_unhandled then
			logn(self, " unhandled reject: ", ...)
			logn(debug.traceback("current trace:"))
			logn(self.debug_trace)
		end

		done(self)
		self.is_rejected = true
		return self
	end

	function meta:Then(func)
		local cb = callback.Create()
		cb.parent = self
		cb.warn_unhandled = false
		list.insert(self.children, cb)

		list.insert(self.funcs.resolved, function(...)
			local ret = list.pack(func(...))
			local returned_cb = ret[1]

			if getmetatable(returned_cb) == meta then
				returned_cb:Catch(function(...)
					return cb:Reject(...)
				end)

				return returned_cb:Then(function(...)
					return cb:Resolve(...)
				end),
				list.unpack(ret, 2)
			else
				cb:Resolve(...)
			end

			return list.unpack(ret)
		end)

		if self.start_on_callback then
			self.start_on_callback = nil
			self:Start()
		end

		return cb
	end

	function meta:Catch(func)
		list.insert(self.funcs.rejected, func)
		return self
	end

	function meta:Done(callback)
		list.insert(self.funcs.done, callback)
		return self
	end

	function meta:Get()
		local res
		local err

		self:Then(function(...)
			res = {...}
		end)

		self:Catch(function(msg)
			err = msg
		end)

		while not res do
			if err then error(err, 3) end

			tasks.Wait()
		end

		return unpack(res)
	end

	function meta:Subscribe(what, callback)
		if self.parent then return self.parent:Subscribe(what, callback) end

		self.funcs[what] = self.funcs[what] or {}
		list.insert(self.funcs[what], callback)
		return self
	end

	local function on_index(t, key)
		local self = t.self
		return function(...)
			if key == "resolve" then
				local ok, err = self:Resolve(...)

				if ok == false and err then
					self.is_resolved = false
					self:Reject(err)
				end
			elseif key == "reject" then
				return self:Reject(...)
			elseif self.funcs[key] then
				for _, cb in ipairs(self.funcs[key]) do
					local ok, ret, err = system.pcall(cb, ...)

					if not ok or ret == false and err then return self:Reject(err) end
				end
			end
		end
	end

	function callback.Create(on_start)
		local self = setmetatable({}, meta)
		self.on_start = on_start
		self.funcs = {resolved = {}, rejected = {}, done = {}}
		self.callbacks = setmetatable({self = self}, {__index = on_index})
		self.debug_trace = debug.traceback("creation trace:")
		self.children = {}
		self.warn_unhandled = true
		return self
	end
end

function callback.WrapKeyedTask(create_callback, max, queue_callback, start_on_callback)
	local callbacks = {}
	local total = 0
	local queue = {}
	max = max or math.huge

	local function add(key, ...)
		local args = list.pack(...)

		if not callbacks[key] or callbacks[key].is_resolved or callbacks[key].is_rejected then
			callbacks[key] = callback.Create(function(self)
				create_callback(self, key, list.unpack(args))
			end)
			callbacks[key].start_on_callback = start_on_callback

			if total >= max then
				list.insert(queue, callbacks[key])
				callbacks[key].key = key

				if queue_callback then
					queue_callback("push", callbacks[key], key, queue)
				end
			else
				callbacks[key]:Start()

				if max ~= math.huge then
					callbacks[key]:Done(function()
						total = total - 1

						if total < max then
							local cb = list.remove(queue)

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

		if tasks.GetActiveTask() then return callbacks[key]:Get() end

		return callbacks[key]
	end

	return add
end

function callback.WrapTask(create_callback)
	return function(...)
		local args = list.pack(...)
		local cb = callback.Create(function(self)
			create_callback(self, list.unpack(args))
		end)
		cb:Start()
		return cb
	end
end

function callback.Resolve(...)
	local args = list.pack(...)
	local cb = callback.Create(function(self)
		self.callbacks.resolve(list.unpack(args))
	end)

	timer.Delay(function()
		cb:Start()
	end)

	return cb
end

if RELOAD then
	local function await(func)
		tasks.enabled = true
		tasks.CreateTask(func)
	end

	local Delay = callback.WrapTask(function(self, delay)
		local resolve = self.callbacks.resolve
		local reject = self.callbacks.reject

		timer.Delay(delay, function()
			resolve("result!")
		end)
	end)

	await(function()
		print(1)
		local res = Delay(1):Get()
		print(2, res)
	end)
end

return callback