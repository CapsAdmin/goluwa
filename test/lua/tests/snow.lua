gui2 = include("gui2/gui2.lua") 
 
local scale = 2
local ninepatch_size = 32
local ninepatch_corner_size = 4
local bg = Color(64, 44, 128, 200) 


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
		
		if x >= ninepatch_size-2 or y >= ninepatch_size-2 then
			return 72, 68, 64, 255
		elseif x <= 2 or y <= 2 then
			return 104, 100, 96, 255
		end
		
		return 88, 92, 88, 255
	end),

	button_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-2 or y >= ninepatch_size-2 then
			return 104, 100, 96, 255
		end
		
		return 72, 68, 64, 255
	end),

	button_rounded = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y)
		y = -y + ninepatch_size
		
		if 
			(x >= ninepatch_size-2 and y >= ninepatch_size-2) or 
			(x <= 2 and y <= 2) or
			(x >= ninepatch_size-2 and y <= 2) or
			(x <= 2 and y >= ninepatch_size-2)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-2 or y >= ninepatch_size-2 then
			return 160, 120, 120, 255
		elseif x <= 2 or y <= 2 then
			return 192, 144, 144, 255
		end
		
		return 176, 132, 128, 255
	end),
	
	tab_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if 
			(x <= 2 and y <= 2) or
			(x >= ninepatch_size-2 and y <= 2)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-2 then
			return 184, 48, 48, 255
		elseif x <= 2 or y <= 2 then
			return 184, 48, 48, 255
		end
		
		return 168, 32, 32, 255
	end),
	
	tab_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if 
			(x <= 2 and y <= 2) or
			(x >= ninepatch_size-2 and y <= 2)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-2 then
			return 136, 0, 0, 255
		elseif x >= ninepatch_size-2 or y >= ninepatch_size-2 then
			return 168, 32, 32, 255
		end
		
		return 152, 16, 16, 255
	end),

	menu_select = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-2 or y >= ninepatch_size-2 or x <= 2 or y <= 2 then
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
		
		if x >= ninepatch_size-2 or y >= ninepatch_size-2 then
			return 152, 16, 16, 255
		elseif x <= 2 or y <= 2 then
			return 184, 48, 48, 255
		end

		return 168, 32, 32, 255
	end),
} 

do
	local META = {}
	META.ClassName = "frame"
	
	function META:Initialize()	
		self:SetDraggable(true)
		self:SetResizable(true) 
		self:SetMargin(Rect(0,10*scale,0,0))  
		self:SetupNinepatch(skin.frame, ninepatch_size, ninepatch_corner_size)
				
			local bar = gui2.CreatePanel("base", self)
			bar:SetObeyMargin(false)
			bar:Dock("fill_top") 
			bar:SetSendMouseInputToParent(true)
			bar:SetHeight(10*scale)
			bar:SetTexture(skin.gradient)
			bar:SetColor(Color(120, 120, 160))
			bar:SetClipping(true)
								
				local close = gui2.CreatePanel("base", bar) 			
				close:SetParseTags(true)  
				close:SetText("<font=snow_font_noshadow><color=50,50,50>X")
				close:SetSize(close:GetTextSize()+Vec2(3,3)*scale)
				close:CenterText()
				
				close:Dock("top_right")
				
				close:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
				
				close.OnMouseInput = function(_, button, press) 
					if button == "button_1" and not press then
						self:Remove()
					end
				end
		
		self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
		
		self.frame = self
		self.bar = bar
		
		self:SetTitle("no title")
	end
	
	function META:SetTitle(str)
		gui2.RemovePanel(self.title)
		local title = gui2.CreatePanel("base", self.bar)
		title:SetHeight(self.bar:GetHeight())
		title:SetParseTags(true)  
		title:SetText("<font=snow_font><color=200,200,200>"..str)
		title:CenterTextY()
		title:SetPosition(Vec2(2*scale,0))
		title:SetColor(Color(0,0,0,0))
		self.title = title
	end
	
	gui2.RegisterPanel(META)   
end 
	
