local metatable = (...) or _G.metatable

local objects = setmetatable({}, { __mode = 'v' })

function metatable.GetCreated()
	return objects
end

function metatable.CreateTemplate(class_name)
	local META = {}
	META.__index = META
	
	META.Type = class_name -- if type differs from classname it might be a better idea to use _G.class
	META.ClassName = class_name
	
	function META:__tostring()
		return ("%s[%p]"):format(class_name, self)
	end
	
	function META:New(tbl, skip_gc_callback)
		tbl = tbl or {}
		local self = setmetatable(tbl, META) 
		if not skip_gc_callback then
			utilities.SetGCCallback(self)
		end
		self.trace = debug.trace(true)
		table.insert(objects, self)
		return self
	end
	
	function META:Remove(...)
		if self.OnRemove then 
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