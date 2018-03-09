local tasks = _G.tasks or {}

tasks.max = 4

tasks.coroutine_lookup = tasks.coroutine_lookup or table.weak()
tasks.created = tasks.created or {}

function tasks.IsEnabled()
	return false
end

function tasks.WaitForTask(name, callback)
	if not tasks.IsEnabled() then
		callback()
		return
	end
	event.AddListener("TaskFinished", "wait_for_task_" .. name, function(task)
		if task:GetName() == name then
			callback()
			return e.EVENT_DESTROY
		end
	end)
end

local META = prototype.CreateTemplate("task")

META:GetSet("Frequency", 0)
META:GetSet("IterationsPerTick", 1)
META:GetSet("EnsureFPS", 30)
META:IsSet("Running", false)

META.wait = 0

function META:Start(now)

	self.progress = {}

	if not tasks.IsEnabled() then
		local ok, err = pcall(self.OnStart, self)
		if not ok then
			if self.OnError then
				self:OnError(err)
			else
				logf("%s error: %s\n", self, err)
			end
		end

		local ok, err = pcall(self.OnFinish, self)
		if not ok then
			if self.OnError then
				self:OnError(err)
			else
				logf("%s error: %s\n", self, err)
			end
		end

		event.Call("TaskFinished", self)
		self:Remove()
		return
	end

	if not now then
		self.run_me = true
		return
	end

	self.Running = true
	self.run_me = nil

	local co = coroutine.create(function(...)
		return select(2, system.pcall(self.OnStart, ...))
	end)

	tasks.coroutine_lookup[co] = self
	self.co = co

	local start = function()
		if not self:IsValid() then return false end -- removed

		local time = system.GetElapsedTime()

		if self.debug then
			if next(self.progress) then
				for k, v in pairs(self.progress) do
					if v.i <= v.max then
						if not v.last_print or v.last_print < time or v.i == v.max then
							logf("%s %s progress: %s\n", self, k, self:GetProgress(k))
							v.last_print = time + 1
						end
						if v.i == v.max then
							self.progress[k] = nil
						end
					end
				end
			end
		end

		if time > self.wait then
			local ok, res, err = coroutine.resume(co, self)

			if coroutine.status(co) == "dead" then
				self.Running = false
				tasks.created[self] = nil
				self:OnUpdate()
				self:OnFinish(res)
				event.Call("TaskFinished", self)
				return false
			end

			if ok == false and res then
				if self.OnError then
					self:OnError(res)
				else
					logf("%s internal error: %s\n", self, res)
				end
			elseif ok and res == false and err then
				if self.OnError then
					self:OnError(err)
				else
					logf("%s user error: %s\n", self, err)
				end
			else
				self:OnUpdate()
			end

			return res
		end
	end

	if self.EnsureFPS ~= 0 then
		event.Thinker(start, true, self.EnsureFPS, true)
	elseif self.Frequency == 0 then
		event.Thinker(start, true, 0, self.IterationsPerTick)
	else
		event.Thinker(start, true, 1/self.Frequency, self.IterationsPerTick)
	end
end

function META:Wait(sec)
	if sec then self.wait = system.GetElapsedTime() + sec end
	if tasks.IsEnabled() then
		coroutine.yield()
	end
end

function META:OnStart()
	return false, "run function not defined"
end

function META:OnFinish()

end

function META:OnUpdate()

end

function META:Report(what)
	if not self.debug then return end
	if not self.last_report or self.last_report < system.GetElapsedTime() then
		logf("%s report: %s\n", self, what)
		self.last_report = system.GetElapsedTime() + 1
	end
end

function META:ReportProgress(what, max)
	if not self.debug then return end
	self.progress[what] = self.progress[what] or {}
	self.progress[what].i = (self.progress[what].i or 0) + 1
	self.progress[what].max = max or 100
end

function META:GetProgress(what)
	if self.progress[what] then
		return ("%.2f%%"):format(math.round((self.progress[what].i / self.progress[what].max) * 100, 3))
	end

	return "0%"
end

function META:OnRemove()
	tasks.created[self] = nil
end

META:Register()

function tasks.CreateTask(on_start, on_finish)
	local self = META:CreateObject()

	if on_start then self.OnStart = function(_, ...) return on_start(...) end end
	if on_finish then self.OnFinish = function(_, ...) return on_finish(...) end end

	if on_start then self:Start() end

	tasks.created[self] = self

	if tasks.IsEnabled() and not event.IsTimer("tasks") then
		event.Timer("tasks", 0.25, 0, tasks.Update)
	end

	return self
end

function tasks.GetActiveTask()
	return tasks.coroutine_lookup[coroutine.running()]
end

function tasks.Wait(time)
	if not tasks.IsEnabled() then return end
	local thread = tasks.coroutine_lookup[coroutine.running()]
	if thread then
		thread:Wait(time)
	end
end

function tasks.ReportProgress(what, max)
	if not tasks.IsEnabled() then return end
	local thread = tasks.coroutine_lookup[coroutine.running()]
	if thread then
		thread:ReportProgress(what, max)
	end
end

function tasks.Report(what)
	if not tasks.IsEnabled() then return end
	local thread = tasks.coroutine_lookup[coroutine.running()]
	if thread then
		thread:Report(what)
	end
end

function tasks.IsBusy()
	return tasks.busy
end

function tasks.Panic()
	for thread in pairs(tasks.created) do
		thread:Remove()
	end
end

function tasks.Update()
	local i = 0

	if next(tasks.created) then
		if not tasks.busy then
			tasks.busy = true
			event.Call("TasksBusy", true)
		end
	else
		if tasks.busy then
			tasks.busy = false
			event.Call("TasksBusy", false)
		end
	end

	for thread in pairs(tasks.created) do
		if thread:IsRunning() then
			i = i + 1
		end

		if i >= tasks.max then return end
	end

	for thread in pairs(tasks.created) do
		if thread.run_me then
			thread:Start(true)
		end
	end
end

return tasks
