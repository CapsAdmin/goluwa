-- drag drop doesn't work properly with camera changes
-- multiple animations of the same type
-- support rotation in TrapChildren and drag drop
-- clipping isn't "recursive"

local gui2 = _G.gui2 or {}

gui2.unroll_draw = false
gui2.hovering_panel = gui2.hovering_panel or NULL
gui2.focus_panel = gui2.focus_panel or NULL

gui2.panels = gui2.panels or {} 

function gui2.CreatePanel(name, parent, store_in_parent)
	parent = parent or gui2.world
	
	local self = prototype.CreateDerivedObject("panel2", name)
	
	if not self then 
		return NULL 
	end
	
	self:SetParent(parent)
	self:Initialize()
	
	gui2.panels[self] = self
	
	-- this will make calls to layout always layout until next frame
	self.layout_me = "init"
	
	if store_in_parent then
		if type(store_in_parent) == "string" then
			prototype.SafeRemove(parent[store_in_parent])
			parent[store_in_parent] = self
		else
			prototype.SafeRemove(parent[name])
			parent[name] = self
		end
	end
	
	return self
end

function gui2.RegisterPanel(META)
	META.TypeBase = "base"
	prototype.Register(META, "panel2")
end

function gui2.RemovePanel(pnl)
	if pnl and pnl:IsValid() then pnl:Remove() end
end

function gui2.GetHoveringPanel(panel, filter)
	panel = panel or gui2.world
	local children = panel:GetChildren()

	for i = #children, 1, -1 do
		local panel = children[i]
		if panel.Visible and panel.mouse_over and (not filter or panel ~= filter) then			
			if panel:HasChildren() then
				return gui2.GetHoveringPanel(panel, filter)
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

	return panel.mouse_over and panel or gui2.world
end

do -- context menu helpers
	gui2.current_menu = gui2.current_menu or NULL

	function gui2.SetActiveMenu(panel)
		if gui2.current_menu:IsValid() then
			gui2.current_menu:Remove()
		end
		
		gui2.current_menu = panel or NULL
	end
	
	function gui2.CreateMenu(options, parent)
		local menu = gui2.CreatePanel("menu")
		gui2.SetActiveMenu(menu)
		
		if parent then
			parent:CallOnRemove(function() gui2.RemovePanel(menu) end, menu)
		end

		local function add_entry(menu, val)
			for k, v in ipairs(val) do
				if type(v[2]) == "table" then
					local menu, entry = menu:AddSubMenu(v[1])
					if v[3] then entry:SetIcon(Texture(v[3])) end
					add_entry(menu, v[2])
				elseif v[1] then
					local entry = menu:AddEntry(v[1], v[2])
					if v[3] then entry:SetIcon(Texture(v[3])) end
				else
					menu:AddSeparator()
				end
			end
		end

		add_entry(menu, options)
		
		menu:Layout(true)
		menu:SetPosition(gui2.world:GetMousePosition():Copy())
		
		return menu
	end
end

do -- events

	function gui2.MouseInput(button, press)
		local panel = gui2.hovering_panel

		if panel:IsValid() and panel:IsMouseOver() then
			panel:MouseInput(button, press)
		end
		
		for panel in pairs(gui2.panels) do
			panel:OnGlobalMouseInput(button, press)
			
			if panel.AlwaysReceiveMouseInput and panel.mouse_over then 
				panel:MouseInput(button, press)
			end
		end
		
		do -- context menus
			local panel = gui2.current_menu
			
			if button == "button_1" and press and panel:IsValid() and not panel:IsMouseOver() then
				panel:Remove()
			end
		end
	end

	function gui2.KeyInput(button, press)
		local panel = gui2.focus_panel

		if panel:IsValid() then
			panel:KeyInput(button, press)
			return true
		end
	end

	function gui2.CharInput(char)
		local panel = gui2.focus_panel

		if panel:IsValid() then
			panel:CharInput(char)
			return true
		end
	end

	function gui2.Draw2D()
		render.SetCullMode("none")
		if gui2.threedee then 
			--surface.Start3D(Vec3(1, -5, 10), Deg3(-90, 180, 0), Vec3(8, 8, 10))
			surface.Start3D(Vec3(0, 0, 0), Ang3(0, 0, 0), Vec3(20, 20, 20))
		end

		gui2.hovering_panel = gui2.GetHoveringPanel()
		
		if gui2.hovering_panel:IsValid() then
			local cursor = gui2.hovering_panel:GetCursor()

			if gui2.active_cursor ~= cursor then
				system.SetCursor(cursor)
				gui2.active_cursor = cursor
			end
		end
		
		gui2.mouse_pos.x, gui2.mouse_pos.y = surface.GetMousePosition()
		
		--surface.EnableStencilClipping()
			
		if gui2.unroll_draw then	
			if not gui2.unrolled_draw then
				gui2.panels_unroll = {}
				gui2.world.unroll_i = 1
				for i,v in ipairs(gui2.world:GetChildrenList()) do
					v.unroll_i = i+1
					gui2.panels_unroll[i] = v
				end
				local str = {"local panels = gui2.panels_unroll"}
				
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
			
				add_children_to_list(gui2.world, str, 0)
				str = table.concat(str, "\n")
				vfs.Write("gui2_draw.lua", str)
				gui2.unrolled_draw = loadstring(str, "gui2_unrolled_draw")
			end
			
			gui2.unrolled_draw()
		else
			gui2.world:Draw()
		end

		--surface.DisableStencilClipping()

		if gui2.threedee then 
			surface.End3D()
		end
	end
