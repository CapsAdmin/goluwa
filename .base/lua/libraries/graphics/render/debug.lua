local gl = require("libraries.ffi.opengl") -- OpenGL
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

local cb = function(source, type, id, severity, length, message, userdata)
	source = sources[source]
	type = types[type]
	severity = severities[severity]
	message = ffi.string(message, length)
					
	render.OnError(source, type, id, severity, message)
end

function render.EnableDebug(b)
	do return end
	if gl.DebugMessageControl then
		if b then		
			gl.Enable(gl.e.GL_DEBUG_OUTPUT_ARB)
			gl.DebugMessageControl(gl.e.GL_DONT_CARE, gl.e.GL_DONT_CARE, gl.e.GL_DONT_CARE, ffi.new("GLuint"), nil, true)
			gl.Enable(gl.e.GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB)
			
			local buffer = ffi.new("char[1024]")
			local length = ffi.sizeof(buffer)
			
			debug.sethook(function() 
				local info = debug.getinfo(2)
				if info.source:find("lj-opengl", nil, true) then
					gl.GetDebugMessageLog(1, length, nil, nil, nil, nil, nil, buffer)
					local str = ffi.string(buffer)
					if str ~= "" then
						if str:sub(0, 11) ~= "Buffer info" and not str:find("Texture 0") then
							local info = debug.getinfo(3)
							local source = info.source:match(".+render/(.+)")
							logf("[render] %s:%i gl.%s: %s\n", source, info.currentline, info.name, str)
						end
					end
				end
			end, "return")
		else
			gl.Disable(gl.e.GL_DEBUG_OUTPUT_ARB)
			debug.sethook()
		end
	else
		logn("[render] glDebugMessageControl is not availible")
	end
end

function render.OnError(source, type, id, severity, message)
	event.Call("GLError", source, type, id, severity, message)
		
	--debug.trace()
	local info = debug.getinfo(5)				
	
	if info.name then 
		info.name = "gl" .. info.name 
	else
		info.name = info.short_src
	end
	
	logf("%s at %s:%i\n", info.name, info.short_src, info.currentline)
	logn("\t", message, "\n")
end