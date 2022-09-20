local render = ... or _G.render
local gl = require("opengl") -- OpenGL
if not render.IsExtensionSupported("ARB_framebuffer_object") then
	runfile("../null/framebuffer.lua", render)
	local META = prototype.GetRegistered("framebuffer")

	function META:ClearAll(r, g, b, a, d, s)
		gl.ClearColor(r or 0, g or 0, b or 0, a or 0)
		gl.ClearDepth(d or 0)
		gl.ClearStencil(s or 0)
		gl.Clear(
			bit.bor(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT, gl.e.GL_STENCIL_BUFFER_BIT)
		)
	end

	function META:ClearColor(r, g, b, a)
		gl.ClearColor(r or 0, g or 0, b or 0, a or 0)
		gl.Clear(gl.e.GL_COLOR_BUFFER_BIT)
	end

	function META:ClearDepth(d)
		gl.ClearDepth(d or 0)
		gl.Clear(gl.e.GL_DEPTH_BUFFER_BIT)
	end

	function META:ClearStencil(s)
		gl.ClearStencil(s or 0)
		gl.Clear(gl.e.GL_STENCIL_BUFFER_BIT)
	end

	function META:ClearDepthStencil(d, s)
		gl.ClearDepth(d or 0)
		gl.ClearStencil(s or 0)
		gl.Clear(bit.bor(gl.e.GL_STENCIL_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT))
	end

	function META:ClearTexture(i, r, g, b, a)
		self:ClearColor(r or 0, g or 0, b or 0, a or 0)
	end

	prototype.Register(META)
	return
end

local META = prototype.GetRegistered("framebuffer")
local ffi = require("ffi")
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
	local i = 1

	for _, v in ipairs(self.textures_sorted) do
		if
			(
				v.mode == "GL_DRAW_FRAMEBUFFER" or
				v.mode == "GL_FRAMEBUFFER"
			)
			and
			(
				v.enum ~= "GL_DEPTH_ATTACHMENT" and
				v.enum ~= "GL_STENCIL_ATTACHMENT" and
				v.enum ~= "GL_DEPTH_STENCIL_ATTACHMENT"
			)
		then
			draw_buffers[i] = v.enum
			i = i + 1
		end
	end

	--table.sort(draw_buffers, function(a, b) return a < b end)
	self.draw_buffers = ffi.new("GLenum[?]", i, draw_buffers)
	self.draw_buffers_size = i - 1
end

local function update_drawbuffers(self)
	if self.draw_buffers ~= self.last_draw_buffers then
		self.gl_fb:DrawBuffers(self.draw_buffers_size, self.draw_buffers)
		self.last_draw_buffers = self.draw_buffers
	end
end

function render._CreateFrameBuffer(self, id_override)
	self.gl_fb = gl.CreateFramebuffer(id_override)
	self.textures = {}
	self.textures_sorted = {}
	self.render_buffers = {}
	self.draw_buffers_cache = {}
end

function META:OnRemove()
	self.gl_fb:Delete()
end

function META:__tostring2()
	return ("[%i]"):format(self.gl_fb.id)
end

function META:SetBindMode(str)
	self.BindMode = str
	self.enum_bind_mode = bind_mode_to_enum[str]
end

local last_fb = 0

function META:_Bind()
	if last_fb ~= self.gl_fb.id then
		self.gl_fb:Bind(self.enum_bind_mode)
		last_fb = self.gl_fb.id
	end
end

function META:SetTextureLayer(pos, tex, layer)
	local enum = attachment_to_enum(self, pos)
	self.gl_fb:TextureLayer(enum, tex.gl_tex.id, 0, layer - 1)
end

function META:SetTexture(pos, tex, mode, uid, face)
	local enum = attachment_to_enum(self, pos)

	if not uid then uid = enum end

	if tex then
		if tex.gl_tex then
			local id = tex and tex.gl_tex.id or 0 -- 0 will be detach if tex is nil
			if face then
				self.gl_fb:TextureLayer(enum, tex and tex.gl_tex.id or 0, 0, face - 1)
			else
				self.gl_fb:Texture(enum, id, 0, tex.gl_tex.target)
			end

			for i, v in ipairs(self.textures_sorted) do
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

				if tex:GetMipMapLevels() < 1 then
					self.gen_mip_map_textures = self.gen_mip_map_textures or {}
					local ok = true

					for _, v in ipairs(self.gen_mip_map_textures) do
						if v == tex then ok = false end
					end

					if ok then table.insert(self.gen_mip_map_textures, tex) end
				end

				table.insert(self.textures_sorted, self.textures[uid])
				self:SetSize(tex:GetSize():Copy())
			end
		else
			local rb = self.render_buffers[uid] or gl.CreateRenderbuffer()

			-- ASDF
			if tex.size then
				tex.width = tex.size.x
				tex.height = tex.size.y
				tex.size = nil
			end

			if tex.samples then
				rb:StorageMultisample(tex.samples, "GL_" .. tex.internal_format:upper(), tex.width, tex.height)
			else
				rb:Storage("GL_" .. tex.internal_format:upper(), tex.width, tex.height)
			end

			self.gl_fb:Renderbuffer(enum, rb.id)
			self.render_buffers[uid] = {rb = rb}
		end
	else
		if self.render_buffers[uid] then self.render_buffers[uid].rb:Delete() end

		self.render_buffers[uid] = nil
		self.textures[uid] = nil
	end

	generate_draw_buffers(self)
