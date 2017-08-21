local screen_size = render.GetScreenSize()
local alpha_buffer = render.CreateFrameBuffer(screen_size)

local background = render.CreateTextureFromPath("https://image.freepik.com/free-vector/abstract-background-with-a-watercolor-texture_1048-2144.jpg")

function goluwa.PostDrawGUI()
		local w, h = screen_size:Unpack()
		x = w / 2
		y = h / 2

		alpha_buffer:Push()
			render2d.SetColor(1, 1, 0, 1)
			render2d.SetTexture()
			render2d.DrawRect(x, y, w/4, h/4, math.rad(45), (w/4)/2, (h/4)/2)
		alpha_buffer:Pop()

		render.SetStencil(true)
			render.GetFrameBuffer():ClearStencil(0) -- out = 0

			render.StencilOperation("keep", "replace", "replace")

			-- if true then stencil = 33 return true end
			render.StencilFunction("always", 33)
				-- on fail, keep zero value
				-- on success replace it with 33

				-- write to the stencil buffer
				-- on fail is probably never reached
				render2d.SetTexture(alpha_buffer:GetTexture())
				render2d.shader.alpha_test_ref = 0.5
				render2d.DrawRect(0, 0, w, h)
				render2d.shader.alpha_test_ref = 0

			-- if stencil == 33 then stencil = 33 return true else return false end
			render.StencilFunction("equal", 33)
				render2d.SetTexture(background)
				render2d.SetColor(1,1,1,1)
				render2d.DrawRect(0, 0, w, h)

		render.SetStencil(false)

		-- debug view
		render2d.SetTexture(alpha_buffer:GetTexture())
		render2d.DrawRect(0,0,100,100)
	end