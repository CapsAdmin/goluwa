local META = prototype.GetRegistered("framebuffer")

function render._CreateFrameBuffer(self, id_override)
	self.textures = {}
end

function META:OnRemove()
end

function META:_Bind()
end

function META:SetTextureLayer(pos, tex, layer)
	self.textures[pos] = tex
end

function META:SetTexture(pos, tex, mode, uid, face)
	self.textures[pos] = tex
end

function META:GetTexture(pos)
	pos = pos or 1

	if self.textures[pos] then
		return self.textures[pos]
	end

	return render.GetErrorTexture()
end

function META:SetWrite(pos, b)
end

function META:WriteThese(str)
end

function META:SaveDrawBuffers()
end

function META:RestoreDrawBuffers()
end

function META:ClearAll(r,g,b,a, d,s)
end

function META:ClearColor(r,g,b,a)
end

function META:ClearDepth(d)
end

function META:ClearStencil(s)
end

function META:ClearDepthStencil(d, s)
end

function META:ClearTexture(i, r,g,b,a)
end

prototype.Register(META)