end

function META:GetTexture(pos)
	pos = pos or 1

	if self.textures[pos] then return self.textures[pos].tex end

	local uid = attachment_to_enum(self, pos)

	if uid and self.textures[uid] then return self.textures[uid].tex end

	return render.GetErrorTexture()
end

function META:SetWrite(pos, b)
	if pos == "depth" or pos == "depth_stencil" or pos == "stencil" then return end

	pos = attachment_to_enum(self, pos)

	if pos then
		local val = self.textures[pos]

		if val then
			local mode = val.mode

			if b then
				if mode == "GL_READ_FRAMEBUFFER" then val.mode = "GL_FRAMEBUFFER" end
			else
				if mode == "GL_FRAMEBUFFER" or mode == "GL_DRAW_FRAMEBUFFER" then
					val.mode = "GL_READ_FRAMEBUFFER"
				end
			end

			if mode ~= val.mode then generate_draw_buffers(self) end
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
			for _, pos in pairs(tostring(str):split("|")) do
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

function META:CheckStatus()
	local ret = self.gl_fb:CheckStatus(self.enum_bind_mode)

	if ret == gl.e.GL_FRAMEBUFFER_COMPLETE then return true end

	return false, ret
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

function META:ClearAll(r, g, b, a, d, s)
	self:SaveDrawBuffers()
	self:WriteThese("all")
	local color = ffi.new("GLfloat[4]", r or 0, g or 0, b or 0, a or 0)

	for i = 0, self.draw_buffers_size do
		self.gl_fb:Clearfv("GL_COLOR", i, color)
	end

	if d or s then
		if d and s then
			self.gl_fb:Clearfi("GL_DEPTH_STENCIL", 0, d or 0, s or 0)
		elseif d then
			self.gl_fb:Clearfv("GL_DEPTH", 0, ffi.new("GLfloat[1]", d))
		elseif s then
			self.gl_fb:Cleariv("GL_STENCIL", 0, ffi.new("GLint[1]", s))
		end
	end

	self:RestoreDrawBuffers()
end

function META:ClearColor(r, g, b, a)
	self:SaveDrawBuffers()
	self:WriteThese("all")
	local color = ffi.new("GLfloat[4]", r or 0, g or 0, b or 0, a or 0)

	for i = 0, self.draw_buffers_size or 1 do
		self.gl_fb:Clearfv("GL_COLOR", i, color)
	end

	self:RestoreDrawBuffers()
end

function META:ClearDepth(d)
	self.gl_fb:Clearfv("GL_DEPTH", 0, ffi.new("GLfloat[1]", d or 0))
end

function META:ClearStencil(s)
	self.gl_fb:Cleariv("GL_STENCIL", 0, ffi.new("GLint[1]", s or 0))
end

function META:ClearDepthStencil(d, s)
	self.gl_fb:Clearfi("GL_DEPTH_STENCIL", 0, d or 0, s or 0)
end

function META:ClearTexture(i, r, g, b, a)
	self:SaveDrawBuffers()
	self:WriteThese(tostring(i))
	self.gl_fb:Clearfv("GL_COLOR", 0, ffi.new("GLfloat[4]", r or 0, g or 0, b or 0, a or 0))
	self:RestoreDrawBuffers()
end

function META.Blit(a, b, a_rect, b_rect, method)
	a_rect = a_rect or Rect(0, 0, a.Size.x, a.Size.y)
	b_rect = b_rect or Rect(0, 0, b.Size.x, b.Size.y)
	a.gl_fb:Blit(
		b.gl_fb.id,
		a_rect.x,
		a_rect.y,
		a_rect.w,
		a_rect.h,
		b_rect.x,
		b_rect.y,
		b_rect.w,
		b_rect.h,
		gl.e.GL_COLOR_BUFFER_BIT,
		method or "GL_NEAREST"
	)
end

prototype.Register(META)