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
	prototype.GetSet(PANEL, "TextWrap", false)
	
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
		markup:SetLineWrap(self.TextWrap)
		
		markup:Clear()
		markup:AddFont(self.Font)
		markup:AddColor(self.TextColor)
		markup:AddString(self.Text, self.ParseTags)
		
		self:OnDraw() -- hack! this will update markup sizes
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
	prototype.GetSet(PANEL, "Highlight", false)

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
		self:Animate("DrawColor", {Color(1,1,1,1)*0.3, function() return self.Highlight or self:IsMouseOver() end, "from"}, duration, "", 0.25)
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
	prototype.GetSetDelegate(PANEL, "TextWrap", false, "label")
	
	prototype.Delegate(PANEL, "label", "CenterText", "Center")
	prototype.Delegate(PANEL, "label", "CenterTextY", "CenterY")
	prototype.Delegate(PANEL, "label", "CenterTextX", "CenterX")
	prototype.Delegate(PANEL, "label", "GetTextSize", "GetSize")
	
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
		self:SetCachedRendering(true)
		
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
	
	function PANEL:OnMouseInput()
		self:MarkCacheDirty()
	end
	
	gui2.RegisterPanel(PANEL)   
end
	
do 
	local PANEL = {}
	
	PANEL.ClassName = "list"
	
	PANEL.columns = {}
	PANEL.last_div = NULL
	PANEL.list = NULL
	
	function PANEL:Initialize()	
		self:SetColor(Color(0,0,0,0))
		
		local top = gui2.CreatePanel("base", self)
		top:SetLayoutParentOnLayout(true)
		top:SetMargin(Rect())
		top:SetClipping(true)
		self.top = top
					
		local list = gui2.CreatePanel("base", self)
		list:SetColor(Color(0,0,0,1))
		--list:SetCachedRendering(true)
		list:SetClipping(true)
		self.list = list
		
		local scroll = gui2.CreatePanel("scroll", self)
		scroll:SetXScrollBar(false)
		scroll:SetPanel(list)
		self.scroll = scroll
		
		self:SetupSorted("")
	end
	
	function PANEL:OnLayout()
		self.top:SetWidth(self:GetWidth())
		self.top:SetHeight(20)
		self.scroll:SetPosition(Vec2(0, 20))
		self.scroll:SetWidth(self:GetWidth())
		self.scroll:SetHeight(self:GetHeight() - 20)
		local y = 0
		for _, entry in ipairs(self.entries) do
			entry:SetPosition(Vec2(0, y))
			entry:SetWidth(self:GetWidth())
			y = y + entry:GetHeight() - scale
			
			
			local x = 0
			for i, label in ipairs(entry.labels) do
				local w = self.columns[i].div.left:GetWidth()
				label:SetWidth(w)
				label:SetX(x)
				label:SetHeight(entry:GetHeight())
				label:CenterTextY()
				
				w = w + self.columns[i].div:GetDividerWidth()
				
				if self.columns[i].div.left then
					x = x + w
				end
			end
		end
		
		self.list:SetHeight(y)
		
