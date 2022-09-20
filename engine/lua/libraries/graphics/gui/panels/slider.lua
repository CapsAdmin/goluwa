local gui = ... or _G.gui
local META = prototype.CreateTemplate("slider")
META:GetSet("Fraction", Vec2(0, 0))
META:GetSet("XSlide", true)
META:GetSet("YSlide", false)
META:GetSet("RightFill", false)
META:GetSet("LeftFill", false)

function META:Initialize()
	self:SetMinimumSize(Vec2(35, 35))
	self:SetNoDraw(true)
	local line = self:CreatePanel("base", "line")
	line:SetStyle("button_active")
	line.OnMouseInput = function(line, button, pressed)
		if pressed then
			self:SetFraction(line:GetMousePosition() / line:GetSize())
		end
	end
	line.OnPostDraw = function()
		self:OnLineDraw(line)
	end
	local button = self:CreatePanel("button", "button")
	button:SetStyleTranslation("button_active", "button_rounded_active")
	button:SetStyleTranslation("button_inactive", "button_rounded_inactive")
	button:SetStyle("button_rounded_inactive")
	button:SetDraggable(true)
	button.OnPositionChanged = function(_, pos)
		self:OnButtonPositionChanged(button, pos)
	end
end

function META:SetFraction(pos)
	self.Fraction = pos
	self.Fraction.x = math.clamp(self.Fraction.x, 0, 1)
	self.Fraction.y = math.clamp(self.Fraction.y, 0, 1)

	if self.XSlide and self.YSlide then

	elseif self.XSlide then
		self.Fraction.y = 0.5
	elseif self.YSlide then
		self.Fraction.x = 0.5
	end

	self.button:SetPosition(self.Fraction * self.line:GetSize())
	self.button:MouseInput("button_1", true)
	self:OnSlide(self.Fraction)
end

function META:OnButtonPositionChanged(button, pos)
	if self.XSlide and self.YSlide then
		pos.x = math.clamp(pos.x, 0, self:GetWidth() - button:GetWidth())
		pos.y = math.clamp(pos.y, 0, self:GetHeight() - button:GetHeight())
	elseif self.XSlide then
		pos.x = math.clamp(pos.x, 0, self:GetWidth() - button:GetWidth())
		pos.y = self:GetHeight() / 2 - button:GetHeight() / 2
	elseif self.YSlide then
		pos.x = self:GetWidth() / 2 - button:GetWidth() / 2
		pos.y = math.clamp(pos.y, 0, self:GetHeight() - button:GetHeight())
	end

	self.Fraction = pos / (self:GetSize() - button:GetSize())
	self.Fraction.x = math.clamp(self.Fraction.x, 0, 1)
	self.Fraction.y = math.clamp(self.Fraction.y, 0, 1)
	self:OnSlide(self.Fraction)
	self:MarkCacheDirty()
end

function META:OnLineDraw(line)
	render2d.SetTexture(self:GetSkin().menu_select[1])

	if self.RightFill then
		if self.XSlide and self.YSlide then
			self:DrawRect(0, 0, self.Fraction.x * line:GetWidth(), self.Fraction.y * line:GetHeight())
		elseif self.XSlide then
			self:DrawRect(0, 0, self.Fraction.x * line:GetWidth(), line:GetHeight())
		elseif self.YSlide then
			self:DrawRect(0, 0, line:GetWidth(), self.Fraction.y * line:GetHeight())
		end
	elseif self.LeftFill then
		if self.XSlide and self.YSlide then
			self:DrawRect(
				self.Fraction.x * line:GetWidth(),
				self.Fraction.y * line:GetHeight(),
				line:GetWidth() - (self.Fraction.x * line:GetWidth()),
				line:GetHeight() - (self.Fraction.y * line:GetHeight())
			)
		elseif self.XSlide then
			self:DrawRect(self.Fraction.x * line:GetWidth(), 0, line:GetWidth() - (self.Fraction.x * line:GetWidth()), 4)
		elseif self.YSlide then
			self:DrawRect(
				0,
				self.Fraction.y * line:GetHeight(),
				4,
				line:GetHeight() - (self.Fraction.y * line:GetHeight())
			)
		end
	end
end

function META:OnSlide(pos) end

function META:OnLayout(S)
	self.button:SetSize(self:GetSize():Copy() - S * 8)

	if self.XSlide and self.YSlide then
		self.line:SetSize(self:GetSize():Copy())
		self.button:SetSize(Vec2() + S * 5)
	elseif self.XSlide then
		self.button:SetWidth(S * 5)
		self.line:SetY(8 * S)
		self.line:SetWidth(self:GetWidth())
		self.line:SetHeight(self:GetHeight() - 8 * S * 2)
	elseif self.YSlide then
		self.button:SetHeight(S * 5)
		self.line:SetX(8 * S)
		self.line:SetHeight(self:GetHeight())
		self.line:SetWidth(self:GetWidth() - 8 * S * 2)
	end

	self.button:SetPosition(self.Fraction * self:GetSize())
end

gui.RegisterPanel(META)