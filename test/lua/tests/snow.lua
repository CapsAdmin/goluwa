gui2 = include("gui2/gui2.lua") 
 
local scale = 2
local ninepatch_size = 32
local ninepatch_corner_size = 4
local ninepatch_pixel_border = scale
local bg = ColorBytes(64, 44, 128, 200) 


surface.CreateFont("snow_font", {
	path = "fonts/zfont.txt", 
	size = 8*scale,
	shadow = scale,
	shadow_color = Color(0,0,0,0.5),
}) 

surface.CreateFont("snow_font_green", {
	path = "fonts/zfont.txt", 
	size = 8*scale,
	shadow = scale,
	shadow_color = Color(0,1,0,0.4),
}) 

surface.CreateFont("snow_font_noshadow", {
	path = "fonts/zfont.txt", 
	size = 8*scale,
})

local skin = {
	button_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 72, 68, 64, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 104, 100, 96, 255
		end
		
		return 88, 92, 88, 255
	end),

	button_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 104, 100, 96, 255
		end
		
		return 72, 68, 64, 255
	end),

	button_rounded_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y)
		y = -y + ninepatch_size
		
		if 
			(x >= ninepatch_size-ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border) or 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x <= ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 192, 144, 144, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 160, 120, 120, 255
		end
		
		return 176, 132, 128, 255
	end),
	
	button_rounded_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y)
		y = -y + ninepatch_size
		
		if 
			(x >= ninepatch_size-ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border) or 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x <= ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 160, 120, 120, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 192, 144, 144, 255
		end
		
		return 176, 132, 128, 255
	end),
	
	tab_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border then
			return 184, 48, 48, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 184, 48, 48, 255
		end
		
		return 168, 32, 32, 255
	end),
	
	tab_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border then
			return 136, 0, 0, 255
		elseif x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 168, 32, 32, 255
		end
		
		return 152, 16, 16, 255
	end),

	menu_select = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border or x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 80, 0, 136, 255
		end
		
		return 80, 0, 160, 255
	end),
	
	gradient = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		local v = (math.sin(y / ninepatch_size * math.pi)^0.8 * 255) / 2.25 + 130
		return v, v, v, 255
	end),

	gradient2 = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		local v = (math.sin(x / ninepatch_size * math.pi) * 255) / 5 + 180
		v = -v + 255
		return v, v, v, 255
	end),
	
	gradient3 = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		local v = (math.sin(y / ninepatch_size * math.pi) * 255) / 5 + 180
		v = -v + 255
		return v, v, v, 255
	end),
	
	frame = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 152, 16, 16, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 184, 48, 48, 255
		end

		return 168, 32, 32, 255
	end),
}

local temp = {}
for k,v in pairs(skin) do
	temp[k] = {v, ninepatch_size, ninepatch_corner_size}
end

gui2.SetSkin(temp)

--[==[

-- VirtualQuery ??

collectgarbage()
local base = tonumber(("%p"):format(coroutine.running()))
ffi.cdef([[
	typedef union {
		uint8_t chars[8];
		uint16_t shorts[4];
		uint32_t longs[2];
		
		int64_t integer_signed;
		uint64_t integer_unsigned;
		double decimal;
		
	} number_buffer_longlong;
	
	typedef union {
		uint8_t chars[4];
		uint16_t shorts[2];
		
		int32_t integer_signed;
		uint32_t integer_unsigned;
		float decimal;
		
	} number_buffer_long;
	
	typedef union {
		uint8_t chars[2];
	
		int16_t integer_signed;
		uint16_t integer_unsigned;
		
	} number_buffer_short;
]])


local number = ffi.new("number_buffer_long")
for i = 0, collectgarbage("count") * 1024 - 1, 4 do
	
	number.chars[0] = ffi.cast("char *", i)[0]
	number.chars[1] = ffi.cast("char *", i)[1]
	number.chars[2] = ffi.cast("char *", i)[2]
	number.chars[3] = ffi.cast("char *", i)[3]
	
	print(number.integer_signed)
	
	if i < 50 then
		print(i, ffi.cast("long *", i)[0])	
		break
	end
end]==]

