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
		self.canvas = FrameBuffer(self:GetWidth(), self:GetHeight(),  {
			attach = "color1",
			texture_format = {
				internal_format = "RGB32F",
				min_filter = "nearest",
			}
		})
		
		self.last_size = size
	end
	
	self.needs_update = true
end 
 
function PANEL:DrawChildren(size)
	self.canvas:Begin() 
		surface.Start(0, 0, size.x, size.y)
			for key, pnl in pairs(self:GetChildren()) do
				pnl:Draw()
			end  
		surface.End()
	self.canvas:End()	
end 

function PANEL:OnDraw(size)
	
	if true or self.needs_update then
		self:DrawChildren(size)
		self.needs_update = false
	end

	if self.canvas:IsValid() then
		surface.SetColor(1, 1, 1, 1)
		surface.SetTexture(self.canvas:GetTexture())
		surface.DrawRect(0, 0, size.w, size.h)
	end
end

function PANEL:OnMouseMove(pos, inside)
	if inside then
		self.needs_update = true
	end
end

gui.RegisterPanel(PANEL)