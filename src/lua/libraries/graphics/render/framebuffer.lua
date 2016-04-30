local render = ... or _G.render

function render.GetScreenFrameBuffer()
	if not render.screen_buffer then
		render.screen_buffer = render.CreateFrameBuffer(render.GetScreenSize(), nil, 0)
	end

	render.screen_buffer.Size.x = render.GetWidth()
	render.screen_buffer.Size.y = render.GetHeight()

	return render.screen_buffer
end

local META = prototype.CreateTemplate("framebuffer")

META:GetSet("BindMode", "all", {"all", "read", "write"})
META:GetSet("Size", Vec2(128,128))

function render.CreateFrameBuffer(size, textures, id_override)
	local self = META:CreateObject()

	render._CreateFrameBuffer(self, id_override)

	self:SetBindMode("read_write")

	if size then
		self:SetSize(size:Copy())

		if not textures and not id_override then
			textures = {
				attach = "color",
				internal_format = "rgba8",
			}
		end
	end

	if textures then
		if not textures[1] then textures = {textures} end

		for i, v in ipairs(textures) do
			local attach = v.attach or "color"

			if attach == "color" then
				attach = i
			end

			local name = v.name or attach

			local tex = render.CreateTexture()
			tex:SetSize(self:GetSize():Copy())

			if attach == "depth" then
				tex:SetMagFilter("nearest")
				--tex:SetMinFilter("nearest")
			else
				if v.filter == "nearest" then
					--tex:SetMinFilter("nearest")
					tex:SetMagFilter("nearest")
				end
			end

			tex:SetWrapS("clamp_to_edge")
			tex:SetWrapT("clamp_to_edge")

			if v.internal_format then
				tex:SetInternalFormat(v.internal_format)
			end

			if v.depth_texture_mode then
				tex:SetDepthTextureMode(v.depth_texture_mode)
			end

			if v.mip_maps then
				tex:SetMipMapLevels(v.mip_maps)
			else
				tex:SetMipMapLevels(1)
			end
			tex:SetupStorage()
			--tex:Clear()

			self:SetTexture(attach, tex, nil, name)
		end

		self:CheckCompletness()
	end

	return self
end

do -- binding

	do
		local current

		function render.SetFrameBuffer(fb)
			if fb == nil then
				fb = render.GetScreenFrameBuffer()
			end

			current = fb

			fb:Bind()
		end

		function render.GetFrameBuffer()
			return current
		end

		utility.MakePushPopFunction(render, "FrameBuffer")
	end

	do
		META.Push = render.PushFrameBuffer
		META.Pop = render.PopFrameBuffer

		function META:Begin()
			self:Push()
			render.PushViewport(0, 0, self.Size.x, self.Size.y)
		end

		function META:End()
			render.PopViewport()
			self:Pop()
			if self.generate_mip_maps then
				for _, v in ipairs(self.textures_sorted) do
					if v.tex and v.tex.MipMapLevels ~= 1 then
						v.tex:GenerateMipMap()
					end
				end
			end
		end
	end

	function META:Bind()
		self:_Bind()
	end
end

include("opengl/framebuffer.lua", render, META)

META:Register()