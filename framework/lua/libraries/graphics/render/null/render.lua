local render = ... or _G.render

runfile("framebuffer.lua", render)
runfile("shader_program.lua", render)

function render._Initialize()
end

function render._SetWindow()

end

function render.IsExtensionSupported()

end

function render.SwapBuffers()

end

function render.SwapInterval()

end

function render.Shutdown()

end

function render.GetVersion()
	return "nil"
end

function render.GetShadingLanguageVersion()
	return "nil"
end

function render.GetInfo()
	return {vendor = "null", version = "null", renderer = "null"}
end

function render._SetScissor(x,y,w,h, sw,sh)
end

function render._SetViewport(x,y,w,h)
end

do
	local A,B,C,D,E,F

	function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)
		A,B,C,D,E,F = src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha
	end

	function render.GetBlendMode()
		return A,B,C,D,E,F
	end

	utility.MakePushPopFunction(render, "BlendMode")
end

function render._SetCullMode(mode)

end

function render._SetDepth(b)

end

function render.TextureBarrier()

end


do -- stencil
	do
		local enabled = false

		function render.SetStencil(b)
			enabled = b
		end

		function render.GetStencil()
			return enabled
		end
	end

	function render.StencilFunction(func, ref, mask)
	end

	function render.StencilOperation(sfail, dpfail, dppass)
	end

	function render.StencilMask(mask)
	end
end

do
	local META = {}
	META.__index = META

	function META:Begin()

	end

	function META:End()

	end

	function META:BeginConditional()

	end

	function META:EndConditional()
	end

	function META:GetResult()

	end

	function META:Delete()

	end

	function render.CreateQuery(type)
		return setmetatable({}, META)
	end
end

function render.SetColorMask(r,g,b,a)

end

function render.SetDepthMask(d)

end

function render.SetDebug()

end

function render.GetDebug()
	return false
end

do
	local META = prototype.GetRegistered("vertex_buffer")

	function render._CreateVertexBuffer(self)
	end

	function META:OnRemove()
	end

	function META:Draw(count)
	end

	function META:_SetVertices(vertices)
	end

	function META:_SetIndices(indices)
	end

	prototype.Register(META)
end

do
	local META = prototype.GetRegistered("texture")

	function META:GetMipSize(mip_map_level)
		return Vec3(1,1,1)
	end

	function META:OnRemove()
	end

	function META:SetupStorage()
	end

	function META:SetBindless(b)
	end

	function META:GetBindless()
		return false
	end

	function META:MakeError(reason)
		self.error_reason = reason
	end

	function META:_Upload(data, y)
	end

	function META:GenerateMipMap()
		return self
	end

	function META:_Download(mip_map_level, buffer, size, format)

	end

	function META:Clear(mip_map_level)
	end

	function META:GetID()
		return tonumber(("%p"):format(self))
	end

	function META:Bind(location)

	end

	function render._CreateTexture(self, type)
	end

	prototype.Register(META)
end