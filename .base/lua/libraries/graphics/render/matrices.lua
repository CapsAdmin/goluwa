local gl = require("libraries.ffi.opengl") -- OpenGL
local render = (...) or _G.render

do -- camera
	render.camera = render.camera or {
		x = 0,
		y = 0,
		
		-- if this is defined here it will be "1000" in Update and other events
		--w = 1000,
		--h = 1000,
		
		pos = Vec3(0,0,0),
		ang = Ang3(0,0,0),
		
		pos2d = Vec2(0,0),
		ang2d = 0,
		zoom2d = 1,
		
		fov = 75,
		farz = 32000,
		nearz = 0.1,
		
		ratio = 1,
	}

	function render.SetCameraPosition(pos)
		render.camera.pos = pos
		render.SetupView3D()
	end

	function render.GetCameraPosition()
		return render.camera.pos
	end

	function render.SetCameraAngles(ang)
		render.camera.ang = ang
		render.SetupView3D()
	end

	function render.GetCameraAngles()
		return render.camera.ang
	end

	function render.GetCameraForward()
		return render.camera.ang:GetUp()
	end

	function render.SetCameraFOV(fov)
		render.camera.fov = fov
	end

	function render.GetCameraFOV()
		return render.camera.fov
	end
	
	render.SetGlobalShaderVariable("g_screen_size", function() return Vec2(render.camera.w, render.camera.h) end, "vec2")

	render.SetGlobalShaderVariable("g_cam_nearz", function() return render.camera.nearz end, "float")
	render.SetGlobalShaderVariable("g_cam_farz", function() return render.camera.farz end, "float")
end

function render.SetViewport(x, y, w, h)	
	render.camera.x = x or render.camera.x
	render.camera.y = y or render.camera.y
	render.camera.w = w or render.camera.w
	render.camera.h = h or render.camera.h
	
	gl.Viewport(render.camera.x, render.camera.y, render.camera.w, render.camera.h)
	gl.Scissor(render.camera.x, render.camera.y, render.camera.w, render.camera.h)
	render.SetupProjection2D()
end

do
	local stack = {}
	
	function render.PushViewport(x, y, w, h)
		table.insert(stack, {render.camera.x, render.camera.y, render.camera.w, render.camera.h})
				
		render.SetViewport(x, y, w, h)
	end
	
	function render.PopViewport()
		render.SetViewport(unpack(table.remove(stack)))
	end
end

do -- orthographic / 2d
	function render.SetupProjection2D(w, h)
		render.camera.w = w or render.camera.w
		render.camera.h = h or render.camera.h
		render.camera.ratio = render.camera.w / render.camera.h 

		local proj = render.matrices.projection
		proj:LoadIdentity()
		proj:Ortho(0, render.camera.w, render.camera.h, 0, -1, 1)
		
		render.InvalidateMatrices("projection")
	end

	function render.SetupView2D(pos, ang, zoom)
		render.camera.pos2d = pos or render.camera.pos2d
		render.camera.ang2d = ang or render.camera.ang2d
		render.camera.zoom2d = zoom or render.camera.zoom2d
		
		local view = render.matrices.view 
		view:LoadIdentity()		
			
		local x, y = render.camera.w/2, render.camera.h/2
		view:Translate(x, y, 0)
		view:Rotate(render.camera.ang2d, 0, 0, 1)
		view:Translate(-x, -y, 0)
		
		view:Translate(render.camera.pos2d.x, render.camera.pos2d.y, 0)
		
		local x, y = render.camera.w/2, render.camera.h/2
		view:Translate(x, y, 0)
		view:Scale(render.camera.zoom2d, render.camera.zoom2d, 1)
		view:Translate(-x, -y, 0)
		
		render.InvalidateMatrices("view")
	end

	function render.Start2D(x, y, w, h)
		render.camera.x = x or render.camera.x 
		render.camera.y = y or render.camera.y
		render.camera.w = w or render.camera.w
		render.camera.h = h or render.camera.h
		
		--render.PushViewport(render.camera.x, render.camera.y, render.camera.w, render.camera.h)
		
		render.SetupProjection2D()
		render.SetupView2D()
		render.PushWorldMatrix()
		
		render.InvalidateMatrices(true)
		render.render_mode = "2d"
	end
	
	function render.End2D()	
		render.PopWorldMatrix()
		--render.PopViewport()
		
		render.InvalidateMatrices(true)
	end
end

