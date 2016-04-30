local gui = ... or _G.gui

local META = {}
META.ClassName = "scroll"

prototype.GetSet(META, "XScrollBar", true)
prototype.GetSet(META, "YScrollBar", true)
prototype.GetSet(META, "ScrollWidth", 8)

function META:Initialize()
	self.panel = NULL

	self:SetNoDraw(true)

	local scroll_area = self:CreatePanel("base", "scroll_area")
	scroll_area:SetClipping(true)
	scroll_area:SetNoDraw(true)
	scroll_area:SetAlwaysReceiveMouseInput(true)
	scroll_area:SetMargin(Rect())
	scroll_area:SetScrollable(true)
end

function META:OnStyleChanged(skin)
	self:SetScrollWidth(self:GetSkin().scroll_width or 8)
end

function META:SetXScrollBar(b)
	self.XScrollBar = b

	if b then
		local x_track = self:CreatePanel("base", "x_track")
		x_track:SetStyle("scroll_horizontal_track")

		local area = self.scroll_area

		local x_handle = x_track:CreatePanel("button")
		x_handle:SetDraggable(true)
		x_handle:SetStyle("scroll_horizontal_handle_inactive")
		x_handle:SetStyleTranslation("button_active", "scroll_horizontal_handle_active")
		x_handle:SetStyleTranslation("button_inactive", "scroll_horizontal_handle_inactive")

		x_handle.OnMouseInput = function(_, button, press)
			if button == "mwheel_down" then
				area:SetScroll(area:GetScroll() + Vec2(10, 0))
			elseif button == "mwheel_up" then
				area:SetScroll(area:GetScroll() + Vec2(-10, 0))
			end
		end
		x_track.OnMouseInput = x_handle.OnMouseInput

		x_handle.OnPositionChanged = function(_, pos)
			if not area:IsValid() then return end

			local w = area:GetSizeOfChildren().x / (area:GetWidth() / x_handle:GetWidth())
			local frac = math.clamp(pos.x / w, 0, 1)
			self.scrolling = true
			area:SetScrollFraction(Vec2(frac, area:GetScrollFraction().y))
			self.scrolling = false

			pos.x = math.clamp(pos.x, 0, x_track:GetWidth() - x_handle:GetWidth())
			pos.y = x_handle.Parent:GetHeight() - x_handle:GetHeight()
		end

		self.x_handle = x_handle
	else
		gui.RemovePanel(self.x_handle)
		gui.RemovePanel(self.x_track)

		self.x_handle = nil
		self.x_track = nil
	end
end

function META:SetYScrollBar(b)
	self.YScrollBar = b

	if b then
		local y_track = self:CreatePanel("base", "y_track")
		y_track:SetStyle("scroll_vertical_track")

		local area = self.scroll_area

		local y_handle = y_track:CreatePanel("button")
		y_handle:SetDraggable(true)
		y_handle:SetStyle("scroll_vertical_handle_inactive")
		y_handle:SetStyleTranslation("button_active", "scroll_vertical_handle_active")
		y_handle:SetStyleTranslation("button_inactive", "scroll_vertical_handle_inactive")

		y_handle.OnMouseInput = function(_, button, press)
			if button == "mwheel_down" then
				area:SetScroll(area:GetScroll() + Vec2(0, 10))
			elseif button == "mwheel_up" then
				area:SetScroll(area:GetScroll() + Vec2(0, -10))
			end
		end
		y_track.OnMouseInput = y_handle.OnMouseInput

		y_handle.OnPositionChanged = function(_, pos)
			if not area:IsValid() then return end

			local h = area:GetSizeOfChildren().y / (area:GetHeight() / y_handle:GetHeight())
			local frac = pos.y / h
			self.scrolling = true
			area:SetScrollFraction(Vec2(area:GetScrollFraction().x, frac))
			self.scrolling = false

			pos.x = y_handle.Parent:GetWidth() - y_handle:GetWidth()
			pos.y = math.clamp(pos.y, 0, y_handle.Parent:GetHeight() - y_handle:GetHeight())
		end

		self.y_handle = y_handle
		self.y_track = y_track
	else
		gui.RemovePanel(self.y_handle)
		gui.RemovePanel(self.y_track)

		self.y_handle = nil
		self.y_track = nil
	end
