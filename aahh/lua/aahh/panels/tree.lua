local PANEL = {}

PANEL.ClassName = "tree"
PANEL.Base = "grid"

local TREE = PANEL

do -- tree node
	local PANEL = {}

	PANEL.ClassName = "tree_node"
	PANEL.Base = "button"
	
	class.GetSet(PANEL, "Expand", true)
	class.GetSet(PANEL, "IndentWidth", 16)

	function PANEL:Initialize()
		self.BaseClass.Initialize(self)
		
		local exp = self:CreatePanel("checkbox")
		local lbl = self:CreatePanel("label")
		local img = self:CreatePanel("image")
		
		lbl:SetIgnoreMouse(true)
		img:SetIgnoreMouse(true)
		img:SetTexture(Image("textures/gui/heart.png"))
				
		self.expand = exp
		self.label = lbl
		self.image = img
		
		exp:SetVisible(false)
		
		exp.OnChecked = function(b) 
			self:OnExpand(b) 
		end
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

	function PANEL:OnRequestLayout()
		self:LayoutHook("TreeNodeLayout")
	end

	function PANEL:AddNode(str, id)
		local pnl = TREE.AddNode(self.tree, str, id, self.pos + 1)
		pnl.offset = self.offset + self.IndentWidth
		pnl.node_parent = self
		
		self.expand:SetVisible(true)
		self:SetExpand(true)
		
		return pnl
	end
	
	function PANEL:SetExpand(b)
		::again::
		for pos, pnl in pairs(self.tree.CustomList) do
			if pnl.node_parent == self and pnl:GetExpand() ~= b then
				pnl:SetExpand(b)
				pnl:SetVisible(b) 
				goto again
			end
		end
		
		self.Expand = b
	
		self.tree:RequestLayout()
		
		self.expand:SetChecked(b)
	end
	
	function PANEL:OnDraw(size)
		self:DrawHook("TreeNodeDraw")
	end
	
	aahh.RegisterPanel(PANEL)
end


function PANEL:Initialize()
	self:SetItemSize(Vec2(0, 16))
	
	self:SetStackRight(false)
	self:SetSizeToWidth(true)
				
	self.CustomList = {}
end

function PANEL:AddNode(str, id, pos)
	if id and self.nodes[id] and self.nodes[id]:IsValid() then self.nodes[id]:Remove() end
	
	local pnl, pos = self:CreatePanel("tree_node", pos)
	pnl:SetText(str) 
	pnl.offset = 0
	pnl.pos = pos
	pnl.tree = self
	
	self:RequestLayout()
	
	table.insert(self.CustomList, pnl)
	
	if id then
		self.nodes[id] = pnl 
	end
	
	return pnl
end

function PANEL:RemovePanel(pnl)	
	for k,v in pairs(self.CustomList) do
		if v == pnl then
			table.remove(self.CustomList, k)
		end
	end

	::again::	
	for k,v in pairs(self.CustomList) do
		if v.node_parent == pnl then
			self:RemovePanel(v)
			goto again
		end
	end	
	
	pnl:Remove()
	self:RequestLayout()
end

aahh.RegisterPanel(PANEL)