do
	local PANEL = {}
	
	PANEL.ClassName = "text"
	
	prototype.GetSet(PANEL, "Text")
	prototype.GetSet(PANEL, "ParseTags", false)
	prototype.GetSet(PANEL, "Editable", false)
	prototype.GetSet(PANEL, "Wrap", false)
	
	prototype.GetSet(PANEL, "Font", "default")
	prototype.GetSet(PANEL, "TextColor", Color(1,1,1,1))
	
	function PANEL:Initialize()
		self.markup = surface.CreateMarkup()
		
		self:SetSendMouseInputToParent(true)
		self:SetColor(Color(0,0,0,0))
		self:SetRedirectFocus(carrier)
	end
	
	function PANEL:SetText(str)
		self.Text = str
		
		self:SetIgnoreMouse(not self.Editable)

		local markup = self.markup
		
		markup:SetEditable(self.Editable)
		markup:SetLineWrap(self.Wrap)
		
		markup:Clear()
		markup:AddFont(self.Font)
		markup:AddColor(self.TextColor)
		markup:AddString(self.Text, self.ParseTags)
		
		self:OnDraw() -- hack! this will update markup sizes
	end
	
	function PANEL:OnDraw()
		local markup = self.markup

		markup:SetMousePosition(self:GetMousePosition():Copy())

		markup.cull_x = self.Parent.Scroll.x
		markup.cull_y = self.Parent.Scroll.y
		markup.cull_w = self.Parent.Size.w
		markup.cull_h = self.Parent.Size.h
		
		markup:Draw()
		
		self.Size.w = markup.width
		self.Size.h = markup.height
		
		if not input.IsMouseDown("button_1") then
			if not markup.mouse_released then
				markup:OnMouseInput("button_1", false)
				markup.mouse_released = true
			end
		end
	end
	
	function PANEL:OnMouseInput(button, press)
		local markup = self.markup

		markup:OnMouseInput(button, press)
		
		if button == "button_1" then
			self:RequestFocus()
			self:BringToFront()
			markup.mouse_released = false
		end
	end
	
	function PANEL:OnKeyInput(key, press)
		local markup = self.markup

		if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) return end
		if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) return end
	
		if press then
			markup:OnKeyInput(key, press)
		end
	end
	
	function PANEL:OnCharInput(char)
		self.markup:OnCharInput(char)
	end	
	
	gui2.RegisterPanel(PANEL)
end

do
	local PANEL = {}

	PANEL.ClassName = "button"
		
	prototype.GetSet(PANEL, "Mode", "normal")
	prototype.GetSet(PANEL, "ResetOnMouseExit", true)

	function PANEL:Initialize()
		self:SetStyle("button_inactive")
		self:SetCursor("hand")
		self.button_down = {}
	end
	
	function PANEL:Toggle(button)
		self:SetState(not self:GetState(button), button)
	end
	
	function PANEL:SetState(pressed, button)
		button = button or "button_1"
		
		if pressed then
			self:OnStateChanged(pressed, button)
			
			self.button_down[button] = pressed
			
			if button == "button_1" then
				self:SetStyle("button_active")
				self:OnRelease() 
			end
			
			
		elseif self.button_down[button] then
			self:OnStateChanged(pressed, button)
			
			self.button_down[button] = nil
			
			if button == "button_1" then
				self:SetStyle("button_inactive")
				self:OnPress()
			end
			
			self:OnOtherButtonPress(button)
		end
	end
	
	function PANEL:GetState(button)
		button = button or "button_1"
		return self.button_down[button]
	end

	function PANEL:OnMouseInput(button, press)
		if self.Mode == "normal" then
			self:SetState(press, button)
		elseif self.Mode == "toggle" and press then
			self:Toggle(button)
		elseif self.Mode == "double" and press then
			--self:SetState(press, button)
		end
	end
	
	function PANEL:OnMouseEnter()
		self:Animate("Color", {Color(1,1,1,1)*1.25, function() return self:IsMouseOver() end, "from"}, duration, "", pow)
	end
	
	function PANEL:OnMouseExit()
		if self.Mode ~= "toggle" and self.ResetOnMouseExit then
			self.button_down = {}
			self:SetStyle("button_inactive")
		end
	end
	
	function PANEL:OnPress() end
	function PANEL:OnRelease() end
	function PANEL:OnOtherButtonPress(button) end
	function PANEL:OnStateChanged(press, button) end
	
	function PANEL:Test()		
		local btn = gui2.CreatePanel("button")
		
		btn:SetMode("toggle")
		btn:SetPosition(Vec2()+100)
		
		return btn
	end
	
	gui2.RegisterPanel(PANEL)
end

do -- text button
	local PANEL = {}
	
	PANEL.ClassName = "text_button"
	PANEL.Base = "button"
	
	prototype.GetSetDelegate(PANEL, "Text", "", "label")
	prototype.GetSetDelegate(PANEL, "ParseTags", false, "label")
	prototype.GetSetDelegate(PANEL, "Font", "default", "label")
	prototype.GetSetDelegate(PANEL, "TextColor", Color(1,1,1), "label")
	
	prototype.Delegate(PANEL, "label", "CenterText", "Center")
	
	function PANEL:Initialize()
		self.BaseClass.Initialize(self)
		
		local label = gui2.CreatePanel("text", self)
		label:SetEditable(false)
		label:SetIgnoreMouse(true)
		self.label = label
	end
	
	function PANEL:SizeToText()
		local marg = self:GetMargin()
			
		self.label:SetPosition(marg:GetPos())
		self:SetSize(self.label:GetSize() + marg:GetSize()*2)
	end
	
	function PANEL:Test()		
		local btn = gui2.CreatePanel("text_button")
		
		btn:SetFont("snow_font")
		btn:SetTextColor(ColorBytes(200, 200, 200))
		btn:SetText("oh")
		btn:SetMargin(Rect()+scale*3)
		btn:SizeToText()
		btn:SetMode("toggle")
		btn:SetPosition(Vec2()+100)
	end
	
	gui2.RegisterPanel(PANEL)
