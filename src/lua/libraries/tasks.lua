local tasks = _G.tasks or {}

tasks.max = 4

tasks.coroutine_lookup = tasks.coroutine_lookup or utility.CreateWeakTable()
tasks.created = tasks.created or {}

local enabled = {Get = function() return false end} event.AddListener("Initialize", function() enabled = pvars.Setup("tasks_enable", true) end)

local META = prototype.CreateTemplate("task")

prototype.GetSet(META, "Frequency", 0)
prototype.GetSet(META, "IterationsPerTick", 1)
prototype.GetSet(META, "EnsureFPS", 30)
prototype.IsSet(META, "Running", false)

META.wait = 0

function META:Start(now)

	if not enabled:Get() then
		self:OnStart()
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

	self.progress = {}

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
	if not enabled:Get() then return end
	if sec then self.wait = system.GetElapsedTime() + sec end
	coroutine.yield()
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
	if not self.last_report or self.last_report < system.GetTime() then
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

prototype.Register(META)

function tasks.CreateTask(on_start, on_finish)
	local self = prototype.CreateObject(META)

	if on_start then self.OnStart = function(_, ...) return on_start(...) end end
	if on_finish then self.OnFinish = function(_, ...) return on_finish(...) end end

	if on_start then self:Start() end

	tasks.created[self] = self

	return self
end

function tasks.Wait(time)
	local thread = tasks.coroutine_lookup[coroutine.running()]
	if thread then
		thread:Wait(time)
	end
end

function tasks.ReportProgress(what, max)
	local thread = tasks.coroutine_lookup[coroutine.running()]
	if thread then
		thread:ReportProgress(what, max)
	end
end

function tasks.Report(what)
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

event.Timer("tasks", 0.25, 0, function()
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
end)

return tasks