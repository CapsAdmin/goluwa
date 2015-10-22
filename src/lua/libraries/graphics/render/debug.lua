local ffi = require("ffi")
local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

do
	local spacing = 50
	local x_offset = 10
	local y_offset = 20

	local function draw_axis(axis, x, y)
		local w,h = surface.GetTextSize(axis)
		surface.SetTextPosition(spacing * x + x_offset, spacing * y + y_offset + h/2 - 2)
		surface.DrawText(axis)
	end

	function render.DrawMatrix(x, y, m, name)
		surface.PushMatrix(x, y)

		surface.SetFont("default")
		surface.SetWhiteTexture()

		surface.SetColor(1, 0, 0, 0.5)
		surface.DrawRect(0, y_offset, spacing * 3, spacing * 3)

		surface.SetColor(0, 1, 0, 0.5)
		surface.DrawRect(spacing * 3, y_offset, spacing, spacing * 3)
		draw_axis("x", 4, 0)
		draw_axis("y", 4, 1)
		draw_axis("z", 4, 2)


		surface.SetColor(0, 0, 1, 0.5)
		surface.DrawRect(0, y_offset + spacing * 3, spacing * 3, spacing - y_offset/2)

		--surface.SetColor(1, 0, 1, 0.5)
		--surface.DrawRect(spacing * 3, y_offset + spacing * 3, spacing, spacing - y_offset/2)

		surface.SetColor(1,1,1,1)

		surface.SetTextPosition(0, 0)
		surface.DrawText(name)

		for x = 0, 3 do
		for y = 0, 3 do
			local str = tostring(math.round(m[x*4+y], 2))
			local x_offset_2 = 0

			if str:sub(1, 1)  == "-" then
				x_offset_2 = surface.GetTextSize("-")
			end
			local w, h = surface.GetTextSize(str)
			surface.SetTextPosition(x*spacing + x_offset - x_offset_2, y*spacing + y_offset + h/2 - 2)
			surface.DrawText(str)
		end
		end

		surface.PopMatrix()
	end
end

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

	if gl.DebugMessageControl then
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

	if gl.DebugMessageControl then
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
	if gl.DebugMessageControl then
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