--		self:SizeColumnsToFit()

		if #self.columns > 0 then
			self.columns[#self.columns].div:SetDividerPosition(self:GetWidth())
		end
	end
	
	function PANEL:SizeColumnsToFit()
		for i, column in ipairs(self.columns) do			
			column.div:SetDividerPosition(column:GetTextSize().w + column.icon:GetWidth() * 2)
		end
	end
	
	function PANEL:SetupSorted(...)
		self.list:RemoveChildren()
		self.top:RemoveChildren()				
		
		self.columns = {}
		self.entries = {}
		
		for i = 1, select("#", ...) do
			local v = select(i, ...)
			local name, func
			
			if type(v) == "table" then
				 name, func = next(v)
			elseif type(v) == "string" then
				name = v
				func = table.sort
			end
						
			local column = gui2.CreatePanel("text_button")
			column:SetMargin(Rect()+2*scale)
			column:SetFont("snow_font")
			column:SetTextColor(ColorBytes(200,200,200)) 
			column:SetText(name)
			column:SetClipping(true)
			column:SizeToText()
			
			local icon = gui2.CreatePanel("text", column)
			icon:SetFont("snow_font") 
			icon:SetTextColor(ColorBytes(200,200,200)) 
			icon:SetText("▼")
			icon:Dock("right")
			column.icon = icon
						
			local div = gui2.CreatePanel("horizontal_divider", self.top)
			div:SetColor(Color(0,0,0,1))
			div:Dock("fill")
			div:SetLeft(column)
			div:SetLayoutParentOnLayout(true)
			column.div = div
			
			self.columns[i] = column
			
			column.OnPress = function()
				
				if column.sorted then
					icon:SetText("▼")
					table.sort(self.entries, function(a, b)
						return a.labels[i].text < b.labels[i].text
					end)
				else
					icon:SetText("▲")
					table.sort(self.entries, function(a, b)
						return a.labels[i].text > b.labels[i].text
					end)
				end
				
				self:Layout()
				
				column.sorted = not column.sorted
			end
			
			column.OnLayout = function()
				column:SetSize(Vec2(column:GetWidth(), 20))
				column:CenterTextY()
			end
			
			if self.last_div:IsValid() then 
				self.last_div:SetRight(div)
			end
			self.last_div = div
		end
	end
	
	function PANEL:AddEntry(...)						
		local entry = gui2.CreatePanel("button", self.list) 
		
		entry.labels = {}
					
		for i = 1, select("#", ...) do
			local text = tostring(select(i, ...) or "nil")
			
			local label = gui2.CreatePanel("text_button", entry)
			label:SetFont("snow_font_green")
			label:SetTextColor(Color(0,1,0))
			label:SetTextWrap(false)
			label:SetText(text)
			label:SizeToText()
			label.text = text
			label:SetClipping(true)
			label:SetColor(Color(0,0,0,0))
			label:SetIgnoreMouse(true)
			
			entry.labels[i] = label
		end

		local last_child = self.list:GetChildren()[#self.list:GetChildren()]
		
		entry:SetSendMouseInputToParent(true)
		entry:SetPosition(Vec2(0, last_child:GetPosition().y + last_child:GetHeight() - 2*scale))
		entry:SetColor(Color(0,0,0,0))
		entry:SetStyleTranslation("button_active", "menu_select")
		entry:SetStyleTranslation("button_inactive", "menu_select")
		entry:SetStyle("menu_select")
		entry:SetHeight(entry.labels[1]:GetHeight() + 2*scale)

		entry.OnPress = function()
			for k, other_entry in ipairs(self.entries) do
				if other_entry ~= entry then
					other_entry:SetColor(Color(0,0,0,0))
				else
					entry:SetStyle("menu_select")
					entry:SetColor(Color(1,1,1,1))
				end
			end
		end
		
		entry.i = #self.entries + 1
		
		table.insert(self.entries, entry)
	end
	
	gui2.RegisterPanel(PANEL)
end
	
do	
	local scroll_width = scale*8 

	local PANEL = {}
	PANEL.ClassName = "scroll"
	
	PANEL.panel = NULL
	
	prototype.GetSet(PANEL, "XScrollBar", true)
	prototype.GetSet(PANEL, "YScrollBar", true)
	
	function PANEL:Initialize()
		self:SetColor(Color(0,0,0,0))
	end
	
	function PANEL:SetPanel(panel)
		panel:SetParent(self)
		
		self.panel = panel
		
		if self.YScrollBar then
			local y_scroll = gui2.CreatePanel("base", self)
			y_scroll:SetTexture(skin.gradient2)

			local up = gui2.CreatePanel("text_button", y_scroll)				
			local down = gui2.CreatePanel("text_button", y_scroll)

			local y_scroll_bar = gui2.CreatePanel("button", y_scroll)
			y_scroll_bar:SetDraggable(true)	
					
			y_scroll_bar.OnPositionChanged = function(_, pos)
				if not panel:IsValid() then return end
				
				if panel.scrolling then return end
				
				local frac = math.clamp((pos.y - scroll_width) / (panel:GetSizeOfChildren().h - scroll_width), 0, 1)
				
				panel:SetScrollFraction(Vec2(panel:GetScrollFraction().x, frac))
		 
				pos.x = y_scroll_bar.Parent:GetWidth() - y_scroll_bar:GetWidth()
				pos.y = math.clamp(pos.y, scroll_width, y_scroll_bar.Parent:GetHeight() - y_scroll_bar:GetHeight() - scroll_width)
			end
			
			up.OnPress = function(_, button, press)
				if not panel:IsValid() then return end

				if #panel:GetChildren() == 0 then return end
				
				local h = panel:GetChildren()[1]:GetHeight()
				
				local pos = panel:GetScroll()
				pos.y = pos.y - h
				panel:SetScroll(pos)
			end
			
			down.OnPress = function(_, button, press)
				if not panel:IsValid() then return end
				
				if #panel:GetChildren() == 0 then return end
				
				local h = panel:GetChildren()[1]:GetHeight()
				
				local pos = panel:GetScroll()
				pos.y = pos.y + h
				panel:SetScroll(pos)
			end
			
			self.down = down
			self.up = up
			self.y_scroll_bar = y_scroll_bar 
			self.y_scroll = y_scroll
		end
		
		if self.XScrollBar then
			local x_scroll = gui2.CreatePanel("base", self)
			x_scroll:SetTexture(skin.gradient3)

			local left = gui2.CreatePanel("text_button", x_scroll)				
			local right = gui2.CreatePanel("text_button", x_scroll)

			local x_scroll_bar = gui2.CreatePanel("button", x_scroll)
			x_scroll_bar:SetDraggable(true)
			
			x_scroll_bar.OnPositionChanged = function(_, pos)
				if not panel:IsValid() then return end
				
				if panel.scrolling then return end
				local frac = math.clamp((pos.x - scroll_width) / (panel:GetSizeOfChildren().w - scroll_width), 0, 1)
				
				panel:SetScrollFraction(Vec2(frac, panel:GetScrollFraction().y))
		 
				pos.x = math.clamp(pos.x, scroll_width, x_scroll:GetWidth() - x_scroll_bar:GetWidth() - scroll_width)
				pos.y = x_scroll_bar.Parent:GetHeight() - x_scroll_bar:GetHeight()
			end
					
			left.OnPress = function(_, button, press)
				if not panel:IsValid() then return end
				
				if #panel:GetChildren() == 0 then return end
				
				local w = panel:GetChildren()[1]:GetWidth()
				
				local pos = panel:GetScroll()
				pos.x = pos.x - w
				panel:SetScroll(pos)
			end
			
			right.OnPress = function(_, button, press)
				if not panel:IsValid() then return end
				
				if #panel:GetChildren() == 0 then return end
				
				local w = panel:GetChildren()[1]:GetWidth()
				
				local pos = panel:GetScroll()
				pos.x = pos.x + w
				panel:SetScroll(pos)
			end
			
			self.right = right
			self.left = left
			self.x_scroll_bar = x_scroll_bar
			self.x_scroll = x_scroll
		end
				
		panel.OnScroll = function(_, frac)
			panel.scrolling = true
			if self.YScrollBar then
				self.y_scroll_bar:SetPosition(Vec2(0, math.clamp(scroll_width + frac.y * (self.y_scroll:GetHeight() - scroll_width*2), 0, self:GetHeight()-self.y_scroll_bar:GetHeight()-scroll_width*2)))
			end
			if self.XScrollBar then
				self.x_scroll_bar:SetPosition(Vec2(math.clamp(scroll_width + frac.x * (self.x_scroll:GetWidth() - scroll_width*2), 0, self:GetWidth()-self.x_scroll_bar:GetWidth()-scroll_width*2), 0))
			end
			panel.scrolling = false
		end
	end
	
	function PANEL:OnLayout()
		local panel = self.panel
		
		if not panel:IsValid() then return end
		
		panel:SetSize(panel:GetSizeOfChildren())
		
		if self.YScrollBar then
			self.y_scroll:SetSize(Vec2(scroll_width, self:GetHeight() - scroll_width))
			self.y_scroll:SetPosition(Vec2(self:GetWidth() - scroll_width, 0))
			
			self.down:SetSize(Vec2(scroll_width, scroll_width))
			self.down:SetPosition(Vec2(0, self:GetHeight() - self.down:GetHeight() - scroll_width))
			
			self.y_scroll_bar:SetSize(Vec2(scroll_width, math.max(-(panel:GetSizeOfChildren().h - self.y_scroll:GetHeight()) + self.y_scroll:GetHeight() - scroll_width, scroll_width)))
			
			self.up:SetSize(Vec2(scroll_width, scroll_width))
				
			if panel:GetHeight() > panel:GetSizeOfChildren().h then
				self.y_scroll:SetVisible(false)
			else
				self.y_scroll:SetVisible(true)
			end
		end
		
		if self.XScrollBar then
			self.x_scroll:SetSize(Vec2(self:GetWidth() - scroll_width, scroll_width))
			self.x_scroll:SetPosition(Vec2(0, self:GetHeight() - scroll_width))
			
			self.right:SetSize(Vec2(scroll_width, scroll_width))
			self.right:SetPosition(Vec2(self:GetWidth() - self.right:GetWidth() - scroll_width, 0))
			
			self.x_scroll_bar:SetSize(Vec2(math.max(-(panel:GetSizeOfChildren().w - self.x_scroll:GetWidth()) + self.x_scroll:GetWidth() - scroll_width, scroll_width), scroll_width))
			
			self.left:SetSize(Vec2(scroll_width, scroll_width))
				
			if panel:GetWidth() > panel:GetSizeOfChildren().w then
				self.x_scroll:SetVisible(false)
			else
				self.x_scroll:SetVisible(true)
			end
		end		
	
		if self.YScrollBar and self.y_scroll:IsVisible() then
			panel:SetWidth(self:GetWidth() - scroll_width)
		else
			panel:SetWidth(self:GetWidth())
		end
	
		if self.XScrollBar and self.x_scroll:IsVisible() then
			panel:SetHeight(self:GetHeight() - scroll_width)
		else
			panel:SetHeight(self:GetHeight())
		end
		
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
			local y = scale*2
			
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
				self.menu:Animate("DrawScaleOffset", {Vec2(0,1), Vec2(1,1)}, 0.25, "*", 0.25, true)
			end
		end
		
		function PANEL:OnMouseExit()
			self:SetColor(Color(1,1,1,0))
		end
		
		function PANEL:SetText(str)
			self.label:SetText(str)
			self:SetHeight(self.label:GetSize().h + 4*scale)
			self.label:SetPosition(Vec2(2*scale,0))
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
		content:SetColor(Color(0,0,0,0))
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
			label:SetColor(Color(1,1,1,-0.001))
			label:SetStyleTranslation("button_active", "button_rounded_active")
			label:SetStyleTranslation("button_inactive", "button_rounded_inactive")
			label:SetStyle("button_rounded_inactive")
			label:SetSendMouseInputToParent(true)
			label.OnPress = function()
				self.label:SetColor(Color(1,1,1,1))
				for k, v in ipairs(self.tree:GetChildren()) do
					if v ~= self then
						v.label:SetColor(Color(1,1,1,-0.001))
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
			self.label:SetHighlight(true)
			self.label:OnMouseEnter(...)
		end
		
		function PANEL:OnMouseExit(...)
			self.label:SetHighlight(false)
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
			self:SetColor(Color(1,1,1,0))
			self:SetClipping(true)
			self:SetSendMouseInputToParent(true)
			self:SetStack(true)
			self:SetForcedStackSize(Vec2(0, 10*scale))
			
			self:SetStackRight(false)
			self:SetSizeStackToWidth(true)
			self:SetScrollable(true)

			self.CustomList = {}
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

do 
	local PANEL = {}
	
	PANEL.ClassName = "horizontal_divider"
	
	prototype.GetSet(PANEL, "DividerHeight", 0)
	prototype.GetSet(PANEL, "DividerWidth", scale*4)
	
	function PANEL:Initialize()
		self:SetColor(Color(0,0,0,0))
		local divider = gui2.CreatePanel("button", self)
		divider:SetX(self:GetWidth() - self.DividerWidth/2)
		divider:SetCursor("sizewe")
		divider:SetDraggable(true)
		divider.OnPositionChanged = function(_, pos)
			pos.x = math.clamp(pos.x, 0, self:GetWidth() - self.DividerWidth)
			pos.y = 0
			self:Layout()
		end
		self.divider = divider
	end
	
	function PANEL:OnLayout()
		self.divider:SetSize(Vec2(self.DividerWidth, self.DividerHeight == 0 and self:GetHeight() or self.DividerHeight))
		
		if self.left then
			self.left:SetPosition(Vec2(0, 0))
			self.left:SetSize(Vec2(self.divider:GetPosition().x, self:GetHeight()))
		end
		
		if self.right then
			self.right:SetPosition(Vec2(self.divider:GetPosition().x + self.DividerWidth, 0))
			self.right:SetSize(Vec2(self:GetWidth() - self.divider:GetPosition().x - self.DividerWidth,  self:GetHeight()))
		end
	end
	
	function PANEL:SetLeft(pnl)
		pnl:SetParent(self)
		self.left = pnl
		self:Layout()
		return pnl
	end
	
	function PANEL:SetRight(pnl)
		pnl:SetParent(self)
		self.right = pnl
		self:Layout()
		return pnl
	end
	
	function PANEL:SetDividerPosition(num)
		self.divider:SetPosition(Vec2(num, 0))
	end
	
	function PANEL:GetDividerPosition()
		return self.divider:GetPosition().x
	end
	
	gui2.RegisterPanel(PANEL)
end

do -- testing

	local frame = gui2.CreatePanel("frame")
	frame:SetPosition(Vec2()+200)
	frame:SetSize(Vec2()+500)

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

		local scroll = gui2.CreatePanel("scroll", content)
		local tree = gui2.CreatePanel("tree")
		scroll:SetPanel(tree)
		scroll:Dock("fill")
		
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
		local content = tab:AddTab("list")
		local list = gui2.CreatePanel("list", content)
		list:SetupSorted("name", "date modified", "type", "size")
		list:Dock("fill")
		
		for k,v in pairs(vfs.Find("lua/")) do
			local file = vfs.Open("lua/"..v)
			
			list:AddEntry(v, os.date("%m/%d/%Y %H:%M", vfs.GetLastModified("lua/"..v) or 0), vfs.IsFile("lua/"..v) and "file" or "folder", file and utility.FormatFileSize(file:GetSize()) or "0")
		end
	end

	do
		local content = tab:AddTab("dividers")
		local div = gui2.CreatePanel("horizontal_divider", content)
		div:Dock("fill")
		div:SetDividerPosition(400)

		local huh = div:SetLeft(gui2.CreatePanel("button"))
		
		local div = div:SetRight(gui2.CreatePanel("horizontal_divider"))
	end
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
		menu:Animate("DrawScaleOffset", {Vec2(1,0), Vec2(1,1)}, 0.25, "*", 0.25, true)


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
	
	
	--surface.SetFont("snow_font")
	--surface.SetTextPos(50, 50)
	--surface.DrawText("ANIMATION 2")
	--local w,h = surface.GetTextSize("ANIMATION 2")
	--surface.DrawRect(50,50,w,h)
	
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

menu.Close()
window.SetMouseTrapped(false) 

