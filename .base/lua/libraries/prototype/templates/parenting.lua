local prototype = (...) or _G.prototype

function prototype.AddParentingTemplate(META)
	META.OnParent = META.OnChildAdd or function() end
	META.OnChildAdd = META.OnChildAdd or function() end
	META.OnUnParent = META.OnUnParent or function() end
	
	META.RootPart = NULL
	
	prototype.GetSet(META, "Parent", NULL)
	META.Children = {}
	
	function META:GetChildrenList()
		if not self.children_list then
			self:BuildChildrenList()
		end
		
		return self.children_list
	end
	
	function META:GetChildren()
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
		
		self.children_list = nil
		self.parent_list = nil
		
		return true
	end
		
	function META:HasParent()
		return self.Parent:IsValid()
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
		for i, obj in ipairs(self.Children) do
			if obj == var then
			
				obj:OnUnParent(self)
				
				obj.Parent = NULL
				obj.children_list = nil
				obj.parent_list = nil
				
				table.remove(self.Children, i)
				
				break
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
			obj:OnUnParent(self)
			
			obj:Remove()
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
		
		add_children_to_list(self, self.children_list)
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