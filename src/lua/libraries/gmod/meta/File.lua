local gmod = ... or gmod

local META = gmod.env.FindMetaTable("File")

function META:Read(length)
	return self.__obj:ReadBytes(length)
end