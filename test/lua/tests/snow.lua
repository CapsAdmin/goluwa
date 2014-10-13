include("gui2.lua")
 
local scale = 2
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

local button_inactive = Texture(16, 16, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
	y = -y + 16
 	
	if x >= 16-2 or y >= 16-2 then
		return 72, 68, 64, 255
	elseif x <= 2 or y <= 2 then
		return 104, 100, 96, 255
	end
	
	return 88, 92, 88, 255
end)

local button_active = Texture(16, 16, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
	y = -y + 16
 	
	if x >= 16-2 or y >= 16-2 then
		return 104, 100, 96, 255
	end
	
	return 72, 68, 64, 255
end)

local menu_select = Texture(16, 16, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
	y = -y + 16
 	
	if x >= 16-2 or y >= 16-2 or x <= 2 or y <= 2 then
		return 80, 0, 136, 255
	end
	
	return 80, 0, 160, 255
end)

local gradient = Texture(16, 16, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
	local v = (math.sin(y / 16 * math.pi)^0.8 * 255) / 2.25 + 130
	return v, v, v, 255
end)  

local function create_frame()
	local frame_texture = Texture(16, 16, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + 16
		
		if x >= 16-2 or y >= 16-2 then
			return 152, 16, 16, 255
		elseif x <= 2 or y <= 2 then
			return 184, 48, 48, 255
		end

		return 168, 32, 32, 255
	end)
 
	local frame = gui2.CreatePanel()
	frame:SetSize(Vec2(400,400))
	frame:SetPosition(Vec2(150, 150))
	frame:SetDraggable(true)
	frame:SetResizable(true)
	frame:SetNinePatch(true)
	frame:SetTexture(frame_texture)
	frame:SetNinePatchSize(16)
	frame:SetNinePatchCornerSize(4)
	frame:SetMargin(Rect())
		
		local bar = gui2.CreatePanel(frame)
		bar:SetMargin(Rect())
		bar:SetSendMouseInputToParent(true)
		bar:SetHeight(10*scale)
		bar:Dock("fill_top")
		bar:SetTexture(gradient)
		bar:SetColor(Color(120, 120, 160))
		bar:SetClipping(true)
				
			local text = gui2.CreatePanel(bar)
			text:SetHeight(bar:GetHeight())
			text:SetParseTags(true)  
			text:SetText("<font=snow_font><color=200,200,200>about")
			text:CenterTextY()
			text:SetPosition(Vec2(2*scale,0))
			text:SetColor(Color(0,0,0,0))
			
			local close_button = Texture(16, 16, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y)
				y = -y + 16
				
				if 
					(x >= 16-2 and y >= 16-2) or 
					(x <= 2 and y <= 2) or
					(x >= 16-2 and y <= 2) or
					(x <= 2 and y >= 16-2)
				then 					
					return 0,0,0,0 
				end
				
				if x >= 16-2 or y >= 16-2 then
					return 160, 120, 120, 255
				elseif x <= 2 or y <= 2 then
					return 192, 144, 144, 255
				end
				
				return 176, 132, 128, 255
			end)

			local close = gui2.CreatePanel(bar)
			close:SetPadding(Rect(1,1,1,1)*scale)
			
			close:SetParseTags(true)  
			close:SetText("<font=snow_font_noshadow><color=50,50,50>X")
			close:SetSize(close:GetTextSize()+Vec2(3,3)*scale)
			close:CenterText()
			
			close:Dock("top_right")
			
			close:SetNinePatch(true)
			close:SetTexture(close_button)   
			close:SetNinePatchSize(16)
			close:SetNinePatchCornerSize(4)
			
			close.OnMouseInput = function(self, button, press) 
				if button == "button_1" and not press then
					frame:Remove()
				end
			end 
	
	frame:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
	
	return frame
end 

