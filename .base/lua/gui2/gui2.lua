-- drag drop doesn't work properly with camera changes
-- multiple animations of the same type
-- support rotation in TrapChildren and drag drop
-- clipping isn't "recursive"

local gui2 = _G.gui2 or {}

gui2.hovering_panel = gui2.hovering_panel or NULL
gui2.focus_panel = gui2.focus_panel or NULL
--gui2.panels = gui2.panels or {}

function gui2.CreatePanel(name, parent)		
	local self = prototype.CreateDerivedObject("panel2", name)
	
	if not self then return NULL end
					
	self:SetParent(parent or gui2.world)
	self:Initialize()
	
	--table.insert(gui2.panels, self)
	--self.i = #gui2.panels
	
	self.layout_me = true
	
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
		if panel.mouse_over and not panel.IgnoreMouse and (not filter or panel ~= filter) then
			if panel:HasChildren() then
				return gui2.GetHoveringPanel(panel, filter)
			end
			return panel
		end
	end

	return panel.mouse_over and panel or gui2.world
end

local menu_second_try

do -- context menu helpers
	gui2.current_menu = gui2.current_menu or NULL

	function gui2.SetActiveMenu(panel)
		if gui2.current_menu:IsValid() then
			gui2.current_menu:Remove()
		end
		
		gui2.current_menu = panel or NULL
		menu_second_try = false
	end
end

do -- events

	function gui2.MouseInput(button, press)
		local panel = gui2.hovering_panel

		if panel:IsValid() and panel:IsMouseOver() then
			panel:MouseInput(button, press)
		end
		
		local panel = gui2.current_menu
		
		if button == "button_1" and press and panel:IsValid() and not panel:IsMouseOver() then
			-- only start checking if we're pressing outside the second press
			if menu_second_try then
				panel:Remove()
			end
			menu_second_try = true
		end
	end

	function gui2.KeyInput(button, press)
		local panel = gui2.focus_panel

		if panel:IsValid() then
			panel:KeyInput(button, press)
		end
	end

	function gui2.CharInput(char)
		local panel = gui2.focus_panel

		if panel:IsValid() then
			panel:CharInput(char)
		end
	end

	function gui2.Draw2D()
		render.SetCullMode("none")
		if gui2.threedee then 
			--surface.Start3D(Vec3(1, -5, 10), Ang3(-90, 180, 0), Vec3(8, 8, 10))
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
		
		gui2.mouse_pos.x, gui2.mouse_pos.y = surface.GetMousePos()

		gui2.world:Draw()
		if gui2.threedee then 
			surface.End3D()
		end
		
		do return end
		
		if not gui2.unrolled_draw then
			local str = {"local panels = gui2.panels"}
			
			local function add_children_to_list(parent, str, level)
				table.insert(str, ("%spanels[%i]:PreDraw()"):format((" "):rep(level), parent.i))
				for i, child in ipairs(parent:GetChildren()) do
					level = level + 1
					add_children_to_list(child, str, level) 
					level = level - 1
				end
				table.insert(str, ("%spanels[%i]:PostDraw()"):format((" "):rep(level), parent.i))
			end
		
			add_children_to_list(gui2.world, str, 0)
			str = table.concat(str, "\n")
			--print(str)			
			gui2.unrolled_draw = loadstring(str, "gui2_unrolled_draw")
		end
		
		gui2.unrolled_draw()
	end
end

function gui2.Initialize()
	local world = gui2.CreatePanel("base")

	world:SetPosition(Vec2(0, 0))
	world:SetSize(Vec2(window.GetSize()))
	world:SetCursor("arrow")
	world:SetTrapChildren(true)
	world:SetColor(Color(1,1,1,0))
	world:SetPadding(Rect(10, 10, 10, 10))

	gui2.world = world

	gui2.mouse_pos = Vec2()

	event.AddListener("Draw2D", "gui2", gui2.Draw2D)
	event.AddListener("MouseInput", "gui2", gui2.MouseInput)
	event.AddListener("KeyInputRepeat", "gui2", gui2.KeyInput)
	event.AddListener("CharInput", "gui2", gui2.CharInput)
end

include("base_panel.lua", gui2)
include("panels/*", gui2)

gui2.Initialize()

gui.SetCursor = function() end

return gui2
--for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end