local screen_size = render.GetScreenSize()

local background = render.CreateTextureFromPath("https://image.freepik.com/free-vector/abstract-background-with-a-watercolor-texture_1048-2144.jpg")

function goluwa.PreDrawGUI()
	render.SetStencil(true)
		render.GetFrameBuffer():ClearStencil(0) -- out = 0

		render.StencilOperation("replace", "keep", "keep")

		-- if true then stencil = 33 return true end
		render.StencilFunction("never", 33)
			-- on fail, keep zero value
			-- on success replace it with 33

			-- write to the stencil buffer
			-- on fail is probably never reached
		render2d.SetColor(0, 0, 0, 0)
		render2d.SetTexture()
		render2d.DrawRect(500, 500, 400, 400, os.clock(), 400/2, 400/2)

		-- if stencil == 33 then stencil = 33 return true else return false end
		render.StencilFunction("equal", 33)

			render2d.SetTexture(background)
			render2d.SetColor(1,1,1,1)
			render2d.DrawRect(0, 0, screen_size:Unpack())

	render.SetStencil(false)
end