do
	local frame = create_frame()
	
	local scroll_width = scale*8
	
	local panel = gui2.CreatePanel(frame)
	panel:SetPosition(Vec2(25, 25 + scroll_width))
	panel:SetSize(Vec2(200, 300))
	panel:SetColor(Color(0,0,0,0))	
	
	local scroll_bar = gui2.CreatePanel(panel)
	scroll_bar:SetColor(Color(0,1,0,1))
	scroll_bar:SetSize(Vec2(scroll_width,scroll_width))
	scroll_bar:SetDraggable(true)
	
	local list = gui2.CreatePanel(panel)
	list:SetColor(Color(0,0,0,1))
	list:SetClipping(true)
	list:SetScrollable(true)
	list:SetSize(panel:GetSize()*1) 
	list:SetWidth(list:GetWidth() - scroll_width)
	
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
	
	scroll_bar:SetPosition(Vec2(200-scroll_width,0))
	
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
		button:SetNinePatch(true)
		button:SetTexture(menu_select)
		button:SetNinePatchSize(16)
		button:SetNinePatchCornerSize(4)	

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
		
		if _ == 10 then break end
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
end
local function create_menu(pos, options)
	local frame = gui2.CreatePanel()
	frame:SetNinePatch(true)
	frame:SetTexture(button_inactive)
	frame:SetNinePatchSize(16)    
	frame:SetNinePatchCornerSize(4)
	frame:SetPosition(pos)
	
	gui2.SetActiveMenu(frame)
	 
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
			button:SetSize(button:GetTextSize() + Vec2(4,4) * scale)
			button:CenterTextY()
			button:SetWidth(frame:GetWidth() - 4*scale)
			button:SetPosition(Vec2(2*scale, y))
			
			button:SetColor(Color(0,0,0,0))
			button:SetNinePatch(true)
			button:SetTexture(menu_select)
			button:SetNinePatchSize(16)
			button:SetNinePatchCornerSize(4)
			
			w = math.max(w, button:GetTextSize().w)
			
			button.OnMouseEnter = function()
				button:SetColor(Color(1,1,1,1))
			end
			button.OnMouseExit = function()
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
			button:SetNinePatch(true)
			button:SetTexture(button_active)
			button:SetNinePatchSize(16)
			button:SetNinePatchCornerSize(2)
			y = y + 8*scale
		end
	end
	
	for i, panel in ipairs(frame:GetChildren()) do
		panel:SetWidth(w)
	end 
	 
	frame:SetSize(Vec2(w + 5*scale, y + 2*scale))
	
	return frame
end

local padding = 5 * scale
local x = padding
local y = 3 * scale

local bar = gui2.CreatePanel() 
bar:SetTexture(gradient)
bar:SetColor(Color(0,72,248))
bar:SetDraggable(true)

local function create_button(text, options)
	local button = gui2.CreatePanel(bar)
	--button:SetColor(Color(88, 92, 88))
	button:SetPosition(Vec2(x, y))
	button:SetClipping(true)
	button:SetParseTags(true)  
	button:SetText("<font=snow_font><color=200,200,200>" .. text)
	button:SetSize(button:GetTextSize() + Vec2(5,5) * scale)
	button:CenterText()
	
	button:SetNinePatch(true)
	button:SetTexture(button_inactive)
	button:SetNinePatchSize(16)
	button:SetNinePatchCornerSize(4)
	 
	button.OnMouseInput = function(self, button, press)
		if press then
			self:SetTexture(button_active)
			
			local menu = create_menu(self:GetWorldPosition() + Vec2(0, self:GetHeight() + 2*scale), options)
			menu:CallOnRemove(function() self:SetTexture(button_inactive) end)
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
	{"load"},
	{"run  [ESC]"},
	{"reset"},
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

event.AddListener("PreDrawMenu", "zsnow", function(dt)	
	--emitter:Update(dt)
	--emitter:Draw()
	
	surface.SetWhiteTexture()
	surface.SetColor(bg)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	
	surface.SetColor(1,1,1,1)
	emitter:Draw()
	
	surface.SetColor(0,0,0,0.25)
	surface.DrawRect(5*scale,5*scale, x, 16 * scale)
end) 

event.CreateTimer("zsnow", 0.01, function()
	do return end
	emitter:SetPos(Vec3(math.random(render.GetWidth() + 100) - 150, -50, 0))
		
	local p = emitter:AddParticle()
	p:SetDrag(1)

	--p:SetStartLength(Vec2(0))
	--p:SetEndLength(Vec2(30, 0))
	p:SetAngle(math.random(360)) 
	 
	p:SetVelocity(Vec3(math.random(100),math.random(40, 80)*2,0))

	p:SetLifeTime(20)

	p:SetStartSize(2 * (1 + math.random() ^ 50))
	p:SetEndSize(2 * (1 + math.random() ^ 50))
	p:SetColor(Color(1,1,1, math.randomf(0.5, 0.8)))
end) 