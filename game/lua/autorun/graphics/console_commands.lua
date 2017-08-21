input.Bind("e+left_alt", "toggle_focus", function()
	window.SetMouseTrapped(not window.GetMouseTrapped())
end)

commands.Add("expand_lights=number", function(num)
	num = math.max(num, 0.01)
	for k,v in pairs(entities.GetAll()) do
		if v.SetShadow then
			v:SetSize(v:GetSize() * num)
		end
	end
end)

commands.Add("expand_light_intensity=number", function(num)
	num = math.max(num, 0.01)
	for k,v in pairs(entities.GetAll()) do
		if v.SetShadow then
			v:SetIntensity(v:GetIntensity() * num)
		end
	end
end)

commands.Add("remove_lights", function()
	for k,v in pairs(entities.GetAll()) do
		if v.SetShadow then
			v:Remove()
		end
	end
end)

do -- source engine
	commands.Add("getpos", function()
		local pos = render3d.camera:GetPosition() * (1/steam.source2meters)
		local ang = render3d.camera:GetAngles():GetDeg()

		logf("setpos %f %f %f;setang %f %f %f", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z)
	end)

	commands.Add("setpos=arg_line", function(source_engine_position)
		local x,y,z = unpack(source_engine_position:match("(.-);"):split(" "))
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
		render3d.camera:SetPosition(Vec3(x,y,z) * steam.source2meters)

		local p,y,r = unpack(source_engine_position:match("setang (.+)"):split(" "))
		p = tonumber(p)
		y = tonumber(y)
		r = tonumber(r)
		render3d.camera:SetAngles(Deg3(p,y,r))
	end)
end