do -- projection / 3d
	function render.SetupProjection3D(fov, nearz, farz, ratio)
		render.camera.fov = fov or render.camera.fov
		render.camera.nearz = nearz or render.camera.nearz
		render.camera.farz = farz or render.camera.farz
		render.camera.ratio = ratio or render.camera.ratio
		
		local proj = render.matrices.projection
		proj:LoadIdentity()
		proj:Perspective(render.camera.fov, render.camera.farz, render.camera.nearz, render.camera.ratio) 
		
		render.InvalidateMatrices("projection")
	end

	function render.SetupView3D(pos, ang)
		render.camera.pos = pos or render.camera.pos
		render.camera.ang = ang or render.camera.ang
		
		local view = render.matrices.view 
		view:LoadIdentity()		
		
		-- source engine style camera angles
		view:Rotate(render.camera.ang.r, 0, 0, 1)
		view:Rotate(render.camera.ang.p + math.pi/2, 1, 0, 0)
		view:Rotate(render.camera.ang.y, 0, 0, 1)

		view:Translate(render.camera.pos.y, render.camera.pos.x, render.camera.pos.z)
		
		render.InvalidateMatrices("view")
	end
	
	function render.Start3D(pos, ang, fov, nearz, farz)				
		render.camera.pos = pos or render.camera.pos
		render.camera.ang = ang or render.camera.ang
		render.camera.fov = fov or render.camera.fov
		render.camera.nearz = nearz or render.camera.nearz
		render.camera.farz = farz or render.camera.farz
		
		render.SetupProjection3D()
		render.SetupView3D()		
		render.PushWorldMatrix()
		
		render.InvalidateMatrices(true)
		render.render_mode = "3d"
	end
	
	event.AddListener("GBufferInitialized", "reset_camera_projection", function()
		last_fov = nil
		last_nearz = nil
		last_farz = nil	
	end)
	
	function render.End3D()
		render.PopWorldMatrix()
		render.InvalidateMatrices(true)
	end
end

do -- 2d in 3d
	function render.Start3D2DEx(pos, ang, scale)	
		local w, h = render.GetHeight(), render.GetHeight()
		
		pos = pos or Vec3(0, 0, 0)
		ang = ang or Ang3(0, 0, 0)
		scale = scale or Vec3(4, 4 * (w / h), 1)
		
		render.is_3d2d = true
		
		render.SetupProjection3D()
		render.SetupView3D()
		render.PushWorldMatrixEx(pos, ang, Vec3(scale.x / w, scale.y / h, 1))
	end

	function render.Start3D2D(mat, dont_multiply)
		render.is_3d2d = true
		
		render.SetupProjection3D()	
		render.SetupView3D()
		render.PushWorldMatrix(mat, dont_multiply)
	end

	function render.End3D2D()
		render.PopWorldMatrix()	
		render.is_3d2d = false
	end

	function render.ScreenToWorld(x, y)
		if render.is_3d2d then
			x = ((x / render.GetWidth()) - 0.5) * 2
			y = ((y / render.GetHeight()) - 0.5) * 2
			
			local m = render.GetViewWorldInverseMatrix()
			
			cursor_x, cursor_y, cursor_z = m:TransformVector(render.GetProjectionInverseMatrix():TransformVector(x, -y, 1))
			local camera_x, camera_y, camera_z = m:TransformVector(0, 0, 0)

			--local intersect = camera + ( camera.z / ( camera.z - cursor.z ) ) * ( cursor - camera )
			
			local z = camera_z / ( camera_z - cursor_z )
			local intersect_x = camera_x + z * ( cursor_x - camera_x )
			local intersect_y = camera_y + z * ( cursor_y - camera_y )
					
			return intersect_x, intersect_y
		else
			render.InvalidateMatrices(true) 
			local x, y = (render.GetViewMatrix() * render.GetWorldMatrix():GetInverse()):TransformVector(x, y, 1)
			return x, y
		end
	end
end

do -- world / model
	do -- push pop helper
		local stack = render.matrix_stack or {}
		local i = #stack + 1
		
		render.matrix_stack = stack
		
		function render.PushWorldMatrixEx(pos, ang, scale, dont_multiply)
			if not stack[i] then
				stack[i] = render.matrices.world or Matrix44()
			end
			
			stack[i] = render.matrices.world
		
			if dont_multiply then	
				render.matrices.world = Matrix44()
			else				
				render.matrices.world = stack[i]:Copy()
			end
						
			-- source engine style world orientation
			if pos then
				render.Translate(-pos.y, -pos.x, -pos.z) -- Vec3(left/right, back/forth, down/up)	
			end
			
			if ang then
				render.Rotate(-ang.y, 0, 0, 1)
				render.Rotate(-ang.r, 0, 1, 0)
				render.Rotate(-ang.p, 1, 0, 0) 
			end
			
			if scale then 
				render.Scale(scale.x, scale.y, scale.z) 
			end
	
			i = i + 1
			
			render.InvalidateMatrices("world")
			
			return render.matrices.world
		end
		
		function render.PushWorldMatrix(mat, dont_multiply)
			if not stack[i] then
				stack[i] = Matrix44()
			else
				stack[i] = render.matrices.world
			end

			if dont_multiply then	
				if mat then
					render.matrices.world = mat
				else
					render.matrices.world = Matrix44()
				end
			else
				if mat then
					render.matrices.world = stack[i] * mat
				else
					render.matrices.world = stack[i]:Copy()
				end
			end
			
			i = i + 1
			
			render.InvalidateMatrices("world")
			
			return render.matrices.world
		end
		
		function render.PopWorldMatrix()
			i = i - 1
			
			if i < 1 then
				error("stack underflow", 2)
			end
						
			render.matrices.world = stack[i]
			
			render.InvalidateMatrices("world")
		end
	end

	-- world matrix helper functions
	function render.Translate(x, y, z)
		render.matrices.world:Translate(x, y, z)
		render.InvalidateMatrices("world")
	end
	
	function render.Rotate(a, x, y, z)
		render.matrices.world:Rotate(a, x, y, z)
		render.InvalidateMatrices("world")
	end
	
	function render.Scale(x, y, z)
		render.matrices.world:Scale(x, y, z)
		render.InvalidateMatrices("world")
	end
	
	function render.LoadIdentity()
		render.matrices.world:LoadIdentity()
		render.InvalidateMatrices("world")
	end	
