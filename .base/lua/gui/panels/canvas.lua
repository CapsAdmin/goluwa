local PANEL = {}

PANEL.ClassName = "canvas"
PANEL.canvas = NULL

function PANEL:Initialize()
	self:SetIgnoreMouse(true)
	self.HideChildren = true
end
 
function PANEL:OnRequestLayout()
	-- umm
	local size = self:GetSize()
	if self.last_size ~= size or not self.canvas:IsValid() then
		
		if self.canvas:IsValid() then self.canvas:Remove() end
		self.canvas = FrameBuffer(self:GetSize():Unpack())
		
		self.last_size = size
		print("canvas resize")
	end
	
	self.needs_update = true
end 
 
function PANEL:DrawChildren(size)

	--surface.Start(0, 0, size.x, size.y)
	self.canvas:Begin() 
		for key, pnl in pairs(self:GetChildren()) do
			pnl:Draw()
		end 
	self.canvas:End()	
	
	--surface.End()
end 

function PANEL:OnDraw(size)
	
	if true or self.needs_update then
		self:DrawChildren(size)
		self.needs_update = false
	end

	if self.canvas:IsValid() then
		surface.SetColor(1, 1, 1, 1)
		surface.SetTexture(self.canvas:GetTexture())
		local pos = self:GetWorldPos()
		surface.DrawRect(pos.x, pos.y, size.w, size.h)
	end
end

function PANEL:OnMouseMove(pos, inside)
	if inside then
		self.needs_update = true
	end
end

gui.RegisterPanel(PANEL)