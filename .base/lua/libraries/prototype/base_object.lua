local prototype = (...) or _G.prototype

local META = {}

prototype.GetSet(META, "DebugTrace", "")
prototype.GetSet(META, "CreationTime", os.clock())
prototype.GetSet(META, "PropertyIcon", "")
prototype.GetSet(META, "HideFromEditor", false)
prototype.GetSet(META, "Name", "")
prototype.GetSet(META, "GUID", "")

function META:__tostring()
	local additional_info = self:__tostring2()
	
	if self.ClassName ~= self.Type then
		return ("%s:%s[%p]%s"):format(self.Type, self.ClassName, self, additional_info)
	else
		return ("%s[%p]%s"):format(self.Type, self, additional_info)
	end
end

function META:__tostring2()
	return ""
end

function META:IsValid()
	return true
end

do 
	prototype.remove_these = prototype.remove_these or {}
	local event_added = false

	function META:Remove(...)
		if self.call_on_remove then
			for k, v in pairs(self.call_on_remove) do
				if v() == false then
					return
				end
			end
		end
		
		if self.added_events then
			for event in pairs(self.added_events) do
				self:RemoveEvent(event)
			end
		end
	
		if self.OnRemove then 
			self:OnRemove(...) 
		end
		
		if not event_added and _G.event then 
			event.AddListener("Update", "prototype_remove_objects", function()
				for k in pairs(prototype.remove_these) do
					prototype.remove_these[k] = nil
					prototype.created_objects[k] = nil
					prototype.MakeNULL(k)
				end
			end)
			event_added = true
		end
		
		prototype.remove_these[self] = true
	end
end

do -- serializing
	local callbacks = {}

	function META:SetStorableTable(tbl)
		self:SetGUID(tbl.GUID)
				
		for _, info in ipairs(prototype.GetStorableVariables(self)) do
			if tbl[info.var_name] then
				self[info.set_name](self, tbl[info.var_name])
			end
		end
		
		if self.OnDeserialize then
			self:OnDeserialize(tbl.__extra_data)
		end
		
		if callbacks[self.GUID] then
			callbacks[self.GUID](self)
			callbacks[self.GUID] = nil
		end
	end
	
	function META:GetStorableTable()
		local out = {}
		
		for _, info in ipairs(prototype.GetStorableVariables(self)) do
			out[info.var_name] = self[info.get_name](self)
		end
		
		out.GUID = self.GUID
		
		if self.OnSerialize then
			out.__extra_data = self:OnSerialize()
		end
		
		return table.copy(out)
	end
	
	function META:WaitForGUID(guid, callback)
		callbacks[guid] = callback
	end
end

function META:CallOnRemove(callback, id)
	id = id or callback
	
	if type(callback) == "table" and callback.Remove then
		callback = function() prototype.SafeRemove(callback) end
	end
	
	self.call_on_remove = self.call_on_remove or {}
	self.call_on_remove[id] = callback
end

do -- events
	local events = {}
	local ref_count = {}

	function META:AddEvent(event_type)			
		ref_count[event_type] = (ref_count[event_type] or 0) + 1
		
		local func_name = "On" .. event_type
		
		events[event_type] = events[event_type] or utility.CreateWeakTable()		
		table.insert(events[event_type], self)
		
		event.AddListener(event_type, "prototype_events", function(a_, b_, c_) 
			for name, self in ipairs(events[event_type]) do
				if self[func_name] then
					self[func_name](self, a_, b_, c_)
				end
			end
		end, {on_error = function(str)
			logn(str)
			self:RemoveEvent(event_type)
		end})
		
		self.added_events = self.added_events or {}
		self.added_events[event_type] = true
	end

	function META:RemoveEvent(event_type)
		ref_count[event_type] = (ref_count[event_type] or 0) - 1

		events[event_type] = events[event_type] or utility.CreateWeakTable()
		
		for i, other in pairs(events[event_type]) do
			if other == self then
				events[event_type][i] = nil
				break
			end
		end
		
		table.fixindices(events[event_type])
		
		if ref_count[event_type] <= 0 then
			event.RemoveListener(event_type, "prototype_events")
		end
	end
end

prototype.base_metatable = META