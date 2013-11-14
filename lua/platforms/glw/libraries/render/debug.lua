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


function render.EnableDebug(b)
	if gl.DebugMessageCallback then
		if b then		
			gl.Enable(e.GL_DEBUG_OUTPUT_ARB)
			gl.DebugMessageControl(e.GL_DONT_CARE, e.GL_DONT_CARE, e.GL_DONT_CARE, ffi.new("GLuint"), nil, true)
			
			gl.DebugMessageCallback(function(source, type, id, severity, length, message, userdata)
				source = sources[source]
				type = types[type]
				severity = severities[severity]
				message = ffi.string(message, length)
				
				render.OnError(source, type, id, severity, message)
			end, nil)
		else
			gl.Disable(e.GL_DEBUG_OUTPUT_ARB)
		end
	else
		logn("render.EnableDebug: gl.DebugMessageCallback is not availible")
		debug.trace()
	end
end

function render.OnError(source, type, id, severity, message)
	event.Call("OnGLError", source, type, id, severity, message)
		
	--debug.trace()
	local info = debug.getinfo(5)				
	
	if info.name then 
		info.name = "gl" .. info.name 
	else
		info.name = info.short_src
	end
	
	logf("%s at %s:%i", info.name, info.short_src, info.currentline)
	logn("\t", message, "\n")
end