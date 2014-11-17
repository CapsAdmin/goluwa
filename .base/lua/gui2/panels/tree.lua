local gui2 = ... or _G.gui2
local S = gui2.skin.scale

do -- tree node
	local PANEL = {}

	PANEL.Base = "button"
	PANEL.ClassName = "tree_node"
	
	prototype.GetSet(PANEL, "Expand", true)
	
	PANEL.nodes = {}

	function PANEL:Initialize()	
		prototype.GetRegistered(self.Type, "button").Initialize(self)

		self:SetNoDraw(true)

		local button = gui2.CreatePanel("text_button", self)
		button:SetMargin(Rect()+2*S)
		button:SetColor(Color(1,1,1,0))
		button:SetIgnoreMouse(true)
		self.button = button

		local exp = gui2.CreatePanel("button", self)
		exp:SetMargin(Rect()+S)
		exp:SetVisible(false)
		exp:SetMode("toggle")
		exp:SetStyle("-")
		exp:SetStyleTranslation("button_active", "+")
		exp:SetStyleTranslation("button_inactive", "-")
		exp.OnStateChanged = function(_, b) 
			self:OnExpand(b) 
		end
		self.expand = exp
		
		local img = gui2.CreatePanel("base", self)
		img:SetIgnoreMouse(true)
		img:SetTexture(Texture("textures/silkicons/heart.png"))
		self.image = img
	end
	
	function PANEL:OnPress()
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
	end
	
	function PANEL:OnMouseEnter(...)
		prototype.GetRegistered(self.Type, "button").OnMouseEnter(self, ...)
		self.button:SetHighlight(true)
		self.button:OnMouseEnter()
	end
	
	function PANEL:OnMouseExit(...)
		prototype.GetRegistered(self.Type, "button").OnMouseExit(self, ...)
		self.button:SetHighlight(false)
	end
	
	function PANEL:OnExpand()
		self:SetExpand(not self.Expand)
	end
	
	function PANEL:SetIcon(...)
		self.image:SetTexture(...)
	end

	function PANEL:SetText(...)
		self.button:SetText(...)
	end

	function PANEL:OnLayout()
		local x = self.offset
					
		self.image:SetSize(Vec2() + S*8)
		self.image:SetPosition(Vec2(x, 0))
		
		self.expand:SetPosition(Vec2(x - self.image:GetWidth(), 0))
		
		self.button:SetPosition(self.image:GetPosition() + Vec2(self.image:GetWidth() + S*2, 0))
		self.button:SizeToText()
					
		self.expand:CenterY()
		self.image:CenterY()
		self.button:CenterY()
	end

	function PANEL:AddNode(str, icon, id)
		local pnl = self.tree.AddNode(self.tree, str, icon, id)
		
		pnl.offset = self.offset + self.tree.IndentWidth
		pnl.node_parent = self
		
		self.expand:SetVisible(true)
		self:SetExpand(true)
		
		
		return pnl
	end
	
	function PANEL:SetExpandInternal(b)
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
	
	function PANEL:SetExpand(b)
		
		for pos, pnl in pairs(self.tree:GetChildren()) do
			if pnl.node_parent == self then
				pnl:SetExpandInternal(b)
			end
		end
		
		self.Expand = b
		self.expand:SetState(not b)
	end
				
	gui2.RegisterPanel(PANEL)
end

do
	local PANEL = {}

	PANEL.ClassName = "tree"
	prototype.GetSet(PANEL, "IndentWidth", S*8)
	prototype.GetSet(PANEL, "SelectedNode", NULL)

	PANEL.nodes = {}

	function PANEL:Initialize()
		self:SetNoDraw(true)
		self:SetClipping(true)
		self:SetStack(true)
		self:SetForcedStackSize(Vec2(0, 10*S))
		
		self:SetStackRight(false)
		self:SetSizeStackToWidth(true)
	end

	function PANEL:AddNode(str, icon, id)
		if id and self.nodes[id] and self.nodes[id]:IsValid() then self.nodes[id]:Remove() end
		
		local pnl = gui2.CreatePanel("tree_node", self)
		pnl:SetText(str) 
		pnl.offset = self.IndentWidth
		pnl.tree = self
		if icon then
			pnl.image:SetTexture(Texture(icon))
		end
		
		if id then
			self.nodes[id] = pnl 
		end
		
		self:Layout()
		
		return pnl
	end

	function PANEL:RemoveNode(pnl)
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
	
	function PANEL:SelectNode(node)
		node:OnPress()
	end
	
	function PANEL:OnLayout()
		local w = self:GetWidth()
		for _, v in ipairs(self:GetChildren()) do
			w = math.max(w, v.button:GetX() + v.button:GetWidth())
		end
		for _, v in ipairs(self:GetChildren()) do
			v:SetWidth(w)
		end
	end

	function PANEL:OnNodeSelect(node) end
	
	gui2.RegisterPanel(PANEL)		
end