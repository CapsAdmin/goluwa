local vfs = (...) or _G.vfs

local META = {}

META.Name = "base"

class.GetSet(META, "Mode", "read")

function META:GetFiles()

end

function META:GetFolders()

end

function META:CreateFolder()

end

function META:Open(path, mode, ...)
	error("not implemented")
end

function META:SetPos(pos)
	error("not implemented")
end

function META:GetPos()
	error("not implemented")
end

function META:Close()
	error("not implemented")
end

function META:GetSize()
	error("not implemented")
end

function META:GetLastModified()
	error("not implemented")
end

function META:GetLastAccessed()
	error("not implemented")
end

function META:WriteByte(byte)
	error("not implemented")
end

function META:ReadByte()
	error("not implemented")
end

utilities.BufferTemplate(META)

vfs.Register(META)