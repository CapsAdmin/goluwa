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

local function create_frame()
	local frame = gui2.CreatePanel()
	frame:SetDraggable(true)
	frame:SetResizable(true) 
	frame:SetMargin(Rect(4,10*scale+4,4,4))  
	frame:SetupNinepatch(skin.frame, ninepatch_size, ninepatch_corner_size)
		
		local bar = gui2.CreatePanel(frame)
		bar:SetObeyMargin(false)
		bar:Dock("fill_top") 
		bar:SetSendMouseInputToParent(true)
		bar:SetHeight(10*scale)
		bar:SetTexture(skin.gradient)
		bar:SetColor(Color(120, 120, 160))
		bar:SetClipping(true)
				
			local text = gui2.CreatePanel(bar)
			text:SetHeight(bar:GetHeight())
			text:SetParseTags(true)  
			text:SetText("<font=snow_font><color=200,200,200>about")
			text:CenterTextY()
			text:SetPosition(Vec2(2*scale,0))
			text:SetColor(Color(0,0,0,0))
			
			local close = gui2.CreatePanel(bar) 			
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
	
	return frame
end 

do
	local scroll_width = scale*8
	
	local frame = create_frame()  
	
	frame:SetPosition(Vec2(100, 100) )
	frame:SetSize(Vec2(300, 300))
	
	local panel = gui2.CreatePanel(frame)
	panel:Dock("fill") 
	panel:SetColor(Color(0,0,0,0))
		
		local list = gui2.CreatePanel(panel)
		list:SetColor(Color(0,0,0,1))
		list:SetClipping(true)
		list:SetScrollable(true)
			
			local y_scroll = gui2.CreatePanel(panel)
			y_scroll:SetTexture(skin.gradient2)
				
				local up = gui2.CreatePanel(y_scroll)				
				up:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
				
				local scroll_bar = gui2.CreatePanel(y_scroll)
				scroll_bar:SetDraggable(true)	
				scroll_bar:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)
				
				local down = gui2.CreatePanel(y_scroll)
				down:SetupNinepatch(skin.button_rounded, ninepatch_size, ninepatch_corner_size)
		
	function panel:OnLayout()	
		list:SetSize(panel:GetSize()*1) 
		list:SetWidth(panel:GetWidth() - scroll_width)
		
		y_scroll:SetSize(Vec2(scroll_width, panel:GetHeight()))
		y_scroll:SetPosition(Vec2(panel:GetWidth() - scroll_width, 0))
		
		down:SetSize(Vec2(scroll_width, scroll_width))
		down:SetPosition(Vec2(0, panel:GetHeight() - down:GetHeight()))
		
		scroll_bar:SetSize(Vec2(scroll_width, scroll_width))
		
		up:SetSize(Vec2(scroll_width, scroll_width))		
	end
	
	local lol
	
	scroll_bar.OnPositionChanged = function(self, pos)
		if not lol then
			local frac = math.clamp(pos.y / self.Parent:GetHeight(), 0, 1)
			list:SetScrollFraction(Vec2(list:GetScrollFraction().x, frac))
		end
 
		pos.x = self.Parent:GetWidth() - self:GetWidth()
		pos.y = math.clamp(pos.y, self:GetHeight(), self.Parent:GetHeight() - (self:GetHeight() * 2))
	end
	
	list.OnScroll = function(self, frac)
		lol = true
		scroll_bar:SetPosition(Vec2(0,frac.y * self.Parent:GetHeight()))
		lol = false
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
	
	scroll_bar:SetPosition(Vec2(0, 0))
	
	local w = 0
	local y = 0
	
	for _, file in ipairs(vfs.Find("/")) do
		local button = gui2.CreatePanel(list)
		button:SetSendMouseInputToParent(true)
		button:SetParseTags(true)
		button:SetText("<font=snow_font_green><color=0,255,0>" .. file)
		button:SetWrapText(false)
		button:SetSize(button:GetTextSize() + Vec2(4,4) * scale)
		button:CenterTextY()
		button:SetPosition(Vec2(0, y))
		
		w = math.max(w, button:GetTextSize().w)
		
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
				end
			end
		end
		
		y = y + button:GetSize().h - 2*scale
	end
	
	for k,v in ipairs(list:GetChildren()) do
		if v ~= self then
			v:SetWidth(w)
		end
	end
	
	scroll_bar:SetHeight(math.max((list:GetHeight() / list:GetSizeOfChildren().h) * list:GetHeight(), scroll_width))
	
	if list:GetHeight() > list:GetSizeOfChildren().h then
		scroll_bar:SetWidth(0)
	end
	
	panel:InvalidateLayout()
