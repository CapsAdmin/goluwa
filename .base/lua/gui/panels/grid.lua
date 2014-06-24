local PANEL = {}

PANEL.ClassName = "grid"

gui.GetSet(PANEL, "ItemSize")
gui.GetSet(PANEL, "Spacing", Vec2(1, 1))

gui.GetSet(PANEL, "StackRight", true)
gui.GetSet(PANEL, "StackDown", true)

gui.GetSet(PANEL, "SizeToWidth", false)
gui.GetSet(PANEL, "SizeToHeight", false)
gui.GetSet(PANEL, "NoPadding", false)


-- this is meant to keep the grid from rarranging due to how children are handled
PANEL.grid_i = 0

function PANEL:OnChildAdd(pnl)
	pnl.grid_pos = self.grid_i
	self.grid_i = self.grid_i + 1
end


function PANEL:Stack(list)

	self:RequestLayout(true)

	list = list or self.CustomList

	if not list then
		list = {}
		
		for k, v in pairs(self:GetChildren()) do
			table.insert(list, v)
		end
		
		table.sort(list, function(a, b) if a.grid_pos and b.grid_pos then return a.grid_pos < b.grid_pos end end)
	end
	
	local pad = self.NoPadding and 0 or self:GetSkinVar("Padding", 1)
	
	local w = 0
	local h
		
	for key, pnl in pairs(list) do
		if not pnl:IsVisible() then goto NEXT end
			
		local siz = pnl:GetSize()
		
		if self.ItemSize then
			if self.ItemSize.w ~= 0 then
				siz.w = self.ItemSize.w
			end
			if self.ItemSize.h ~= 0 then
				siz.h = self.ItemSize.h
			end
		end
		
		if self.Spacing then
			siz = siz + self.Spacing
		end

		if self.StackRight then
			h = h or siz.h
			w = w + siz.w

			if self.StackDown and w > self:GetWidth() then
				h = h + siz.h
				w = siz.w
			end
			
			pnl:SetPos(Vec2(w + pad, h + pad) - siz)
		else
			h = h or 0
			h = h + siz.h
			w = siz.w > w and siz.w or w
			
			pnl:SetPos(Vec2(pad, h + pad - siz.h))
		end
		
		if self.ItemSize then
			local siz = self.ItemSize
			
			if self.SizeToWidth then
				siz.w = self:GetWidth()
			end
			
			if self.SizeToHeight then
				siz.w = self:GetHeight()
			end

			pnl:SetSize(Vec2( siz.w - pad * 2, siz.h))
		else
			if self.SizeToWidth then
				pnl:SetWidth(self:GetWidth() - pad * 2)
			end
			
			if self.SizeToHeight then
				pnl:SetHeight(self:GetHeight() - pad * 2)
			end
		end
		
		::NEXT::
	end
	
	if self.SizeToWidth then
		w = self:GetWidth() - pad * 2
	end


	return Vec2(w, h) + pad * 2
end

function PANEL:SizeToContents()
	self:SetSize(self:Stack())
end

function PANEL:OnRequestLayout()
	self:LayoutHook("GridLayout")
end

function PANEL:OnDraw()
	self:DrawHook("GridDraw")
end

gui.RegisterPanel(PANEL)