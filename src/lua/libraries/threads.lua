local threads = _G.threads or {}

threads.max = 4

threads.coroutine_lookup = threads.coroutine_lookup or utility.CreateWeakTable()
threads.created = threads.created or {}

local enabled event.AddListener("Initialize", function() enabled = console.CreateVariable("threads_enable", true) end)

local META = prototype.CreateTemplate("thread")

prototype.GetSet(META, "Frequency", 0)
prototype.GetSet(META, "IterationsPerTick", 1)
prototype.GetSet(META, "EnsureFPS", 30)
prototype.IsSet(META, "Running", false)
 
META.wait = 0
 
function META:Start(now)
	
	if not enabled:Get() then
		event.Delay(0, function() self:OnStart() end)
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
	
	threads.coroutine_lookup[co] = self
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
				threads.created[self] = nil
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
		event.CreateThinker(start, true, self.EnsureFPS, true)
	elseif self.Frequency == 0 then
		event.CreateThinker(start, true, 0, self.IterationsPerTick)
	else
		event.CreateThinker(start, true, 1/self.Frequency, self.IterationsPerTick)
	end
end
 
function META:Sleep(sec)
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
	threads.created[self] = nil
end

prototype.Register(META)

function threads.CreateThread(on_start, on_finish)
	local self = prototype.CreateObject(META)
	
	if on_start then self.OnStart = function(_, ...) return on_start(...) end end
	if on_finish then self.OnFinish = function(_, ...) return on_finish(...) end end
	
	if on_start then self:Start() end
	
	threads.created[self] = self

	return self
end

function threads.Sleep(time)
	local thread = threads.coroutine_lookup[coroutine.running()]
	if thread then
		thread:Sleep(time)
	end
end

function threads.ReportProgress(what, max)
	local thread = threads.coroutine_lookup[coroutine.running()]
	if thread then
		thread:ReportProgress(what, max)
	end
end

function threads.Report(what)
	local thread = threads.coroutine_lookup[coroutine.running()]
	if thread then
		thread:Report(what)
	end
end

function threads.IsBusy()
	return threads.busy
end

event.CreateTimer("threads", 0.25, 0, function()	
	local i = 0
	
	if next(threads.created) then
		threads.busy = true
	else
		threads.busy = false
	end
	
	for thread in pairs(threads.created) do
		if thread:IsRunning() then
			i = i + 1
		end
		
		if i >= threads.max then return end
	end
	
	if i == 0 then
		system.SetJITOption("minstitch", 0)
	else
		system.SetJITOption("minstitch", 100000)
	end
	
	for thread in pairs(threads.created) do
		if thread.run_me then
			thread:Start(true)
		end
	end
end)

return threads