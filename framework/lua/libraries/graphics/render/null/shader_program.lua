local META = prototype.CreateTemplate("shader_program")

function render.CreateShaderProgram()
	local self = META:CreateObject()
	return self
end

function META:CompileShader(type, source)

end

function META:Link()

end

function META:GetProperties()
	return {}
end

function META:BindShaderBlock(block_index, where)

end

function META:BindUniformBuffer(block_index, where)

end

function META:UploadBoolean(key, val)

end

function META:UploadNumber(key, val)

end

function META:UploadInteger(key, val)

end

function META:UploadVec2(key, val)

end

function META:UploadVec3(key, val)

end

function META:UploadColor(key, val)

end

function META:UploadTexture(key, val)
end

function META:UploadMatrix44(key, val)
end

function META:Bind()

end

function META:GetUniformLocation(key)
	return 0
end

function META:BindAttribLocation(i, name)

end

function META:OnRemove()

end

META:Register()