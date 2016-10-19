local render = ... or _G.render

do -- AUTOMATE THIS
	local size = 6
	local x,y,w,h,i

	function render.DrawGBufferDebugOverlay()
		w, h = render2d.GetSize()
		w = w / size
		h = h / size

		x = 0
		y = 0
		i = 1

		local buffer_i = 1

		gfx.SetFont()

		for _, pass in pairs(render3d.gbuffer_data_pass.Buffers) do
			local pass_name = pass.name

			for _, buffer in pairs(pass.layout) do
				for channel_name, str in pairs(buffer) do
					if channel_name ~= "format" then
						render2d.shader.color_override.r = 0
						render2d.shader.color_override.g = 0
						render2d.shader.color_override.b = 0
						render2d.shader.color_override.a = 0

						for _, color in ipairs({"r", "g", "b", "a"}) do
							if str:find(color) then
								render2d.shader.color_override[color] = 0
							else
								render2d.shader.color_override[color] = 1
							end
						end

						--print(i, channel_name, render2d.shader.color_override)

						render2d.SetColor(0,0,0,1)
						render2d.SetTexture()
						render2d.DrawRect(x, y, w, h)

						render2d.SetColor(1,1,1,1)
						render2d.SetTexture(render3d.gbuffer:GetTexture("data"..buffer_i))
						render2d.DrawRect(x, y, w, h)

						render2d.shader.color_override.r = 0
						render2d.shader.color_override.g = 0
						render2d.shader.color_override.b = 0
						render2d.shader.color_override.a = 0

						gfx.SetTextPosition(x, y + 5)
						gfx.DrawText(channel_name)

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
	end
end