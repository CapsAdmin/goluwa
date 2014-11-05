local prototype = (...) or _G.prototype

do
	local META = {}
	
	prototype.GetSet(META, "DebugTrace", "")
	prototype.GetSet(META, "CreationTime", os.clock())
	prototype.GetSet(META, "PropertyIcon", "")
	prototype.GetSet(META, "Name", "")

	function META:__tostring()
		if self.ClassName ~= self.Type then
			return ("%s:%s[%p]"):format(self.Type, self.ClassName, self)
		else
			return ("%s[%p]"):format(self.Type, self)
		end
	end
	
	function META:IsValid()
		return true
	end
	
	do 
		prototype.remove_these = prototype.remove_these or {}
		local event_added = false

		function META:Remove(...)
			for k, v in pairs(self.call_on_remove) do
				if v() == false then
					return
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
	
	do -- call on remove
		META.call_on_remove = {}

		function META:CallOnRemove(callback, id)
			id = id or callback
			
			self.call_on_remove[id] = callback
		end
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

	function prototype.CreateTemplate(super_type, sub_type, skip_register)
		local template = type(super_type) == "table" and super_type or {}
		
		if type(super_type) == "string" then
			template.Type = super_type
			template.ClassName = sub_type or super_type
		end
		
		if not skip_register then
			prototype.Register(template)
			if RELOAD then 
				event.Delay(0, function() 
					prototype.UpdateObjects(super_type)
				end) 
			end
		end
		
		return template
	end
end

function prototype.CreateObject(meta, override, skip_gc_callback)
	override = override or {}
	
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end
	
	-- this has to be done in order to ensure we have the prepared metatable with bases
	meta = prototype.GetRegistered(meta.Type, meta.ClassName) or meta
		
	local self = setmetatable(override, table.copy(meta))
		
	if not skip_gc_callback then
		utility.SetGCCallback(self, function(self)
			if self:IsValid() then 
				self:Remove() 
			end
			prototype.created_objects[self] = nil
		end)
	end
	
	--print(meta, "!!!")
	
	self:SetDebugTrace(debug.trace(true))
	
	prototype.created_objects = prototype.created_objects or utility.CreateWeakTable()
	prototype.created_objects[self] = self
	
	self:SetCreationTime(os.clock())
	
	return self
end

function prototype.CreateDerivedObject(super_type, sub_type, override, skip_gc_callback)
    local meta = prototype.GetRegistered(super_type, sub_type)
	
    if not meta then
        logf("tried to create unknown %s %q!\n", super_type or "no type", sub_type or "no class")
        return
    end

	return prototype.CreateObject(meta, override, skip_gc_callback)
end

function prototype.SafeRemove(obj)
	if hasindex(obj) and obj.IsValid and obj.Remove and obj:IsValid() then
		obj:Remove()
	end
end

function prototype.GetCreated(sorted, super_type, sub_type)
	if sorted then
		local out = {}
		for k,v in pairs(prototype.created_objects) do
			if (not super_type or v.Type == super_type) and (not sub_type or v.ClassName == sub_type) then
				table.insert(out, v)
			end
		end
		table.sort(out, function(a, b) return a.creation_time < b.creation_time end)
		return out
	end
	return prototype.created_objects or {}
end

function prototype.UpdateObjects(meta)
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end
	
	if not meta then return end
	
	for key, obj in pairs(prototype.GetCreated()) do
		if obj.Type == meta.Type and obj.ClassName == meta.ClassName then
			for k, v in pairs(meta) do
				-- update entity functions only
				-- updating variables might mess things up
				if type(v) == "function" and k:sub(1, 2) ~= "On" then
					obj[k] = v
				end
			end
		end
	end	
end

function prototype.RemoveObjects(super_type, sub_type)
	sub_type = sub_type or super_type
	for _, obj in pairs(prototype.GetCreated()) do
		if obj.Type == super_type and obj.ClassName == sub_type then
			if obj:IsValid() then
				obj:Remove()
			end
		end
	end
end
