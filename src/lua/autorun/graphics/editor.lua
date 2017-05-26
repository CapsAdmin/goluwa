editor = _G.editor or {}

local mctrl = {}

do -- PUT ME IN TRANSFORM
	mctrl.size = 1
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

	local function draw_line_to_box(origin, point, siz)
		siz = siz or 7
		gfx.DrawLine(origin.x, origin.y, point.x, point.y, 3)
		gfx.DrawCircle(point.x, point.y, siz, 2, 32)
	end

	local function draw_rotation_lines(pos, dir, dir2, r)
		local pr = math3d.WorldPositionToScreen(pos + dir * r * mctrl.angle_pos)
		local pra = math3d.WorldPositionToScreen(pos + dir * r * (mctrl.angle_pos * 0.9) + dir2*r*0.08)
		local prb = math3d.WorldPositionToScreen(pos + dir * r * (mctrl.angle_pos * 0.9) + dir2*r*-0.08)
		gfx.DrawLine(pr.x, pr.y, pra.x, pra.y, 3)
		gfx.DrawLine(pr.x, pr.y, prb.x, prb.y, 3)
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
				local localpos = math3d.LinePlaneIntersection(pos, camera.camera_3d:GetAngles():GetForward(), mouse_pos)

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
			local final = Quat(0,0,0,1)


			if axis == "x" then
				local localpos = math3d.LinePlaneIntersection(pos, right, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang.x = diffang.x + math.pi / 2
					diffang:Normalize()

					if diffang.y < 0 then
						diffang.x = -diffang.x + math.pi
					end

					final = QuatFromAxis(diffang.x, Vec3(1,0,0))
				end
			elseif axis == "y" then
				local localpos = math3d.LinePlaneIntersection(pos, up, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang.y = diffang.y + math.pi / 2
					diffang:Normalize()

					final = QuatFromAxis(diffang.y, Vec3(0,0,1))
				end
			elseif axis == "z" then
				local localpos = math3d.LinePlaneIntersection(pos, forward, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang.x = diffang.x + math.pi / 2
					diffang:Normalize()

					if diffang.y < 0 then
						diffang.x = -diffang.x - math.pi
					end

					diffang.x = diffang.x + math.pi/2

					final = QuatFromAxis(diffang.x, Vec3(0,-1,0))
				end
			end

			if final and final:IsValid() then
				target:SetRotation(final * rot)
			end

			--[[
			local vector_origin = Vec3(0,0,0)

			if axis == "x" then
				local localpos = math3d.LinePlaneIntersection(pos, right, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang:RotateAroundAxis(right, math.rad(180))

					local _, localang = math3d.WorldToLocal(vector_origin, diffang, vector_origin, ang)
					local _, newang = math3d.LocalToWorld(vector_origin, Ang3(math.normalizeangle(localang.x + localang.y), 0, 0), vector_origin, ang)

					final = newang
				end
			elseif axis == "y" then
				local localpos = math3d.LinePlaneIntersection(pos, up, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang:RotateAroundAxis(up, math.rad(90))

					local _, localang = math3d.WorldToLocal(vector_origin, diffang, vector_origin, ang)
					local _, newang = math3d.LocalToWorld(vector_origin, Ang3(0, math.normalizeangle(localang.x + localang.y), 0), vector_origin, ang)

					final = newang
				end
			elseif axis == "z" then
				local localpos = math3d.LinePlaneIntersection(pos, forward, mouse_pos)
				if localpos then
					local diffang = (pos - (localpos + pos)):GetAngles()
					diffang:RotateAroundAxis(forward, math.rad(-90))

					local _, localang = math3d.WorldToLocal(vector_origin, diffang, vector_origin, ang)
					local _, newang = math3d.LocalToWorld(vector_origin, Ang3(0, 0, math.normalizeangle(localang.x)), vector_origin, ang)

					final = newang
				end
			end

			if final and final:IsValid() then
				target:SetRotation(Quat():SetAngles(final))
			end
			]]
		end
	end

	function mctrl.Draw()
		local target = mctrl.target

		if not target:IsValid() or not target:HasComponent("transform") then return end

		local x, y = gfx.GetMousePosition()
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
				render2d.SetColor(ColorBytes(255, 200, 0, 255):Unpack())
			else
				render2d.SetColor(ColorBytes(255, 80, 80, 255):Unpack())
			end
			draw_line_to_box(o, (math3d.WorldPositionToScreen(pos + forward * r)))
			draw_rotation_lines(pos, forward, up, r)


			if mctrl.grab.axis == "y" or mctrl.grab.axis == "view" then
				render2d.SetColor(ColorBytes(255, 200, 0, 255):Unpack())
			else
				render2d.SetColor(ColorBytes(80, 255, 80, 255):Unpack())
			end
			draw_line_to_box(o, (math3d.WorldPositionToScreen(pos + right * r)))
			draw_rotation_lines(pos, right, forward, r)

			if mctrl.grab.axis == "z" or mctrl.grab.axis == "view" then
				render2d.SetColor(ColorBytes(255, 200, 0, 255):Unpack())
			else
				render2d.SetColor(ColorBytes(80, 80, 255, 255):Unpack())
			end
			draw_line_to_box(o, (math3d.WorldPositionToScreen(pos + up * r)))
			draw_rotation_lines(pos, up, right, r)

			render2d.SetColor(ColorBytes(255, 200, 0, 255):Unpack())
			gfx.DrawCircle(o.x, o.y, 4, 2, 32)
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

		local x, y = gfx.GetMousePosition()
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
				break
			end
		end

		if axis then
			mctrl.grab.mode = "move"
			mctrl.grab.axis = axis
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
				break
			end
		end

		if axis then
			mctrl.grab.mode = "rotate"
			mctrl.grab.axis = axis
		end
	end

	_G.mctrl = mctrl
end

editor.frame = editor.frame or NULL
editor.tree = editor.tree or NULL
editor.properties = editor.properties or NULL
editor.selected_ent = editor.selected_ent or NULL
editor.prev_selected_ent = editor.prev_selected_ent or NULL

local function get_save_menu(ent)
	return
	L"save",
	{
		{
			L"auto load",
			function()
				serializer.WriteFile("luadata", "data/saved/autoload.tbl", ent:GetStorableTable())
			end,
			editor.frame:GetSkin().icons.transmit_go,
		},
		{},
		{
			L"new file",
			function()
				gui.StringInput(L"filename", L"filename", ent:GetName(), function(name)
					serializer.WriteFile("luadata", "data/saved/" .. name .. ".tbl", ent:GetStorableTable())
				end)
			end,
			editor.frame:GetSkin().icons.save,
		},
		{},
		(function()
			local out = {}
			for file_name in vfs.Iterate("saved/") do
				table.insert(out, {file_name:gsub("%.tbl", ""), function()
					serializer.WriteFile("luadata", "data/saved/" .. file_name, ent:GetStorableTable())
				end})
			end
			return unpack(out)
		end)()
	},
	editor.frame:GetSkin().icons.save
end

local function get_load_menu(ent)
	return
	L"load",
	{
		(function()
			function editor.GetSavedFiles(where)
				where = where or "saved/"
				local out = {}
				for file_name in vfs.Iterate(where) do
					local path = where .. file_name

					if vfs.IsFile(path) and file_name:endswith(".tbl") then
						local tbl = serializer.ReadFile("luadata", where .. file_name)
						if tbl then
							table.insert(out, {
								is_file = true,
								name = file_name:gsub("%.tbl", ""),
								path = path,
								ent_tbl = tbl,
							})
						end
					else
						table.insert(out, {
							name = file_name,
							is_dir = true,
							files = editor.GetSavedFiles(path .. "/"),
							path = path,
						})
					end
				end
				return out
			end

			local function populate(files)
				local out = {}
				for _, v in ipairs(files) do
					if v.is_file then
						if v.name == "autoload" then
							table.insert(out, 1, {L"auto load", function()
								ent:SetStorableTable(v.ent_tbl)
							end, editor.frame:GetSkin().icons.transmit_go})
							table.insert(out, 2, {})
						else
							local config = prototype.GetConfigurations()[v.ent_tbl.config]

							table.insert(out, {v.name, function()
								ent:SetStorableTable(v.ent_tbl)
							end, config.icon})
						end
					else
						table.insert(out, {v.name, populate(v.files), editor.frame:GetSkin().icons.load})
					end
				end
				return out
			end

			return unpack(populate(editor.GetSavedFiles(path)))
		end)()
	},
	editor.frame:GetSkin().icons.load
end

function editor.Open()
	if not render3d.gbuffer:IsValid() then
		render3d.Initialize()
		local data = serializer.ReadFile("luadata", "saved/autoload.tbl")
		if data then
			entities.GetWorld():SetStorableTable(data)
		end
	end

	gui.RemovePanel(editor.frame)

	local frame = gui.CreatePanel("frame")
	frame:SetWidth(300)
	frame:SetTitle(L"editor")
	frame:SetIcon(frame:GetSkin().icons.application_edit)
	frame:CallOnRemove(function() frame.UGH = true editor.Close() end)
	editor.frame = frame

	local menu_bar = gui.CreateMenuBar({
		{
			name = "file",
			options = {
				{
					get_save_menu(entities.GetWorld())
				},
				{
					get_load_menu(entities.GetWorld())
				},
				--[[{
					L"wear",
					function() end,
					frame:GetSkin().icons.transmit,
				},
				{
					L"clear",
					{
						{
							L"ok",
							function() entities.Panic() end,
							frame:GetSkin().icons.cross,
						}
					},
					frame:GetSkin().icons.cross,
				},]]
				{},
				--[[{
					L"help",
					function() end,
					frame:GetSkin().icons.information,
				},
				{
					L"about",
					function() end,
					frame:GetSkin().icons.star,
				},]]
				{
					L"exit",
					function() editor.Close() end,
					frame:GetSkin().icons.cancel,
				},
			},
		},
		{
			name = "view",
			options = {
				{
					L"hide editor",
					function() editor.Toggle() end,
				},
				{
					L"camera follow",
					function() end,
				},
				{
					L"reset view position",
					function() camera.camera_3d:SetPosition(Vec3(0,0,0)) end,
				},
			},
		}
	}, frame)

	menu_bar:SetHeight(25)
	menu_bar:SetStyle("frame")
	menu_bar:SetupLayout("top", "fill_x")


	local div = gui.CreatePanel("divider", frame)
	div:SetupLayout("fill")
	div:SetHideDivider(true)

	editor.top_scroll = div:SetTop(gui.CreatePanel("scroll"))
	editor.bottom_scroll = div:SetBottom(gui.CreatePanel("scroll"))

	local tree

	local function right_click_node(node)
		if node then tree:SelectNode(node) end

		local options = {}

		local function add(...)
			table.insert(options, {...})
		end

		local clipboard = serializer.Decode("luadata", window.GetClipboard(), true)
		if not clipboard.config or not clipboard.self or not clipboard.self.GUID then clipboard = nil end

		--add("wear", nil, frame:GetSkin().icons.wear)

		if node then
			add(L"copy", function()
				window.SetClipboard(assert(serializer.Encode("luadata", node.ent:GetStorableTable())))
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
					camera.camera_3d:SetPosition(node.ent:GetPosition())
				end, "textures/silkicons/brick_go.png")
			end
			add()
		end



		local groups = {}

		for config_name, info in pairs(prototype.GetConfigurations()) do
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
						ent:SetPosition(camera.camera_3d:GetPosition())
					end
					if ent.SetModelPath then
						ent:SetModelPath(ent:GetModelPath())

						local mat = render.CreateMaterial("model")
						mat:SetAlbedoTexture(render.GetWhiteTexture())
						mat:SetRoughnessTexture(render.GetWhiteTexture())
						mat:SetMetallicTexture(render.GetWhiteTexture())
						mat:SetRoughnessMultiplier(0)
						mat:SetMetallicMultiplier(1)
						ent:SetMaterialOverride(mat)
					end
				end, info.icon})
			end
			add(L(group_name), tbl, group.icon) -- FIX ME
		end

		add()

		add(get_save_menu(editor.selected_ent))
		add(get_load_menu(editor.selected_ent))

		if clipboard then
			add(L("add") .. " " .. ((clipboard.self.Name and clipboard.self.Name ~= "" and clipboard.self.Name) or clipboard.config), function()
				local ent = entities.CreateEntity(clipboard.config)
				ent:SetStorableTable(clipboard)
			end, frame:GetSkin().icons.add)
		end

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
		for _, ent in pairs(entities) do
			if not ent:GetHideFromEditor() then
				local name = ent:GetEditorName()

				if name == "" then
					name = ent.config
				end
				local node = node:AddNode(name, ent:GetPropertyIcon())
				node.OnRightClick = right_click_node
				--node.OnMouseHoverTrigger = show_tooltip
				node.ent = ent
				ent.editor_node = node

				--node:SetIcon(render.CreateTextureFromPath("textures/" .. frame:GetSkin().icons[val.self.ClassName]))
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
		for _, v in pairs(entities.GetAll()) do
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

			properties:AddGroup(L("entity"))
			properties:AddPropertiesFromObject(node.ent)

			local found_anything = false

			for _, v in pairs(node.ent:GetComponents()) do
				if next(prototype.GetStorableVariables(v)) then
					properties:AddGroup(L(v.ClassName))
					properties:AddPropertiesFromObject(v)
					found_anything = true
				end
			end

			editor.bottom_scroll:SetPanel(properties)
			editor.properties = properties

			editor.SelectEntity(node.ent, false)
		end

		tree.OnNodeDrop = function(_, node, dropped_node, drop_pos)
			if dropped_node.ent then
				node.ent:AddChild(dropped_node.ent)
				repopulate()
			end
		end

		editor.tree = tree

		if editor.selected_ent:IsValid() then
			editor.SelectEntity(editor.selected_ent)
		elseif editor.prev_selected_ent:IsValid() then
			editor.SelectEntity(editor.prev_selected_ent)
		elseif tree:GetChildren()[1] then
			tree:SelectNode(tree:GetChildren()[1])
		end
	end

	--editor.top_scroll.OnRightClick = function() right_click_node() end

	event.AddListener("EntityCreated", "editor", function() event.Delay(0, function() repopulate() end, "editor_repopulate_hack", frame) end)
	event.AddListener("EntityRemoved", "editor", function() event.Delay(0, function() repopulate() end, "editor_repopulate_hack", frame) end)
	event.AddListener("MouseInput", "editor", mctrl.MouseInput)
	event.AddListener("PreDrawGUI", "editor", mctrl.Draw)
	event.AddListener("GUIObjectPropertyChanged", "editor", function(obj, val, info)
		if info.var_name == "Name" and obj.editor_node then
			if val == "" then
				obj.editor_node:SetText(obj:GetEditorName())
			else
				obj.editor_node:SetText(val)
			end
		end
	end)
	repopulate()

	tree:SetSize(tree:GetSizeOfChildren())
	tree:SetWidth(frame:GetWidth()-20)

	frame.OnRightClick = function() right_click_node() end

	div:SetDividerPosition(gui.world:GetHeight()/2)

	window.SetMouseTrapped(false)

	frame:SetY(50)
	frame:MoveLeft()
	frame:FillY()
end

function editor.Close()
	if not editor.frame.UGH then
		gui.RemovePanel(editor.frame)
	end
	window.SetMouseTrapped(false)

	event.RemoveListener("EntityCreated", "editor")
	event.RemoveListener("EntityRemoved", "editor")
	event.RemoveListener("MouseInput", "editor")
	event.RemoveListener("PreDrawGUI", "editor")
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

function editor.SelectEntity(ent, update_editor)
	event.Call("EditorSelectEentity", ent)
	if editor.prev_selected_ent ~= editor.selected_ent and editor.selected_ent:IsValid() then
		editor.prev_selected_ent = editor.selected_ent
	end
	editor.selected_ent = ent
	mctrl.target = ent

	if
		update_editor == false or
		not editor.frame:IsValid()
	then
		return
	end

	for i, v in ipairs(editor.tree:GetChildren()) do
		if v.ent == ent then
			editor.tree:SelectNode(v)
			return v
		end
	end
end

input.Bind("e+left_control", "toggle_editor")

commands.Add("close_editor", editor.Close)
commands.Add("toggle_editor", editor.Toggle)
commands.Add("open_editor", editor.Open)

if RELOAD then
	editor.Close()
	editor.Open()
end