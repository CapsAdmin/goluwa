local prototype = (...) or _G.prototype

do
	local META = {}

	function META:__tostring()
		if self.ClassName ~= self.Type then
			return ("%s:%s[%p]"):format(self.Type, self.ClassName, self)
		else
			return ("%s[%p]"):format(self.Type, self)
		end
	end

	function META.New(meta, tbl, skip_gc_callback)
		return prototype.CreateObject(nil, meta, tbl, skip_gc_callback)
	end
	
	prototype.remove_these = prototype.remove_these or {}
	local event_added = false

	function META:Remove(...)
		if self.OnRemove then 
			self:OnRemove(...) 
		end
		
		if not event_added and _G.event then 
			event.AddListener("Update", "prototype_remove_objects", function()
				for k in pairs(prototype.remove_these) do
					if self.Type == "panel2" then print(self) end
					prototype.remove_these[k] = nil
					prototype.created_objects[k] = nil
					prototype.MakeNULL(k)
				end
			end)
			event_added = true
		end
		
		prototype.remove_these[self] = true
	end

	function META:IsValid()
		return true
	end

	function META:GetDebugTrace()
		return self.debug_trace or ""
	end
	
	function META:GetCreationTime()
		return self.creation_time
	end
	
	function META:FindReferences()
		do return utility.FindReferences(self) end
		local found = {utility.FindReferences(self)}
		for k,v in pairs(self) do
			if string.format("%p", k) ~= "NULL" and type(k) ~= "string" then
				table.insert(found, utility.FindReferences(k))
			end
			if string.format("%p", v) ~= "NULL" and type(v) ~= "string" then
				table.insert(found, utility.FindReferences(v))
			end
		end
		return table.concat(found, "\n")
	end

	function prototype.CreateTemplate(super_type, sub_type, skip_register)
		local template = type(super_type) == "table" and super_type or {}
		
		for k, v in pairs(META) do
			template[k] = template[k] or v
		end
		
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
		
		template.__index = template
		
		return template
	end
end

function prototype.CreateObject(meta, override, skip_gc_callback)
	override = override or {}
	
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end
		
	local self = setmetatable(override, table.copy(meta)) 
	
	if not skip_gc_callback then
		utility.SetGCCallback(self, function(self)
			if self:IsValid() then 
				self:Remove() 
			end
			prototype.created_objects[self] = nil
		end)
	end
	
	self.debug_trace = debug.trace(true)
	
	prototype.created_objects = prototype.created_objects or utility.CreateWeakTable()
	prototype.created_objects[self] = self
	self.creation_time = os.clock()
	
	return self
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
