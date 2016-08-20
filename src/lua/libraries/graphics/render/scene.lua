local render = (...) or _G.render

do -- current window
	system.current_window = system.current_window or NULL

	function render.SetWindow(window)
		window:MakeContextCurrent()

		system.current_window = window

		_G.window.wnd = window

		render.SetViewport(0, 0, window:GetSize():Unpack())
	end

	function render.GetWindow()
		return system.current_window
	end

	utility.MakePushPopFunction(render, "Window")

	function render.GetWidth()
		return system.current_window:GetSize().x
	end

	function render.GetHeight()
		return system.current_window:GetSize().y
	end

	function render.GetScreenSize()
		return system.current_window:GetSize()
	end
end

render.scene_3d = render.scene_3d or {}

function render.Draw3DScene(what, dist)
	--[[local cam_pos = render.camera_3d:GetPosition()

	table.sort(render.scene_3d, function(a, b)
		return
			a:GetComponent("transform"):GetPosition():Distance(cam_pos) <
			b:GetComponent("transform"):GetPosition():Distance(cam_pos)

	end)]]

	for _, model in ipairs(render.scene_3d) do
		model:Draw(what, dist)
	end
end

function render.Sort3DScene()
	local temp = {}
	for i, v in ipairs(render.scene_3d) do
		if v:GetComponent("model").sub_models[1] then
			local mat = v:GetComponent("model").sub_models[1].material
			for _, model in ipairs(v:GetComponent("model").sub_models) do
				if mat ~= model.material then
					mat = nil
					break
				end
				mat = model.material
			end
			if mat then
				temp[mat] = temp[mat] or {}
				table.insert(temp[mat], v)
			else
				temp.lol = temp.lol or {}
				table.insert(temp.lol, v)
			end
		else
			print(v, v:GetComponent("model").ModelPath)
		end
	end
	local sorted = {}
	local i = 1
	for _, group in pairs(temp) do
		for _,v in ipairs(group) do
			sorted[i] = v
			i = i + 1
		end
	end
	render.scene_3d = sorted
	--for i,v in ipairs(sorted) do
	--	print(v:GetComponent("model").sub_models[1].material)
	--end
end

function render.DrawScene(skip_2d)
	render.GetScreenFrameBuffer():Begin()

	if render.IsGBufferReady() then
		render.DrawGBuffer()
	end

	if not skip_2d and surface.IsReady() then
		surface.Start()

		surface.SetColor(1,1,1,1)
		render.SetDepth(false)
		render.SetBlendMode("alpha")
		render.SetShaderOverride()

		if render.IsGBufferReady() then
			if menu and menu.IsVisible() then
				surface.PushHSV(1,0,1)
			end

			surface.SetTexture(render.GetFinalGBufferTexture())
			surface.DrawRect(0, 0, surface.GetSize())

			if menu and menu.IsVisible() then
				surface.PopHSV()
			end

			if render.debug then
				render.DrawGBufferDebugOverlay()
			end
		end

		event.Call("Draw2D", system.GetFrameTime())

		surface.End()

		event.Call("PostDrawScene")
	end

	render.GetScreenFrameBuffer():End()
end