end
local function create_menu(pos, options, parent_menu)
	local frame = gui2.CreatePanel()
	frame:SetupNinepatch(skin.button_inactive, ninepatch_size, ninepatch_corner_size)
	frame:SetPosition(pos)
	
	if parent_menu then
		parent_menu:CallOnRemove(function() if frame:IsValid() then frame:Remove() end end)
	else
		gui2.SetActiveMenu(frame)
	end
	 
	local y = 2*scale
	local w = 0
	
	for i, option in ipairs(options) do
		
		local text, callback = option[1], option[2] or print
		
		if text then 
			local button = gui2.CreatePanel(frame)
			--button:SetColor(Color(88, 92, 88))
			--button:SetClipping(true)
			button:SetParseTags(true)  
			button:SetText("<font=snow_font><color=200,200,200>" .. text)
			button:SetHeight(button:GetTextSize().h + 4*scale)
			button:CenterTextY()
			button:SetPosition(Vec2(2*scale, y))			
			button:SetColor(Color(0,0,0,0))			
			button:SetupNinepatch(skin.menu_select, ninepatch_size, ninepatch_corner_size)			
			button:SetMargin(Rect(0,0,0,0))
			
			if type(callback) == "table" then
				local icon = gui2.CreatePanel(button)
				icon:SetIgnoreMouse(true)
				icon:SetPadding(Rect(0,0,scale*2,0))
				icon:Dock("right")
				icon:SetColor(Color(0,0,0,0))
				icon:SetParseTags(true) 
				icon:SetText("<font=snow_font><color=200,200,200>▶")
				icon:SetSize(icon:GetTextSize())

			end
			
			w = math.max(w, button:GetTextSize().w)
			 
			button.OnMouseEnter = function()
				button:SetColor(Color(1,1,1,1))
				
				if frame.sub_menu and frame.sub_menu:IsValid() and frame.sub_menu.button ~= button then
					frame.sub_menu:Remove() 
				end
				
				if type(callback) == "table" then
					if not frame.sub_menu or not frame.sub_menu:IsValid() then
						frame.sub_menu = create_menu(button:GetWorldPosition() + Vec2(button:GetWidth() + scale*2, 0), callback, frame)
						frame.sub_menu.button = button
					end
				end
			end
			button.OnMouseExit = function()
				if frame.sub_menu and frame.sub_menu:IsValid() then
					if frame.sub_menu.button ~= button then
						frame.sub_menu:Remove() 
					end
				end
				button:SetColor(Color(1,1,1,0))
			end
			
			button.OnMouseInput = function(self, button, press)
				if button == "button_1" and press then
					create_frame()
				end
			end
			
			--button:CenterText() 
			y = y + button:GetSize().h + scale
		else
			local button = gui2.CreatePanel(frame)
			button:SetPosition(Vec2(4, y + scale*4))
			button:SetSize(Vec2(frame:GetWidth() - 8, 6))	
			
			button:SetupNinepatch(skin.button_active, ninepatch_size, ninepatch_corner_size)
			y = y + 8*scale
		end
	end
	
	for i, panel in ipairs(frame:GetChildren()) do
		panel:SetWidth(w + 4*scale)
	end 
	 
	frame:SetSize(Vec2(w + 8*scale, y + 2*scale))
	
	return frame
end

local padding = 5 * scale
local x = padding
local y = 3 * scale

local bar = gui2.CreatePanel() 
bar:SetTexture(skin.gradient)
bar:SetColor(Color(0,72,248))
bar:SetDraggable(true)
bar:SetResizable(true)

local function create_button(text, options)
	local button = gui2.CreatePanel(bar)
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
			
			local menu = create_menu(self:GetWorldPosition() + Vec2(0, self:GetHeight() + 2*scale), options)
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

do return end

local emitter = ParticleEmitter(800)
emitter:SetPos(Vec3(50,50,0))
--emitter:SetMoveResolution(0.25)  
emitter:SetAdditive(false)

local fb
local DX = false

if DX then
	fb = render.CreateFrameBuffer(128, 128)
end

event.AddListener("PreDrawMenu", "zsnow", function(dt)
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
end) 

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