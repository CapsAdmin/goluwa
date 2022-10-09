local gui = ... or _G.gui
local META = prototype.CreateTemplate("scroll")
META:GetSet("XScrollBar", true)
META:GetSet("YScrollBar", true)
META:GetSet("ScrollWidth", 8)

function META:Initialize()
	self.panel = NULL
	self:SetNoDraw(true)
	local scroll_area = self:CreatePanel("base", "scroll_area")
	scroll_area:SetClipping(true)
	scroll_area:SetNoDraw(true)
	scroll_area:SetAlwaysReceiveMouseInput(true)
	scroll_area:SetPadding(Rect())
	scroll_area:SetScrollable(true)
	scroll_area.OnLayout = function()
		self:Layout(true)
	end
end

function META:OnStyleChanged(skin)
	self:SetScrollWidth(self:GetSkin().scroll_width or 8)
end

function META:ScrollToFraction(vec)
	self.scroll_area:SetScrollFraction(vec)
end

function META:SetXScrollBar(b)
	self.XScrollBar = b

	if b then
		local track = self:CreatePanel("base", "x_track")
		track:SetStyle("scroll_horizontal_track")
		local area = self.scroll_area
		local handle = track:CreatePanel("button")
		self.x_handle = handle
		handle.real_width = 10
		handle:SetDraggable(true)
		handle:SetDragMinDistance(0)
		handle:SetStyle("scroll_horizontal_handle_inactive")
		handle:SetStyleTranslation("button_active", "scroll_horizontal_handle_active")
		handle:SetStyleTranslation("button_inactive", "scroll_horizontal_handle_inactive")
		handle.OnMouseInput = function(_, button, press)
			if button == "mwheel_down" then
				area:SetScroll(area:GetScroll() + Vec2(10, 0))
			elseif button == "mwheel_up" then
				area:SetScroll(area:GetScroll() + Vec2(-10, 0))
			end
		end
		track.OnMouseInput = handle.OnMouseInput
		handle.OnPositionChanged = function(_, pos)
			if not area:IsValid() then return end

			local w = area:GetSizeOfChildren().x / (area:GetWidth() / handle.real_width)
			w = w - handle:GetWidth()
			local frac = math.clamp(pos.x / w, 0, 1)
			self.scrolling = true
			area:SetScrollFraction(Vec2(frac, area:GetScrollFraction().y))
			self.scrolling = false
			pos.x = math.clamp(pos.x, 0, track:GetWidth() - handle:GetWidth())
			pos.y = handle.Parent:GetHeight() - handle:GetHeight()
		end
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
		local track = self:CreatePanel("base", "y_track")
		track:SetStyle("scroll_vertical_track")
		local area = self.scroll_area
		local handle = track:CreatePanel("button")
		self.y_handle = handle
		handle.real_height = 10
		handle:SetDraggable(true)
		handle:SetDragMinDistance(0)
		handle:SetStyle("scroll_vertical_handle_inactive")
		handle:SetStyleTranslation("button_active", "scroll_vertical_handle_active")
		handle:SetStyleTranslation("button_inactive", "scroll_vertical_handle_inactive")
		handle.OnMouseInput = function(_, button, press)
			if button == "mwheel_down" then
				area:SetScroll(area:GetScroll() + Vec2(0, 10))
			elseif button == "mwheel_up" then
				area:SetScroll(area:GetScroll() + Vec2(0, -10))
			end
		end
		track.OnMouseInput = handle.OnMouseInput
		handle.OnPositionChanged = function(_, pos)
			if not area:IsValid() then return end

			local h = area:GetSizeOfChildren().y / (area:GetHeight() / handle.real_height)
			h = h - handle:GetHeight()
			local frac = pos.y / h
			self.scrolling = true
			area:SetScrollFraction(Vec2(area:GetScrollFraction().x, frac))
			self.scrolling = false
			pos.x = handle.Parent:GetWidth() - handle:GetWidth()
			pos.y = math.clamp(pos.y, 0, handle.Parent:GetHeight() - handle:GetHeight())
		end
	else
		gui.RemovePanel(self.y_handle)
		gui.RemovePanel(self.y_track)
		self.y_handle = nil
		self.y_track = nil
	end
end

function META:GetAreaSize()
	local size = self:GetSize():Copy()

	if self.y_track and self.y_track:IsVisible() then
		size.y = self.y_track:GetPosition().y
	end

	if self.x_track and self.x_track:IsVisible() then
		size.x = self.y_track:GetPosition().x
	end

	return size
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
	self:SetScrollWidth(S * 4)
	local panel = self.panel

	if not panel:IsValid() then return end

	--panel:Layout(true)
	if self.scroll_area.scrolling then return end

	self.scroll_area.scrolling = true
	local children_size = self.scroll_area:GetSizeOfChildren()
	--	panel:SetSize(children_size)
	self.scroll_area:SetScroll(self.scroll_area:GetScroll())
	local x_offset = 0
	local y_offset = 0

	if self.x_track and self.x_track:IsVisible() then
		y_offset = self.ScrollWidth
	end

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
		local real = (
				self.y_track:GetHeight() / self.scroll_area:GetSizeOfChildren().y
			) * self.y_track:GetHeight()
		self.y_handle.real_height = real
		self.y_handle:SetHeight(math.max(real, 20))
	end

	if self.x_track then
		self.x_track:SetWidth(self:GetWidth() - x_offset)
		self.x_track:SetY(self:GetHeight() - self.x_track:GetHeight())
		local real = (
				self.x_track:GetWidth() / self.scroll_area:GetSizeOfChildren().x
			) * self.x_track:GetWidth()
		self.x_handle.real_width = real
		self.x_handle:SetWidth(math.max(real, 20))
	end

	self.scroll_area:SetWidth(self:GetWidth() - x_offset)
	self.scroll_area:SetHeight(self:GetHeight() - y_offset)
	self.scroll_area.scrolling = false
end

gui.RegisterPanel(META)

if RELOAD then
	local panel = gui.CreatePanel("frame", nil, "lol")
	panel:SetSize(Vec2() + 300)
	panel:SetStyle("frame")
	panel:CenterSimple()
	panel:SetResizable(true)
	local scroll = gui.CreatePanel("scroll", panel)
	scroll:SetXScrollBar(true)
	scroll:SetYScrollBar(true)
	scroll:SetupLayout("fill")
	scroll:SetMargin(Rect() + 4)
	local lol = gui.CreatePanel("text")
	lol:SetWidth(300)
	lol:SetObeyPanelWidth(true)
	lol:SetTextWrap(true)
	runfile("lua/examples/2d/markup.lua", lol.markup)
	scroll:SetPanel(lol)
	local old = panel.OnLayout

	function panel:OnLayout(...)
		panel:SetTitle(tostring(lol:GetSize()))
		return old(self, ...)
	end
end