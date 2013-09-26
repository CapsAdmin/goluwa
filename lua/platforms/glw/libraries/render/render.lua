render = render or {}

render.top_left = true

function render.Initialize(w, h, window)		
	check(w, "number")
	check(h, "number")
	
	window = window or render.CreateWindow(w, h)
	
	render.current_window = NULL 
	render.frame = 0
	
	render.w = w
	render.h = h
	
	gl.Enable(e.GL_BLEND)
	gl.Enable(e.GL_TEXTURE_2D)

	gl.Enable(e.GL_CULL_FACE)
	
	gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
	gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_FILL)
	
	gl.Disable(e.GL_DEPTH_TEST)
	gl.CullFace(e.GL_BACK)
	
	render.SetClearColor(0.25, 0.25, 0.25, 0.5)
	
	render.CreateMatrices()
	
	if surface then
		surface.Initialize()
	end
			
	event.Call("RenderContextInitialized")
	
	return window
end

function render.Shutdown()
end

function render.Start(window)
	glfw.MakeContextCurrent(window.__ptr)
	
	render.current_window = window
	local w, h = window:GetSize():Unpack()
	render.w = w
	render.h = h
	render.SetViewport(0, 0, w, h)
end

function render.End()
	if render.current_window:IsValid() then
		glfw.SwapBuffers(render.current_window.__ptr)
	end
	gl.Flush()
	render.frame = render.frame + 1
end

function render.GetScreenSize()
	if render.current_window:IsValid() then
		return render.current_window:GetSize():Unpack()
	end
	
	return 0, 0
end


do
	local major = ffi.new("int[1]")
	local minor = ffi.new("int[1]")
	
	function render.GetVersion()		

		gl.GetIntegerv(33307, major)
		gl.GetIntegerv(33308, minor)
		
		return major[0] .. "." .. minor[0]
	end
end

function render.SetClearColor(r,g,b,a)
	gl.ClearColor(r,g,b, a or 1)
end

function render.Clear(flag, ...)
	flag = flag or e.GL_COLOR_BUFFER_BIT
	gl.Clear(bit.bor(flag, ...))
end

function render.ScissorRect(x, y, w, h)
	if not x then
		gl.Disable(e.GL_SCISSOR_TEST)
	else
		gl.Scissor(x, y, w, h)
		gl.Enable(e.GL_SCISSOR_TEST)
	end
end

do
	local data = ffi.new("float[3]")

	function render.ReadPixels(x, y, w, h)
		w = w or 1
		h = h or 1
		
		gl.ReadPixels(x, y, w, h, e.GL_RGBA, e.GL_FLOAT, data)
			
		return data[0], data[1], data[2], data[3]
	end
end