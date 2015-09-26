local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local base_color = gl.e.GL_COLOR_ATTACHMENT0

local function attachment_to_enum(self, var)
	if not var then return end

	if self.textures[var] then
		return var
	elseif type(var) == "number" then
		return base_color + var - 1
	elseif var == "depth" then
		return "GL_DEPTH_ATTACHMENT"
	elseif var == "stencil" then
		return "GL_STENCIL_ATTACHMENT"
	elseif var == "depth_stencil" then
		return "GL_DEPTH_STENCIL_ATTACHMENT"
	elseif var:startswith("color") then
		return base_color + (tonumber(var:match(".-(%d)")) or 0) - 1
	end
end

local function bind_mode_to_enum(str)
	if str == "all" or str == "read_write" then
		return "GL_FRAMEBUFFER"
	elseif str == "read" then
		return "GL_READ_FRAMEBUFFER"
	elseif str == "write" or str == "draw" then
		return "GL_DRAW_FRAMEBUFFER"
	end
end

local function generate_draw_buffers(self)
	local draw_buffers = {}
	--self.read_buffer = nil -- TODO

	for k,v in pairs(self.textures) do
		if (v.mode == "GL_DRAW_FRAMEBUFFER" or v.mode == "GL_FRAMEBUFFER") and not v.draw_manual then
			table.insert(draw_buffers, v.pos)
		else
			--if self.read_buffer then
			--	warning("more than one read buffer attached", 2)
			--end
			--self.read_buffer = v.mode
			--table.insert(draw_buffers, 0)
		end
	end

	table.sort(draw_buffers, function(a, b) return a < b end)

	return ffi.new("GLenum["..#draw_buffers.."]", draw_buffers), #draw_buffers
end

local function update_drawbuffers(self)
	if self.draw_buffers ~= self.last_draw_buffers then
		self.fb:DrawBuffers(self.draw_buffers_size, self.draw_buffers)
		self.last_draw_buffers = self.draw_buffers
	end
end

local META = prototype.CreateTemplate("framebuffer")

META:GetSet("BindMode", "all", {"all", "read", "write"})
META:GetSet("Size", Vec2(128,128))

function render.GetScreenFrameBuffer()
	if not gl.GenFramebuffer then return end
	if not render.screen_buffer then
		local self = prototype.CreateObject(META)
		self.fb = gl.CreateFramebuffer(0)
		self.textures = {}
		self.render_buffers = {}
		self.draw_buffers_cache = {}
		self:SetSize(render.GetScreenSize())
		self:SetBindMode("read_write")

		render.screen_buffer = self
	end

	return render.screen_buffer
end

function render.CreateFrameBuffer(width, height, textures)
	local self = prototype.CreateObject(META)
	self.fb = gl.CreateFramebuffer()
	self.textures = {}
	self.render_buffers = {}
	self.draw_buffers_cache = {}

	self:SetBindMode("read_write")

	if width and height then
		self:SetSize(Vec2(width, height))

		if not textures then
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

			tex:SetMipMapLevels(1)
			tex:SetupStorage()
			--tex:Clear()

			self:SetTexture(attach, tex, nil, name)
		end

		self:CheckCompletness()
	end

	return self
end

function META:__tostring2()
	return ("[%i]"):format(self.fb.id)
end

function META:CheckCompletness()
	local err = self.fb:CheckStatus("GL_FRAMEBUFFER")

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
			logn(v.tex, " attached to ", v.pos)
			v.tex:DumpInfo()
		end

		warning(str)
	end
end

function META:SetBindMode(str)
	self.BindMode = str

	self.enum_bind_mode = bind_mode_to_enum(str)
end

do -- binding
	local current_id = 0

	do
		local stack = {}

		function META:Push(...)
			table.insert(stack, current_id)

			self:Bind()

			update_drawbuffers(self)

			--if fb.read_buffer then
			--	gl.ReadBuffer(fb.read_buffer)
			--end

			current_id = self.fb.id
		end

		function META:Pop()
			local id = table.remove(stack)

			--fb:Unbind()
			gl.BindFramebuffer("GL_FRAMEBUFFER", id)

			current_id = id
		end

		function META:Begin(...)
			self:Push(...)
			render.PushViewport(0, 0, self.Size.x, self.Size.y)
		end

		function META:End()
			render.PopViewport()
			self:Pop()
		end
	end

	function META:Bind()
		self.fb:Bind(self.enum_bind_mode)
		render.active_framebuffer = self
	end

	function META:Unbind()
		gl.BindFramebuffer(self.enum_bind_mode, 0) -- uh
		render.active_framebuffer = render.GetScreenFrameBuffer()
	end

	function render.GetActiveFramebuffer()
		return render.active_framebuffer
	end
end

function META:SetCubemapTexture(pos, i, tex)
	pos = attachment_to_enum(self, pos)
	self.fb:TextureFace(pos, tex and tex.gl_tex.id or 0, 0, i - 1)
end

function META:SetTexture(pos, tex, mode, uid, face)
	pos = attachment_to_enum(self, pos)
	mode = bind_mode_to_enum(mode or "write")

	if not uid then
		uid = pos
	end

	if typex(tex) == "texture" then
		local id = tex and tex.gl_tex.id or 0 -- 0 will be detach if tex is nil

		if face then
			self.fb:TextureLayer(pos, tex and tex.gl_tex.id or 0, 0, face - 1)
		else
			self.fb:Texture(pos, id, 0)
		end

		if id ~= 0 then
			self.textures[uid] = {
				tex = tex,
				mode = mode,
				pos = pos,
				uid = uid,
				draw_manual = pos == "GL_DEPTH_ATTACHMENT" or pos == "GL_STENCIL_ATTACHMENT" or pos == "GL_DEPTH_STENCIL_ATTACHMENT"
			}
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
		self.fb:Renderbuffer(pos, rb.id)

		self.render_buffers[uid] = {rb = rb}
	elseif self.render_buffers[uid] then
		self.render_buffers[uid].rb:Delete()
		self.render_buffers[uid] = nil
	end

	self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
end

function META:GetTexture(pos)
	local uid = attachment_to_enum(self, pos or 1)

	if not uid then
		return render.GetErrorTexture()
	end

	return self.textures[uid] and self.textures[uid].tex or render.GetErrorTexture()
end

function META:SetWrite(pos, b)
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
			self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
		end
	end

	update_drawbuffers(self)
end

function META:SetRead(pos, b)
	pos = attachment_to_enum(self, pos)

	if pos then
		local val = self.textures[pos]
		local mode = val.mode

		if b then
			if val.mode == "GL_DRAW_FRAMEBUFFER" then
				val.mode = "GL_FRAMEBUFFER"
				self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
			end
		else
			if mode == "GL_FRAMEBUFFER" or mode == "GL_READ_FRAMEBUFFER" then
				val.mode = "GL_DRAW_FRAMEBUFFER"
			end
		end

		if mode ~= val.mode then
			self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
		end
	end
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

	self.draw_buffers, self.draw_buffers_size = self.draw_buffers_cache[str][1], self.draw_buffers_cache[str][2]

	update_drawbuffers(self)
end

do
	local temp_color = ffi.new("float[4]")
	local temp_colori = ffi.new("int[4]")

	function META:Clear(i, r,g,b,a, d,s)
		i = i or "all"

		temp_color[0] = r or 0
		temp_color[1] = g or 0
		temp_color[2] = b or 0
		temp_color[3] = a or 0

		if i == "all" then
			self:Clear("color", r,g,b,a)
			self:Clear("depth", d or 1)
			if s then self:Clear("stencil", s) end
		elseif i == "color" then
			local x,y = self.draw_buffers, self.draw_buffers_size
			self:WriteThese("all")

			for i = 0, self.draw_buffers_size or 1 do
				self.fb:Clearfv("GL_COLOR", i, temp_color)
			end

			if x then
				self.draw_buffers, self.draw_buffers_size = x,y
				update_drawbuffers(self)
			end
		elseif i == "depth" then
			temp_color[0] = r or 0
			local old = render.EnableDepth(true)
			self.fb:Clearfv("GL_DEPTH", 0, temp_color)
			render.EnableDepth(old)
		elseif i == "stencil" then
			temp_colori[0] = r or 0
			self.fb:Cleariv("GL_STENCIL", 0, temp_colori)
		elseif i == "depth_stencil" then
			local old = render.EnableDepth(true)
			self.fb:Clearfi("GL_DEPTH_STENCIL", 0, r or 0, g or 0)
			render.EnableDepth(old)
		elseif type(i) == "number" then
			local x,y = self.draw_buffers, self.draw_buffers_size
			self:WriteThese(i)
			self.fb:Clearfv("GL_COLOR", 0, temp_color)
			if x then
				self.draw_buffers, self.draw_buffers_size = x,y
				update_drawbuffers(self)
			end
		elseif self.textures[i] then
			local x,y = self.draw_buffers, self.draw_buffers_size
			self:WriteThese(i)
			self.fb:Clearfv("GL_COLOR", 0, temp_color)
			if x then
				self.draw_buffers, self.draw_buffers_size = x,y
				update_drawbuffers(self)
			end
		end
	end
end

prototype.Register(META)