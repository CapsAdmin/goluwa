local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "base"

metatable.GetSet(CONTEXT, "Mode", "read")

function CONTEXT:PCall(name, ...)
	local ok, var = pcall(self[name], self, ...)
	if vfs.debug and not ok then
		vfs.DebugPrint("%s: error calling %s: %s", self.Name or "", name, var)
		return false
	end
	
	if ok then
		return var
	end
	
	return false
end

function CONTEXT:Write(str)
	return self:WriteBytes(str)
end

function CONTEXT:Read(bytes)
	return self:ReadBytes(bytes)
end

function CONTEXT:Lines()
	local temp = {}
	return function()
		while not self:TheEnd() do 
			local char = self:ReadChar()
			
			if char == "\n" then
				local str = table.concat(temp)
				table.clear(temp)
				return str
			else
				table.insert(temp, char)
			end
		end
	end
end

function CONTEXT:PeakByte(bytes)
	return self:ReadByte(), self:SetPos( self:GetPos() - 1 )
end

function CONTEXT:ReadByte()
	local str = self:ReadBytes(1)
	if str then
		return str:byte()
	end
end

function CONTEXT:WriteByte(byte)
	self:WriteBytes(string.char(byte))
end

do -- push pop position
	function CONTEXT:PushPos(pos)
		self.stack = self.stack or {}
		
		table.insert(self.stack, self:GetPos())
		
		self:SetPos(pos)
	end
	
	function CONTEXT:PopPos()
		self:SetPos(table.remove(self.stack))
	end
end

function CONTEXT:TheEnd()
	return self:GetPos() >= self:GetSize()
end

function CONTEXT:Advance(i)
	i = i or 1
	self:SetPos(self:GetPos() + i) 
end

CONTEXT.__len = CONTEXT.GetSize

function CONTEXT:GetDebugString()
	return self:GetString():readablehex()
end

function CONTEXT:GetFiles()
	error(self.Name .. ": not implemented")
end

function CONTEXT:IsFile()
	error(self.Name .. ": not implemented")
end

function CONTEXT:IsFolder()
	error(self.Name .. ": not implemented")
end

function CONTEXT:CreateFolder()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Open(path, mode, ...)
	error(self.Name .. ": not implemented")
end

function CONTEXT:SetPos(pos)
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetPos()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Close()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetSize()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetLastModified()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetLastAccessed()
	error(self.Name .. ": not implemented")
end

function CONTEXT:OnRemove()
	vfs.opened_files[self] = nil
end

function CONTEXT:Remove()
	self:OnRemove()
end

metatable.AddBufferTemplate(CONTEXT)

metatable.Register(CONTEXT, "file_system", CONTEXT.Name)