end

do -- pre multiplied matrices
	render.matrices = render.matrices or {
		projection = Matrix44(),
		projection_inverse = Matrix44(),
		
		view = Matrix44(),
		view_inverse = Matrix44(),
		
		projection_view = Matrix44(),
		projection_view_inverse = Matrix44(),
		
		
		world = Matrix44(),
		world_inverse = Matrix44(),
		
		view_world = Matrix44(),
		view_world_inverse = Matrix44(),
		
		projection_view_world = Matrix44(),	
	}
	
	local invalidate = true

	function render.RebuildMatrices(now)
		if now then render.InvalidateMatrices(true) end
		
		if invalidate then
			
			if invalidate == true or invalidate == "projection" or invalidate == "view" then
				render.matrices.projection_view = render.matrices.view * render.matrices.projection
				render.matrices.projection_view_inverse = render.matrices.projection_view:GetInverse()
				
				render.matrices.view_inverse = render.matrices.view:GetInverse()
			end
			
			if invalidate == true or invalidate == "view" or invalidate == "world" then
				render.matrices.view_world =  render.matrices.world * render.matrices.view		
				render.matrices.view_world_inverse = render.matrices.view_world:GetInverse()
			end
			
			if invalidate == true or invalidate == "world" then
				render.matrices.world_inverse = render.matrices.world:GetInverse()
			end
			
			render.matrices.projection_view_world = render.matrices.world * render.matrices.view * render.matrices.projection
			
			invalidate = false
		end
	end

	function render.InvalidateMatrices(type)
		if invalidate then invalidate = true return end -- todo
		invalidate = type or true
	end
		
	function render.SetWorldMatrix(mat)
		render.matrices.world = mat
		render.InvalidateMatrices("world")
	end

	function render.SetViewMatrix(mat)
		render.matrices.view = mat
		render.InvalidateMatrices("view")
	end

	function render.SetProjectionMatrix(mat)
		render.matrices.projection = mat
		render.InvalidateMatrices("projection")
	end

	for k, v in pairs(render.matrices) do
		local name = "Get" .. ("_" .. k):gsub("_(.)", string.upper) .. "Matrix"
		render[name] = function()
			render.RebuildMatrices()
			return render.matrices[k]
		end
	end
	
	render.SetGlobalShaderVariable("g_projection", render.GetProjectionMatrix, "mat4")
	render.SetGlobalShaderVariable("g_projection_inverse", render.GetProjectionInverseMatrix, "mat4")

	render.SetGlobalShaderVariable("g_view", render.GetViewMatrix, "mat4")
	render.SetGlobalShaderVariable("g_view_inverse", render.GetViewInverseMatrix, "mat4")

	render.SetGlobalShaderVariable("g_world", render.GetWorldMatrix, "mat4")
	render.SetGlobalShaderVariable("g_world_inverse", render.GetWorldInverseMatrix, "mat4")

	render.SetGlobalShaderVariable("g_projection_view", render.GetProjectionViewMatrix, "mat4")
	render.SetGlobalShaderVariable("g_projection_view_inverse", render.GetProjectionViewInverseMatrix, "mat4")

	render.SetGlobalShaderVariable("g_view_world", render.GetViewWorldMatrix, "mat4")
	render.SetGlobalShaderVariable("g_view_world_inverse", render.GetViewWorldInverseMatrix, "mat4")
	render.SetGlobalShaderVariable("g_projection_view_world", render.GetProjectionViewWorldMatrix, "mat4")

	render.SetGlobalShaderVariable("g_normal_matrix", function() return (render.matrices.world * render.matrices.view):GetInverse():GetTranspose() end, "mat4")
end

render.AddGlobalShaderCode([[
float get_depth(vec2 uv) 
{
	return (2.0 * g_cam_nearz) / (g_cam_farz + g_cam_nearz - texture(tex_depth, uv).r * (g_cam_farz - g_cam_nearz));
}]], "get_noise")

-- lol

--[[
Shader Inputs
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)
uniform float     iChannelTime[4];       // channel playback time (in seconds)
uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
uniform vec4      iDate;                 // (year, month, day, time in seconds)
uniform float     iSampleRate;           // sound sample rate (i.e., 44100)]]

render.SetGlobalShaderVariable("iResolution", function() return Vec2(render.camera.w, render.camera.h, render.camera.ratio) end, "vec3")
render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")
render.SetGlobalShaderVariable("iMouse", function() return Vec2(surface.GetMousePosition()) end, "float")
render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")
