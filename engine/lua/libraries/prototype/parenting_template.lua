local META = ...
META.OnParent = META.OnParent or function() end
META.OnChildAdd = META.OnChildAdd or function() end
META.OnChildRemove = META.OnChildRemove or function() end
META.OnUnParent = META.OnUnParent or function() end
META:GetSet("Parent", NULL)
META:GetSet("Children", {})
META:GetSet("ChildrenMap", {})
META:GetSet("ChildOrder", 0)

do -- children
	function META:GetChildren()
		return self.Children
	end

	local function add_recursive(obj, tbl, index)
		local source = obj.Children

		for i = 1, #source do
			tbl[index] = source[i]
			index = index + 1
			index = add_recursive(source[i], tbl, index)
		end

		return index
	end

	function META:GetChildrenList()
		if not self.children_list then
			local tbl = {}
			add_recursive(self, tbl, 1)
			self.children_list = tbl
		end

		return self.children_list
	end

	function META:InvalidateChildrenList()
		self.children_list = nil

		for _, parent in ipairs(self:GetParentList()) do
			parent.children_list = nil
		end
	end
end

do -- parent
	function META:SetParent(obj)
		if not obj or not obj:IsValid() then
			self:UnParent()
			return false
		else
			return obj:AddChild(self)
		end
	end

	function META:ContainsParent(obj)
		for _, v in ipairs(self:GetParentList()) do
			if v == obj then return true end
		end
	end

	local function quick_copy(input)
		local output = {}

		for i = 1, #input do
			output[i + 1] = input[i]
		end

		return output
	end

	function META:GetParentList()
		if not self.parent_list then
			if self.Parent and self.Parent:IsValid() then
				self.parent_list = quick_copy(self.Parent:GetParentList())
				self.parent_list[1] = self.Parent
			else
				self.parent_list = {}
			end
		end

		return self.parent_list
	end

	function META:InvalidateParentList()
		self.parent_list = nil

		for _, child in ipairs(self:GetChildrenList()) do
			child.parent_list = nil
		end
	end

	function META:InvalidateParentListPartial(parent_list, parent)
		self.parent_list = quick_copy(parent_list)
		self.parent_list[1] = parent

		for _, child in ipairs(self:GetChildren()) do
			child:InvalidateParentListPartial(self.parent_list, self)
		end
	end
end

function META:AddChild(obj, pos)
	if not obj or not obj:IsValid() then
		self:UnParent()
		return
	end

	if self == obj or obj:HasChild(self) then return false end

	if obj:HasParent() then obj:UnParent() end

	obj.Parent = self

	if not self:HasChild(obj) then
		self.ChildrenMap[obj] = obj

		if pos then
			list.insert(self.Children, pos, obj)
		else
			list.insert(self.Children, obj)
		end
	end

	self:InvalidateChildrenList()
	obj:OnParent(self)

	if not obj.suppress_child_add then
		obj.suppress_child_add = true
		self:OnChildAdd(obj)
		obj.suppress_child_add = nil
	end

	if self:HasParent() then self:GetParent():SortChildren() end

	-- why would we need to sort obj's children
	-- if it is completely unmodified?
	obj:SortChildren()
	self:SortChildren()
	obj:InvalidateParentListPartial(self:GetParentList(), self)
	return true
end

do
	local function sort(a, b)
		return a.ChildOrder < b.ChildOrder
	end

	function META:SortChildren() -- todo
	--table.sort(self.Children, sort)
	--self:InvalidateChildrenList()
	end
end

function META:HasParent()
	return self.Parent:IsValid()
end

function META:HasChildren()
	return self.Children[1] ~= nil
end

function META:HasChild(obj)
	return self.ChildrenMap[obj] ~= nil
end

function META:UnparentChild(obj)
	self.ChildrenMap[obj] = nil

	for i, val in ipairs(self:GetChildren()) do
		if val == obj then
			self:InvalidateChildrenList()
			table.remove(self.Children, i)
			obj:OnUnParent(self)
			self:OnChildRemove(obj)
			obj.Parent = NULL
			self.ChildrenMap[obj] = nil

			break
		end
	end
end

function META:GetRoot()
	local list = self:GetParentList()

	if list[1] then return list[#list] end

	return self
end

function META:RemoveChildren()
	self:InvalidateChildrenList()

	for i, obj in ipairs(self:GetChildrenList()) do
		obj:OnUnParent(self)
		obj:Remove(true)
	end

	self.Children = {}
	self.ChildrenMap = {}
end

function META:UnParent()
	local parent = self:GetParent()

	if parent:IsValid() then parent:RemoveChild(self) end

	self:OnUnParent(parent)
	self.Parent = NULL
end

function META:RemoveChild(obj)
	self.ChildrenMap[obj] = nil

	for i, val in ipairs(self:GetChildren()) do
		if val == obj then
			self:InvalidateChildrenList()
			table.remove(self.Children, i)
			obj:OnUnParent(self)

			break
		end
	end
end

do
	function META:CallRecursive(func, a, b, c)
		assert(c == nil, "EXTEND ME")

		if self[func] then self[func](self, a, b, c) end

		for _, child in ipairs(self:GetChildrenList()) do
			if child[func] then child[func](child, a, b, c) end
		end
	end

	function META:CallRecursiveOnClassName(class_name, func, a, b, c)
		assert(c == nil, "EXTEND ME")

		if self[func] and self.ClassName == class_name then
			self[func](self, a, b, c)
		end

		for _, child in ipairs(self:GetChildrenList()) do
			if child[func] and self.ClassName == class_name then
				child[func](child, a, b, c)
			end
		end
	end

	function META:SetKeyValueRecursive(key, val)
		self[key] = val

		for _, child in ipairs(self:GetChildrenList()) do
			child[key] = val
		end
	end
end