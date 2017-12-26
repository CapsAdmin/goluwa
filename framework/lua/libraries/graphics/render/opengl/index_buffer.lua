local render = ... or _G.render
local META = prototype.GetRegistered("index_buffer")

local gl = system.GetFFIBuildLibrary("opengl", true)

local buffers_supported = gl.GenBuffers

do
	local translate = {
		["uint8_t"] = "GL_UNSIGNED_BYTE",
		["uint16_t"] = "GL_UNSIGNED_SHORT",
		["uint32_t"] = "GL_UNSIGNED_INT",
	}

	function META:SetIndicesType(typ)
		self.IndicesType = typ
		self.gl_indices_type = translate[typ] or translate["uint16_t"]
	end
end

do
	local translate = {
		dynamic = "GL_DYNAMIC_DRAW",
		stream = "GL_STREAM_DRAW",
		static = "GL_STATIC_DRAW",
	}

	function META:SetDrawHint(hint)
		self.DrawHint = hint
		self.gl_draw_hint = translate[hint] or translate.dynamic
	end
end

function render._CreateIndexBuffer(self)
	self:SetIndicesType(self:GetIndicesType())
	self:SetDrawHint(self:GetDrawHint())

	if buffers_supported then
		self.element_buffer = gl.CreateBuffer("GL_ELEMENT_ARRAY_BUFFER")
	end
end

function META:OnRemove()
	if self.element_buffer then
		self.element_buffer:Delete()
	end
end

if buffers_supported then
	function META:_SetIndices(indices)
		self.element_buffer:Data(indices:GetSize(), indices:GetPointer(), self.gl_draw_hint)
	end
else
	-- this will probably only happen when running goluwa in virtual box with windows as a host
	-- it's using the windows opengl api (seems to be 1.1)

	function META:_SetIndices(indices)

	end
end
prototype.Register(META)
