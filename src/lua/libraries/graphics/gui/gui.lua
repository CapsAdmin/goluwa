-- drag drop doesn't work properly with camera changes
-- multiple animations of the same type
-- support rotation in TrapChildren and drag drop
-- clipping isn't "recursive"

local gui = _G.gui or {}

gui.unroll_draw = false

gui.panels = gui.panels or {} 

function gui.CreatePanel(name, parent, store_in_parent)
	parent = parent or gui.world
	
	local child_i
	
	if store_in_parent then
		if type(store_in_parent) ~= "string" then
			store_in_parent = name
		end
		
		for i,v in ipairs(parent:GetChildren()) do
			if v == parent[store_in_parent] then
				child_i = i
			end
		end
	end
		
	local self = prototype.CreateDerivedObject("panel2", name, nil, true)
	
	if not self then 
		return NULL 
	end
	
	if parent then
		parent:AddChild(self)
		
		if child_i then
			table.remove(parent:GetChildren())
			table.insert(parent:GetChildren(), child_i, self)
		end
	end
	
	self:Initialize()	
	
	if parent and parent.Skin then
		self:SetSkin(parent:GetSkin())
	else
		self:OnStyleChanged(gui.skin)
	end

	gui.panels[self] = self
	
	if store_in_parent then
		prototype.SafeRemove(parent[store_in_parent])
		parent[store_in_parent] = self
	end
	
	return self
end

function gui.RegisterPanel(META)
	META.TypeBase = "base"
	prototype.Register(META, "panel2")
end

function gui.RemovePanel(pnl)
	if pnl and pnl:IsValid() then pnl:Remove() end
end

function gui.Panic()
	gui.Initialize()
end

function gui.GetHoveringPanel(panel, filter)
	panel = panel or gui.world
	local children = panel:GetChildren()

	for i = #children, 1, -1 do
		local panel = children[i]
		if panel.Visible and panel.mouse_over and (not filter or panel ~= filter) then			
			if panel:HasChildren() then
				return gui.GetHoveringPanel(panel, filter)
			end
			
			if panel.IgnoreMouse then
				for i, panel in ipairs(panel:GetParentList()) do
					if not panel.IgnoreMouse then
						return panel
					end
				end
			end
			
			return panel
		end
	end
	
	if panel.IgnoreMouse then
		for i, panel in ipairs(panel:GetParentList()) do
			if not panel.IgnoreMouse and panel.mouse_over then
				return panel
			end
		end
	end
	
	return panel.mouse_over and panel or gui.world
end

do -- context menu helpers
	gui.current_menu = gui.current_menu or NULL

	function gui.SetActiveMenu(panel)
		if gui.current_menu:IsValid() then
			gui.current_menu:Remove()
		end
		
		gui.current_menu = panel or NULL
	end
end

