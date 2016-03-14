local ffi = require("ffi")
local gl = require("libopengl") -- OpenGL
local render = (...) or _G.render

local severities = {
	[0x9146] = "important", -- high
	[0x9147] = "warning", -- medium
	[0x9148] = "notice", -- low
}

local sources = {
	[0x8246] = "api",
	[0x8247] = "window system",
	[0x8248] = "shader compiler",
	[0x8249] = "third party",
	[0x824A] = "application",
	[0x824B] = "other",
}

local types = {
	[0x824C] = "error",
	[0x824D] = "deprecated behavior",
	[0x824E] = "undefined behavior",
	[0x824F] = "portability",
	[0x8250] = "performance",
	[0x8251] = "other",
}

function render.StartDebug()
	if EXTERNAL_OPENGL_DEBUGGER then return end
	if render.verbose_debug then return end

	if window.IsExtensionSupported("GL_KHR_debug") then
		gl.Enable("GL_DEBUG_OUTPUT")
		gl.DebugMessageControl("GL_DONT_CARE", "GL_DONT_CARE", "GL_DONT_CARE", ffi.new("GLuint"), nil, true)
		gl.Enable("GL_DEBUG_OUTPUT_SYNCHRONOUS")
	else
		-- todo
	end
end

function render.StopDebug()
	if EXTERNAL_OPENGL_DEBUGGER then return end
	if render.verbose_debug then return end

	if window.IsExtensionSupported("GL_KHR_debug") then
		level = level or 0

		local buffer = ffi.new("char[1024]")
		local length = ffi.sizeof(buffer)

		local int = ffi.new("int[1]")
		gl.GetIntegerv("GL_DEBUG_LOGGED_MESSAGES", int)

		local message

		if int[0] ~= 0 then
			message = {}

			for i = 0, int[0] do
				local types = ffi.new("GLenum[1]")
				if gl.GetDebugMessageLog(1, length, nil, types, nil, nil, nil, buffer) ~= 0 and types[0] == gl.e.GL_DEBUG_TYPE_ERROR then
					local str = ffi.string(buffer)
					table.insert(message, str)
				end
			end

			message = table.concat(message, "\n")

			if message == "" then message = nil end
		end

		gl.Disable("GL_DEBUG_OUTPUT")

		return message
	else
		-- todo
	end
end

function render.EnableVerboseDebug(b)
	if window.IsExtensionSupported("GL_KHR_debug") then
		if b then
			gl.Enable("GL_DEBUG_OUTPUT")
			gl.DebugMessageControl("GL_DONT_CARE", "GL_DEBUG_TYPE_ERROR", "GL_DONT_CARE", ffi.new("GLuint"), nil, true)
			gl.Enable("GL_DEBUG_OUTPUT_SYNCHRONOUS")

			local buffer = ffi.new("char[1024]")
			local length = ffi.sizeof(buffer)

			debug.sethook(function()
				local info = debug.getinfo(2)
				if info.source:find("opengl", nil, true) then

					local logged_count = ffi.new("int[1]")
					gl.GetIntegerv("GL_DEBUG_LOGGED_MESSAGES", logged_count)

					if logged_count[0] ~= 0 then
						local info = debug.getinfo(3)
						local source = info.source:match(".+render/(.+)")

						local message

						for i = 0, logged_count[0] do
							local type = ffi.new("GLenum[1]")
							if gl.GetDebugMessageLog(1, length, nil, type, nil, nil, nil, buffer) ~= 0 then
								type = types[type[0]]
								if type ~= "other" then
									message = (message or "") .. "\t" .. type .. ": " .. ffi.string(buffer) .. "\n"
								end
							end
						end

						if message then
							logf("[render] %s:%i gl.%s:\n", source, info.currentline, info.name)
							logn(message)
						end
					end
				end
			end, "return")
			render.verbose_debug = true
		else
			gl.Disable("GL_DEBUG_OUTPUT")
			debug.sethook()
			render.verbose_debug = false
		end
	else
		logn("[render] glDebugMessageControl is not availible")
	end
