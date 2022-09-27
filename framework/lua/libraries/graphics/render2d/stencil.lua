local render2d = ... or _G.render2d

do
	local X, Y, W, H = 0, 0

	function render2d.SetScissor(x, y, w, h)
		X = x
		Y = y
		W = w or render.GetWidth()
		H = h or render.GetHeight()

		if not x then
			X = 0
			Y = 0
			render.SetScissor()
		else
			x, y = render2d.ScreenToWorld(-x, -y)
			render.SetScissor(-x, -y, w, h)
		end
	end

	function render2d.GetScissor()
		return X, Y, W, H
	end

	utility.MakePushPopFunction(render2d, "Scissor")
end

do
	function render2d.PushStencilRect(x, y, w, h)
		render.SetStencil(true)
		render.GetFrameBuffer():ClearStencil(0)
		render.StencilFunction("always", 1, 0xFFFFFFFF)
		render.StencilOperation("keep", "keep", "replace")
		render.SetColorMask(0, 0, 0, 0)
		render2d.PushTexture()
		render2d.DrawRect(x, y, w, h)
		render2d.PopTexture()
		render.SetColorMask(1, 1, 1, 1)
		render.StencilFunction("equal", 1)
	end

	function render2d.PopStencilRect()
		render.SetStencil(false)
	end
end

do
	local X, Y, W, H

	function render2d.EnableClipRect(x, y, w, h, i)
		i = i or 1
		render.SetStencil(true)
		render.GetFrameBuffer():ClearStencil(0) -- out = 0
		render.StencilOperation("keep", "replace", "replace")
		-- if true then stencil = 33 return true end
		render.StencilFunction("always", i)
		-- on fail, keep zero value
		-- on success replace it with 33
		-- write to the stencil buffer
		-- on fail is probably never reached
		render2d.PushTexture()
		render.SetColorMask(0, 0, 0, 0)
		render2d.DrawRect(x, y, w, h)
		render.SetColorMask(1, 1, 1, 1)
		render2d.PopTexture()
		-- if stencil == 33 then stencil = 33 return true else return false end
		render.StencilFunction("equal", i)
		X = x
		Y = y
		W = w
		H = h
	end

	function render2d.GetClipRect()
		return X or 0, Y or 0, W or render.GetWidth(), H or render.GetHeight()
	end

	function render2d.DisableClipRect()
		render.SetStencil(false)
	end
end