do -- events
	gui.last_clicked = gui.last_clicked or NULL
	gui.hovering_panel = gui.hovering_panel or NULL
	gui.focus_panel = gui.focus_panel or NULL
	gui.keyboard_selected_panel = gui.keyboard_selected_panel or NULL
	
	function gui.SystemFileDrop(wnd, path)
		print(wnd, path)
		gui.UpdateMousePosition()
		local panel = gui.hovering_panel
		if panel:IsValid() and panel:IsMouseOver() then
			panel:OnSystemFileDrop(path)
		end
	end
	
	function gui.MouseInput(button, press)
		gui.RemovePanel(gui.active_tooltip)
		
		gui.UpdateMousePosition()
		
		local panel = gui.hovering_panel

		if panel:IsValid() and panel:IsMouseOver() then
			panel:MouseInput(button, press)
			gui.last_clicked = panel
		end
		
		for panel in pairs(gui.panels) do
			panel:GlobalMouseInput(button, press)
			
			if panel.AlwaysReceiveMouseInput and panel.mouse_over then 
				panel:MouseInput(button, press)
			end
		end
		
		do -- context menus
			local panel = gui.current_menu
			
			if button == "button_1" and press and panel:IsValid() and not panel:IsMouseOver() then
				panel:Remove()
			end
		end
	end
	
	local i = 1

	function gui.KeyInput(button, press)
		local panel = gui.focus_panel

		if panel:IsValid() then
			panel:KeyInput(button, press)
			return true
		end

		if button == "space" then
			gui.MouseInput("button_1", press)
		end		
				
		if press and input.IsKeyDown("left_control") then
			
			local last = gui.hovering_panel
			
			if button == "up" then
				local x, y = window.GetMousePosition():Unpack()
				for i = y, 1, -16 do
					window.SetMousePosition(Vec2(x, i))
					gui.UpdateMousePosition()
					gui.world:Draw()
					if last ~= gui.hovering_panel and last.Parent ~= gui.hovering_panel then
						gui.hovering_panel:BringMouse()
						if window.GetMousePosition().y > i then 
							break
						end
					end
				end
			elseif button == "left" then
				local x, y = window.GetMousePosition():Unpack()
				for i = x, 1, -16 do
					window.SetMousePosition(Vec2(i, y))
					gui.UpdateMousePosition()
					gui.world:Draw()
					if last ~= gui.hovering_panel and last.Parent ~= gui.hovering_panel then
						gui.hovering_panel:BringMouse()
						if window.GetMousePosition().x > i then 
							break
						end
					end
				end
			elseif button == "right" then
				local x, y = window.GetMousePosition():Unpack()
				for i = x, window.GetSize().w, 16 do
					window.SetMousePosition(Vec2(i, y))
					gui.UpdateMousePosition()
					gui.world:Draw()
					if last ~= gui.hovering_panel and last.Parent ~= gui.hovering_panel then
						gui.hovering_panel:BringMouse()
						if window.GetMousePosition().x < i then 
							break
						end
					end
				end
			elseif button == "down" then
				local x, y = window.GetMousePosition():Unpack()
				for i = y, window.GetSize().h, 16 do
					window.SetMousePosition(Vec2(x, i))
					gui.UpdateMousePosition()
					gui.world:Draw()
					if last ~= gui.hovering_panel and last.Parent ~= gui.hovering_panel then
						gui.hovering_panel:BringMouse()
						if window.GetMousePosition().y > i then 
							break
						end
					end
				end
			end
		end
		
	end

	function gui.CharInput(char)
		local panel = gui.focus_panel

		if panel:IsValid() then
			panel:CharInput(char)
			return true
		end
	end

	function gui.UpdateMousePosition()
		gui.hovering_panel = gui.GetHoveringPanel()
		
		if gui.hovering_panel:IsValid() then
			local cursor = gui.hovering_panel:GetCursor()

			if gui.active_cursor ~= cursor then
				system.SetCursor(cursor)
				gui.active_cursor = cursor
			end
		end
		
		gui.mouse_pos.x, gui.mouse_pos.y = surface.GetMousePosition()

		if not input.IsKeyDown("left_control") then
			if input.IsKeyDown("up") then
				window.SetMousePosition(Vec2(gui.mouse_pos.x, gui.mouse_pos.y - 1))
			elseif input.IsKeyDown("down") then
				window.SetMousePosition(Vec2(gui.mouse_pos.x, gui.mouse_pos.y + 1))
			elseif input.IsKeyDown("left") then
				window.SetMousePosition(Vec2(gui.mouse_pos.x - 1, gui.mouse_pos.y))
			elseif input.IsKeyDown("right") then
				window.SetMousePosition(Vec2(gui.mouse_pos.x + 1, gui.mouse_pos.y))
			end
		end
	end
	
	function gui.Draw2D(dt)		
		event.Call("DrawHUD", dt)
		event.Call("PreDrawMenu", dt)
		
		if gui.threedee then 
			--render.camera_2d:Start3D2DEx(Vec3(1, -5, 10), Deg3(-90, 180, 0), Vec3(8, 8, 10))
			render.camera_2d:Start3D2DEx(Vec3(0, 0, 0), Ang3(0, 0, 0), Vec3(20, 20, 20))
		end
		
		gui.UpdateMousePosition()
		
		--surface.EnableStencilClipping()
			
		if gui.unroll_draw then	
			if not gui.unrolled_draw then
				gui.panels_unroll = {}
				gui.world.unroll_i = 1
				for i,v in ipairs(gui.world:GetChildrenList()) do
					v.unroll_i = i+1
					gui.panels_unroll[i] = v
				end
				local str = {"local panels = gui.panels_unroll"}
				
				local function add_children_to_list(parent, str, level)
					table.insert(str, ("%sif panels[%i] and panels[%i].Visible then"):format(("\t"):rep(level), parent.unroll_i, parent.unroll_i))
						table.insert(str, ("%spanels[%i]:PreDraw()"):format(("\t"):rep(level+1), parent.unroll_i))
						for i, child in ipairs(parent:GetChildren()) do
							level = level + 1
							add_children_to_list(child, str, level) 
							level = level - 1
						end
						table.insert(str, ("%spanels[%i]:PostDraw()"):format(("\t"):rep(level+1), parent.unroll_i))
					table.insert(str, ("%send"):format(("\t"):rep(level)))
				end
			
				add_children_to_list(gui.world, str, 0)
				str = table.concat(str, "\n")
				vfs.Write("data/gui2_draw.lua", str)
				gui.unrolled_draw = loadstring(str, "gui2_unrolled_draw")
			end
			
			gui.unrolled_draw()
		else
			gui.world:Draw()
		end

		--surface.DisableStencilClipping()
		surface.SetWorldMatrix()

		if gui.threedee then 
			render.camera_2d:End3D2D()
		end
		
		event.Call("PostDrawMenu", dt)
	end
end

