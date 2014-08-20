local metatable = (...) or _G.metatable

function metatable.AddParentingTemplate(META)
	META.OnParent = META.OnChildAdd or function() end
	META.OnChildAdd = META.OnChildAdd or function() end
	META.OnUnParent = META.OnUnParent or function() end
	
	META.RootPart = NULL
	
	metatable.GetSet(META, "Parent", NULL)
	META.Children = {}
	META.children_list = {}
	
	function META:GetAllChildren()
		return self.children_list
	end
	
	function META:GetChildren(all)
		return self.Children
	end
	
	function META:GetParentList()
		
		if not self.parent_list then
			self:BuildParentList()
		end
		
		return self.parent_list
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
		
		self.children_list = nil
		
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
		for key, child in ipairs(self:GetChildren(true)) do
			if child == obj then
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
	
	local function add_children_to_list(parent, list)
		for i, child in ipairs(parent:GetChildren()) do
			table.insert(list, child)
			add_children_to_list(child, list)
		end
	end
	
	function META:BuildChildrenList()
		self.children_list = {}
		
		for i, child in ipairs(self:GetChildren()) do
			add_children_to_list(child, self.children_list)
		end
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