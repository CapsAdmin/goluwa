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

commands.Add("scene_info", function()
	logf("%s models\n", #render3d.scene)

	local model_count = 0
	for _, model in ipairs(render3d.scene) do
		model_count = model_count + #model.sub_meshes
	end

	logf("%s sub models\n", model_count)

	local light_count = 0
	for _, ent in ipairs(entities.GetAll()) do
		if ent.SetShadow then
			light_count = light_count + 1
		end
	end
	logf("%s lights\n", light_count)

	logf("%s maximum draw calls\n", model_count + light_count)

	local total_visible = 0
	local vis = {}
	for _, model in ipairs(render3d.scene) do
		for key, is_visible in pairs(model.visible) do
			local visible = is_visible and 1 or 0
			vis[key] = (vis[key] or 0) + visible
			total_visible = total_visible + visible
		end
	end

	logf("%s current draw calls with shadows\n", total_visible)

	local temp = {}
	for id, count in pairs(vis) do table.insert(temp, {id = id, count = count}) end
	table.sort(temp, function(a, b) return a.id < b.id end)
	for _, v in ipairs(temp) do
		logf("\t%s visible in %s\n", v.count, v.id)
	end

	local mat_count = {}
	local tex_count = {}
	for _, model in ipairs(render3d.scene) do
		for _, mesh in ipairs(model.sub_meshes) do
			if mesh.material then
				mat_count[mesh.material] = true
				for key, val in pairs(mesh.material) do
					if typex(val) == "texture" then
						tex_count[val] = true
					end
				end
			end
		end
	end
	mat_count = table.count(mat_count)
	tex_count = table.count(tex_count)

	logf("%s materials\n", mat_count)
	logf("%s textures\n", tex_count)
end)

commands.Add("dump_gbuffer=string|nil,string|nil", function(format, depth_format)
	ffi.cdef[[
		void *fopen(const char *filename, const char *mode);
		size_t fwrite(const void *ptr, size_t size, size_t nmemb, void *stream);
		int fclose( void * stream );
	]]

	event.AddListener("GBufferPrePostProcess", function()
		for k,v in pairs(render3d.gbuffer.textures) do
			local ok, err = pcall(function()
				local format = format
				if k == "depth" then format = depth_format end
				print(format)
				local data = v.tex:Download(nil, format)
				local buffer = data.buffer
				data.buffer = nil
				serializer.WriteFile("luadata", "" .. k .. ".tbl", data)
				local f = ffi.C.fopen(R("data/") .. k .. ".data", "wb")
				ffi.C.fwrite(buffer, 1, data.size, f)
				ffi.C.fclose(f)
			end)
			if ok then
				logf("dumped buffer %s to %s\n", k,  k .. ".tbl and *.data")
			else
				logf("error dumping buffer %s: %s\n", k, err)
			end
		end
	end)
end)

do -- source engine
	commands.Add("getpos", function()
		local pos = camera.camera_3d:GetPosition() * (1/steam.source2meters)
		local ang = camera.camera_3d:GetAngles():GetDeg()

		logf("setpos %f %f %f;setang %f %f %f", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z)
	end)

	commands.Add("setpos=arg_line", function(source_engine_position)
		local x,y,z = unpack(source_engine_position:match("(.-);"):split(" "))
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
		camera.camera_3d:SetPosition(Vec3(x,y,z) * steam.source2meters)

		local p,y,r = unpack(source_engine_position:match("setang (.+)"):split(" "))
		p = tonumber(p)
		y = tonumber(y)
		r = tonumber(r)
		camera.camera_3d:SetAngles(Deg3(p,y,r))
	end)
end