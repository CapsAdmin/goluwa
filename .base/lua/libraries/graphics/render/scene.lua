local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

do -- current window
	render.current_window = NULL

	local last_w
	local last_h

	function render.SetWindow(window)
		window:MakeContextCurrent()
			
		render.current_window = window
		local w, h = window:GetSize():Unpack()
		render.w = w
		render.h = h
		
		render.SetViewport(0, 0, w, h)
	end
	
	function render.GetWindow()
		return render.current_window
	end

	function render.SwapBuffers()		
		if render.current_window:IsValid() then
			render.current_window:SwapBuffers()
		end
	end

	utility.MakePushPopFunction(render, "Window", render.SetWindow, render.GetWindow, reset)
	
	function render.GetWidth()
		if render.current_window:IsValid() then
			return render.current_window:GetSize().w
		end
		
		return 0
	end

	function render.GetHeight()
		if render.current_window:IsValid() then
			return render.current_window:GetSize().h
		end
		
		return 0
	end
	
	function render.GetScreenSize()
		return Vec2(render.GetWidth(), render.GetHeight())
	end
end

render.scene_3d = render.scene_3d or {}

function render.Draw3DScene()
	--[[local cam_pos = render.camera_3d:GetPosition()
	
	table.sort(render.scene_3d, function(a, b)
		return 
			a:GetComponent("transform"):GetPosition():Distance(cam_pos) <
			b:GetComponent("transform"):GetPosition():Distance(cam_pos)
			
	end)]]
	
	--render.SetCullMode("none")
	
	for i, model in ipairs(render.scene_3d) do
		model:Draw()
	end
end

console.CreateVariable("render_accum", 0)
local deferred = console.CreateVariable("render_deferred", true, "whether or not deferred rendering is enabled.")

function render.DrawScene(window, dt)
	render.delta = dt
	render.Clear(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT)
	render.PushWindow(window)
	
	if deferred:Get() and render.IsGBufferReady() then
		render.DrawGBuffer(dt, window:GetSize():Unpack())
	else
		render.EnableDepth(true)
		render.SetBlendMode("alpha")	
		render.SetCullMode("back")

		render.Draw3DScene()
	end
	
	render.EnableDepth(false)	
	render.SetBlendMode("alpha")	
	render.SetCullMode("back")
	
	event.Call("Draw2D", dt)
	
	local blur_amt = console.GetVariable("render_accum") or 0
	if blur_amt ~= 0 then			
		gl.Accum(gl.e.GL_ACCUM, 1)
		gl.Accum(gl.e.GL_RETURN, 1-blur_amt)
		gl.Accum(gl.e.GL_MULT, blur_amt)
	end
	
	event.Call("PostDrawScene")
	
	render.SwapBuffers()
	render.PopWindow()
end