local metatable = (...) or _G.metatable

local objects = setmetatable({}, { __mode = 'v' })

function metatable.GetCreated()
	return objects
end

function metatable.CreateTemplate(class_name, skip_onremove)

	local META

	if type(skip_onremove) == "table" then
		META = skip_onremove
	else
		META = {}
	end
	
	META.__index = META
	
	META.Type = class_name -- if type differs from classname it might be a better idea to use _G.class
	META.ClassName = class_name
	
	function META:__tostring()
		return ("%s[%p]"):format(class_name, self)
	end
	
	function META:New(tbl, skip_gc_callback)
		tbl = tbl or {}
		
		local copy = table.copy(META)
		local self = setmetatable(tbl, copy) 
		
		if not skip_gc_callback then
			utilities.SetGCCallback(self)
		end
		
		self.trace = debug.trace(true)
		
		table.insert(objects, self)
		
		return self
	end
	
	function META:Remove(...)
		if self.OnRemove and not skip_onremove then 
			self:OnRemove(...) 
		end
		utilities.MakeNULL(self)
	end
	
	function META:IsValid()
		return true
	end
	
	function META:GetTrace()
		return self.trace or ""
	end
	
	metatable.Register(META)
	
	return META
end