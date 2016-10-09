local gmod = ... or gmod

function gmod.env.CreateMaterial()
	return gmod.WrapObject(render.CreateMaterial("model"), "IMaterial")
end

function gmod.env.Material(path)
	local mat = render.CreateMaterial("model")
	mat.gmod_name = path

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

	return gmod.WrapObject(mat, "IMaterial")
end

local META = gmod.env.FindMetaTable("IMaterial")

function META:GetTexture()
	return gmod.WrapObject(self.__obj:GetAlbedoTexture(), "ITexture")
end

function META:GetColor(x,y)
	local r,g,b,a = self.__obj:GetAlbedoTexture():GetPixelColor(x,y)
	return {r=r,g=g,b=b,a=a or 255}
end

function META:GetName()
	return self.__obj.gmod_name
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
	return gmod.env.Vector()
end

META.GetHDRTexture = META.GetTexture
META.SetHDRTexture = META.SetTexture