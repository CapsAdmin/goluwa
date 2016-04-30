local gui = ... or _G.gui

do -- tree node
	local META = {}

	META.Base = "button"
	META.ClassName = "tree_node"

	prototype.GetSet(META, "Expand", true)

	function META:Initialize()
		self:SetDraggable(true)
		self:SetDragMinDistance(Vec2()-1)
		self.nodes = {}

		prototype.GetRegistered(self.Type, "button").Initialize(self)

		self:SetWidth(1000)
		self:SetNoDraw(true)

		local exp = self:CreatePanel("button", "expand")
		exp:SetVisible(false)
		exp:SetMode("toggle")
		exp:SetStyle("-")
		exp:SetStyleTranslation("button_active", "+")
		exp:SetStyleTranslation("button_inactive", "-")
		exp:SetupLayout("center_left")
		exp.OnStateChanged = function(_, b)
			self:OnExpand(b)
			if self.expand_callback then
				self.expand_callback(b)
			end
		end

		local img = self:CreatePanel("base", "image")
		img:SetIgnoreMouse(true)
		self:SetIcon(render.CreateTextureFromPath("textures/silkicons/heart.png"))

		local button = self:CreatePanel("text_button", "button")
		button:SetColor(Color(1,1,1,0))

		button:SetIgnoreMouse(true)
		button.label:SetIgnoreMouse(true)
		button.OnMouseInput = function(_,...)self:OnMouseInput(...) end -- FIX IGNORE MOUSE

		self:SetText("nil")
	end

	function META:OnChildDrop(child, drop_pos)
		self.tree:OnNodeDrop(self, child, drop_pos)
	end

	function META:OnParentLand(parent)

	end

	function META:OnLayout(S)
		self.expand:SetPadding(Rect()+2*S)

		self.image:SetPadding(Rect()+2*S)
		self.image:SetSize(Vec2(math.min(S*8, self.image.Texture:GetSize().x), math.min(S*8, self.image.Texture:GetSize().y)))
		self.image:SetupLayout("center_left")

		self.button:SetPadding(Rect()+2*S)
		self.button:SetMargin(Rect()+2*S)
		self.button:SizeToText()
		self.button:SetupLayout("center_left")

		self:SetMargin(Rect(0,0,self.offset*S,0))
	end

	function META:OnPress()
		self.button:SetColor(Color(1,1,1,1))
		--self.button:SetNoDraw(false)
		for k, v in ipairs(self.tree:GetChildren()) do
			if v ~= self then
				v.button:SetColor(Color(1,1,1,0))
				--self.button:SetNoDraw(true)
			end
		end
		self.tree:SetSelectedNode(self)
		self.tree:OnNodeSelect(self)
		self:OnSelect()
	end

	function META:OnMouseEnter(...)
		prototype.GetRegistered(self.Type, "button").OnMouseEnter(self, ...)
		self.button:SetHighlight(true)
		self.button:OnMouseEnter()
	end

	function META:OnMouseExit(...)
		prototype.GetRegistered(self.Type, "button").OnMouseExit(self, ...)
		self.button:SetHighlight(false)
	end

	function META:OnExpand()
		self:SetExpand(not self.Expand)
		self:Layout()
	end

	function META:SetIcon(...)
		self.image:SetTexture(...)
		self:Layout()
	end

	function META:SetText(...)
		self.button:SetText(...)
		self:Layout()
	end

	function META:AddNode(str, icon, id)
		local pnl = self.tree.AddNode(self.tree, str, icon, id)

		local pos
		for i,v in ipairs(self.tree:GetChildren()) do if v == self then pos = i break end  end
		if pos then self.tree:AddChild(pnl, pos+1) end

		pnl.offset = self.offset + self.tree.IndentWidth
		pnl.node_parent = self

		self.expand:SetVisible(true)
		self:SetExpand(true)

		return pnl
	end

	function META:SetExpandCallback(callback)
		if callback then
			self.expand_callback = function(b)
				callback()
				self.expand_callback = nil
			end
			self.expand:SetVisible(true)
			self:SetExpand(false)
		else
			self.expand:SetVisible(false)
		end
	end

	function META:SetExpandInternal(b)
		self:SetVisible(b)
		self:SetStackable(b)

		if b and not self.Expand then return end

		for pos, pnl in pairs(self.tree:GetChildren()) do
			if pnl.node_parent == self then
				pnl:SetExpandInternal(b)
			end
		end

		self.Parent:Layout()
	end

	function META:SetExpand(b)

		for pos, pnl in pairs(self.tree:GetChildren()) do
			if pnl.node_parent == self then
				pnl:SetExpandInternal(b)
			end
		end

		self.Expand = b
		self.expand:SetState(not b)
	end

	function META:OnSelect() end

	gui.RegisterPanel(META)
end

do
	local META = {}

	META.ClassName = "tree"
	prototype.GetSet(META, "IndentWidth", 8)
	prototype.GetSet(META, "SelectedNode", NULL)

	function META:Initialize()
		self:SetNoDraw(true)
		self:SetClipping(true)
		self:SetStack(true)

		self:SetStackRight(false)
		self:SetSizeStackToWidth(true)
	end

	function META:AddNode(str, icon, id)
		if id and self.nodes[id] and self.nodes[id]:IsValid() then self.nodes[id]:Remove() end

		local pnl = self:CreatePanel("tree_node")

		pnl:SetText(str)
		pnl.offset = 0
		pnl.tree = self

		if icon then
			pnl.image:SetTexture(render.CreateTextureFromPath(icon))
		end

		if id then
			self.nodes[id] = pnl
		end

		self:Layout()

		return pnl
	end

	function META:RemoveNode(pnl)
		::again::

		for k,v in ipairs(self:GetChildren()) do
			if v.node_parent == pnl then
				self:RemoveNode(v)
				goto again
			end
		end

		pnl:Remove()

		self:Layout()
	end

	function META:SelectNode(node)
		node:OnPress()
	end

	function META:OnLayout(S)
		self:SetForcedStackSize(Vec2(0, 10*S))
	end

	function META:OnNodeSelect(node) end
	function META:OnNodeDrop(node, dropped_node, drop_pos) end

	gui.RegisterPanel(META)
end

if RELOAD then
	local frame = gui.CreatePanel("frame", nil, "tree_test")
	frame:SetSize(Vec2(200, 400))

	local tree = frame:CreatePanel("tree")
	tree:SetupLayout("fill")
	local node = tree:AddNode("test")
	node:AddNode("yea")
	local node = node:AddNode("wo")
		node:AddNode("!")
		node:AddNode("!")
		node:AddNode("!")
		node:AddNode("!")
end