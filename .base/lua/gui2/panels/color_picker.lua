local gui2 = ... or _G.gui2

local PANEL = {}

PANEL.ClassName = "color_picker"

prototype.GetSet(PANEL, "Hue", 0)
prototype.GetSet(PANEL, "Saturation", 1)
prototype.GetSet(PANEL, "Value", 1)

function PANEL:SetValue(val)
	self.Value = val
	self:OnColorChanged(HSVToColor(self:GetHue(), self:GetSaturation(), self:GetValue()))
end

function PANEL:SetSaturation(sat)
	self.Saturation = sat
	self:OnColorChanged(HSVToColor(self:GetHue(), self:GetSaturation(), self:GetValue()))
end

function PANEL:SetHue(hue)
	self.Hue = hue
	self:OnColorChanged(HSVToColor(self:GetHue(), self:GetSaturation(), self:GetValue()))
end

function PANEL:SetColor(color)
	self.Color = color
	local h,s,v = ColorToHSV(color)
	
	self:SetHue(h)
	self:SetSaturation(s)
	self:SetValue(v)
	
	self:OnColorChanged(color)
end

function PANEL:Initialize()
	self:SetNoDraw(true)
	local slider = self:CreatePanel("slider", "y_slider")
	slider:SetXSlide(false)
	slider:SetYSlide(true)
	slider.OnSlide = function(_, pos)
		self:SetValue(-pos.y+1)
		self.xy_slider.line:SetColor(Color(1,1,1)*self:GetValue())
	end
	
	local xy = self:CreatePanel("slider", "xy_slider")
	xy:SetXSlide(true)
	xy:SetYSlide(true)
	xy:SetRightFill(false)
	
	xy.OnSlide = function(_, pos)
		pos = pos - Vec2(0.5, 0.5)
		
		local sat = (pos:GetLength() ^ 2) * 2
		local hue = Vec2(-pos.y+1, pos.x):GetRad()
		hue = (hue + 1) / 2
		
		self:SetHue(hue)
		self:SetSaturation(sat)
		xy.line:SetColor(Color(1,1,1)*self:GetValue())
		
		self:OnColorChanged(HSVToColor(self:GetHue(), self:GetSaturation(), self:GetValue()))
	end
	
	xy.line:SetStyle("none")
	xy.line:SetTexture(Texture("textures/gui/hsv_square.png"))
	
	xy:SetFraction(Vec2(0.5, 0.5))
	slider:SetFraction(Vec2(0,1))
end

function PANEL:OnLayout()
	self.xy_slider:SetSize(self:GetSize() - Vec2(S*10 + S*4, 0))
	self.y_slider:SetX(self.xy_slider:GetWidth() - S*5 + S*2)
	self.y_slider:SetHeight(self:GetHeight())
	self.y_slider:SetWidth(S*20)
end

function PANEL:OnColorChanged(color) end

gui2.RegisterPanel(PANEL)