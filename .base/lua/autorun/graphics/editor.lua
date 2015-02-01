editor = _G.editor or {}

local mctrl = {}

do -- PUT ME IN TRANSFORM
	local vector_origin = Vec3()

	mctrl.AXIS_X = 1
	mctrl.AXIS_Y = 2
	mctrl.AXIS_Z = 3
	mctrl.AXIS_VIEW = 4
	mctrl.MODE_MOVE = 1
	mctrl.MODE_ROTATE = 2
	mctrl.MODE_SCALE = 3

	local AXIS_X, AXIS_Y, AXIS_Z, AXIS_VIEW = mctrl.AXIS_X, mctrl.AXIS_Y, mctrl.AXIS_Z, mctrl.AXIS_VIEW
	local MODE_MOVE, MODE_ROTATE, MODE_SCALE = mctrl.MODE_MOVE, mctrl.MODE_ROTATE, mctrl.MODE_SCALE

	mctrl.scale = 2
	mctrl.grab_dist = 15
	mctrl.angle_pos = 0.5
	mctrl.scale_pos = 0.25

	mctrl.grab = {mode = nil, axis = nil}
	mctrl.target = NULL

	local function get_axes(ang)
		return ang:GetForward(),
			ang:GetRight(),
			ang:GetUp()
	end
	
	local function get_target_position(pos, ang) 
		return (utility.WorldToLocal(pos, ang, mctrl.target:GetPosition(), mctrl.target:GetAngles()))
	end

	local function get_target_angles(pos, ang) 
		return select(2, utility.WorldToLocal(pos, ang, mctrl.target:GetPosition(), mctrl.target:GetAngles()))
	end

	function mctrl.Move(axis, x, y)
		local target = mctrl.target
		if target:IsValid() then
		
			local pos, ang = mctrl.target:GetPosition(), mctrl.target:GetAngles()
			local forward, right, up = get_axes(ang)
			local final
					
			if axis == AXIS_X then
				local pos = utility.PointToAxis(pos, right, x, y):Unpack()
				local localpos = utility.LinePlaneIntersection(pos, right, x, y)
				
				if localpos then
					final = get_target_position(localpos:GetDot(forward)*forward - forward*mctrl.scale, ang)
				end
			elseif axis == AXIS_Y then
				local x, y = utility.PointToAxis(pos, right, x, y):Unpack()
				local localpos = utility.LinePlaneIntersection(pos, forward, x, y)

				if localpos then
					final = get_target_position(localpos:GetDot(right)*right - right*mctrl.scale, ang)
				end
			elseif axis == AXIS_Z then
				local x, y = utility.PointToAxis(pos, up, x, y):Unpack()
				local localpos = utility.LinePlaneIntersection(pos, forward, x, y) or utility.LinePlaneIntersection(pos, right, x, y)

				if localpos then
					final = get_target_position(localpos:GetDot(up)*up - up*mctrl.scale, ang)
				end
			elseif axis == AXIS_VIEW then
				local localpos = utility.LinePlaneIntersection(pos, render.GetCameraAngles():GetForward(), x, y)
				
				if localpos then
					final = get_target_position(localpos, ang)
				end
			end
					
			if final then
				target:SetPosition(final)
			end
		end
	end

	function mctrl.Scale(axis, x, y) 
		local target = mctrl.target
		if target:IsValid() then
		
			local target = mctrl.target
			local pos, ang = mctrl.target:GetPosition(), mctrl.target:GetAngles()
			local forward, right, up = get_axes(ang)
			local final
			
			if axis == AXIS_X then
				local x, y = utility.PointToAxis(pos, forward, x, y):Unpack()
				local localpos = utility.LinePlaneIntersection(pos, right, x, y)

				if localpos then
					final = get_target_position(pos + localpos:GetDot(forward)*forward - forward*mctrl.scale, ang)
				end
			elseif axis == AXIS_Y then
				local x, y = utility.PointToAxis(pos, right, x, y):Unpack()
				local localpos = utility.LinePlaneIntersection(pos, forward, x, y)

				if localpos then
					final = get_target_position(pos + localpos:GetDot(right)*right - right*mctrl.scale, ang)
				end
			elseif axis == AXIS_Z then
				local x, y = utility.PointToAxis(pos, up, x, y):Unpack()
				local localpos = utility.LinePlaneIntersection(pos, forward, x, y) or utility.LinePlaneIntersection(pos, right, x, y)

				if localpos then
					final = get_target_position(pos + localpos:GetDot(up)*up - up*mctrl.scale, ang)
				end
			end
			
			if final then
				target:SetScale(final)
			end
		end
	end

	function mctrl.Rotate(axis, x, y)
		local target = mctrl.target
		if target:IsValid() then
			
			local pos, ang = mctrl.target:GetPosition(), mctrl.target:GetAngles()
			local forward, right, up = get_axes(ang) 
			local final
			
			if axis == AXIS_X then
				local localpos = utility.LinePlaneIntersection(pos, right, x, y)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang:RotateAroundAxis(right, math.rad(180))

					local  _, localang = utility.WorldToLocal(vector_origin, diffang, vector_origin, ang)
					local _, newang = utility.LocalToWorld(vector_origin, Ang3(math.normalizeangle(localang.p + localang.y), 0, 0), vector_origin, ang)
					final = get_target_angles(vector_origin, newang)
				end
			elseif axis == AXIS_Y then
				local localpos = utility.LinePlaneIntersection(pos, up, x, y)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang:RotateAroundAxis(up, math.rad(90))

					local _, localang = utility.WorldToLocal(vector_origin, diffang, vector_origin, ang)
					local _, newang = utility.LocalToWorld(vector_origin, Ang3(0, math.normalizeangle(localang.p + localang.y), 0), vector_origin, ang)

					final = get_target_angles(vector_origin, newang)
				end
			elseif axis == AXIS_Z then
				local localpos = utility.LinePlaneIntersection(pos, forward, x, y)
				
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang:RotateAroundAxis(forward, math.rad(-90))

					local _, localang = utility.WorldToLocal(vector_origin, diffang, vector_origin, ang)
					local _, newang = utility.LocalToWorld(vector_origin, Ang3(0, 0, math.normalizeangle(localang.p)), vector_origin, ang)

					final = get_target_angles(vector_origin, newang)
				end
			end
			
			if final then
				target:SetRotation(Quat():SetAngles(final))
			end
		end
	end

	function mctrl.MouseInput(key, press)
		if not key == "button_1" then return end
			
		if not press then
			mctrl.grab.mode = nil
			mctrl.grab.axis = nil
			return
		end
		
		local target = mctrl.target
		if not target:IsValid() or not target:HasComponent("transform") then return end
		
		local x, y = surface.GetMousePosition()
		local pos, ang = mctrl.target:GetPosition(), mctrl.target:GetAngles()
		
		local forward, right, up = get_axes(ang)
		local r = mctrl.scale

		-- Movement
		local axis
		local dist = mctrl.grab_dist

		for i, v in pairs
			{
				[AXIS_X] = utility.WorldPositionToScreen(pos + forward * r),
				[AXIS_Y] = utility.WorldPositionToScreen(pos + right * r),
				[AXIS_Z] = utility.WorldPositionToScreen(pos + up * r),
				[AXIS_VIEW] = utility.WorldPositionToScreen(pos)
			}
		do
			local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
			if d <= dist then
				axis = i
				dist = d
			end
		end

		if axis then
			mctrl.grab.mode = MODE_MOVE
			mctrl.grab.axis = axis
			return true
		end

		-- Scale
		local axis
		local dist = mctrl.grab_dist

		for i, v in pairs
			{
				[AXIS_X] = utility.WorldPositionToScreen(pos + forward * r * mctrl.scale_pos),
				[AXIS_Y] = utility.WorldPositionToScreen(pos + right * r * mctrl.scale_pos),
				[AXIS_Z] = utility.WorldPositionToScreen(pos + up * r * mctrl.scale_pos)
			}
		do
			local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
			if d <= dist then
				axis = i
				dist = d
			end
		end

		if axis then
			mctrl.grab.mode = MODE_SCALE
			mctrl.grab.axis = axis
			return true
		end

		-- Rotation
		local axis
		local dist = mctrl.grab_dist
		for i, v in pairs
			{
				[AXIS_X] = utility.WorldPositionToScreen(pos + forward * r * mctrl.angle_pos),
				[AXIS_Y] = utility.WorldPositionToScreen(pos + right * r * mctrl.angle_pos),
				[AXIS_Z] = utility.WorldPositionToScreen(pos + up * r * mctrl.angle_pos)
			}
		do
			local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
			if d <= dist then
				axis = i
				dist = d
			end
		end

		if axis then
			mctrl.grab.mode = MODE_ROTATE
			mctrl.grab.axis = axis
			return true
		end
	end

	local function draw_line_to_box(origin, point, siz)
		siz = siz or 7
		surface.DrawLine(origin.x, origin.y, point.x, point.y)
		surface.DrawCircle(point.x, point.y, siz, 2, 32)
	end

	local function draw_rotation_lines(pos, dir, dir2, r)
		local pr = utility.WorldPositionToScreen(pos + dir * r * mctrl.angle_pos)
		local pra = utility.WorldPositionToScreen(pos + dir * r * (mctrl.angle_pos * 0.9) + dir2*r*0.08)
		local prb = utility.WorldPositionToScreen(pos + dir * r * (mctrl.angle_pos * 0.9) + dir2*r*-0.08)
		surface.DrawLine(pr.x, pr.y, pra.x, pra.y)
		surface.DrawLine(pr.x, pr.y, prb.x, prb.y)
	end

	function mctrl.Draw()
		local target = mctrl.target
		
		if not target:IsValid() or not target:HasComponent("transform") then return end

		local x, y = surface.GetMousePosition()
		if mctrl.grab.axis and mctrl.grab.mode == MODE_MOVE then
			mctrl.Move(mctrl.grab.axis, x, y)
		elseif mctrl.grab.axis and mctrl.grab.mode == MODE_SCALE then
			mctrl.Scale(mctrl.grab.axis, x, y)
		elseif mctrl.grab.axis and mctrl.grab.mode == MODE_ROTATE then
			mctrl.Rotate(mctrl.grab.axis, x, y)
		end

		local pos, ang = mctrl.target:GetPosition(), mctrl.target:GetAngles()

		local forward, right, up = get_axes(ang)

		local r = mctrl.scale
		local o, visible = utility.WorldPositionToScreen(pos)

		if visible > 0 then
			if mctrl.grab.axis == AXIS_X or mctrl.grab.axis == AXIS_VIEW then
				surface.SetColor(ColorBytes(255, 200, 0, 255))
			else
				surface.SetColor(ColorBytes(255, 80, 80, 255))
			end
			draw_line_to_box(o, (utility.WorldPositionToScreen(pos + forward * r)))
			draw_line_to_box(o, utility.WorldPositionToScreen(pos + forward * r * mctrl.scale_pos), 8)
			draw_rotation_lines(pos, forward, up, r)


			if mctrl.grab.axis == AXIS_Y or mctrl.grab.axis == AXIS_VIEW then
				surface.SetColor(ColorBytes(255, 200, 0, 255))
			else
				surface.SetColor(ColorBytes(80, 255, 80, 255))
			end
			draw_line_to_box(o, (utility.WorldPositionToScreen(pos + right * r)))
			draw_line_to_box(o, utility.WorldPositionToScreen(pos + right * r * mctrl.scale_pos), 8)
			draw_rotation_lines(pos, right, forward, r)

			if mctrl.grab.axis == AXIS_Z or mctrl.grab.axis == AXIS_VIEW then
				surface.SetColor(ColorBytes(255, 200, 0, 255))
			else
				surface.SetColor(ColorBytes(80, 80, 255, 255))
			end
			draw_line_to_box(o, (utility.WorldPositionToScreen(pos + up * r)))
			draw_line_to_box(o, utility.WorldPositionToScreen(pos + up * r * mctrl.scale_pos), 8)
			draw_rotation_lines(pos, up, right, r)

			surface.SetColor(ColorBytes(255, 200, 0, 255))
			surface.DrawCircle(o.x, o.y, 4, 2, 32)
		end
	end
