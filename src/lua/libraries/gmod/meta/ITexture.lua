local gmod = ... or gmod
local META = gmod.env.FindMetaTable("ITexture")

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