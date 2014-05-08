local printf = function(fmt, ...) logn(string.format(fmt, ...)) end
local class = _G.class or {}

class.Registered = {}

local function checkfield(tbl, key, def)
    tbl[key] = tbl[key] or def
	
    if not tbl[key] then
        error(string.format("The type field %q was not found!", key), 3)
    end

    return tbl[key]
end

local __store = false

function class.StartStorableProperties()
	__store = true
end

function class.EndStorableProperties()
	__store = false
end

function class.GetSet(tbl, name, def)

    if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) or def end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self[name]) or def end
	elseif type(def) == "string" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tostring(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self[name]) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) if var == nil then var = def end self[name] = var end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) if self[name] ~= nil then return self[name] end return def end
	end
		
    tbl[name] = def
	

	if __store then
		tbl.StorableProperties = tbl.StorableProperties or {}
		table.insert(tbl.StorableProperties, key)
	end
end

function class.IsSet(tbl, name, def)
	if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
	end
    tbl["Is" .. name] = tbl["Is" .. name] or function(self, var) if self[name] ~= nil then return self[name] end return def end

    tbl[name] = def
	
	if __store then
		tbl.StorableProperties = tbl.StorableProperties or {}
		table.insert(tbl.StorableProperties, key)
	end
end

function class.RemoveField(tbl, name)
	tbl["Set" .. name] = nil
    tbl["Get" .. name] = nil
    tbl["Is" .. name] = nil

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

function class.GetAllTypes()
	return class.Registered
end

function class.Register(META, type_name, name)
    local type_name = checkfield(META, "Type", type_name)
    local name = checkfield(META, "ClassName", name)

    class.Registered[type_name] = class.Registered[type_name] or {}
    class.Registered[type_name][name] = META
	
	return type_name, name
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

class.active_classes = {}
-- class.GetAll("panel_textbutton"):SetText("asdfasd")
function class.GetAll(type_name, class_name)
	
	if not class_name then
		type_name, class_name = type_name:match("(.-)_(.+)")
	end
	
	local META = class.Get(type_name, class_name)
	local types = class.active_classes[type_name]
	if types then
		local objects = types[class_name] 
		if objects then
			return setmetatable(
				{},
				{
					__index = function(_, key)
						return function(_, ...)
							for k,v in pairs(objects) do
								META[key](v, ...)
							end
						end
					end,
				}
			)
		end
	end
end

function class.Create(type_name, class_name)
    local META = class.Get(type_name, class_name)
	
    if not META then
        printf("tried to create unknown %s %q!", type or "no type", class_name or "no class")
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
		
	META.__index = META
	obj.MetaTable = META

	setmetatable(obj, META)
	
	-- copy all structs and such
	for key, val in pairs(obj) do
		if hasindex(val) and val.Copy then
			obj[key] = val:Copy()
		end
	end
	
	class.active_classes[type_name] = class.active_classes[type_name] or {}
	class.active_classes[type_name][class_name] = class.active_classes[type_name][class_name] or {}
	table.insert(class.active_classes[type_name][class_name], obj)
			
	return obj
end

class.Copy = table.copy

