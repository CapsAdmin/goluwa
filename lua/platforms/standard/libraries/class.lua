local class = {}

class.Registered = {}

local function checkfield(tbl, key, def)
    tbl[key] = tbl[key] or def
	
    if not tbl[key] then
        error(string.format("The type field %q was not found!", key), 3)
    end

    return tbl[key]
end

function class.GetSet(tbl, name, def)

    if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self[name]) end
	elseif type(def) == "string" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tostring(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self[name]) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return self[name] end
	end
	
	tbl["__def" .. name] = def
	
    tbl[name] = def
end

function class.IsSet(tbl, name, def)
	if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
	end
    tbl["Is" .. name] = tbl["Is" .. name] or function(self, var) return self[name] end
	tbl["__def" .. name] = def
    tbl[name] = def
end

function class.RemoveField(tbl, name)
	tbl["Set" .. name] = nil
    tbl["Get" .. name] = nil
    tbl["Is" .. name] = nil
	tbl["__def" .. name] = nil
    tbl[name] = nil
end

function class.Get(type_name, class_name)
    check(type_name, "string")
    check(class_name, "string")
	
    return class.Registered[type_name] and class.Registered[type_name][class_name] or nil
end

function class.GetAll(type_name)
	check(type_name, "string")
	return class.Registered[type_name]
end

function class.Register(META, type_name, name)
    local type_name = checkfield(META, "Type", type_name)
    local name = checkfield(META, "ClassName", name)

    class.Registered[type_name] = class.Registered[type_name] or {}
    class.Registered[type_name][name] = META
end

function class.HandleBaseField(META, var)
	if not var then return end
	
	local t = type(var)
	
	if t == "string" then
		class.HandleBaseField(META, class.Get(META.Type, var))
	elseif t == "table" then
		-- if it's a table and does not have the Type field we assume it's a table of bases
		if not var.Type then
			for key, base in pairs(var) do
				class.HandleBaseField(META, base)
			end
		else
			-- make a copy of it so we don't alter the meta template
			var = table.copy(var)
			
			META.BaseList = META.BaseList or {}
			
			table.insert(META.BaseList, var)
		end
	end
end

function class.Create(type_name, class_name)
    local META = class.Get(type_name, class_name)
	
    if not META then
        logf("tried to create unknown %s %q!", type or "no type", class_name or "no class")
        return
    end
	
	local obj = table.copy(META)
	class.HandleBaseField(obj, obj.Base)
	class.HandleBaseField(obj, obj.TypeBase)

	if obj.BaseList then	
		if #obj.BaseList == 1 then
			for key, val in pairs(obj.BaseList[1]) do
				obj[key] = obj[key] or val
			end
			obj.BaseClass = obj.BaseList[1]
		else		
			local current = obj
			for i, base in pairs(obj.BaseList) do
				for key, val in pairs(base) do
					obj[key] = obj[key] or val
				end
				current.BaseClass = base
				current = base
			end
		end
	end
	
	setmetatable(obj, obj)
	
	return obj
end

do -- helpers
	function class.SetupLib(tbl, type, base)
		base = base or "base"

		function tbl.Create(name)
			local obj = class.Create(type, name, base)
			
			if not obj then return end
					
			if obj.Initialize then
				obj:Initialize()
			end

			return obj
		end

		function tbl.Register(META, name)
			META.TypeBase = base
			class.Register(META, type, name)
		end
		
		function tbl.GetRegistered(name)
			return class.Get(type, name)
		end

		function tbl.GetAllRegistered()
			return class.GetAll(type)
		end
	end

	function class.SetupParentingSystem(META)
		META.OnParent = META.OnChildAdd or function() end
		META.OnChildAdd = META.OnChildAdd or function() end
		META.OnUnParent = META.OnUnParent or function() end

		function META:GetChildren()
			return self.Children
		end

		function META:SetParent(var)
			if not var or not var:IsValid() then
				self:UnParent()
				return false
			else
				return var:AddChild(self)
			end
		end
		
		function META:AddChild(var)		
			if self == var or var:HasChild(self) then 
				return false 
			end
		
			var:UnParent()
		
			var.Parent = self

			if not table.HasValue(self.Children, var) then
				table.insert(self.Children, var)
			end
			
			var:OnParent(self)
			self:OnChildAdd(var)

			self:GetRoot():SortChildren() 
			
			return true
		end
			
		local sort = function(a, b)
			if a and b then
				return a.DrawOrder < b.DrawOrder
			end
		end
		
		function PART:SortChildren()
			local new = {}
			for key, val in pairs(self.Children) do 
				table.insert(new, val) 
				val:SortChildren()
			end
			self.Children = new
			table.sort(self.Children, sort)
		end

		function META:HasParent()
			return self:GetParent() and self:GetParent():IsValid()
		end

		function META:HasChildren()
			return next(self.Children) ~= nil
		end

		function META:HasChild(obj)
			for key, child in pairs(self.Children) do
				if child == obj or child:HasChild(obj) then
					return true
				end
			end
			return false
		end
		
		function META:RemoveChild(var)
			for key, obj in pairs(self.Children) do
				if obj == var then
				
					obj.Parent = NULL
					self.Children[key] = nil
					
					self:GetRoot():SortChildren() 
					
					obj:OnUnParent(self)
					
					return
				end
			end
		end
		
		function META:GetRoot()
			if not self:HasParent() then return self end
		
			local temp = self
			
			for i = 1, 100 do
				local parent = temp:GetParent()

				if parent:IsValid() then
					temp = parent
				else
					break
				end
			end
			
			return temp
		end

		function META:RemoveChildren()
			for key, obj in pairs(self.Children) do
				obj:RemoveChild()
			end
			self.Children = {}
		end

		function META:UnParent()
			local parent = self:GetParent()
			
			if parent:IsValid() then
				parent:RemoveChild(self)
			end
					
			self:OnUnParent(parent)
		end
	end
end

return class