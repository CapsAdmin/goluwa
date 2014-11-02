local gui2 = ... or _G.gui2
local S = gui2.skin.scale

do -- tree node
	local PANEL = {}

	PANEL.ClassName = "tree_node"
	
	prototype.GetSet(PANEL, "Expand", true)

	function PANEL:Initialize()	
		self:SetNoDraw(true)

		local label = gui2.CreatePanel("text_button", self)
		label:SetMargin(Rect()+2*S)
		label:SetStyleTranslation("button_active", "button_rounded_active")
		label:SetStyleTranslation("button_inactive", "menu_select")
		label:SetStyle("button_rounded_inactive")
		label:SetColor(Color(1,1,1,0))
		--label:SetNoDraw(true)
		label.OnRelease = function()
			self.label:SetColor(Color(1,1,1,1))
			--self.label:SetNoDraw(false)
			for k, v in ipairs(self.tree:GetChildren()) do
				if v ~= self then
					v.label:SetColor(Color(1,1,1,0))
					--self.label:SetNoDraw(true)
				end
			end
			self.tree:OnNodeSelect(self)
		end
		self.label = label

		local exp = gui2.CreatePanel("button", self)
		exp:SetMargin(Rect()+S)
		exp:SetVisible(false)
		exp.OnMouseInput = function(_, button, press) 
			if button == "button_1" and press then
				self:OnExpand(b) 
			end
		end
		self.expand = exp
		
		local img = gui2.CreatePanel("base", self)
		img:SetIgnoreMouse(true)
		img:SetTexture(Texture("textures/silkicons/heart.png"))
		self.image = img
	end
	
	function PANEL:OnMouseEnter(...)
		self.label:SetHighlight(true)
		self.label:OnMouseEnter(...)
	end
	
	function PANEL:OnMouseExit(...)
		self.label:SetHighlight(false)
		self.label:OnMouseExit(...)
	end
	
	function PANEL:OnMouseInput(...)
		self.label:OnMouseInput(...)
	end
	
	function PANEL:OnExpand()
		self:SetExpand(not self.Expand)
	end
	
	function PANEL:SetIcon(...)
		self.image:SetTexture(...)
	end

	function PANEL:SetText(...)
		self.label:SetText(...)
	end

	function PANEL:OnLayout()
		local x = self.offset
					
		self.image:SetSize(Vec2() + 16)
		self.image:SetPosition(Vec2(x, 0))
		
		self.expand:SetPosition(Vec2(x - self.image:GetWidth(), 0))
		
		self.label:SetPosition(self.image:GetPosition() + Vec2(self.image:GetWidth() + S*2, 0))
		self.label:SizeToText()
					
		self.expand:CenterY()
		self.image:CenterY()
		self.label:CenterY()
	end

	function PANEL:AddNode(str, id)
		local pnl = self.tree.AddNode(self.tree, str, id)
		
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
		
		self.expand:SetStyle(b and "-" or "+")
		self.expand:SetStyleTranslation("button_active", b and "-" or "+")
		self.expand:SetStyleTranslation("button_inactive", b and "-" or "+")
	end
				
	gui2.RegisterPanel(PANEL)
end

do
	local PANEL = {}

	PANEL.ClassName = "tree"
	prototype.GetSet(PANEL, "IndentWidth", 16)  

	function PANEL:Initialize()
		self:SetNoDraw(true)
		self:SetClipping(true)
		self:SetStack(true)
		self:SetForcedStackSize(Vec2(0, 10*S))
		
		self:SetStackRight(false)
		self:SetSizeStackToWidth(true)
	end

	function PANEL:AddNode(str, id)
		if id and self.nodes[id] and self.nodes[id]:IsValid() then self.nodes[id]:Remove() end
		
		local pnl = gui2.CreatePanel("tree_node", self)
		pnl:SetText(str) 
		pnl.offset = self.IndentWidth
		pnl.tree = self
		
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
		node.label:OnRelease()
	end
	
	function PANEL:OnLayout()
		local w = self:GetWidth()
		for _, v in ipairs(self:GetChildren()) do
			w = math.max(w, v.label:GetX() + v.label:GetWidth())
		end
		for _, v in ipairs(self:GetChildren()) do
			v:SetWidth(w)
		end
	end

	function PANEL:OnNodeSelect(node) end
	
	gui2.RegisterPanel(PANEL)		
end