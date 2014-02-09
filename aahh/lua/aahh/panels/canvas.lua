local PANEL = {}

PANEL.ClassName = "canvas"
PANEL.canvas = NULL

function PANEL:Initialize()
	self.HideChildren = true
	self.NoMatrix = true 
	self:SetIgnoreMouse(true)
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
 
function PANEL:DrawChildren(pos, size)

	surface.Start(0, 0, size.x, size.y)
	surface.Translate(-pos.x, -pos.y)
	self.canvas:Begin() 
		for key, pnl in pairs(self:GetChildren()) do
			pnl:Draw()
		end 
	self.canvas:End()
	
	
	surface.End()
end 

function PANEL:OnDraw(size)
	local pos = self:GetWorldPos()
	
	if self.needs_update then
		self:DrawChildren(pos, size)
		self.needs_update = false
	end

	if self.canvas:IsValid() then
		surface.Color(1, 1, 1, 1)
		surface.SetTexture(self.canvas:GetTexture())
		surface.DrawRect(pos.x, pos.y, size.w, size.h)
	end
end

function PANEL:OnMouseMove(pos, inside)
	if inside then
		self.needs_update = true
	end
end

aahh.RegisterPanel(PANEL)