do -- helpers
	function class.SetupLib(tbl, type, base)
		base = base or "base"

		function tbl.Create(name)
			local obj = class.Create(type, name, base)
			
			if not obj then return end
					
			if obj.__init then
				obj:__init()
			end
					
			if obj.Initialize then
				obj:Initialize()
			end

			return obj
		end

		function tbl.Register(META, name)
			META.TypeBase = base
			return class.Register(META, type, name)
		end
		
		function tbl.GetRegistered(name)
			return class.Get(type, name)
		end

		function tbl.GetAllRegistered()
			return class.GetAll(type)
		end
	end
	
	function class.SetupSerializing(lib)
		local variable_order = {}
		
		local function insert_key(key)
			for k,v in pairs(variable_order) do
				if k == key then
					return
				end
			end
			
			table.insert(variable_order, key)
		end
		
		local __store = false

		function lib.StartStorableProperties()
			__store = true
		end

		function lib.EndStorableProperties()
			__store = false
		end
		
		function lib.GetVariableOrder()	
			return variable_order
		end

		function lib.GetSet(tbl, key, ...)
			insert_key(key)
			
			class.GetSet(tbl, key, ...)

			if __store then
				tbl.StorableProperties = tbl.StorableProperties or {}
				tbl.StorableProperties[key] = key
			end
		end

		function lib.IsSet(tbl, key, ...)
			insert_key(key)
			class.IsSet(tbl, key, ...)

			if __store then
				tbl.StorableProperties = tbl.StorableProperties or {}
				tbl.StorableProperties[key] = key
			end
		end
		
		
		-- todo
		do return end
		function lib.SetupPartName(PART, key)		
			PART.PartNameResolvers = PART.PartNameResolvers or {}
					
			local part_key = key
			local part_set_key = "Set" .. part_key
			
			local uid_key = part_key .. "UID"
			local name_key = key.."Name"
			local name_set_key = "Set" .. name_key
			
			local last_name_key = "last_" .. name_key:lower()
			local last_uid_key = "last_" .. uid_key:lower()
			local try_key = "try_" .. name_key:lower()
			
			local name_find_count_key = name_key:lower() .. "_try_count"
			
			-- these keys are ignored when table is set. it's kind of a hack..
			PART.IngoreSetKeys = PART.IgnoreSetKeys or {}
			PART.IngoreSetKeys[name_key] = true
			
			lib.EndStorableProperties()
				lib.GetSet(PART, part_key, lib.NULL)
			lib.StartStorableProperties()
			
			lib.GetSet(PART, name_key, "")
			lib.GetSet(PART, uid_key, "")
						
			PART.ResolvePartNames = PART.ResolvePartNames or function(self, force)
				for key, func in pairs(self.PartNameResolvers) do
					func(self, force)
				end
			end		
					
			PART["Resolve" .. name_key] = function(self, force)
				PART.PartNameResolvers[part_key](self, force)
			end
			
			PART.PartNameResolvers[part_key] = function(self, force)
		
				if self[uid_key] == "" and self[name_key] == "" then return end 
		
				if force or self[try_key] or self[uid_key] ~= "" and not self[part_key]:IsValid() then
					
					-- match by name instead
					if self[try_key] and not self.supress_part_name_find then
						for key, part in pairs(lib.GetParts()) do
							if 
								part ~= self and 
								self[part_key] ~= part and 
								part:GetPlayerOwner() == self:GetPlayerOwner() and 
								part.Name == self[name_key] 
							then
								self[name_set_key](self, part)
								break
							end
							
							self[last_uid_key] = self[uid_key] 
						end
						self[try_key] = false
					else
						local part = lib.GetPartFromUniqueID(self.owner_id, self[uid_key])
						
						if part:IsValid() and part ~= self and self[part_key] ~= part then 
							self[name_set_key](self, part)
						end
						
						self[last_uid_key] = self[uid_key] 
					end
				end
			end
			
			PART[name_set_key] = function(self, var)
				self[name_find_count_key] = 0
				
				if type(var) == "string" then
					
					self[name_key] = var

					if var == "" then
						self[uid_key] = ""
						self[part_key] = lib.NULL
						return
					else
						self[try_key] = true
					end
				
					PART.PartNameResolvers[part_key](self)
				else
					self[name_key] = var.Name
					self[uid_key] = var.UniqueID
					self[part_set_key](self, var)
				end
			end			
		end
	end

	function class.SetupParentingSystem(META)
		META.OnParent = META.OnChildAdd or function() end
		META.OnChildAdd = META.OnChildAdd or function() end
		META.OnUnParent = META.OnUnParent or function() end
		
		class.GetSet(META, "Parent", NULL)
		META.Children = {}
		
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

			if not table.hasvalue(self.Children, var) then
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
		
		function META:SortChildren()
			local new = {}
			for key, val in pairs(self.Children) do 
				table.insert(new, val) 
				val:SortChildren()
			end
			self.Children = new
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
		
		function META:UnparentChild(var)
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
		
			if not self.RootPart:IsValid() then
				self:BuildParentList()
			end
			
			return self.RootPart
		end

		function META:RemoveChildren()
			for key, obj in pairs(self.Children) do
				self:UnparentChild(obj)
				if obj.Remove then
					obj:Remove()
				end
				self.Children[key] = nil
			end
		end

		function META:UnParent()
			local parent = self:GetParent()
			
			if parent:IsValid() then
				parent:UnparentChild(self)
			end
					
			self:OnUnParent(parent)
		end
		
		function META:BuildParentList()
	
			self.parent_list = {}

			if not self:HasParent() then return end
						
			local temp = self:GetParent()
			table.insert(self.parent_list, temp)
			
			while true do
				local parent = temp:GetParent()
				
				if parent:IsValid() then
					table.insert(self.parent_list, parent)
					temp = parent
				else
					break
				end
			end
			
			
			self.RootPart = temp
			
			for key, obj in pairs(self.Children) do
				obj:BuildParentList()
			end
		end		
		
	end
end

return class