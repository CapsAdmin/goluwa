do
	gine.created_materials = utility.CreateWeakTable()

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

	function gine.env.Material(path)
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
				steam.LoadVMT(vmt_path, function(key, val)
					self:SetString("$" .. key, tostring(val))
				end, nil, function(name) mat:SetShader(name:lower()) end)
			end
		end

		gine.created_materials[path:lower()] = self

		return self
	end

	local META = gine.GetMetaTable("IMaterial")

	function META:GetColor(x,y)
		local r,g,b,a = self:GetTexture("$basetexture").__obj:GetPixelColor(x, y):Unpack()
		return gine.env.Color(r*255, g*255, b*255, a*255)
	end

	function META:GetName()
		return self.__obj.name
	end

	function META:GetShader()
		return self.__obj.shader
	end

	function META:Width()
		return self:GetTexture("$basetexture").__obj:GetSize().x
	end

	function META:Height()
		return self:GetTexture("$basetexture").__obj:GetSize().y
	end

	function META:GetKeyValues()
		return table.copy(self.vars)
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
		return math.round(self.__obj:GetNumber(key))
	end

	function META:SetTexture(key, val)
		key = key:lower():sub(2)
		self.__obj:Set(key, val.__obj)
	end

	function META:GetTexture(key)
		key = key:lower():sub(2)
		local val = self.__obj:Get(key)
		if typex(val) == "texture" then
			return gine.WrapObject(val, "ITexture")
		end
	end

	function META:SetVector(key, val)
		key = key:lower():sub(2)
		self.__obj:Set(key, Vec3(val.x, val.y, val.z))
	end

	function META:GetVector(key)
		key = key:lower():sub(2)
		return gine.env.Vector(self.__obj:Get(key:sub(2)):Unpack())
	end

	function META:IsError()
		return false
	end
end

do
	local surface = gine.env.surface

	function surface.GetTextureID(path)
		if vfs.IsFile("materials/" .. path) then
			if vfs.IsFile("materials/" .. path .. ".vtf") then
				return render.CreateTextureFromPath("materials/" .. path)
			else
				wlog("texture not found %s", path)
			end
		end

		return render.CreateTextureFromPath("materials/" .. path .. ".vtf")
	end

	function surface.SetMaterial(mat)
		local tex = mat:GetTexture("$basetexture")
		if tex then
			render2d.SetTexture(tex.__obj)
		end
	end

	function surface.SetTexture(tex)
		if tex == 0 then tex = render.GetWhiteTexture() end
		render2d.SetTexture(tex)
	end
end

do
	local META = gine.GetMetaTable("ITexture")

	function META:Width()
		return self.__obj.Size.x
	end

	function META:Height()
		return self.__obj.Size.y
	end

	function META:GetColor(x, y)
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

function gine.env.render.SetMaterial(mat)
	render2d.SetTexture(mat:GetTexture("$basetexture").__obj)
	--render.SetMaterial(mat.__obj)
end