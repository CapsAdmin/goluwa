do
	gine.created_materials = table.weak()

	function gine.env.CreateMaterial(name, shader, tbl)
		shader = shader:lower()

		if gine.created_materials[name] then
			return gine.created_materials[name]
		end

		local mat = gine.CreateMaterial(shader)
		mat.name = name

		for k,v in pairs(tbl) do
			k = k:lower():sub(2)
			local t = type(v)
			if t == "string" then
				mat:SetString(k, v)
			elseif t == "number" then
				mat:SetNumber(k, v)
			else
				mat:Set(k, v)
			end
		end

		local self = gine.WrapObject(mat, "IMaterial")

		gine.created_materials[name] = self

		return self
	end

	function gine.env.Material(path, flags)
		if gine.created_materials[path:lower()] then
			return gine.created_materials[path:lower()]
		end

		local mat = gine.CreateMaterial()
		mat.name = path

		local self = gine.WrapObject(mat, "IMaterial")

		if not path:lower():endswith(".vtf") and path:find(".+%.") then
			mat:SetShader("unlitgeneric")
			self:SetString("$basetexture", path)
		else
			local vmt_path

			if vfs.IsFile("materials/" .. path .. ".vmt") then
				vmt_path = "materials/" .. path .. ".vmt"
			elseif vfs.IsFile("materials/" .. path) then
				vmt_path = "materials/" .. path
			end

			if vmt_path then
				resource.skip_providers = true
				steam.LoadVMT(vmt_path, function(key, val)
					if type(val) == "boolean" then
						val = val and "1" or "0"
					elseif type(val) == "number" then
						val = tostring(val)
					elseif typex(val) == "vec3" then
						val = ("[%f %f %f]"):format(val:Unpack())
					elseif typex(val) == "color" then
						val = ("[%f %f %f %f]"):format(val:Unpack())
					end
					self:SetString("$" .. key, val)
				end, nil, function(name) mat:SetShader(name:lower()) end)
				resource.skip_providers = false
			end
		end

		gine.created_materials[path:lower()] = self

		return self
	end

	local META = gine.GetMetaTable("IMaterial")

	function META:GetColor(x, y)
		local tex = self:GetTexture("$basetexture")

		if tex then
			return tex:GetColor(x, y)
		end

		return gine.env.Color(0, 0, 0, 0)
	end

	function META:GetName()
		return self.__obj.name
	end

	function META:GetShader()
		return self.__obj.shader or "vertexlitgeneric"
	end

	function META:Width()
		local tex = self:GetTexture("$basetexture")

		if tex then
			return tex:Width()
		end

		return 0
	end

	function META:Height()
		local tex = self:GetTexture("$basetexture")

		if tex then
			return tex:Height()
		end

		return 0
	end

	function META:GetKeyValues()
		return table.copy(self.__obj.vars)
	end

	function META:Recompute()

	end

	function META:SetString(key, val)
		key = key:lower():sub(2)
		self.__obj:SetString(key, val)
	end

	function META:GetString(key)
		key = key:lower():sub(2)
		return self.__obj:GetString(key)
	end

	function META:SetFloat(key, val)
		key = key:lower():sub(2)
		self.__obj:SetNumber(key, val)
	end

	function META:GetFloat(key)
		key = key:lower():sub(2)
		return self.__obj:GetNumber(key)
	end

	function META:SetInt(key, val)
		key = key:lower():sub(2)
		self.__obj:SetNumber(key, math.round(val))
	end

	function META:GetInt(key)
		key = key:lower():sub(2)
		return math.round(self.__obj:GetNumber(key) or 0)
	end

	function META:SetTexture(key, val)
		if key == nil or val == nil then return end -- ?? gmod doesn't error
		key = key:lower():sub(2)
		self.__obj:Set(key, val.__obj)
	end

	function META:GetTexture(key)
		key = key:lower():sub(2)
		local val = self.__obj:Get(key)
		if typex(val) == "texture" then
			return gine.WrapObject(val, "ITexture")
		end

		return gine.WrapObject(render.GetErrorTexture(), "ITexture")
	end

	META.SetHDRTexture = META.SetTexture
	META.GetHDRTexture = META.GetTexture

	function META:SetVector(key, val)
		key = key:lower():sub(2)
		self.__obj:Set(key, Vec3(val.x, val.y, val.z))
	end

	function META:GetVector(key)
		key = key:lower():sub(2)
		local vec = self.__obj:Get(key:sub(2))
		if vec then
			return gine.env.Vector(vec:Unpack())
		end
	end

	function META:IsError()
		return false
	end
end

do
	local META = gine.GetMetaTable("ITexture")

	function META:Width()
		return math.pow2round(self.__obj.Size.x)
	end

	function META:Height()
		return math.pow2round(self.__obj.Size.y)
	end

	function META:GetColor(x, y)
		local s = self.__obj:GetSize()

		x = (x / s.x) * math.pow2round(s.x)
		y = (y / s.y) * math.pow2round(s.y)

		local r,g,b,a = self.__obj:GetPixelColor(x, y):Unpack()
		return gine.env.Color(r*255, g*255, b*255, a*255)
	end

	function META:GetName()
		return self.__obj:GetPath()
	end

	function META:IsError()
		return false
	end
end

if CLIENT then

	do
		local surface = gine.env.surface
		local idmap = {}
		local id = 0

		function surface.GetTextureID(path)
			local tex

			resource.skip_providers = true

			if vfs.IsFile("materials/" .. path) then
				if vfs.IsFile("materials/" .. path .. ".vtf") then
					tex = render.CreateTextureFromPath("materials/" .. path)
				else
					wlog("texture not found %s", path)
				end
			end

			tex = render.CreateTextureFromPath("materials/" .. path .. ".vtf")

			resource.skip_providers = nil

			idmap[id] = tex
			id = id + 1

			return id
		end

		function surface.SetMaterial(mat)
			gine.env.render.SetMaterial(mat)
		end

		function surface.SetTexture(id)
			render2d.SetTexture(idmap[id])
		end
	end

	function gine.env.render.SetMaterial(mat)
		if not mat then return end
		mat = mat.__obj

		render2d.SetTexture(mat.vars.basetexture)

		if mat.vars.alphatest == 1 then
			render2d.SetAlphaTestReference(mat.vars.alphatestreference)
		else
			render2d.SetAlphaTestReference(0)
		end

		if mat.vars.additive then
			render.SetPresetBlendMode("additive")
		else
			render.SetPresetBlendMode("alpha")
		end
	end

	function gine.env.render.MaterialOverride(mat)
		if mat == 0 then mat = nil end
		gine.env.render.SetMaterial(mat)
	end

	function gine.env.render.ModelMaterialOverride(mat)
		gine.env.render.SetMaterial(mat)
	end
end