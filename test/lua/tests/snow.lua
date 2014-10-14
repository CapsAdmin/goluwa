include("gui2.lua")
 
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
		local frame = self
		frame:SetDraggable(true)
		frame:SetResizable(true) 
		frame:SetMargin(Rect(4,10*scale+4,4,4))  
		frame:SetupNinepatch(skin.frame, ninepatch_size, ninepatch_corner_size)
			
			local bar = gui2.CreatePanel("base", frame)
			bar:SetObeyMargin(false)
			bar:Dock("fill_top") 
			bar:SetSendMouseInputToParent(true)
			bar:SetHeight(10*scale)
			bar:SetTexture(skin.gradient)
			bar:SetColor(Color(120, 120, 160))
			bar:SetClipping(true)
					
				local text = gui2.CreatePanel("base", bar)
				text:SetHeight(bar:GetHeight())
				text:SetParseTags(true)  
				text:SetText("<font=snow_font><color=200,200,200>about")
				text:CenterTextY()
				text:SetPosition(Vec2(2*scale,0))
				text:SetColor(Color(0,0,0,0))
				
				local close = gui2.CreatePanel("base", bar) 			
				close:SetParseTags(true)  
				close:SetText("<font=snow_font_noshadow><color=50,50,50>X")
				close:SetSize(close:GetTextSize()+Vec2(3,3)*scale)
				close:CenterText()
				
				close:Dock("top_right")
				
				close:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
				
				close.OnMouseInput = function(self, button, press) 
					if button == "button_1" and not press then
						frame:Remove()
					end
				end 
		
		frame:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
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
			
		local y_scroll = gui2.CreatePanel("base", self)
		y_scroll:SetTexture(skin.gradient2)

		local up = gui2.CreatePanel("base", y_scroll)				
		up:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)

		local scroll_bar = gui2.CreatePanel("base", y_scroll)
		scroll_bar:SetDraggable(true)	
		scroll_bar:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)

		local down = gui2.CreatePanel("base", y_scroll)
		down:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
				
		
		scroll_bar.OnPositionChanged = function(self, pos)
			local frac = math.clamp(pos.y / self.Parent:GetHeight(), 0, 1)
			list:SetScrollFraction(Vec2(list:GetScrollFraction().x, frac))
	 
			pos.x = self.Parent:GetWidth() - self:GetWidth()
			pos.y = math.clamp(pos.y, self:GetHeight(), self.Parent:GetHeight() - (self:GetHeight() * 2))
		end
		
		list.OnScroll = function(self, frac)
			scroll_bar:SetPosition(Vec2(0,frac.y * self.Parent:GetHeight()))
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
		self.scroll_bar = scroll_bar
		self.y_scroll = y_scroll
	end
	
	function META:OnLayout()
		local w = 0
		
		local y = 0
		
		for k, v in pairs(self.entries) do
			v:SetPosition(Vec2(0, y))
			y = y + v:GetHeight() + 2*scale
			w = math.max(w, v:GetTextSize().w)
		end
		
		for k,v in ipairs(self.list:GetChildren()) do
			v:SetWidth(w)
		end
	
		self.list:SetSize(self:GetSize()*1) 
		self.list:SetWidth(self:GetWidth() - scroll_width)
		
		self.y_scroll:SetSize(Vec2(scroll_width, self:GetHeight()))
		self.y_scroll:SetPosition(Vec2(self:GetWidth() - scroll_width, 0))
		
		self.down:SetSize(Vec2(scroll_width, scroll_width))
		self.down:SetPosition(Vec2(0, self:GetHeight() - self.down:GetHeight()))
		
		self.scroll_bar:SetSize(Vec2(scroll_width, scroll_width))
		
		self.up:SetSize(Vec2(scroll_width, scroll_width))
	
		self.scroll_bar:SetHeight(math.max((self.list:GetHeight() / self.list:GetSizeOfChildren().h) * self.list:GetHeight(), scroll_width))
		
		if self.list:GetHeight() > self.list:GetSizeOfChildren().h then
			self.scroll_bar:SetWidth(0)
		end
	end
	
	function META:AddEntry(name, on_click)		
		local button = gui2.CreatePanel("base", self.list)
		button:SetSendMouseInputToParent(true)
		button:SetParseTags(true)
		button:SetText("<font=snow_font_green><color=0,255,0>" .. name)
		button:SetWrapText(false)
		button:SetSize(button:GetTextSize() + Vec2(4,4) * scale)
		button:CenterTextY()
		
		local last_child = self:GetChildren()[#self:GetChildren()]
		button:SetPosition(Vec2(0, last_child:GetPosition().y + last_child:GetHeight() - 2*scale))
			
		button:SetColor(Color(0,0,0,0))
		button:SetupNinepatch(skin.menu_select, ninepatch_size, ninepatch_corner_size)

		button.OnMouseInput = function(self, button, press)
			if button == "button_1" then
				if press then
					self:SetColor(Color(1,1,1,1))
					for k,v in ipairs(list:GetChildren()) do
						if v ~= self then
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
			local y = 0
			
			for k, v in ipairs(self:GetChildren()) do
				v:SetPosition(Vec2(2*scale, y))
				w = math.max(w, v:GetTextSize().w)
				y = y + v:GetSize().h + scale
			end
			
			for k, v in ipairs(self:GetChildren()) do
				v:SetWidth(w + 4*scale)
			end
			
			self:SetSize(Vec2(w + 8*scale, y))
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
				self.menu:SetPosition(self:GetWorldPosition() + Vec2(self:GetWidth() + scale*2, 0))
				self.menu:SetVisible(true)							
				self.menu:Layout()
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
	local frame = gui2.CreatePanel("frame") 
	
	frame:SetPosition(Vec2(100, 100) )
	frame:SetSize(Vec2(300, 300))
	
	local panel = gui2.CreatePanel("list", frame)
	panel:Dock("fill") 
	for k,v in pairs(vfs.Find("/")) do
		panel:AddEntry(v)
	end
end

local padding = 5 * scale
local x = padding
local y = 3 * scale

local bar = gui2.CreatePanel("base") 
bar:SetTexture(skin.gradient)
bar:SetColor(Color(0,72,248))
bar:SetDraggable(true)
bar:SetResizable(true)

local function create_button(text, options)
	local button = gui2.CreatePanel("base", bar)
	--button:SetColor(Color(88, 92, 88))
	button:SetPosition(Vec2(x, y))
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
			menu:SetPosition(self:GetWorldPosition() + Vec2(0, self:GetHeight() + 2*scale), options)
			
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
			
			menu:CallOnRemove(function() self:SetTexture(skin.button_inactive) end)
		end
	end
	
	x = x + button:GetSize().x + padding
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
	{"load", {
		{"save state"},
		{"open state"},
		{"pick state"},
	}},
	{"run  [ESC]"},
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
	{"quit"}
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

bar:SetSize(Vec2(x, 16 * scale))

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
	
	surface.SetColor(0,0,0,0.25)
	surface.DrawRect(5*scale,5*scale, x, 16 * scale)
	
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