do -- skin
	function gui.SetSkin(skin, reload_panels)		
		if type(skin) == "string" then
			skin = gui.GetRegisteredSkin(skin).skin
		end
		
		gui.skin = skin
		
		if reload_panels then 
			include("lua/libraries/graphics/gui/panels/*", gui) 
		end
		
		for panel in pairs(gui.panels) do
			panel:ReloadStyle()
		end
	end

	function gui.GetSkin()
		return gui.skin
	end
	
	gui.registered_skins = {}
	
	function gui.GetRegisteredSkin(name)
		if gui.registered_skins[name] then 
			local tbl = gui.registered_skins[name] 
			
			if not tbl.skin then
				local skin = tbl:Build()
				skin.name = tbl.Name
				skin.GetScale = tbl.GetScale
				tbl.skin = skin
			end
			
			return tbl
		end
	end
	
	function gui.GetRegisteredSkins()
		local out = {}
		for k, v in pairs(gui.registered_skins) do
			table.insert(out, k)
		end
		return out
	end

	console.AddCommand("gui_skin", function(_, str, sub_skin)
		str = str or "gwen"
		gui.SetSkin(str, sub_skin)
	end)
	
	function gui.RegisterSkin(tbl)
		gui.registered_skins[tbl.Name] = tbl
				
		if RELOAD or gui.force_reload then
			if not tbl.skin then
				local skin = tbl:Build()
				skin.name = tbl.Name
				skin.GetScale = tbl.GetScale
				tbl.skin = skin
			end
		
			for k,v in pairs(gui.panels) do
				if v:HasSkin(tbl.Name) then
					v:SetSkin(tbl.skin)
				end
			end
		end
	end
end

do -- gui scaling
	gui.scale_multiplier = 1

	function gui.SetScale(scale)
		scale = scale or 1
		
		gui.scale_multiplier = scale
		for panel in pairs(gui.panels) do
			if panel.GetText then
				panel:SetText(panel:GetText())
			end
			panel:Layout()
		end
		
		gui.force_reload = true
			include("lua/libraries/graphics/gui/skins/*", gui)
		gui.force_reload = nil
	end

	function gui.GetScale()
		return gui.scale_multiplier
	end
end

function gui.CreateWorld()
	local world = gui.CreatePanel("base")
	world:SetParent()
	world:SetPosition(Vec2(0, 0))
	world:SetSize(Vec2(window.GetSize()))
	world:SetCursor("arrow")
	world:SetTrapChildren(true)
	world:SetNoDraw(true)
	--world:SetPadding(Rect(10, 10, 10, 10))
	world:SetPadding(Rect(0, 0, 0, 0))
	world:SetMargin(Rect(0, 0, 0, 0))
	world.is_world = true
	
	return world
end

function gui.Initialize()
	include("lua/libraries/graphics/gui/skins/*", gui)
	gui.SetSkin("gwen_dark")

	gui.RemovePanel(gui.world)
	
	gui.world = gui.CreateWorld()

	gui.mouse_pos = Vec2()

	event.AddListener("FontChanged", "gui", function(name) 
		gui.world:Layout()
	end, {on_error = system.OnError})
	
	event.AddListener("Draw2D", "gui", gui.Draw2D, {on_error = system.OnError})
	event.AddListener("MouseInput", "gui", gui.MouseInput, {on_error = system.OnError})
	event.AddListener("KeyInputRepeat", "gui", gui.KeyInput, {on_error = system.OnError})
	event.AddListener("CharInput", "gui", gui.CharInput, {on_error = system.OnError})
	event.AddListener("WindowFileDrop", "gui", gui.SystemFileDrop, {on_error = system.OnError})
	local window = render.GetWindow()
	event.AddListener("WindowFramebufferResized", "gui", function(wnd, w,h) 
		if window == wnd then
			gui.world:SetSize(Vec2(w, h))
		end
	end, {on_error = system.OnError})
	
	
	-- should this be here?	
	do -- task bar (well frame bar is more appropriate since the frame control adds itself to this)
		local S = gui.skin:GetScale()
		
		local bar = gui.CreatePanel("base") 
		bar:SetStyle("gradient")
		bar:SetVisible(false)
				
		bar.buttons = {}
		
		function bar:AddButton(text, key, callback, callback2)
			self:SetVisible(true)
			
			local button = self.buttons[key] or gui.CreatePanel("text_button", self) 
			button:SetText(text)
			button.OnPress = callback
			button.OnRightClick = callback2

			button:SetupLayout("center_left")
			
			self.buttons[key] = button
						
			self:Layout()
		end 
		
		function bar:RemoveButton(key)
			gui.RemovePanel(self.buttons[key])
			self.buttons[key] = nil
			
			if not next(self.buttons) then
				self:SetVisible(false)
			end
			
			self:Layout()
		end
		
		function bar:OnLayout(S)
			self:SetHeight(S*14)
			self:SetMargin(Rect()+S*2)
			
			for i,v in ipairs(self:GetChildren()) do
				v:SetMargin(Rect()+2.5*S)
				v:SizeToText()
			end
			
			
			self:MoveDown()
			self:FillX()
		end
		
		bar:Layout(true)
	
		gui.task_bar = bar
	end
end

include("base_panel.lua", gui)
include("panels/*", gui)
include("helpers.lua", gui)

gui.Initialize()

return gui
--for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end