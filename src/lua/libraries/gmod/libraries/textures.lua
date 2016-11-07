do
	function gine.env.CreateMaterial()
		return gine.WrapObject(render.CreateMaterial("model"), "IMaterial")
	end

	function gine.env.Material(path)
		local mat = render.CreateMaterial("model")
		mat.gine_name = path

		if path:lower():endswith(".png") then
			if vfs.IsFile(path) then
				mat:SetAlbedoTexture(render.CreateTextureFromPath(path))
			else
				mat:SetAlbedoTexture(render.CreateTextureFromPath("materials/" .. path))
			end
		elseif vfs.IsFile("materials/" .. path) then
			steam.LoadMaterial("materials/" .. path, mat)
		elseif vfs.IsFile("materials/" .. path .. ".vmt") then
			steam.LoadMaterial("materials/" .. path .. ".vmt", mat)
		elseif vfs.IsFile("materials/" .. path .. ".png") then
			steam.LoadMaterial("materials/" .. path .. ".png", mat)
		end

		return gine.WrapObject(mat, "IMaterial")
	end

	local META = gine.GetMetaTable("IMaterial")

	function META:GetTexture()
		return gine.WrapObject(self.__obj:GetAlbedoTexture(), "ITexture")
	end

	function META:GetColor(x,y)
		local r,g,b,a = self.__obj:GetAlbedoTexture():GetPixelColor(x,y)
		return {r=r,g=g,b=b,a=a or 255}
	end

	function META:GetName()
		return self.__obj.gine_name
	end

	function META:GetShader()
		return self.__obj.vmt and self.__obj.vmt.shader or "Loading"-- this isn't cased properly
	end

	function META:Recompute()

	end

	function META:SetFloat()

	end

	function META:IsError()
		return false
	end


	function META:GetVector(key)
		return gine.env.Vector()
	end
end

do
	local surface = gine.env.surface

	function surface.GetTextureID(path)
		if vfs.IsFile("materials/" .. path) then
			return render.CreateTextureFromPath("materials/" .. path)
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
		local r,g,b,a = self.__obj:GetPixelColor(x,y)
		return {r=r,g=g,b=b,a=a or 255}
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
