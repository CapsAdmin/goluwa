local render3d = ... or _G.render3d

do -- AUTOMATE THIS
	local size = 6
	local x,y,w,h,i

	function render3d.DrawGBufferDebugOverlay()
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
				for buffer_type, colors in pairs(buffer) do
					for color, sub_name in pairs(colors) do

						render2d.PushColorOverride(0,0,0,0)

						for _, channel in ipairs({"r", "g", "b", "a"}) do
							if color:find(channel, nil, true) then
								render2d.shader.color_override[channel] = 0
							else
								render2d.shader.color_override[channel] = 1
							end
						end

						gfx.DrawRect(x,y,w,h, nil, 0,0,0,1)
						gfx.DrawRect(x,y,w,h, render3d.gbuffer:GetTexture("data"..buffer_i), 1,1,1,1)

						render2d.PopColorOverride()

						sub_name = type(sub_name) == "table" and sub_name[1] or sub_name

						gfx.DrawText(("%s %s %s %s"):format(pass_name, buffer_type, color, sub_name), x, y + 5)

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

		for _, ent in ipairs(entities.GetAll()) do
			local obj = ent:GetComponent("light")
			if obj and obj:IsValid() and obj.shadow_maps then
				local name = obj:GetName()
				for light_i, map in ipairs(obj.shadow_maps) do
					local tex = map:GetTexture("depth")

					gfx.DrawRect(x, y, w, h, nil, 1,1,1,1)
					gfx.DrawRect(x,y,w,h, tex, 1,1,1,1)
					gfx.DrawText(tostring(name) .. " " .. light_i, x, y + 5)

					if i%size == 0 then
						y = y + h
						x = 0
					else
						x = x + w
					end

					i = i + 1
				end
			end
		end
	end
end