local render2d = ... or _G.render2d

do
	local X, Y, W, H = 0,0

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
	function render2d.SetStencilState(tbl)
		if tbl.function_ then

		end
	end

	--[[
		local function stencil_pass(func, ref)
			if func == "never" then
				return false
			end

			if func == "equal" then
				return pixel == ref
			end
		end

		local stencil_pass = stencil_pass(func, ref)
		local depth_pass = depth_pass()

		if depth_pass and stencil_pass then

		elseif not depth_pass and stencil_pass then

		elseif not stencil_pass then
			if op == "incr" then
				pixel = pixel + ref
			end
		end

		1: 000000000 -- clear
		2: 000111110 -- draw stencil rect
		2: 000112210 -- draw stencil rect
		2: 000111110 -- draw stencil rect
	]]


	local i = 0
	local X,Y,W,H

	function render2d.PushStencilRect(x,y,w,h, i_override)
		render.StencilFunction("never", 1)
		render.StencilOperation("increase", "keep", "zero")

		render2d.PushTexture()
			render2d.DrawRect(x,y,w,h)
		render2d.PopTexture()

		render.StencilFunction("equal", i)

		i = i + 1
		X,Y,W,H = x,y,w,h
	end

	function render2d.PopStencilRect()
		render.StencilFunction("never", 1)
		render.StencilOperation("decrease", "keep", "zero")

		render2d.PushTexture()
			render2d.DrawRect(X,Y,W,H)
		render2d.PopTexture()

		if i >= 4 then i = 0 end
	end

	local i = 0
	local X,Y,W,H

	function render2d.PushStencilRect2(x,y,w,h, i_override)
		render.StencilFunction("never", 1)
		render.StencilOperation("increase", "keep", "zero")

		render2d.PushTexture()
			render2d.DrawRect(x,y,w,h)
		render2d.PopTexture()

		render.StencilFunction("equal", i)

		i = i + 1
		X,Y,W,H = x,y,w,h
	end

	function render2d.PopStencilRect2()
		render.StencilFunction("never", 1)
		render.StencilOperation("decrease", "keep", "zero")

		render2d.PushTexture()
			render2d.DrawRect(X,Y,W,H)
		render2d.PopTexture()

		if i >= 4 then i = 0 end
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
				render2d.DrawRect(x, y, w, h)
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