end


do -- AUTOMATE THIS
	local size = 6
	local x,y,w,h,i

	function render.DrawGBufferDebugOverlay()
		w, h = surface.GetSize()
		w = w / size
		h = h / size

		x = 0
		y = 0
		i = 1

		local buffer_i = 1

		surface.SetFont("default")

		for _, pass in pairs(render.gbuffer_fill.Buffers) do
			local pass_name = pass.name

			for _, buffer in pairs(pass.layout) do
				for channel_name, str in pairs(buffer) do
					if channel_name ~= "format" then
						surface.mesh_2d_shader.color_override.r = 0
						surface.mesh_2d_shader.color_override.g = 0
						surface.mesh_2d_shader.color_override.b = 0
						surface.mesh_2d_shader.color_override.a = 0

						for _, color in ipairs({"r", "g", "b", "a"}) do
							if str:find(color) then
								surface.mesh_2d_shader.color_override[color] = 0
							else
								surface.mesh_2d_shader.color_override[color] = 1
							end
						end

						--print(i, channel_name, surface.mesh_2d_shader.color_override)

						surface.SetColor(0,0,0,1)
						surface.SetWhiteTexture()
						surface.DrawRect(x, y, w, h)

						surface.SetColor(1,1,1,1)
						surface.SetTexture(render.gbuffer:GetTexture("data"..buffer_i))
						surface.DrawRect(x, y, w, h)

						surface.mesh_2d_shader.color_override.r = 0
						surface.mesh_2d_shader.color_override.g = 0
						surface.mesh_2d_shader.color_override.b = 0
						surface.mesh_2d_shader.color_override.a = 0

						surface.SetTextPosition(x, y + 5)
						surface.DrawText(channel_name)

						if i%size == 0 then
							y = y + h
							x = 0
						else
							x = x + w
						end

						i = i  + 1
					end
				end
				buffer_i = buffer_i + 1
			end
		end

		do return end

		for _, data in pairs(render.gbuffer_buffers) do
			draw_buffer(data.name, render.gbuffer:GetTexture(data.name))
		end

		surface.SetColor(0,0,0,1)
		surface.SetTexture(tex)
		surface.DrawRect(x, y, w, h)
		surface.mesh_2d_shader.color_override.r = 1
		surface.mesh_2d_shader.color_override.g = 1
		surface.mesh_2d_shader.color_override.b = 1
		draw_buffer("self illumination", render.gbuffer:GetTexture("data3"))
		surface.mesh_2d_shader.color_override.r = 0
		surface.mesh_2d_shader.color_override.g = 0
		surface.mesh_2d_shader.color_override.b = 0

		surface.SetColor(0,0,0,1)
		surface.SetTexture(tex)
		surface.DrawRect(x, y, w, h)
		surface.mesh_2d_shader.color_override.r = 1
		surface.mesh_2d_shader.color_override.g = 1
		surface.mesh_2d_shader.color_override.b = 1
		draw_buffer("roughness", render.gbuffer:GetTexture("data1"))
		surface.mesh_2d_shader.color_override.r = 0
		surface.mesh_2d_shader.color_override.g = 0
		surface.mesh_2d_shader.color_override.b = 0

		surface.SetColor(0,0,0,1)
		surface.SetTexture(tex)
		surface.DrawRect(x, y, w, h)
		surface.mesh_2d_shader.color_override.r = 1
		surface.mesh_2d_shader.color_override.g = 1
		surface.mesh_2d_shader.color_override.b = 1
		draw_buffer("metallic", render.gbuffer:GetTexture("data2"))
		surface.mesh_2d_shader.color_override.r = 0
		surface.mesh_2d_shader.color_override.g = 0
		surface.mesh_2d_shader.color_override.b = 0

		draw_buffer("discard", render.gbuffer_discard:GetTexture())

		i,x,y,w,h = render.gbuffer_fill:DrawDebug(i,x,y,w,h,size)
	end
end