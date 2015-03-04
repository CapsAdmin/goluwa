local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

render.matrices = {
	projection_3d = Matrix44(),
	projection_3d_inverse = Matrix44(),
	
	view_3d = Matrix44(),
	view_3d_inverse = Matrix44(),
	
	vp_matrix = Matrix44(),
	vp_3d_inverse = Matrix44(),
	
	world = Matrix44(),
	
	projection_2d = Matrix44(),	
	view_2d = Matrix44(),
	view_2d_inverse = Matrix44(),
}

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

local cam = render.camera

-- useful for shaders
function render.GetCameraPosition()
	return cam.pos
end

function render.GetCameraAngles()
	return cam.ang
end

function render.GetCameraFOV()
	return cam.fov
end

-- projection  
do
	-- this isn't really matrix related..
	function render.SetViewport(x, y, w, h)	
		cam.x = x or cam.x
		cam.y = y or cam.y
		cam.w = w or cam.w
		cam.h = h or cam.h
		
		cam.ratio = cam.w / cam.h 
	
		gl.Viewport(cam.x, cam.y, cam.w, cam.h)
		gl.Scissor(cam.x, cam.y, cam.w, cam.h)
		
		local proj = render.matrices.projection_2d

		proj:LoadIdentity()
		proj:Ortho(0, cam.w, cam.h, 0, -1, 1)
	end
	
	do
		local stack = {}
		
		function render.PushViewport(x, y, w, h)
			table.insert(stack, {cam.x, cam.y, cam.w, cam.h})
					
			render.SetViewport(x, y, w, h)
		end
		
		function render.PopViewport()
			render.SetViewport(unpack(table.remove(stack)))
		end
	end

	function render.Start2D(x, y, w, h)				
		render.PushWorldMatrix()
		
		x = x or cam.x 
		y = y or cam.y
		w = w or cam.w
		h = h or cam.h
		
		render.Translate(x, y, 0)
		
		cam.x = x 
		cam.y = y
		cam.w = w
		cam.h = h
		
		gl.Disable(gl.e.GL_DEPTH_TEST)				
	end
	
	function render.End2D()	
		render.PopWorldMatrix()
	--	render.PopViewport() 
	end
	
	local last_farz
	local last_nearz
	local last_fov
	local last_ratio
		
	function render.Start3D(pos, ang, fov, nearz, farz)				
		cam.fov = fov or cam.fov
		cam.nearz = nearz or cam.nearz
		cam.farz = farz or cam.farz
				
		if 
			last_fov ~= cam.fov or
			last_nearz ~= cam.nearz or
			last_farz ~= cam.farz
		then
			local proj = render.matrices.projection_3d
		
			proj:LoadIdentity()
			proj:Perspective(cam.fov, cam.farz, cam.nearz, cam.ratio) 
			--proj:OpenGLFunc("Perspective", cam.fov, cam.nearz, cam.farz, cam.ratio)
			
			last_fov = cam.fov
			last_nearz = cam.nearz
			last_farz = cam.farz
			
			render.matrices.projection_3d_inverse = proj:GetInverse()
		end
		
		if pos and ang then
			render.SetupView3D(pos, ang, fov)
		end
				
		gl.Enable(gl.e.GL_DEPTH_TEST) 
		
		render.PushWorldMatrix()
	end
	
	event.AddListener("GBufferInitialized", "reset_camera_projection", function()
		last_fov = nil
		last_nearz = nil
		last_farz = nil	
	end)
	
	function render.End3D()
		render.PopWorldMatrix()
	end		
end

function render.SetupView3D(pos, ang, fov, out)
	cam.pos = pos or cam.pos
	cam.ang = ang or cam.ang
	cam.fov = fov or cam.fov
	
	local view = out or render.matrices.view_3d 
	view:LoadIdentity()		
	
	if ang then
		-- source engine style camera angles
		view:Rotate(ang.r, 0, 0, 1)
		view:Rotate(ang.p + math.pi/2, 1, 0, 0)
		view:Rotate(ang.y, 0, 0, 1)
	end
	
	if pos then
		view:Translate(pos.y, pos.x, pos.z)
	end
	
	if out then return out end
	
	render.matrices.vp_matrix = render.matrices.view_3d * render.matrices.projection_3d
	render.matrices.vp_3d_inverse = render.matrices.vp_matrix:GetInverse()
	render.matrices.view_3d_inverse = render.matrices.view_3d:GetInverse()
end

function render.SetCameraPosition(pos)
	cam.pos = pos
	render.SetupView3D(cam.pos, cam.ang)
end

function render.GetCameraPosition()
	return cam.pos
end

function render.SetCameraAngles(ang)
	cam.ang = ang
	render.SetupView3D(cam.pos, cam.ang)
end

function render.GetCameraAngles()
	return cam.ang
