local gmod = ... or gmod

local META = gmod.env.FindMetaTable("File")

function META:Read(length) return self.__obj:ReadBytes(length) end
function META:Close() return self.__obj:Close() end
function META:Tell() return self.__obj:Tell() end
function META:Size() return self.__obj:GetSize() end
function META:Skip(pos) return self.__obj:SetPos(pos) end