end 

do
	local PANEL = {}
	PANEL.ClassName = "frame"
	
	function PANEL:Initialize()	
		self:SetDraggable(true)
		self:SetResizable(true) 
		self:SetBringToFrontOnClick(true)
		
		self:SetMargin(Rect(0,10*scale,0,0))  
		self:SetStyle("frame")
			
		local bar = gui2.CreatePanel("base", self)
		bar:SetObeyMargin(false)
		bar:Dock("fill_top") 
		bar:SetSendMouseInputToParent(true)
		bar:SetHeight(10*scale)
		bar:SetTexture(skin.gradient)
		bar:SetColor(ColorBytes(120, 120, 160))
		bar:SetClipping(true)
						
		local close = gui2.CreatePanel("text_button", bar)
		close:SetFont("snow_font_noshadow")  
		close:SetTextColor(ColorBytes(50,50,50))
		close:SetText("X")
		close:SizeToText()
		close:SetStyle("button_rounded_inactive")
		close:SetStyleTranslation("button_active", "button_rounded_active")
		close:SetStyleTranslation("button_inactive", "button_rounded_inactive")
		
		close:Dock("right") 
		
		 --close:SetStyle("button_rounded")
		
		close.OnPress = function() 
			self:Remove()
		end
	
		self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
		
		self.frame = self
		self.bar = bar
		
		self:SetTitle("no title")
	end
	
	function PANEL:SetTitle(str)
		gui2.RemovePanel(self.title)
		local title = gui2.CreatePanel("text", self.bar)
		title:SetHeight(self.bar:GetHeight())
		title:SetFont("snow_font")  
		title:SetTextColor(ColorBytes(200, 200, 200))
		title:SetText(str)
		title:SetPosition(Vec2(2*scale,0))
		title:CenterY()
		title:SetColor(Color(0,0,0,0))
		self.title = title
	end
	
	gui2.RegisterPanel(PANEL)   
end
	