end

function render.SetCameraFOV(fov)
	cam.fov = fov
end

function render.GetCameraFOV()
	return cam.fov
end
  

function render.SetupView2D(pos, ang, zoom)
	cam.pos2d = pos or cam.pos2d
	cam.ang2d = ang or cam.ang2d
	cam.zoom2d = zoom or cam.zoom2d
	
	local view = render.matrices.view_2d 
	view:LoadIdentity()		
		
	if ang then
		local x, y = cam.w/2, cam.h/2
		view:Translate(x, y, 0)
		view:Rotate(ang, 0, 0, 1)
		view:Translate(-x, -y, 0)
	end
	
	if pos then
		view:Translate(pos.x, pos.y, 0)
	end
	
	if zoom then
		local x, y = cam.w/2, cam.h/2
		view:Translate(x, y, 0)
		view:Scale(zoom, zoom, 1)
		view:Translate(-x, -y, 0)
	end
	
	render.matrices.view_2d_inverse = view:GetInverse()
end

-- world
do
	do -- push pop helper
		local stack = {}
		local i = 1
		
		function render.PushWorldMatrixEx(pos, ang, scale, dont_multiply)
			if not stack[i] then
				stack[i] = Matrix44()
			else
				stack[i] = render.matrices.world
			end
			
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
			
			return render.matrices.world
		end
		
		function render.PopWorldMatrix()
			i = i - 1
			
			if i < 1 then
				error("stack underflow", 2)
			end
						
			render.matrices.world = stack[i]
		end
		
		render.matrix_stack = stack
	end
	
	function render.SetWorldMatrixOverride(matrix)
		render.matrices.world_override = matrix
	end
	
	-- world matrix helper functions
	function render.Translate(x, y, z)
		render.matrices.world:Translate(x, y, z)
	end
	
	function render.Rotate(a, x, y, z)
		render.matrices.world:Rotate(a, x, y, z)
	end
	
	function render.Scale(x, y, z)
		render.matrices.world:Scale(x, y, z)
	end
	
	function render.LoadIdentity()
		render.matrices.world:LoadIdentity()
	end	
end  

function render.GetProjectionViewWorld2DMatrix()
	return (render.matrices.world_override or render.matrices.world) * render.matrices.view_2d * render.matrices.projection_2d
end

function render.GetProjectionViewWorld3DMatrix()
	return (render.matrices.world_override or render.matrices.world) * render.matrices.view_3d * render.matrices.projection_3d
end

render.SetGlobalShaderVariable("g_screen_size", function() return Vec2(cam.w, cam.h) end, "vec2")

render.SetGlobalShaderVariable("g_projection", function() return render.matrices.projection_3d end, "mat4")
render.SetGlobalShaderVariable("g_projection_inverse", function() return render.matrices.projection_3d_inverse end, "mat4")

render.SetGlobalShaderVariable("g_view", function() return render.matrices.view_3d end, "mat4")
render.SetGlobalShaderVariable("g_view_inverse", function() return render.matrices.view_3d_inverse end, "mat4")

render.SetGlobalShaderVariable("g_world", function() return render.matrices.world_override and render.matrices.world_override or render.matrices.world end, "mat4")
render.SetGlobalShaderVariable("g_world_inverse", function() return (render.matrices.world_override and render.matrices.world_override or render.matrices.world):GetInverse() end, "mat4")

render.SetGlobalShaderVariable("g_projection_view", function() return render.matrices.vp_matrix end, "mat4")
render.SetGlobalShaderVariable("g_projection_view_inverse", function() return render.matrices.vp_3d_inverse end, "mat4")

render.SetGlobalShaderVariable("g_normal_matrix", function() return ((render.matrices.world_override and render.matrices.world_override or render.matrices.world) * render.matrices.view_3d):GetInverse():GetTranspose() end, "mat4")
render.SetGlobalShaderVariable("g_view_world", function() return (render.matrices.world_override and render.matrices.world_override or render.matrices.world) * render.matrices.view_3d end, "mat4")
render.SetGlobalShaderVariable("g_view_world_inverse", function() return ((render.matrices.world_override and render.matrices.world_override or render.matrices.world) * render.matrices.view_3d):GetInverse() end, "mat4")
render.SetGlobalShaderVariable("g_projection_view_world", render.GetProjectionViewWorld3DMatrix, "mat4")

render.SetGlobalShaderVariable("g_cam_nearz", function() return cam.nearz end, "float")
render.SetGlobalShaderVariable("g_cam_farz", function() return cam.farz end, "float")

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

render.SetGlobalShaderVariable("iResolution", function() return Vec2(cam.w, cam.h, cam.ratio) end, "vec3")
render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")
render.SetGlobalShaderVariable("iMouse", function() return Vec2(surface.GetMousePosition()) end, "float")
render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")