do	
	local scroll_width = scale*8 

	local META = {}
	META.ClassName = "list"
	
	META.entries = {}
	
	function META:Initialize()		
		local list = gui2.CreatePanel("base", self)
		list:SetColor(Color(0,0,0,1))
		list:SetClipping(true)
		list:SetScrollable(true)
		
		do
			local y_scroll = gui2.CreatePanel("base", self)
			y_scroll:SetTexture(skin.gradient2)

			local up = gui2.CreatePanel("base", y_scroll)				
			up:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)

			local y_scroll_bar = gui2.CreatePanel("base", y_scroll)
			y_scroll_bar:SetDraggable(true)	
			y_scroll_bar:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)

			local down = gui2.CreatePanel("base", y_scroll)
			down:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
					
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
			left:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)

			local x_scroll_bar = gui2.CreatePanel("base", x_scroll)
			x_scroll_bar:SetDraggable(true)	
			x_scroll_bar:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)

			local right = gui2.CreatePanel("base", x_scroll)
			right:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
					
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
	
	function META:OnLayout()
		local w = 0		
		local y = 0
		
		for k, v in pairs(self.entries) do
			v:SetPosition(Vec2(0, y))
			y = y + v:GetHeight() - scale
			w = math.max(w, v:GetTextSize().w)
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
	
	function META:AddEntry(name, on_click)		
		local button = gui2.CreatePanel("base", self.list)
		button:SetSendMouseInputToParent(true)
		button:SetParseTags(true)
		button:SetWrapText(false)
		button:SetText("<font=snow_font_green><color=0,255,0>" .. name)
		button:SetSize(button:GetTextSize() + Vec2(4,4) * scale)
		button:CenterTextY()
		
		local last_child = self:GetChildren()[#self:GetChildren()]
		button:SetPosition(Vec2(0, last_child:GetPosition().y + last_child:GetHeight() - 2*scale))
			
		button:SetColor(Color(0,0,0,0))
		button:SetupNinepatch(skin.menu_select, ninepatch_size, ninepatch_corner_size)

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
	
	gui2.RegisterPanel(META)  
end
 
do
	do
		local META = {}
		META.ClassName = "menu"
		META.sub_menu = NULL
		
		function META:Initialize()
			self:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)
		end
		
		function META:AddEntry(text, on_click)
			local entry = gui2.CreatePanel("menu_entry", self)
			
			entry:SetText(text)
			entry.OnClick = on_click
			
			return entry
		end
		
		function META:AddSubMenu(text, on_click)
			local menu = self:AddEntry(text, on_click):CreateSubMenu()
			
			self:CallOnRemove(function() gui2.RemovePanel(menu) end)
			self:CallOnHide(function() menu:SetVisible(false) end)
			
			return menu  
		end
		
		function META:AddSeparator()
			local panel = gui2.CreatePanel("base", self)
			panel:SetupNinepatch(skin.button_active, ninepatch_size, ninepatch_corner_size)
			panel:SetHeight(2*scale)
			panel:SetIgnoreMouse(true)
		end
		
		function META:OnLayout()
			local w = 0
			local y = scale
			
			for k, v in ipairs(self:GetChildren()) do
				v:SetPosition(Vec2(2*scale, y))
				w = math.max(w, v:GetTextSize().w)
				y = y + v:GetSize().h + scale
			end
			
			for k, v in ipairs(self:GetChildren()) do
				v:SetWidth(w + 4*scale)
			end
			
			self:SetSize(Vec2(w + 8*scale, y + scale))
		end
		
		gui2.RegisterPanel(META)
	end

	do
		local META = {}
		
		META.ClassName = "menu_entry"
		META.menu = NULL
		
		function META:Initialize()
			self:SetParseTags(true) 			
			self:SetColor(Color(0,0,0,0))			
			self:SetupNinepatch(skin.menu_select, ninepatch_size, ninepatch_corner_size)
			self:SetPadding(Rect(scale, scale, scale, scale))
		end
		
		function META:OnMouseEnter()
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
			end
		end
		
		function META:OnMouseExit()
			self:SetColor(Color(1,1,1,0))
		end
		
		function META:SetText(str)
			self.BaseClass.SetText(self, "<font=snow_font><color=200,200,200>" .. str)
			self:SetHeight(self:GetTextSize().h + 4*scale)
			self:CenterTextY()
		end
		
		function META:CreateSubMenu()			
		
			local icon = gui2.CreatePanel("base", self)
			icon:Dock("right")
			icon:SetIgnoreMouse(true)
			icon:SetPadding(Rect(0,0,scale*2,0))
			icon:SetColor(Color(0,0,0,0))
			icon:SetParseTags(true) 
			icon:SetText("<font=snow_font><color=200,200,200>▶")
			icon:SetSize(icon:GetTextSize())

			self.menu = gui2.CreatePanel("menu")
			self.menu:SetVisible(false)
			
			return self.menu
		end
				 
		function META:OnMouseInput(button, press)
			if button == "button_1" and press then
				self:OnClick()
			end
		end
		
		function META:OnClick() gui2.SetActiveMenu() end 
		
		gui2.RegisterPanel(META)
	end
