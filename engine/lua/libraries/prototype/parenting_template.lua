local META = ...
META.OnParent = META.OnParent or function() end
META.OnChildAdd = META.OnChildAdd or function() end
META.OnChildRemove = META.OnChildRemove or function() end
META.OnUnParent = META.OnUnParent or function() end
META:GetSet("Parent", NULL)
META:GetSet("Children", {})
META:GetSet("Children2", {})

function META:GetChildrenList()
	if not self.children_list then self:BuildChildrenList() end

	return self.children_list
end

function META:GetParentList()
	if not self.parent_list then self:BuildParentList() end

	return self.parent_list
end

function META:AddChild(obj, pos)
	if self == obj or obj:HasChild(self) then return false end

	obj:UnParent()
	obj.Parent = self

	if not self:HasChild(obj) then
		self.Children2[obj] = obj

		if pos then
			list.insert(self.Children, pos, obj)
		else
			list.insert(self.Children, obj)
		end
	end

	self.children_list = nil
	self.parent_list = nil
	obj.parent_list = nil
	obj:OnParent(self)

	if not obj.suppress_child_add then
		obj.suppress_child_add = true
		self:OnChildAdd(obj)
		obj.suppress_child_add = nil
	end

	return true
end

function META:SetParent(obj)
	if not obj:IsValid() then
		self:UnParent()
		return
	end

	return obj:AddChild(self)
end

function META:ContainsParent(obj)
	for _, v in ipairs(self:GetParentList()) do
		if v == obj then return true end
	end
end

function META:HasParent()
	return self.Parent:IsValid()
end

function META:HasChildren()
	return self.Children[1] ~= nil
end

function META:HasChild(obj)
	return self.Children2[obj] ~= nil
end

function META:UnparentChild(var)
	local obj = self.Children2[var]

	if obj == var then
		obj:OnUnParent(self)
		self:OnChildRemove(obj)
		obj.Parent = NULL
		obj.children_list = nil
		obj.parent_list = nil
		self.Children2[obj] = nil

		for i, v in ipairs(self.Children) do
			if v == var then
				list.remove(self.Children, i)

				break
			end
		end
	end
end

function META:GetRoot()
	if not self:HasParent() then return self end

	self.RootPart = self.RootPart or NULL

	if not self.RootPart:IsValid() then self:BuildParentList() end

	return self.RootPart
end

function META:RemoveChildren()
	for _, obj in ipairs(self:GetChildrenList()) do
		if obj:IsValid() then
			obj:OnUnParent(self)
			obj:Remove()
		end
	end

	self.children_list = nil
end

function META:UnParent()
	local parent = self:GetParent()

	if parent:IsValid() then
		parent:UnparentChild(self)
		self:OnUnParent(parent)
	end
end

local function add_children_to_list(parent, lst)
	for _, child in ipairs(parent:GetChildren()) do
		list.insert(lst, child)
		add_children_to_list(child, lst)
	end
end

function META:BuildChildrenList()
	self.children_list = {}
	add_children_to_list(self, self.children_list)
end

function META:BuildParentList()
	self.parent_list = {}

	if not self:HasParent() then return end

	local parent = self:GetParent()

	while parent:IsValid() do
		list.insert(self.parent_list, parent)
		parent = parent:GetParent()
	end

	self.RootPart = self.parent_list[#self.parent_list]
end