end

function META:SetPanel(panel)
	panel:SetParent(self.scroll_area)
--	panel:SetVisibilityPanel(self.scroll_area)
	self.panel = panel

	local area = self.scroll_area

	self:SetYScrollBar(self:GetYScrollBar())
	self:SetXScrollBar(self:GetXScrollBar())

	area.OnScroll = function(_, frac)
		if self.scrolling then return end
		if self.y_track then
			self.y_handle:SetY(frac.y * (self.y_track:GetHeight() - self.y_handle:GetHeight()))
		end
		if self.x_track then
			self.x_handle:SetX(frac.x * (self.x_track:GetWidth() - self.x_handle:GetWidth()))
		end
	end

	self:SetScrollWidth(self:GetSkin().scroll_width or self.ScrollWidth)
	self:Layout()

	return panel
end

function META:SetScrollFraction(scroll)
	--self.scroll_area.scrolling = true
	self.scroll_area:SetScrollFraction(scroll)
	--self.scroll_area.scrolling = false
end

function META:SetScrollWidth(num)
	if self.x_track then
		self.x_track:SetHeight(num)
		self.x_handle:SetHeight(num)
	end

	if self.y_track then
		self.y_track:SetWidth(num)
		self.y_handle:SetWidth(num)
	end

	self.ScrollWidth = num
end

function META:OnLayout(S)
	self:SetScrollWidth(S*4)

	local panel = self.panel

	if not panel:IsValid() then return end
	--panel:Layout(true)

	if self.scroll_area.scrolling then return end

	self.scroll_area.scrolling = true

	local children_size = self.scroll_area:GetSizeOfChildren()
--	panel:SetSize(children_size)

	local y_offset = 0

	self.scroll_area:SetScroll(self.scroll_area:GetScroll())

	if self.x_track and self.x_track:IsVisible() then
		y_offset = self.ScrollWidth
	end

	local x_offset = 0

	if self.y_track and self.y_track:IsVisible() then
		x_offset = self.ScrollWidth
	end

	if self.y_track then
		if self.scroll_area:GetHeight() > children_size.y + self.ScrollWidth then
			self.y_track:SetVisible(false)
		else
			self.y_track:SetVisible(true)
		end
	end

	if self.x_track then
		if self.scroll_area:GetWidth() > children_size.x + self.ScrollWidth then
			self.x_track:SetVisible(false)
		else
			self.x_track:SetVisible(true)
		end
	end

	if self.y_track then
		self.y_track:SetHeight(self:GetHeight() - y_offset)
		self.y_track:SetX(self:GetWidth() - self.y_track:GetWidth())

		self.y_handle:SetHeight((self.y_track:GetHeight() / self.scroll_area:GetSizeOfChildren().y) * self.y_track:GetHeight())
	end

	if self.x_track then
		self.x_track:SetWidth(self:GetWidth() - x_offset)
		self.x_track:SetY(self:GetHeight() - self.x_track:GetHeight())

		self.x_handle:SetWidth((self.x_track:GetWidth() / self.scroll_area:GetSizeOfChildren().x) * self.x_track:GetWidth())
	end

	if self.y_track and self.y_track:IsVisible() then
		x_offset = self.ScrollWidth
	end

	self.scroll_area:SetWidth(self:GetWidth() - x_offset)
	self.scroll_area:SetHeight(self:GetHeight() - y_offset)

	self.scroll_area.scrolling = false
end

gui.RegisterPanel(META)

if RELOAD then
	local panel = gui.CreatePanel("base", nil, "lol")
	panel:SetSize(Vec2() + 300)
	panel:SetStyle("frame")
	panel:CenterSimple()
	panel:SetResizable(true)

	local scroll = gui.CreatePanel("scroll", panel)
	scroll:SetXScrollBar(true)
	scroll:SetYScrollBar(true)
	scroll:SetupLayout("fill")
	scroll:SetPadding(Rect()+4)


	local lol = gui.CreatePanel("base")
	lol:SetSize(Vec2() + 250)
	lol:SetColor(Color(1,0,0,0.5))
	scroll:SetPanel(lol)
end