end

do	
	local META = {}
	META.ClassName = "tab"
	
	function META:Initialize()
		self:SetSendMouseInputToParent(true)
		self:SetColor(Color(0,0,0,0))
	
		local tab_bar =  gui2.CreatePanel("base", self)
		tab_bar:SetColor(Color(16,16,152,1))
		
		tab_bar:SetStack(true)
		tab_bar:SetStackDown(false)
		tab_bar:SetClipping(true)
		tab_bar:SetScrollable(true)
		
		local content = gui2.CreatePanel("base", self)
		content:SetupNinepatch(skin.frame, ninepatch_size, ninepatch_corner_size)
		content:SetSendMouseInputToParent(true)
		
		self.tab_bar = tab_bar
		self.content = content
	end
	
	function META:AddTab(name)
		local button = gui2.CreatePanel("base", self.tab_bar)
		button:SetSendMouseInputToParent(true)
		button:SetParseTags(true)  
		button:SetSize(Vec2(22,14)*scale)
		
		button:SetText("<font=snow_font><color=168,168,224>"..name)
		button:SetupNinepatch(skin.tab_inactive, ninepatch_size, ninepatch_corner_size)
		button:SetHeight(button:GetHeight() - scale)
		button:CenterText()
		button.text = name
		
		button.OnMouseInput = function(button, key, press)
			if press and key == "button_1" then
				button:SetText("<font=snow_font><color=160,160,0>"..button.text)
				button:SetupNinepatch(skin.tab_active, ninepatch_size, ninepatch_corner_size)
				button:CenterText()
				
				for i, panel in ipairs(self.tab_bar:GetChildren()) do
					if button ~= panel then
						panel:SetText("<font=snow_font><color=168,168,224>"..panel.text)
						panel:SetupNinepatch(skin.tab_inactive, ninepatch_size, ninepatch_corner_size)
						panel:CenterText()
					end
				end
				
				self:Layout()
			end
		end
	end
	
	function META:OnLayout()
		self.tab_bar:SetWidth(self:GetWidth())
		self.tab_bar:SetHeight(12*scale)

		self.content:SetPosition(Vec2(0, self.tab_bar:GetHeight()))
		self.content:SetHeight(self:GetHeight() - self.tab_bar:GetHeight())
		self.content:SetWidth(self:GetWidth())
	end
	
	gui2.RegisterPanel(META)
end

local frame = gui2.CreatePanel("frame")
frame:SetPosition(Vec2()+200)
frame:SetSize(Vec2()+200)

local tab = gui2.CreatePanel("tab", frame)
tab:Dock("fill")

for i = 1, 10 do
	tab:AddTab("#" .. i)
end

	   
local padding = 5 * scale

local bar = gui2.CreatePanel("base") 
bar:SetTexture(skin.gradient)
bar:SetColor(Color(0,72,248))
bar:SetDraggable(true)

local function create_button(text, options)
	local button = gui2.CreatePanel("base", bar)
	button:SetClipping(true) 
	button:SetParseTags(true)  
	button:SetText("<font=snow_font><color=200,200,200>" .. text)
	button:SetSize(button:GetTextSize() + Vec2(5,5) * scale)
	button:CenterText()
	
	button:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)
	 
	button.OnMouseInput = function(self, button, press)
		if press then
			self:SetTexture(skin.button_active)
			
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
			
			menu:SetPosition(self:GetWorldPosition() + Vec2(0, self:GetHeight() + 2*scale), options)

			menu:CallOnRemove(function() self:SetTexture(skin.button_inactive) end)
		end
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

--do return end

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