do
	function gine.env.CreateMaterial()
		local self = gine.WrapObject(render.CreateMaterial("model"), "IMaterial")
		self.vars = {}
		return self
	end

	function gine.env.Material(path)
		llog("Material: %s", path)
		local mat = render.CreateMaterial("model")
		mat.gine_name = path

		if path:lower():endswith(".png") then
			if vfs.IsFile(path) then
				mat:SetAlbedoTexture(render.CreateTextureFromPath(path))
			else
				mat:SetAlbedoTexture(render.CreateTextureFromPath("materials/" .. path))
			end
		elseif vfs.IsFile("materials/" .. path .. ".vmt") then
			mat:LoadVMT("materials/" .. path .. ".vmt")
		elseif vfs.IsFile("materials/" .. path) then
			mat:LoadVMT("materials/" .. path)
		end

		local self = gine.WrapObject(mat, "IMaterial")
		self.vars = {}
		return self
	end

	local META = gine.GetMetaTable("IMaterial")

	function META:GetColor(x,y)
		local r,g,b,a = self.__obj:GetAlbedoTexture():GetPixelColor(x,y):Unpack()
		return gine.env.Color(r*255, g*255, b*255, a*255)
	end

	function META:GetName()
		return self.__obj.gine_name
	end

	function META:GetShader()
		return self.__obj.vmt and self.__obj.vmt.shader or "Loading"-- this isn't cased properly
	end

	function META:Width()
		return self.__obj:GetAlbedoTexture():GetSize().x
	end

	function META:Height()
		return self.__obj:GetAlbedoTexture():GetSize().y
	end

	function META:GetKeyValues()
		return {}
	end

	function META:Recompute()

	end

	local function set(self, key, val) self.vars[key] = val end
	local function get(def) return function(self, key) return self.vars[key] or def(self) end end

	META.SetFloat = set
	META.GetFloat = get(function() return 0 end)

	META.SetInt = set
	META.GetInt = get(function() return 0 end)

	META.SetStrint = set
	META.GetString = get(function() return "" end)

	local SetTexture = set
	local GetTexture = get(function(self) return gine.WrapObject(render.GetErrorTexture(), "ITexture") end)

	function META:SetTexture(key, val)
		key = key:lower()

		if key == "$basetexture" then
			return self.__obj:SetAlbedoTexture(val.__obj)
		end

		return SetTexture(self, key, val)
	end

	function META:GetTexture(key)
		key = key:lower()

		if key == "$basetexture" then
			return gine.WrapObject(self.__obj:GetAlbedoTexture(), "ITexture")
		end

		return GetTexture(self, key)
	end

	META.SetVector = set
	META.GetVector = get(function() return genv.env.Vector() end)

	function META:IsError()
		return false
	end
end

do
	local surface = gine.env.surface

	function surface.GetTextureID(path)
		llog("surface.GetTextureID: %s", path)

		if vfs.IsFile("materials/" .. path) then
			if path:lower():endswith(".vmt") then
				local mat = render.CreateMaterial("model")
				mat:LoadVMT("materials/" .. path)
				return mat:GetAlbedoTexture()
			else
				return render.CreateTextureFromPath("materials/" .. path)
			end
		end

		return render.CreateTextureFromPath("materials/" .. path .. ".vtf")
	end

	function surface.SetMaterial(mat)
		render2d.SetTexture(mat.__obj.AlbedoTexture)
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
		return self.__obj.Size.x
	end

	function META:GetColor(x,y)
		local r,g,b,a = self.__obj:GetAlbedoTexture():GetPixelColor(x,y):Unpack()
		return gine.env.Color(r*255, g*255, b*255, a*255)
	end

	function META:GetName()
		return "huh"
	end

	function META:IsError()
		return false
	end
end

function gine.env.render.SetMaterial(mat)
	render.SetMaterial(mat.__obj)
end