do	
	local scroll_width = scale*8 

	local PANEL = {}
	PANEL.ClassName = "list"
	
	PANEL.entries = {}
	
	function PANEL:Initialize()				
		local list = gui2.CreatePanel("base", self)
		list:SetColor(Color(0,0,0,1))
		list:SetClipping(true)
		list:SetScrollable(true)
				
		do
			local y_scroll = gui2.CreatePanel("base", self)
			y_scroll:SetTexture(skin.gradient2)

			local up = gui2.CreatePanel("base", y_scroll)				
			up:SetStyle("button_rounded_inactive")

			local y_scroll_bar = gui2.CreatePanel("base", y_scroll)
			y_scroll_bar:SetDraggable(true)	
			y_scroll_bar:SetStyle("button_inactive")

			local down = gui2.CreatePanel("base", y_scroll)
			down:SetStyle("button_rounded_inactive")
					
			y_scroll_bar.OnPositionChanged = function(self, pos)
				local frac = math.clamp(pos.y / self.Parent:GetHeight(), 0, 1)
				list:SetScrollFraction(Vec2(list:GetScrollFraction().x, frac))
		 
				pos.x = self.Parent:GetWidth() - self:GetWidth()
				pos.y = math.clamp(pos.y, self:GetHeight(), self.Parent:GetHeight() - (self:GetHeight() * 2))
			end
			
			list.OnScroll = function(self, frac)
				y_scroll_bar:SetPosition(Vec2(0,frac.y * self.Parent:GetHeight()))
			end
			
			up.OnMouseInput = function(self, button, press)
				if button ~= "button_1" or not press then return end
				if #list:GetChildren() == 0 then return end
				
				local h = list:GetChildren()[1]:GetHeight()
				
				local pos = list:GetScroll()
				pos.y = pos.y - h
				list:SetScroll(pos)
			end
			
			down.OnMouseInput = function(self, button, press)
				if button ~= "button_1" or not press then return end
				if #list:GetChildren() == 0 then return end
				
				local h = list:GetChildren()[1]:GetHeight()
				
				local pos = list:GetScroll()
				pos.y = pos.y + h
				list:SetScroll(pos)
			end
			
			self.list = list
			self.down = down
			self.up = up
			self.y_scroll_bar = y_scroll_bar
			self.y_scroll = y_scroll
		end
		
		do
			local x_scroll = gui2.CreatePanel("base", self)
			x_scroll:SetTexture(skin.gradient3)

			local left = gui2.CreatePanel("base", x_scroll)				
			left:SetStyle("button_rounded_inactive")

			local x_scroll_bar = gui2.CreatePanel("base", x_scroll)
			x_scroll_bar:SetDraggable(true)	
			x_scroll_bar:SetStyle("button_inactive")

			local right = gui2.CreatePanel("base", x_scroll)
			right:SetStyle("button_rounded_inactive")
					
			x_scroll_bar.OnPositionChanged = function(self, pos)
				local frac = math.clamp(pos.x / self.Parent:GetWidth(), 0, 1)
				list:SetScrollFraction(Vec2(frac, list:GetScrollFraction().y))
		 
				pos.x = math.clamp(pos.x, self:GetWidth(), self.Parent:GetWidth() - (self:GetWidth() * 2))
				pos.y = self.Parent:GetHeight() - self:GetHeight()
			end
			
			list.OnScroll = function(self, frac)
				x_scroll_bar:SetPosition(Vec2(frac.x * self.Parent:GetWidth(), 0))
			end
			
			left.OnMouseInput = function(self, button, press)
				if button ~= "button_1" or not press then return end
				if #list:GetChildren() == 0 then return end
				
				local w = list:GetChildren()[1]:GetWidth()
				
				local pos = list:GetScroll()
				pos.x = pos.x - w
				list:SetScroll(pos)
			end
			
			right.OnMouseInput = function(self, button, press)
				if button ~= "button_1" or not press then return end
				if #list:GetChildren() == 0 then return end
				
				local w = list:GetChildren()[1]:GetWidth()
				
				local pos = list:GetScroll()
				pos.x = pos.x + w
				list:SetScroll(pos)
			end
			
			self.list = list
			self.right = right
			self.left = left
			self.x_scroll_bar = x_scroll_bar
			self.x_scroll = x_scroll
		end
	end
	
	function PANEL:OnLayout()
		local w = 0		
		local y = 0
		
		for k, v in pairs(self.entries) do
			v:SetPosition(Vec2(0, y))
			y = y + v:GetHeight() - scale
			
			if v.label then
				w = math.max(w, v.label:GetSize().w)
			end
		end
		
		for k,v in ipairs(self.list:GetChildren()) do
			v:SetWidth(w)
		end
	
		self.list:SetSize(self:GetSize()*1)
		
		if self.y_scroll:IsVisible() then
			self.list:SetWidth(self:GetWidth())
		else
			self.list:SetWidth(self:GetWidth() - scroll_width)
		end
		
		if self.x_scroll:IsVisible() then
			self.list:SetHeight(self:GetHeight())
		else
			self.list:SetHeight(self:GetHeight() - scroll_width)
		end
		
		do
			self.y_scroll:SetSize(Vec2(scroll_width, self:GetHeight()))
			self.y_scroll:SetPosition(Vec2(self:GetWidth() - scroll_width, 0))
			
			self.down:SetSize(Vec2(scroll_width, scroll_width))
			self.down:SetPosition(Vec2(0, self:GetHeight() - self.down:GetHeight()))
			
			self.y_scroll_bar:SetSize(Vec2(scroll_width, scroll_width))
			
			self.up:SetSize(Vec2(scroll_width, scroll_width))
		
			--self.y_scroll_bar:SetHeight(math.max((self.list:GetHeight() / self.list:GetSizeOfChildren().h) * self.list:GetHeight(), scroll_width))
		
			if self.list:GetHeight() > self.list:GetSizeOfChildren().h then
				self.y_scroll:SetVisible(false)
			else
				self.y_scroll:SetVisible(true)
			end
		end
		
		do
			self.x_scroll:SetSize(Vec2(self:GetWidth(), scroll_width))
			self.x_scroll:SetPosition(Vec2(0, self:GetHeight() - scroll_width))
			
			self.right:SetSize(Vec2(scroll_width, scroll_width))
			self.right:SetPosition(Vec2(self:GetWidth() - self.right:GetWidth(), 0))
			
			self.x_scroll_bar:SetSize(Vec2(scroll_width, scroll_width))
			
			self.left:SetSize(Vec2(scroll_width, scroll_width))
		
		--	self.x_scroll_bar:SetWidth(math.max((self.list:GetWidth() / self.list:GetSizeOfChildren().w) * self.list:GetWidth(), scroll_width))
		
			if self.list:GetWidth() > self.list:GetSizeOfChildren().w then
				self.x_scroll:SetVisible(false)
			else
				self.x_scroll:SetVisible(true)
			end
		end
	end
	
	function PANEL:AddEntry(name, on_click)		
		local button = gui2.CreatePanel("base", self.list)
		button:SetSendMouseInputToParent(true)
		
		local label = gui2.CreatePanel("text", button)				
		label:SetSendMouseInputToParent(true)
		
		label:SetFont("snow_font_green")
		label:SetTextColor(Color(0,1,0))
		label:SetWrap(false)
		label:SetText(name)
		button:SetSize(label:GetSize() + Vec2(4,4) * scale)
		label:CenterY()
		button.label = label
		
		local last_child = self:GetChildren()[#self:GetChildren()]
		button:SetPosition(Vec2(0, last_child:GetPosition().y + last_child:GetHeight() - 2*scale))
			
		button:SetColor(Color(0,0,0,0))
		button:SetStyle("menu_select")

		button.OnMouseInput = function(_, key, press)
			if key == "button_1" then
				if press then
					button:SetColor(Color(1,1,1,1))
					for k,v in ipairs(self.list:GetChildren()) do
						if v ~= button then
							v:SetColor(Color(0,0,0,0))
						end
					end
					if on_click then on_click(button) end
				end
			end
		end
		
		table.insert(self.entries, button)
	end	
	
	gui2.RegisterPanel(PANEL)  
end
 
do
	do
		local PANEL = {}
		PANEL.ClassName = "menu"
		PANEL.sub_menu = NULL
		
		function PANEL:Initialize()
			self:SetStyle("button_inactive")
		end
		
		function PANEL:AddEntry(text, on_click)
			local entry = gui2.CreatePanel("menu_entry", self)
			
			entry:SetText(text)
			entry.OnClick = on_click
			
			return entry
		end
		
		function PANEL:AddSubMenu(text, on_click)
			local menu = self:AddEntry(text, on_click):CreateSubMenu()
			
			self:CallOnRemove(function() gui2.RemovePanel(menu) end)
			self:CallOnHide(function() menu:SetVisible(false) end)
			
			return menu  
		end
		
		function PANEL:AddSeparator()
			local panel = gui2.CreatePanel("base", self)
			panel:SetStyle("button_active")
			panel:SetHeight(2*scale)
			panel:SetIgnoreMouse(true)
		end
		
		function PANEL:OnLayout()
			local w = 0
			local y = scale
			
			for k, v in ipairs(self:GetChildren()) do
				v:SetPosition(Vec2(2*scale, y))
				if v.label then
					w = math.max(w, v.label:GetSize().w)
				end
				y = y + v:GetSize().h + scale
			end
			
			for k, v in ipairs(self:GetChildren()) do
				v:SetWidth(w + 4*scale)
			end
			
			self:SetSize(Vec2(w + 8*scale, y + scale))
		end
		
		gui2.RegisterPanel(PANEL)
	end

	do
		local PANEL = {}
		
		PANEL.ClassName = "menu_entry"
		PANEL.menu = NULL
		
		function PANEL:Initialize()
			self:SetColor(Color(0,0,0,0))
			self:SetStyle("menu_select")
			self:SetPadding(Rect(scale, scale, scale, scale))
			
			self.label = gui2.CreatePanel("text", self)
			self.label:SetFont("snow_font") 
			self.label:SetTextColor(ColorBytes(200, 200, 200)) 
		end
		
		function PANEL:OnMouseEnter()
			self:SetColor(Color(1,1,1,1))
			
			-- close all parent menus
			for k,v in ipairs(self.Parent:GetChildren()) do
				if v ~= self and v.ClassName == "menu_entry" and v.menu and v.menu:IsValid() and v.menu.ClassName == "menu" then
					v.menu:SetVisible(false)
				end
			end
			
			if self.menu:IsValid() then				
				self.menu:SetVisible(true)
				self.menu:Layout(true)
				self.menu:SetPosition(self:GetWorldPosition() + Vec2(self:GetWidth() + scale*2, 0))
				self.menu:Animate("DrawPositionOffset", {Vec2(-self.menu.Size.w/2), Vec2(0)}, 0.1, "+", nil, true)
				--self.menu:Animate("DrawAngleOffset", {Ang3(0,0,0)}, 0.5, "*", nil, Ang3(0, 10, 0))
			end
		end
		
		function PANEL:OnMouseExit()
			self:SetColor(Color(1,1,1,0))
		end
		
		function PANEL:SetText(str)
			self.label:SetText(str)
			self:SetHeight(self.label:GetSize().h + 4*scale)
			self.label:CenterY()
		end
		
		function PANEL:CreateSubMenu()			
		
			local icon = gui2.CreatePanel("base", self)
			icon:Dock("right")
			icon:SetIgnoreMouse(true)
			icon:SetPadding(Rect(0,0,scale*2,0))
			icon:SetColor(Color(0,0,0,0))
			
			local label = gui2.CreatePanel("text", icon)
			label:SetFont("snow_font") 
			label:SetTextColor(ColorBytes(200,200,200)) 
			label:SetText("▶")
			icon:SetSize(label:GetSize())

			self.menu = gui2.CreatePanel("menu")
			self.menu:SetVisible(false)
			
			return self.menu
		end
				 
		function PANEL:OnMouseInput(button, press)
			if button == "button_1" and press then
				self:OnClick()
			end
		end
		
		function PANEL:OnClick() gui2.SetActiveMenu() end 
		
		gui2.RegisterPanel(PANEL)
	end
end

do	
	local PANEL = {}
	
	PANEL.ClassName = "tab"
	PANEL.tabs = {}
	
	function PANEL:Initialize()
		self:SetSendMouseInputToParent(true)
		self:SetColor(Color(0,0,0,0))
	
		local tab_bar =  gui2.CreatePanel("base", self)
		tab_bar:SetColor(ColorBytes(16,16,152,255))
		
		tab_bar:SetStack(true)
		tab_bar:SetStackDown(false)
		tab_bar:SetClipping(true)
		tab_bar:SetScrollable(true)
				
		self.tab_bar = tab_bar
	end
	
	function PANEL:AddTab(name)
		if self.tabs[name] then
			gui2.RemovePanel(self.tabs[name].button)
			gui2.RemovePanel(self.tabs[name].content)
		end
	
		local button = gui2.CreatePanel("text_button", self.tab_bar)
		button:SetMode("toggle")
		button:SetSendMouseInputToParent(true)

		button:SetStyleTranslation("button_active", "tab_active")
		button:SetStyleTranslation("button_inactive", "tab_inactive")
		button:SetStyle("tab_inactive")
		
		button:SetSize(Vec2(22,14)*scale)
		button:SetHeight(button:GetHeight() - scale)
		
		button:SetFont("snow_font")
		button:SetTextColor(ColorBytes(168,168,224))
		button:SetText(name)
		button:SetMargin(Rect()+4*scale)
		button:SizeToText()
		button:CenterText()

		button.text = name
		
		button.OnMouseInput = function(button, key, press)
			if press and key == "button_1" then
				button:SetTextColor(ColorBytes(160,160,0))
				button:SetText(button.text)
				button:CenterText()
				button:SetState(true)
				
				self.content = self.tabs[name].content
				self.content:SetVisible(true)
				
				for i, panel in ipairs(self.tab_bar:GetChildren()) do
					if button ~= panel then
						panel:SetTextColor(ColorBytes(168,168,224))
						panel:SetText(panel.text)
						panel:CenterText()
						panel:SetState(false)
						self.tabs[panel.text].content:SetVisible(false)
					end
				end
				
				self:Layout()
			end
		end
		
		local content = gui2.CreatePanel("base", self)
		content:SetStyle("frame")
		content:SetSendMouseInputToParent(true)
		content:SetVisible(false)
		self.content = content
		
		self:Layout(true)
		
		self.tabs[name] = {button = button, content = content}
		
		return content
	end
	
	function PANEL:OnLayout()
		self.tab_bar:SetWidth(self:GetWidth())
		self.tab_bar:SetHeight(12*scale)

		if self.content then
			self.content:SetPosition(Vec2(0, self.tab_bar:GetHeight()))
			self.content:SetHeight(self:GetHeight() - self.tab_bar:GetHeight())
			self.content:SetWidth(self:GetWidth())
		end
	end
	
	gui2.RegisterPanel(PANEL)
end

do
	do -- tree node
		local PANEL = {}

		PANEL.ClassName = "tree_node"
		
		prototype.GetSet(PANEL, "Expand", true)

		function PANEL:Initialize()	
			self:SetSendMouseInputToParent(true)
			self:SetColor(Color(1,1,1,0))

			local label = gui2.CreatePanel("text_button", self)
			label:SetTextColor(ColorBytes(200, 200, 200))
			label:SetFont("snow_font")
			label:SetMargin(Rect()+2*scale)
			label:SetColor(Color(0,0,0,0))
			label:SetStyleTranslation("button_active", "button_rounded_active")
			label:SetStyleTranslation("button_inactive", "button_rounded_inactive")
			label:SetStyle("button_rounded_inactive")
			label.OnMouseEnter = function()
				label:Animate("Color", {Color(1,1,1,1), function() return self:IsMouseOver() end, "from"}, duration, "", pow)
			end
			label.OnStateChanged = function()
				self.label:SetColor(Color(1,1,1,1))
				for k, v in ipairs(self.tree:GetChildren()) do
					if v ~= self then
						v.label:SetColor(Color(1,1,1,0))
					end
				end
			end
			self.label = label

			local exp = gui2.CreatePanel("text_button", self)
			exp:SetFont("snow_font")
			exp:SetTextColor(ColorBytes(200, 200, 200))
			exp:SetMargin(Rect()+scale)
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
			self.label:OnMouseEnter(...)
		end
		
		function PANEL:OnMouseExit(...)
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
			self.image:SetPosition(Vec2(x + scale*2, 0))
			
			self.expand:SetSize(Vec2()+scale*6)
			self.expand:SetPosition(Vec2(x - self.image:GetWidth(), 0))
			self.expand:CenterText()
			
			self.label:SetPosition(self.image:GetPosition() + Vec2(self.image:GetWidth() + scale*2, 0))
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
			
			for pos, pnl in pairs(self.tree.CustomList) do
				if pnl.node_parent == self then
					pnl:SetExpandInternal(b)
				end
			end
			
			self.Parent:Layout()
		end
		
		function PANEL:SetExpand(b)
			
			for pos, pnl in pairs(self.tree.CustomList) do
				if pnl.node_parent == self then
					pnl:SetExpandInternal(b)
				end
			end
			
			self.Expand = b
			
			self.expand:SetText(b and "-" or "+")
		end
					
		gui2.RegisterPanel(PANEL)
	end

	do
		local PANEL = {}

		PANEL.ClassName = "tree"
		prototype.GetSet(PANEL, "IndentWidth", 16)

		function PANEL:Initialize()
			self:SetClipping(true)
			self:SetSendMouseInputToParent(true)
			self:SetStack(true)
			self:SetForcedStackSize(Vec2(0, 10*scale))
			
			self:SetStackRight(false)
			self:SetSizeStackToWidth(true)
			self:SetScrollable(true)
						
			self.CustomList = {}
			
			self:SetColor(Color(1,1,1,0))
		end

		function PANEL:AddNode(str, id)
			if id and self.nodes[id] and self.nodes[id]:IsValid() then self.nodes[id]:Remove() end
			
			local pnl = gui2.CreatePanel("tree_node", self)
			pnl:SetText(str) 
			pnl.offset = self.IndentWidth
			pnl.tree = self
						
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

		gui2.RegisterPanel(PANEL)		
	end
end

local frame = gui2.CreatePanel("frame")
frame:SetPosition(Vec2()+200)
frame:SetSize(Vec2()+200)

local tab = gui2.CreatePanel("tab", frame)
tab:Dock("fill")

do
	local content = tab:AddTab("tree")
	
	local icons =
	{
		text = "silkicons/text_align_center.png",
		bone = "silkicons/wrench.png",
		clip = "silkicons/cut.png",
		light = "silkicons/lightbulb.png",
		sprite = "silkicons/layers.png",
		bone = "silkicons/connect.png",
		effect = "silkicons/wand.png",
		model = "silkicons/shape_square.png",
		animation = "silkicons/eye.png",
		entity = "silkicons/brick.png",
		group = "silkicons/world.png",
		trail = "silkicons/arrow_undo.png",
		event = "silkicons/clock.png",
		sunbeams = "silkicons/weather_sun.png",
		jiggle = "silkicons/chart_line.png",
		sound = "silkicons/sound.png",
		command = "silkicons/application_xp_terminal.png",
		material = "silkicons/paintcan.png",
		proxy = "silkicons/calculator.png",
		particles = "silkicons/water.png",
		woohoo = "silkicons/webcam_delete.png",
		halo = "silkicons/shading.png",
		poseparameter = "silkicons/vector.png",
	}

	local tree = gui2.CreatePanel("tree", content)	
	tree:Dock("fill")
	  
	local data = serializer.ReadFile("luadata", R"data/tree.txt") or {}
	local done = {}
	 
	local function fill(tbl, node)		
		for key, val in pairs(tbl) do
			local node = node:AddNode(val.self.Name)
			node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
			fill(val.children, node)
		end  
	end 
	
	fill(data, tree)
end

do
	local content = tab:AddTab("huh")
end
	 
	   
local padding = 5 * scale

local bar = gui2.CreatePanel("base") 
bar:SetTexture(skin.gradient)
bar:SetColor(ColorBytes(0,72,248))
bar:SetDraggable(true)

local function create_button(text, options)
	local button = gui2.CreatePanel("text_button", bar)
	button:SetClipping(true) 
	button:SetFont("snow_font")  
	button:SetTextColor(ColorBytes(200, 200, 200))
	button:SetText(text)
	button:SetMargin(Rect()+2.5*scale)
	button:SizeToText()
	button:SetMode("toggle")
	 
	button.OnRelease = function()		
		local menu = gui2.CreatePanel("menu")
		gui2.SetActiveMenu(menu)
		
		local function add_entry(menu, val)
			for k, v in ipairs(val) do
				if type(v[2]) == "table" then
					add_entry(menu:AddSubMenu(v[1]), v[2])
				elseif v[1] then
					menu:AddEntry(v[1], v[2])
				else
					menu:AddSeparator()
				end
			end
		end
		
		add_entry(menu, options)			
		
		menu:Layout(true)
		
		menu:SetPosition(button:GetWorldPosition() + Vec2(0, button:GetHeight() + 2*scale), options)
		menu:Animate("DrawPositionOffset", {Vec2(0,-menu.Size.h/2), Vec2(0, 0)}, 0.1, "+", nil, true)

		menu:CallOnRemove(function() button:SetState(false) end)
	end
end

create_button("↓", {
	{"1."},
	{"2."},
	{"3."},
	{"4."},
	{"5."},
	{"6."},
	{"7."},
	{"8."},
	{"9."},
	{"0."},
	{},
	{"freeze data: off"},
	{"clear all data"},
}) 
create_button("game", {
	{"load", function() 
		local frame = gui2.CreatePanel("frame") 

		frame:SetPosition(Vec2(100, 100))
		frame:SetSize(Vec2(300, 300))
		frame:SetTitle("file browser")
		
		local panel = gui2.CreatePanel("list", frame)
		panel:Dock("fill") 
		for k,v in pairs(vfs.Find("/")) do
			panel:AddEntry(v)
		end
	end},
	{"run  [ESC]", function() debug.trace() end},
	{"reset", {
		{"video"},
		{"sound"},
		{"paths"},
		{"huh", {
			{"misc keys"},
			{"gui opts"},
			{"key comb."},
			{"save cfg"},
			{},
			{"about"},
		}},
		{"saves"},
		{"speed"},
	}},
	{},
	{"save state"},
	{"open state"},
	{"pick state"},
	{},
	{"quit", function() os.exit() end} 
})
create_button("config", {
	{"input"},
	{},
	{"devices"},
	{"chip cfg"},
	{},
	{"options"},
	{"video"},
	{"sound"},
	{"paths"},
	{"saves"},
	{"speed"},
})
create_button("cheat", {
	{"add code"},
	{"browse"},
	{"search"},
})
create_button("netplay", {
	{"internet"},
})
create_button("misc", {
	{"misc keys"},
	{"gui opts"},
	{"key comb."},
	{"save cfg"},
	{},
	{"about"},
})

bar:SetStack(true)
bar:SetSize(Vec2(1000,1000))
bar:SetPadding(Rect(1,1,5*scale,3*scale))
bar:SetSize(bar:StackChildren())

local emitter = ParticleEmitter(800)
emitter:SetPos(Vec3(50,50,0)) 
--emitter:SetMoveResolution(0.25) 
emitter:SetAdditive(false)

local fb
local DX = false

if DX then
	fb = render.CreateFrameBuffer(128, 128)
end

event.AddListener("Draw2D", "zsnow", function(dt)
	if DX then
		fb:Begin()
			surface.SetColor(0,0,0,0.01)
			surface.DrawRect(0,0,128,128)
			
			surface.PushMatrix()
							
				for i = -4, 4 do
					i = (i / 4) * math.pi
					
					surface.PushMatrix(math.sin(i)/2, math.cos(i)/2)
						render.Translate(-0.4, -0.4, 0)
						surface.SetColor(1,1,1,1)
						surface.SetTexture(fb:GetTexture())
						surface.DrawRect(0,0,128,128)
					surface.PopMatrix()
				end
			surface.PopMatrix()
			
			render.SetBlendMode("additive")
			emitter:Update(dt)
			emitter:Draw()
			render.SetBlendMode("alpha")
		fb:End()
	else
		emitter:Update(dt)
	end
		
	surface.SetWhiteTexture()
	surface.SetColor(DX and Color(0,0,0,1) or bg)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	
	--surface.SetColor(1,1,1,1)
	--emitter:Draw()
	
	--surface.SetColor(0,0,0,0.25)
	--surface.DrawRect(5*scale,5*scale, x, 16 * scale)
	
	
	surface.SetFont("snow_font")
	surface.SetTextPos(50, 50)
	surface.DrawText("ANIMATION 2")
	local w,h = surface.GetTextSize("ANIMATION 2")
	surface.DrawRect(50,50,w,h)
	
	if DX then
		render.SetBlendMode("additive")
		surface.SetColor(1,1,1,1)
		surface.SetTexture(fb:GetTexture())
		surface.DrawRect(0,0,render.GetWidth(), render.GetHeight())
		render.SetBlendMode("alpha")
	else
		emitter:Draw()
	end
end, {priority = math.huge}) 

event.CreateTimer("zsnow", 0.01, function()
	emitter:SetPos(Vec3(math.random((DX and 256 or render.GetWidth()) + 100) - 150, -50, 0))
		
	local p = emitter:AddParticle()
	p:SetDrag(1)

	--p:SetStartLength(Vec2(0))
	--p:SetEndLength(Vec2(30, 0))
	p:SetAngle(math.random(360)) 
	 
	p:SetVelocity(Vec3(math.random(100),math.random(40, 80)*2,0) * (DX and 0.25 or 1))

	p:SetLifeTime(20)

	p:SetStartSize(2 * (1 + math.random() ^ 50))
	p:SetEndSize(2 * (1 + math.random() ^ 50))
	
	if DX then
		p:SetColor(HSVToColor(os.clock()/30,0.75, 1))
	else
		p:SetColor(Color(1,1,1, math.randomf(0.5, 0.8)))
	end
end) 