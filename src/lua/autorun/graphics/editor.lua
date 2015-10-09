editor = _G.editor or {}

local mctrl = {}

do -- PUT ME IN TRANSFORM
	mctrl.size = 2
	mctrl.grab_dist = 15
	mctrl.angle_pos = 0.5

	mctrl.grab = {mode = nil, axis = nil}
	mctrl.target = NULL

	local function get_axes(ang)
		return
			ang:GetForward(),
			-ang:GetRight(),
			ang:GetUp()
	end

	local function get_draw_position()
		return mctrl.target:GetTRPosition(), mctrl.target:GetRotation():GetAngles("yzx")
	end

	local function get_target_pos_ang(pos, ang)
		local parent = mctrl.target:GetParent()

		if parent:IsValid() and parent:HasComponent("transform") then
			--return math3d.WorldToLocal(pos, ang, parent:GetTRPosition(), parent:GetTRAngles())
		end

		return pos, ang
	end

	local function get_target_position(pos, ang)
		return (get_target_pos_ang(pos, ang))
	end

	local function get_target_angles(pos, ang)
		return select(2, get_target_pos_ang(pos, ang))
	end

	local function draw_line_to_box(origin, point, siz)
		siz = siz or 7
		surface.DrawLine(origin.x, origin.y, point.x, point.y, 3)
		surface.DrawCircle(point.x, point.y, siz, 2, 32)
	end

	local function draw_rotation_lines(pos, dir, dir2, r)
		local pr = math3d.WorldPositionToScreen(pos + dir * r * mctrl.angle_pos)
		local pra = math3d.WorldPositionToScreen(pos + dir * r * (mctrl.angle_pos * 0.9) + dir2*r*0.08)
		local prb = math3d.WorldPositionToScreen(pos + dir * r * (mctrl.angle_pos * 0.9) + dir2*r*-0.08)
		surface.DrawLine(pr.x, pr.y, pra.x, pra.y, 3)
		surface.DrawLine(pr.x, pr.y, prb.x, prb.y, 3)
	end

	function mctrl.Move(axis, mouse_pos)
		local target = mctrl.target
		if target:IsValid() then
			local pos, ang = get_draw_position()
			local forward, right, up = get_axes(ang)
			local final

			if axis == "x" then
				local screen_pos = math3d.PointToAxis(pos, forward, mouse_pos)
				local localpos = math3d.LinePlaneIntersection(pos, right, screen_pos)

				if localpos then
					final = get_target_position(pos + localpos:GetDot(forward)*forward - forward*mctrl.size, ang)
				end
			elseif axis == "y" then
				local screen_pos = math3d.PointToAxis(pos, right, mouse_pos)
				local localpos = math3d.LinePlaneIntersection(pos, forward, screen_pos)

				if localpos then
					final = get_target_position(pos + localpos:GetDot(right)*right - right*mctrl.size, ang)
				end
			elseif axis == "z" then
				local screen_pos = math3d.PointToAxis(pos, up, mouse_pos)
				local localpos = math3d.LinePlaneIntersection(pos, forward, screen_pos) or math3d.LinePlaneIntersection(pos, right, screen_pos)

				if localpos then
					final = get_target_position(pos + localpos:GetDot(up)*up - up*mctrl.size, ang)
				end
			elseif axis == "view" then
				local localpos = math3d.LinePlaneIntersection(pos, render.camera_3d:GetAngles():GetForward(), mouse_pos)

				if localpos then
					final = get_target_position(pos + localpos, ang)
				end
			end

			if final then
				if input.IsKeyDown("left_shift") then
					mctrl.temp_scale = mctrl.temp_scale or target:GetScale()
					mctrl.temp_scale_offset = mctrl.temp_scale_offset or final
					target:SetScale(mctrl.temp_scale + (final - mctrl.temp_scale_offset))
				else
					mctrl.temp_scale = nil
					target:SetPosition(final)
				end
			end
		end
	end

	function mctrl.Rotate(axis, mouse_pos)
		local target = mctrl.target
		if target:IsValid() then

			local pos, ang = get_draw_position()
			local rot = mctrl.target:GetRotation():Copy()
			local forward, right, up = get_axes(ang)
			local final

			if axis == "x" then
				local localpos = math3d.LinePlaneIntersection(pos, right, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang.x = diffang.x + math.pi / 2
					diffang:Normalize()

					if diffang.y < 0 then
						diffang.x = -diffang.x + math.pi
					end

					rot:SetAxis(diffang.x, Vec3(1,0,0))
					final = rot
				end
			elseif axis == "y" then
				local localpos = math3d.LinePlaneIntersection(pos, up, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang.y = diffang.y + (math.pi / 2)
					diffang:Normalize()
					print(diffang)
					if diffang.y < math.pi then
						--diffang.y = diffang.y
					end

					rot:SetAxis(diffang.y, Vec3(0,0,-1))
					final = rot
				end
			elseif axis == "z" then
				local localpos = math3d.LinePlaneIntersection(pos, forward, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang.x = diffang.x - math.pi / 2
					diffang:Normalize()

					if diffang.x < 0 then
						diffang.x = -diffang.x + math.pi
					end

					diffang:RotateAroundAxis(forward, math.rad(-90))
					rot:SetAxis(diffang.x, Vec3(0,-1,0))
					final = rot
				end
			end

			if final and final:IsValid() then
				target:SetRotation(final)
			end
		end
	end

	function mctrl.Draw()
		local target = mctrl.target

		if not target:IsValid() or not target:HasComponent("transform") then return end

		local x, y = surface.GetMousePosition()
		if mctrl.grab.axis and mctrl.grab.mode == "move" then
			mctrl.Move(mctrl.grab.axis, Vec2(x, y))
		elseif mctrl.grab.axis and mctrl.grab.mode == "rotate" then
			mctrl.Rotate(mctrl.grab.axis, Vec2(x, y))
		end

		local pos, ang = get_draw_position()

		local forward, right, up = get_axes(ang)

		local r = mctrl.size
		local o, visible = math3d.WorldPositionToScreen(pos)

		if visible > 0 then
			if mctrl.grab.axis == "x" or mctrl.grab.axis == "view" then
				surface.SetColor(ColorBytes(255, 200, 0, 255))
			else
				surface.SetColor(ColorBytes(255, 80, 80, 255))
			end
			draw_line_to_box(o, (math3d.WorldPositionToScreen(pos + forward * r)))
			draw_rotation_lines(pos, forward, up, r)


			if mctrl.grab.axis == "y" or mctrl.grab.axis == "view" then
				surface.SetColor(ColorBytes(255, 200, 0, 255))
			else
				surface.SetColor(ColorBytes(80, 255, 80, 255))
			end
			draw_line_to_box(o, (math3d.WorldPositionToScreen(pos + right * r)))
			draw_rotation_lines(pos, right, forward, r)

			if mctrl.grab.axis == "z" or mctrl.grab.axis == "view" then
				surface.SetColor(ColorBytes(255, 200, 0, 255))
			else
				surface.SetColor(ColorBytes(80, 80, 255, 255))
			end
			draw_line_to_box(o, (math3d.WorldPositionToScreen(pos + up * r)))
			draw_rotation_lines(pos, up, right, r)

			surface.SetColor(ColorBytes(255, 200, 0, 255))
			surface.DrawCircle(o.x, o.y, 4, 2, 32)
		end
	end

	function mctrl.MouseInput(key, press)
		if not key == "button_1" then return end

		if not press then
			mctrl.grab.mode = nil
			mctrl.grab.axis = nil
			mctrl.temp_scale_offset = nil
			mctrl.temp_scale = nil
			return
		end

		local target = mctrl.target
		if not target:IsValid() or not target:HasComponent("transform") then return end

		local x, y = surface.GetMousePosition()
		local pos, ang = get_draw_position()

		local forward, right, up = get_axes(ang)
		local r = mctrl.size

		-- Movement
		local axis
		local dist = mctrl.grab_dist

		for k, v in pairs
			{
				x = math3d.WorldPositionToScreen(pos + forward * r),
				y = math3d.WorldPositionToScreen(pos + right * r),
				z = math3d.WorldPositionToScreen(pos + up * r),
				view = math3d.WorldPositionToScreen(pos)
			}
		do
			local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
			if d <= dist then
				axis = k
				dist = d
			end
		end

		if axis then
			mctrl.grab.mode = "move"
			mctrl.grab.axis = axis
			return true
		end

		-- Rotation
		local axis
		local dist = mctrl.grab_dist
		for k, v in pairs({
			x = math3d.WorldPositionToScreen(pos + forward * r * mctrl.angle_pos),
			y = math3d.WorldPositionToScreen(pos + right * r * mctrl.angle_pos),
			z = math3d.WorldPositionToScreen(pos + up * r * mctrl.angle_pos)
		}) do
			local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
			if d <= dist then
				axis = k
				dist = d
			end
		end

		if axis then
			mctrl.grab.mode = "rotate"
			mctrl.grab.axis = axis
			return true
		end
	end
end

editor.frame = editor.frame or NULL
editor.tree = editor.tree or NULL
editor.properties = editor.properties or NULL
editor.selected_ent = editor.selected_ent or NULL

function editor.Open()
	if not render.gbuffer:IsValid() then
		render.InitializeGBuffer()
		entities.GetWorld():SetStorableTable(serializer.ReadFile("luadata", "world.map"))
	end

	gui.RemovePanel(editor.frame)

	local frame = gui.CreatePanel("frame")
	frame:SetWidth(300)
	frame:SetTitle(L"editor")
	frame:SetIcon(frame:GetSkin().icons.application_edit)
	editor.frame = frame

	local div = gui.CreatePanel("divider", frame)
	div:SetupLayout("fill")
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

		local clipboard = serializer.Decode("luadata", system.GetClipboard(), true)
		if not clipboard.config or not clipboard.self or not clipboard.self.GUID then clipboard = nil end

		--add("wear", nil, frame:GetSkin().icons.wear)

		if node then
			add(L"copy", function()
				system.SetClipboard(assert(serializer.Encode("luadata", node.ent:GetStorableTable())))
			end, frame:GetSkin().icons.copy)
			if clipboard then
				add(L"paste", function()
					node.ent:SetStorableTable(clipboard)
				end, frame:GetSkin().icons.paste)
			end
			add(L"clone", function()
				local ent = entities.CreateEntity(node.ent.config)
				ent:SetParent(node.ent:GetParent())
				ent:SetStorableTable(node.ent:GetStorableTable())
			end, frame:GetSkin().icons.clone)

			if node.ent:HasComponent("transform") then
				add(L"goto", function()
					render.camera_3d:SetPosition(node.ent:GetPosition())
				end, "textures/silkicons/brick_go.png")
			end
			add()
		end



		local groups = {}

		for config_name, info in pairs(prototype.GetConfigurations()) do
			local group

			local meta = #info.components == 1 and prototype.GetRegistered("component", info.components[1])

			if meta and meta.Base then
				groups[meta.Base] = groups[meta.Base] or {configs = {}, icon = meta.Icon}
				groups[meta.Base].configs[config_name] = info
			else
				groups.default = groups.default or {configs = {}, icon = "textures/silkicons/shape_square.png"}
				groups.default.configs[config_name] = info
			end
		end

		for group_name, group in pairs(groups) do
			local tbl = {}
			for config_name, info in pairs(group.configs) do
				table.insert(tbl, {L(info.name), function()
					local ent = entities.CreateEntity(config_name, node and node.ent)
					if ent.SetPosition then
						ent:SetPosition(render.camera_3d:GetPosition())
					end
				end, info.icon})
			end
			add(L(group_name), tbl, group.icon) -- FIX ME
		end

		add()
		--add("help", nil, frame:GetSkin().icons.help)

		if clipboard then
			add(L("add") .. " " .. ((clipboard.self.Name and clipboard.self.Name ~= "" and clipboard.self.Name) or clipboard.config), function()
				local ent = entities.CreateEntity(clipboard.config)
				ent:SetStorableTable(clipboard)
			end, frame:GetSkin().icons.add)
		end

		add(L"save map", function()
			serializer.WriteFile("luadata", "world.map", entities.GetWorld():GetStorableTable())
		end, frame:GetSkin().icons.save)
		add(L"load map", function()
			entities.GetWorld():SetStorableTable(serializer.ReadFile("luadata", "world.map"))
		end, frame:GetSkin().icons.load)

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

		tree = frame:CreatePanel("tree")
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

			local properties = frame:CreatePanel("properties")

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

		tree.OnNodeDrop = function(_, node, dropped_node, drop_pos)
			node.ent:AddChild(dropped_node.ent)
			repopulate()
		end

		editor.tree = tree
	end

	--editor.top_scroll.OnRightClick = function() right_click_node() end

	event.AddListener("EntityCreated", "editor", function() event.Delay(0.1, function() repopulate() end, frame, "editor_repopulate_hack") end)
	event.AddListener("EntityRemoved", "editor", function() event.Delay(0.1, function() repopulate() end, frame, "editor_repopulate_hack") end)
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

	frame:SetY(500)
	frame:MoveLeft()
	frame:FillY()
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

if RELOAD then
	editor.Close()
	editor.Open()
end