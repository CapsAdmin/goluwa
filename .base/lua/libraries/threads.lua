local threads = _G.threads or {}

threads.created = threads.created or utility.CreateWeakTable()

local META = prototype.CreateTemplate("thread")

prototype.GetSet(META, "Frequency", 0)
prototype.GetSet(META, "IterationsPerTick", 1)
prototype.GetSet(META, "EnsureFPS", 120)
 
META.wait = 0
 
function META:Start()
	local co = coroutine.create(function(...) 
		return select(2, xpcall(self.OnStart, system.OnError, ...)) 
	end)
	
	threads.created[co] = self
	self.co = co
	
	self.progress = {}
	
	local start = function()
		if not self:IsValid() then return false end -- removed
		
		local time = system.GetElapsedTime()

		if self.debug then 
			if next(self.progress) then
				for k, v in pairs(self.progress) do	
					if v.i < v.max then 
						if not v.last_print or v.last_print < time then
							logf("%s %s progress: %s\n", self, k, self:GetProgress(k))
							v.last_print = time + 1
						end
					end
				end
			end
		end
					
		if time > self.wait then
			local ok, res, err = coroutine.resume(co, self)
			
			if coroutine.status(co) == "dead" then
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

prototype.Register(META)

function threads.CreateThread(on_start, on_finish)
	local self = prototype.CreateObject(META)
	
	if on_start then self.OnStart = function(_, ...) return on_start(...) end end
	if on_finish then self.OnFinish = function(_, ...) return on_finish(...) end end
	
	if on_start then self:Start() end

	return self
end

function threads.Sleep(time)
	local thread = threads.created[coroutine.running()]
	if thread then
		thread:Sleep(time)
	end
end

function threads.ReportProgress(what, max)
	local thread = threads.created[coroutine.running()]
	if thread then
		thread:ReportProgress(what, max)
	end
end

function threads.Report(what)
	local thread = threads.created[coroutine.running()]
	if thread then
		thread:Report(what)
	end
end

return threads