end

do -- skin
	function gui2.SetSkin(tbl, reload_panels)
		if reload_panels then include("gui2/panels/*", gui2) end
		
		gui2.skin = tbl
		gui2.scale = tbl.scale or gui2.scale
		
		for panel in pairs(gui2.panels) do
			panel:ReloadStyle()
		end
		logn("gui skin changed. you might need to reopen some panels to fully see the changes")
	end

	function gui2.GetSkin()
		return gui2.skin
	end

	console.AddCommand("gui_skin", function(_, str, sub_skin)
		str = str or "gwen"
		include("gui2/skins/" .. str .. ".lua", gui2, sub_skin)
	end)
end

do -- gui scaling
	gui2.scale = 1

	function gui2.SetScale(scale)
		gui2.scale = scale
		for panel in pairs(gui2.panels) do
			if panel.GetText then
				panel:SetText(panel:GetText())
			end
			panel:Layout()
		end
	end

	function gui2.GetScale(scale)
		return gui2.scale
	end
end

function gui2.Initialize()
	gui2.RemovePanel(gui2.world)
	
	local world = gui2.CreatePanel("base")

	world:SetPosition(Vec2(0, 0))
	world:SetSize(Vec2(window.GetSize()))
	world:SetCursor("arrow")
	world:SetTrapChildren(true)
	world:SetNoDraw(true)
	--world:SetPadding(Rect(10, 10, 10, 10))
	world:SetPadding(Rect(0, 0, 0, 0))
	world:SetMargin(Rect(0, 0, 0, 0))

	gui2.world = world

	gui2.mouse_pos = Vec2()

	event.AddListener("Draw2D", "gui2", gui2.Draw2D)
	event.AddListener("MouseInput", "gui2", gui2.MouseInput)
	event.AddListener("KeyInputRepeat", "gui2", gui2.KeyInput)
	event.AddListener("CharInput", "gui2", gui2.CharInput)
	event.AddListener("WindowFramebufferResized", "gui2", function(_, w,h) 
		gui2.world:SetSize(Vec2(w, h))
	end)
	
	
	-- should this be here?	
	do -- task bar (well frame bare is more appropriate since the frame control adds itself to this)
		local S = gui2.skin.scale
		
		local bar = gui2.CreatePanel("base") 
		bar:SetStyle("gradient")
		bar:SetupLayoutChain("bottom", "fill_x")
		bar:SetVisible(false)
				
		bar.buttons = {}
		
		function bar:AddButton(text, key, callback)
			self:SetVisible(true)
			
			local button = self.buttons[key] or gui2.CreatePanel("text_button", self) 
			button:SetText(text)
			button.label:SetupLayoutChain("left")
			button.OnPress = callback  

			button:SetupLayoutChain("left")
			
			self.buttons[key] = button
		end 
		
		function bar:RemoveButton(key)
			gui2.RemovePanel(self.buttons[key])
			self.buttons[key] = nil
			
			if not next(self.buttons) then
				self:SetVisible(false)
			end
			
			self:Layout()
		end
		
		function bar:OnLayout(S)
			self:SetLayoutSize(Vec2()+S*14)
			self:SetMargin(Rect()+S*2)
			
			for i,v in ipairs(self:GetChildren()) do
				v:SetMargin(Rect()+2.5*S)
				v:SizeToText()
			end
		end
		
		bar:Layout(true)
	
		gui2.task_bar = bar
	end
end

include("base_panel.lua", gui2)
include("skins/gwen.lua", gui2)
include("panels/*", gui2)

gui2.Initialize()

gui.SetCursor = function() end

return gui2
--for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end