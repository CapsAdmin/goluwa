local vfs2 = (...) or _G.vfs2

local META = {}

META.Name = "base"

class.GetSet(META, "Mode", "read")

function META:PCall(name, ...)
	local ok, var = pcall(self[name], self, ...)
	
	if vfs2.debug and not ok then
		vfs2.DebugPrint("%s: error calling %s: %s", self.Name or "", name, var)
		return false
	end
	
	if ok then
		return var
	end
end

function META:Write(str)
	return self:WriteBytes(str)
end

function META:Read(bytes)
	return self:ReadBytes(bytes)
end

function META:GetFiles()
	error("not implemented")
end

function META:IsFile()
	error("not implemented")
end

function META:IsFolder()
	error("not implemented")
end

function META:CreateFolder()
	error("not implemented")
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

metatable.AddBufferTemplate(META)

vfs2.RegisterFileSystem(META)