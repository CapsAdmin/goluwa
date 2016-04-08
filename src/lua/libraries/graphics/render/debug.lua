local render = ... or _G.render

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

		surface.SetDefaultFont()

		for _, pass in pairs(render.gbuffer_data_pass.Buffers) do
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

		i,x,y,w,h = render.gbuffer_data_pass:DrawDebug(i,x,y,w,h,size)
	end
end