end

editor.frame = editor.frame or NULL
editor.tree = editor.tree or NULL
editor.properties = editor.properties or NULL
editor.selected_ent = editor.selected_ent or NULL

function editor.Open()
	gui.RemovePanel(editor.frame)
	
	local frame = gui.CreatePanel("frame")
	frame:SetWidth(300)
	frame:SetTitle(L"editor")
	frame:SetupLayout("left", "fill_y")
	editor.frame = frame
	
	local div = gui.CreatePanel("divider", frame)
	div:SetupLayout("fill_x", "fill_y")
	div:SetHideDivider(true)
	
	editor.top_scroll = div:SetTop(gui.CreatePanel("scroll"))
	editor.bottom_scroll = div:SetBottom(gui.CreatePanel("scroll"))
	
	local tree
	
	local function show_tooltip(node, entered, x, y)
		local ent = node.ent
		
		if entered then
			local tooltip = gui.CreatePanel("text_button")
			tooltip:SetPosition(Vec2(surface.GetMousePosition()))
			tooltip:SetMargin(Rect()+4)
			tooltip:SetText(ent:GetDebugTrace())
			tooltip:SizeToText()
			tooltip:Layout(true)
			node.tooltip = tooltip
		else
			gui.RemovePanel(node.tooltip)
		end
	end
		
	local function right_click_node(node)
		if node then tree:SelectNode(node) end
		
		local options = {}
		
		local function add(...)
			table.insert(options, {...})
		end
		
		--add("wear", nil, frame:GetSkin().icons.wear)
		
		if node then
			add(L"copy", function()
				system.SetClipboard(assert(serializer.Encode("luadata", node.ent:GetStorableTable())))
			end, frame:GetSkin().icons.copy)
			add(L"paste", function()
				node.ent:SetStorableTable(assert(serializer.Decode("luadata", system.GetClipboard())))
			end, frame:GetSkin().icons.paste)
			add(L"clone", function()
				local ent = entities.CreateEntity(node.ent.config)
				ent:SetParent(node.ent:GetParent())
				ent:SetStorableTable(node.ent:GetStorableTable())
			end, frame:GetSkin().icons.clone)
			
			if node.ent:HasComponent("transform") then
				add(L"goto", function()
					render.SetCameraPosition(node.ent:GetPosition())
				end, "textures/silkicons/brick_go.png")
			end
		end
		
		add()
		
		
		local groups = {}
		
		for config_name, info in pairs(prototype.GetConfigurations()) do
			local group
			
			local meta = #info.components == 1 and prototype.GetRegistered("component", info.components[1])
			
			if meta and meta.Base then		
				groups[meta.Base] = groups[meta.Base] or {configs = {}}
				groups[meta.Base].configs[config_name] = info
			else			
				groups.default = groups.default or {configs = {}}
				groups.default.configs[config_name] = info
			end
		end
				
		for group_name, group in pairs(groups) do
			local tbl = {}
			for config_name, info in pairs(group.configs) do		
				table.insert(tbl, {L(info.name), function() 
					local ent = entities.CreateEntity(config_name, node and node.ent) 
					if ent.SetPosition then 
						ent:SetPosition(render.GetCameraPosition())
					end
				end, info.icon})				
			end
			add(L(group_name), tbl, group.icon) -- FIX ME
		end
	
		add()
		--add("help", nil, frame:GetSkin().icons.help)
		add(L"save", nil, frame:GetSkin().icons.save)
		add(L"load", nil, frame:GetSkin().icons.load)
		
		if node then
			add()
			add(L"remove", function() 
				local node = tree:GetSelectedNode()
				if node:IsValid() and node.ent:IsValid() then
					node.ent:Remove()
				end
			end, frame:GetSkin().icons.clear)
		end
		
		gui.CreateMenu(options, frame)
	end
	
	local function fill(entities, node)
		for key, ent in pairs(entities) do
			if not ent:GetHideFromEditor() then
				local name = ent:GetName()
				if name == "" then
					name = ent.config
				end
				local node = node:AddNode(name, ent:GetPropertyIcon())
				node.OnRightClick = right_click_node
				--node.OnMouseHoverTrigger = show_tooltip
				node.ent = ent
				ent.editor_node = node
				--node:SetIcon(Texture("textures/" .. frame:GetSkin().icons[val.self.ClassName]))
				fill(ent:GetChildren(), node)
			end
		end  
	end
	
	local function repopulate()
		if not frame:IsValid() then return end
				
		gui.RemovePanel(tree)
		
		tree = gui.CreatePanel("tree")
		editor.top_scroll:SetPanel(tree)
		
		local ents = {}
		for k,v in pairs(entities.GetAll()) do
			if not v:HasParent() then 
				table.insert(ents, v) 
			end 
		end
		fill(ents, tree)
		tree:SetSize(tree:GetSizeOfChildren())
		tree:SetWidth(frame:GetWidth())
		
		editor.top_scroll:SetAlwaysReceiveMouseInput(true)
		
		tree.OnNodeSelect = function(_, node)
			gui.RemovePanel(editor.properties)
			
			local properties = gui.CreatePanel("properties")
			
			local found_anything = false
			
			for k, v in pairs(node.ent:GetComponents()) do
				if next(prototype.GetStorableVariables(v)) then
					properties:AddGroup(L(v.ClassName))
					properties:AddPropertiesFromObject(v)
					found_anything = true
				end
			end
			
			editor.bottom_scroll:SetPanel(properties)
			
			editor.properties = properties
			
			event.Call("EditorSelectEentity", node.ent)
			editor.selected_ent = node.ent
			mctrl.target = node.ent
		end
		
		editor.tree = tree
	end
	
	--editor.top_scroll.OnRightClick = function() right_click_node() end
	
	event.AddListener("EntityCreate", "editor", function() event.Delay(0.1, repopulate) end)
	event.AddListener("EntityRemoved", "editor", repopulate)	
	event.AddListener("MouseInput", "editor", mctrl.MouseInput)	
	event.AddListener("PreDrawMenu", "editor", mctrl.Draw)	
	repopulate()
	
	tree:SetSize(tree:GetSizeOfChildren())
	tree:SetWidth(frame:GetWidth()-20)
	
	frame.OnRightClick = function() right_click_node() end
	
	div:SetDividerPosition(gui.world:GetHeight()/2) 
	
	if editor.selected_ent:IsValid() then
		editor.SelectEntity(editor.selected_ent)
	elseif tree:GetChildren()[1] then 
		tree:SelectNode(tree:GetChildren()[1])
	end
		
	window.SetMouseTrapped(false) 
end

function editor.Close()
	gui.RemovePanel(editor.frame)
	window.SetMouseTrapped(false) 
end

function editor.Toggle()
	if editor.frame:IsValid() then
		if editor.frame:IsMinimized() then
			editor.frame:Minimize(false)
			window.SetMouseTrapped(true)
		else
			editor.frame:Minimize(true)
			window.SetMouseTrapped(false) 
		end
	else
		editor.Open()
	end
end

function editor.SelectEntity(ent)
	editor.selected_ent = ent

	if not editor.frame:IsValid() then return end
	
	for i, v in ipairs(editor.tree:GetChildren()) do
		if v.ent == ent then
			editor.tree:SelectNode(v)
			return v
		end
	end
end

input.Bind("e+left_control", "toggle_editor")

console.AddCommand("close_editor", editor.Close)
console.AddCommand("toggle_editor", editor.Toggle)
console.AddCommand("open_editor", editor.Open)