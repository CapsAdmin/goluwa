local ffi = require("ffi")
local gl = require("libopengl") -- OpenGL
local render = (...) or _G.render

local base_color = gl.e.GL_COLOR_ATTACHMENT0

local function attachment_to_enum(self, var)
	if not var then return end

	if var == "depth" then
		return "GL_DEPTH_ATTACHMENT"
	elseif var == "stencil" then
		return "GL_STENCIL_ATTACHMENT"
	elseif var == "depth_stencil" then
		return "GL_DEPTH_STENCIL_ATTACHMENT"
	elseif self.textures[var] then
		return var
	elseif type(var) == "number" then
		return base_color + var - 1
	elseif var:startswith("color") then
		return base_color + (tonumber(var:match(".-(%d)")) or 0) - 1
	end
end

local bind_mode_to_enum = {
	all = "GL_FRAMEBUFFER",
	read_write = "GL_FRAMEBUFFER",
	read = "GL_READ_FRAMEBUFFER",
	write = "GL_DRAW_FRAMEBUFFER",
	draw = "GL_DRAW_FRAMEBUFFER",
}

local function generate_draw_buffers(self)
	local draw_buffers = {}

	for _, v in ipairs(self.textures_sorted) do
		if
			(v.mode == "GL_DRAW_FRAMEBUFFER" or v.mode == "GL_FRAMEBUFFER") and
			(v.enum ~= "GL_DEPTH_ATTACHMENT" and v.enum ~= "GL_STENCIL_ATTACHMENT" and v.enum ~= "GL_DEPTH_STENCIL_ATTACHMENT")
		then
			table.insert(draw_buffers, v.enum)
		end
	end

	table.sort(draw_buffers, function(a, b) return a < b end)

	self.draw_buffers = ffi.new("GLenum[?]", #draw_buffers, draw_buffers)
	self.draw_buffers_size = #draw_buffers
end

local function update_drawbuffers(self)
	if self.draw_buffers ~= self.last_draw_buffers then
		self.gl_fb:DrawBuffers(self.draw_buffers_size, self.draw_buffers)
		self.last_draw_buffers = self.draw_buffers
	end
end

local META = prototype.CreateTemplate("framebuffer")

META:GetSet("BindMode", "all", {"all", "read", "write"})
META:GetSet("Size", Vec2(128,128))

function render.GetScreenFrameBuffer()
	if not window.IsExtensionSupported("GL_ARB_framebuffer_object") then return end

	if not render.screen_buffer then
		render.screen_buffer = render.CreateFrameBuffer(render.GetScreenSize(), nil, 0)
	end

	return render.screen_buffer
end

function render.CreateFrameBuffer(size, textures, id_override)
	local self = prototype.CreateObject(META)
	self.gl_fb = gl.CreateFramebuffer(id_override)
	self.textures = {}
	self.textures_sorted = {}
	self.render_buffers = {}
	self.draw_buffers_cache = {}

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

function META:OnRemove()
	self.gl_fb:Delete()
end

function META:__tostring2()
	return ("[%i]"):format(self.gl_fb.id)
end

function META:CheckCompletness()
	local err = self.gl_fb:CheckStatus("GL_FRAMEBUFFER")

	if err ~= gl.e.GL_FRAMEBUFFER_COMPLETE then
		local str = "Unknown error: " .. err

		if err == gl.e.GL_FRAMEBUFFER_UNSUPPORTED then
			str = "format not supported"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT then
			str = "incomplete texture"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT then
			str = "missing texture"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS then
			str = "attached textures must have same dimensions"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_FORMATS then
			str = "attached textures must have same format"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER then
			str = "missing draw buffer"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER then
			str = "missing read buffer"
		elseif err == 0 then
			str = "invalid framebuffer target"
		end

		for k, v in pairs(self.textures) do
			logn(v.tex, " attached to ", v.enum)
			v.tex:DumpInfo()
		end

		warning(str)

		debug.trace()
	end
end

function META:SetBindMode(str)
	self.BindMode = str

	self.enum_bind_mode = bind_mode_to_enum[str]
end

do -- binding
	do
		local stack = {}
		local current

		function META:Push(...)
			current = current or render.GetScreenFrameBuffer()
			stack[#stack + 1] = current

			self:Bind()

			update_drawbuffers(self)

			current = self
		end

		function META:Pop()
			local fb = stack[#stack] stack[#stack] = nil

			fb:Bind()

			current = fb
		end

		function META:Begin(...)
			self:Push(...)
			render.PushViewport(0, 0, self.Size.x, self.Size.y)
		end

		function META:End()
			render.PopViewport()
			self:Pop()
			for i,v in ipairs(self.textures_sorted) do
				if v.tex and v.tex.MipMapLevels ~= 1 then
					v.tex:GenerateMipMap()
				end
			end
		end
	end

	function META:Bind()
		self.gl_fb:Bind(self.enum_bind_mode)
		render.active_framebuffer = self
	end

	function render.GetActiveFramebuffer()
		return render.active_framebuffer
	end
end

function META:SetTexture(pos, tex, mode, uid, face)
	local enum = attachment_to_enum(self, pos)

	if not uid then
		uid = enum
	end

	if typex(tex) == "texture" then
		local id = tex and tex.gl_tex.id or 0 -- 0 will be detach if tex is nil

		if face then
			self.gl_fb:TextureLayer(enum, tex and tex.gl_tex.id or 0, 0, face - 1)
		else
			self.gl_fb:Texture(enum, id, 0)
		end

		for i,v in ipairs(self.textures_sorted) do
			if v.uid == uid then
				table.remove(self.textures_sorted, i)
				break
			end
		end

		if id ~= 0 then
			self.textures[uid] = {
				tex = tex,
				mode = bind_mode_to_enum[mode or "write"],
				enum = enum,
				uid = uid,
			}

			table.insert(self.textures_sorted, self.textures[uid])

			self:SetSize(tex:GetSize():Copy())
		else
			self.textures[uid] = nil
		end
	elseif tex then
		local rb = self.render_buffers[uid] or gl.CreateRenderbuffer()

		-- ASDF
		if tex.size then
			tex.width = tex.size.x
			tex.height = tex.size.y
			tex.size = nil
		end

		rb:Storage("GL_" .. tex.internal_format:upper(), tex.width, tex.height)
		self.gl_fb:Renderbuffer(enum, rb.id)

		self.render_buffers[uid] = {rb = rb}
	elseif self.render_buffers[uid] then
		self.render_buffers[uid].rb:Delete()
		self.render_buffers[uid] = nil
	end

	generate_draw_buffers(self)
end

function META:GetTexture(pos)
	local uid = attachment_to_enum(self, pos or 1)

	if not uid then
		return render.GetErrorTexture()
	end

	return self.textures[uid] and self.textures[uid].tex or render.GetErrorTexture()
end

function META:SetWrite(pos, b)
	if pos == "depth" or pos == "depth_stencil" or pos == "stencil" then return end

	pos = attachment_to_enum(self, pos)
	if pos then
		local val = self.textures[pos]
		local mode = val.mode

		if b then
			if mode == "GL_READ_FRAMEBUFFER" then
				val.mode = "GL_FRAMEBUFFER"
			end
		else
			if mode == "GL_FRAMEBUFFER" or mode == "GL_DRAW_FRAMEBUFFER" then
				val.mode = "GL_READ_FRAMEBUFFER"
			end
		end

		if mode ~= val.mode then
			generate_draw_buffers(self)
		end
	end

	update_drawbuffers(self)
end

function META:WriteThese(str)
	if not self.draw_buffers_cache[str] then
		for pos in pairs(self.textures) do
			self:SetWrite(pos, false)
		end

		if str == "all" then
			for pos in pairs(self.textures) do
				self:SetWrite(pos, true)
			end
		elseif str == "none" then
			for pos in pairs(self.textures) do
				self:SetWrite(pos, false)
			end
		else
			for _, pos in pairs(tostring(str):explode("|")) do
				pos = tonumber(pos) or pos
				self:SetWrite(pos, true)
			end
		end

		self.draw_buffers_cache[str] = {self.draw_buffers, self.draw_buffers_size}
	end

	self.draw_buffers = self.draw_buffers_cache[str][1]
	self.draw_buffers_size = self.draw_buffers_cache[str][2]

	update_drawbuffers(self)
end

function META:SaveDrawBuffers()
	self.old_draw_buffers = self.draw_buffers
	self.old_draw_buffers_size = self.draw_buffers_size
end

function META:RestoreDrawBuffers()
	if self.old_draw_buffers then
		self.draw_buffers = self.old_draw_buffers
		self.draw_buffers_size = self.old_draw_buffers_size
		update_drawbuffers(self)
	end
end

function META:Clear(i, r,g,b,a, d,s)
	i = i or "all"

	r = r or 0
	g = g or 0
	b = b or 0
	a = a or 0

	if i == "all" then
		self:SaveDrawBuffers()

		self:WriteThese("all")

		local color = ffi.new("float[4]",r,g,b,a)

		for i = 0, self.draw_buffers_size or 1 do
			self.gl_fb:Clearfv("GL_COLOR", i, color)
		end

		if d or s then
			local old = render.EnableDepth(true)
			if d and s then
				self.gl_fb:Clearfi("GL_DEPTH_STENCIL", 0, d or 0, s or 0)
			elseif d then
				self.gl_fb:Clearfv("GL_DEPTH", 0, ffi.new("float[1]", d))
			elseif s then
				self.gl_fb:Cleariv("GL_STENCIL", 0, ffi.new("int[1]", s))
			end
			render.EnableDepth(old)
		end

		self:RestoreDrawBuffers()
	elseif i == "color" then
		self:SaveDrawBuffers()

		self:WriteThese("all")

		local color = ffi.new("float[4]",r,g,b,a)

		for i = 0, self.draw_buffers_size or 1 do
			self.gl_fb:Clearfv("GL_COLOR", i, color)
		end

		self:RestoreDrawBuffers()
	elseif i == "depth" then
		local old = render.EnableDepth(true)

		self.gl_fb:Clearfv("GL_DEPTH", 0, ffi.new("float[1]", r))

		render.EnableDepth(old)
	elseif i == "stencil" then

		self.gl_fb:Cleariv("GL_STENCIL", 0, ffi.new("int[1]", r))

	elseif i == "depth_stencil" then
		local old = render.EnableDepth(true)

		self.gl_fb:Clearfi("GL_DEPTH_STENCIL", 0, r or 0, g or 0)

		render.EnableDepth(old)
	elseif type(i) == "number" then
		self:SaveDrawBuffers()

		self:SetWrite(i, true)
		self.gl_fb:Clearfv("GL_COLOR", 0, ffi.new("float[4]",r,g,b,a))

		self:RestoreDrawBuffers()
	elseif self.textures[i] then
		self:SaveDrawBuffers()

		self:SetWrite(i, true)
		self.gl_fb:Clearfv("GL_COLOR", 0, ffi.new("float[4]",r,g,b,a))

		self:RestoreDrawBuffers()
	end
end

prototype.Register(META)