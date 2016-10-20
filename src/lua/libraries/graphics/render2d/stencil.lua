local render2d = ... or _G.render2d

local gl = require("libopengl")
local ffi = require("libopengl")

function render2d.SetScissor(x, y, w, h)
	if not x then
		render.SetScissor()
	else
		x, y = render2d.ScreenToWorld(-x, -y)
		render.SetScissor(-x, -y, w, h)
	end
end

do
    local stack = {}
	local depth = 1

	local stencil_debug_tex

	function render2d.DrawStencilTexture()

	    stencil_debug_tex = stencil_debug_tex or render.CreateBlankTexture(Vec2(render.GetWidth(), render.GetHeight()))

		local stencilStateArray = ffi.new("GLboolean[1]", 0)
		gl.GetBooleanv("GL_STENCIL_TEST", stencilStateArray)

		--if wait(0.25) then

			gl.Enable("GL_STENCIL_TEST")

			local stencilWidth = render.GetWidth()
			local stencilHeight = render.GetHeight()
			local stencilSize = stencilWidth*stencilHeight
			local stencilData = ffi.new("unsigned char[?]", stencilSize)
			gl.ReadPixels(0, 0, stencilWidth, stencilHeight, "GL_STENCIL_INDEX", "GL_UNSIGNED_BYTE", stencilData)

			--[[for y = 0, stencilHeight-1 do
				for x = 0, stencilWidth-1 do
					local i = y*stencilWidth + x
					io.stdout:write(string.format("%02X ", stencilData[i]))
				end
				io.stdout:write("\n")
			end]]

			local y = math.floor(stencilHeight/2)
			for x = math.floor(stencilWidth/2-10), math.floor(stencilWidth/2+10) do
				local i = y*stencilWidth + x
				stencilData[i] = 1
			end

			local maxValue = 0
			for i = 0, stencilSize-1 do
				maxValue = math.max(maxValue, stencilData[i])
			end

			local scale = 255/maxValue
			for i = 0, stencilSize-1 do
				stencilData[i] = math.floor(stencilData[i]*scale)
			end

			stencil_debug_tex:Upload(stencilData, {upload_format = "red", internal_format = "r8"})
		--end

		render2d.PushMatrix()
		render2d.LoadIdentity()
    		render2d.SetColor(1,1,1,1)
    		render2d.SetTexture(stencil_debug_tex)
    		gl.Disable("GL_STENCIL_TEST")
    		render2d.DrawRect(64,64,128,128)
    		gl.Enable("GL_STENCIL_TEST")
		render2d.PopMatrix()

		if stencilStateArray[0] == 0 then
		    gl.Disable("GL_STENCIL_TEST")
	    end
    end

	function render2d.EnableStencilClipping()
		--assert(#stack == 0, "I think this is good assertion, wait, you may want to draw something regardless of clipping, so nvm")
		--table.clear(stack)
		-- that means the stack should not be emptied, in case you want to disobey clipping?

		-- Don't consider depth buffer while stenciling or drawing
		gl.DepthMask(0)
		gl.DepthFunc("GL_ALWAYS")

		-- Enable stencil test
		gl.Enable("GL_STENCIL_TEST")

		-- Write to all stencil bits
		gl.StencilMask(0xFF)

		-- Don't consider stencil buffer while clearing it
		gl.StencilFunc("GL_ALWAYS", 0, 0xFF)

		-- Clear the stencil buffer to zero
		gl.ClearStencil(0)
		gl.Clear("GL_STENCIL_BUFFER_BIT")

		-- Stop writing to stencil
		gl.StencilMask("GL_FALSE")
	end

	function render2d.DisableStencilClipping()
		-- disable stencil completely, how2
		gl.Disable("GL_STENCIL_TEST")
	end

    --[[
		it works like this:

		00000000000000000000000000
	    push frame; depth = 1
    		00011111111111111000000000
		    push panel; depth = 2
        		00011222222222211000000000
        		push button1; depth = 3
        		    00011233322222211000000000
    		    pop button1; depth = 2
    		    00011222222222211000000000
    		    push button2; depth = 3
    		        00011222222333211000000000
		        pop button2; depth = 2
		        00011222222222211000000000
	        pop panel; depth = 1
	        00011111111111111000000000
        pop frame; depth = 0
        00000000000000000000000000

        gl.StencilFunc("GL_EQUAL", depth, 0xFF)
        means
        only draw if stencil == current depth
	]]

	local function update_stencil_buffer(mode)

		-- Write to all stencil bits
		gl.StencilMask(0xFF)

		-- For each object on the stack, increment/decrement any pixel it touches by 1
		gl.DepthMask(0) -- Don't write to depth buffer
		gl.StencilFunc("GL_NEVER", 0, 0xFF) -- Update stencil regardless of current value
		gl.StencilOp(
			mode, -- For each pixel white pixel, increment/decrement
			"GL_REPLACE", -- Ignore depth buffer
			"GL_REPLACE" -- Ignore depth buffer
		)

		local data = stack[depth]
		data.func(unpack(data.args))

		-- Stop writing to stencil
		gl.StencilMask("GL_FALSE")

		-- Now make future drawing obey stencil buffer
		gl.DepthMask(1) -- Write to depth buffer
		gl.StencilFunc("GL_EQUAL", depth-1, 0xFF) -- Pass test if stencil value is equal to depth
	end

	function render2d.PushClipFunction(draw_func, ...)
	    depth = depth+1

		stack[depth] = {func = draw_func, args = {...}}

		update_stencil_buffer("GL_INCR")
	end

	function render2d.PopClipFunction()
		update_stencil_buffer("GL_DECR")

		stack[depth] = nil
		depth = depth-1

		if depth < 1 then
			error("stack underflow", 2)
		end
	end
end

do
	local X, Y, W, H
	function render2d.EnableClipRect(x, y, w, h)
		gl.Enable("GL_STENCIL_TEST")

		gl.StencilFunc("GL_ALWAYS", 1, 0xFF) -- Set any stencil to 1
		gl.StencilOp("GL_KEEP", "GL_KEEP", "GL_REPLACE")
		gl.StencilMask(0xFF) -- Write to stencil buffer
		render.GetFrameBuffer():ClearStencil(0xFF) -- Clear stencil buffer (0 by default)

		render2d.PushColor(0,0,0,0)
		render2d.DrawRect(x, y, w, h)
		render2d.PopColor()

		gl.StencilFunc("GL_EQUAL", 1, 0xFF) -- Pass test if stencil value is 1
		gl.StencilMask(0x00) -- Don't write anything to stencil buffer

		X = x
		Y = y
		W = w
		H = h
	end

	function render2d.GetClipRect()
		return X or 0, Y or 0, W or render.GetWidth(), H or render.GetHeight()
	end

	function render2d.DisableClipRect()
		gl.Disable("GL_STENCIL_TEST")
	end
end