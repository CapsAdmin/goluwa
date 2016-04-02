local render = ... or _G.render
local ffi = require("ffi")

local META = prototype.CreateTemplate("texture")

function META:__tostring2()
	if self.error_reason then
		return ("[error: %s][%s]"):format(self.error_reason, self:GetPath())
	else
		return ("[%s]"):format(self:GetPath())
	end
end

META:StartStorable()
META:GetSet("StorageType", "2d")
META:GetSet("Size", Vec2())
META:GetSet("Depth", 0)
META:GetSet("MipMapLevels", -1)
META:GetSet("Path", "")
META:GetSet("Multisample", 0)
META:GetSet("InternalFormat", "rgba8")
META:IsSet("SRGB", true)
META:GetSet("StencilTextureMode")
META:GetSet("DepthTextureMode")
META:GetSet("BaseLevel", 0)
META:GetSet("BorderColor", Color())
META:GetSet("CompareMode", "none")
META:GetSet("CompareFunc", "never")
META:GetSet("LodBias", 0)
META:GetSet("MinFilter", "nearest")
META:GetSet("MagFilter", "nearest")
META:GetSet("MaxLevel", 0)
META:GetSet("MaxLOD", 0)
META:GetSet("MinLOD", 0)
META:GetSet("SwizzleR", "zero")
META:GetSet("SwizzleG", "zero")
META:GetSet("SwizzleB", "zero")
META:GetSet("SwizzleA", "zero")
META:GetSet("SwizzleRgba", Color())
META:GetSet("WrapS", "repeat")
META:GetSet("WrapT", "repeat")
META:GetSet("WrapU", "repeat")
META:GetSet("Anisotropy", -1)
META:EndStorable()

META:IsSet("Loading", false)

function META:__copy()
	return self
end

function META:SetPath(path, face, flip_y)
	self.Path = path

	self.Loading = true

	resource.Download(path, function(full_path)
		local val, err = vfs.Read(full_path)
		if val then
			local buffer, w, h, info = render.DecodeTexture(val, full_path)

			if buffer then
				self:SetSize(Vec2(w, h))

				if flip_y == nil then
					--flip_y = full_path:endswith(".vtf")
				end

				self:Upload({
					buffer = buffer,
					width = w,
					height = h,
					format = info.format or "bgra",
					face = face, -- todo
					flip_y = flip_y,
					type = info.type,
				})
			else
				local reason = w
				logn("======")
				logf("[%s] unable to decode %s: %s\n", self, path, reason)
				logn("======")
			end
		else
			logn("======")
			logf("[%s] unable to read %s: %s\n", self, full_path, err)
			logn("======")
		end

		self.Loading = false

		if self.OnLoad then
			self:OnLoad()
		end
	end, function(reason)
		logf("[%s] unable to find %s: %s\n", self, path, reason)
		self.Loading = false
		self:MakeError(reason)
	end)
end

do -- todo
	local faces = {
		"ft",
		"bk",
		"up",
		"dn",
		"rt",
		"lf",
	}
--[[
"FRONT",
"BACK",
"LEFT",
"RIGHT",
"TOP",
"BOTTOM",
]]

	function META:LoadCubemap(path)
		path = path:sub(0,-1)
		for i, face in pairs(faces) do
			self:SetPath(path:gsub("(%..+)", function(rest) return face .. rest end), i, false)
		end
	end
end

function META:SetupStorage()
	self:_SetupStorage()

	self.storage_setup = true
end

function META:Upload(data)
	data.mip_map_level = data.mip_map_level or 0
	data.format = data.format or "rgba"
	data.type = data.type or "unsigned_byte"
	data.width = data.width or self:GetSize().x
	data.height = data.height or self:GetSize().y

	if type(data.buffer) == "string" then
		data.buffer = ffi.cast("uint8_t *", data.buffer)
	elseif type(data.buffer) == "table" and typex(data.buffer[1]) == "color" then
		local numbers = {}
		local i2 = 0
		for i = 1, #data.buffer do
			numbers[i2] = data.buffer[i].r * 255 i2 = i2 + 1
			numbers[i2] = data.buffer[i].g * 255 i2 = i2 + 1
			numbers[i2] = data.buffer[i].b * 255 i2 = i2 + 1
			numbers[i2] = data.buffer[i].a * 255 i2 = i2 + 1
		end
		data.buffer = ffi.new("uint8_t[?]", (data.width * data.height) * 4, numbers)
		data.flip_y = true
	end

	check(data.buffer, "cdata")

	if self.StorageType == "cube_map" then
		if data.face then
			data.z = data.face - 1
		end
		data.depth = data.depth or 1
	end

	local y

	if data.y then
		y = -data.y + self.Size.y - data.height
	end

	if data.flip_y or data.flip_x then
		local stride

		if data.format == "rgba" or data.format == "bgra" then
			stride = 4
		elseif data.format == "rgb" or data.format == "bgr" then
			stride = 3
		else
			stride = 1
		end

		local buffer = ffi.cast("uint8_t *", data.buffer)
		local new_buffer = ffi.new("uint8_t[?]", data.width * data.height * stride)

		if data.flip_y and data.flip_x then
			for s = 0, stride - 1 do
			for x = 0, data.width - 1 do
			for y = 0, data.height - 1 do
				local i1 = (y * stride * data.width + x * stride) + s
				local i2 = ((-y+data.height-1) * stride * data.width + (-x+data.width-1) * stride) + s
				new_buffer[i1] = buffer[i2]
			end
			end
			end
		elseif data.flip_y then
			for s = 0, stride - 1 do
			for x = 0, data.width - 1 do
			for y = 0, data.height - 1 do
				local i1 = (y * stride * data.width + x * stride) + s
				local i2 = ((-y+data.height-1) * stride * data.width + x * stride) + s
				new_buffer[i1] = buffer[i2]
			end
			end
			end
		elseif data.flip_x then
			for s = 0, stride - 1 do
			for x = 0, data.width - 1 do
			for y = 0, data.height - 1 do
				local i1 = (y * stride * data.width + x * stride) + s
				local i2 = (y * stride * data.width + (-x+data.width-1) * stride) + s
				new_buffer[i1] = buffer[i2]
			end
			end
			end
		end

		data.buffer = new_buffer
	end

	self:_Upload(data)

	self.downloaded_image = nil

	return self
end

function META:GenerateMipMap()

end

function META:DumpInfo()
	logn("==================================")
		logn("storage type = ", self.StorageType)
		logn("internal format = ", self.InternalFormat)
		if self.MipMapLevels > 0 then
			logn("mip map levels = ", self.MipMapLevels)
		else
			logn("mip map levels = ", math.floor(math.log(math.max(self.Size.x, self.Size.y)) / math.log(2)) + 1, "(", self, ".MipMapLevels = ", self.MipMapLevels ,")")
		end
		logn("size = ", self.Size)
		if self.StorageType == "3d" then
			logn("depth = ", self.Depth)
		end
		log(self:GetDebugTrace())
	logn("==================================")
end

function META:MakeError(reason)
	error("nyi", 2)
end

function META:CreateBuffer(format_override)
	local format = render.GetTextureFormatInfo(self.InternalFormat or format_override)
	local size = self.Size.x * self.Size.y * ffi.sizeof(format.ctype)
	local buffer = ffi.malloc(format.ptr_ctype, size)

	return buffer, size, format
end

function META:Download(mip_map_level, format_override)
	mip_map_level = mip_map_level or 0

	local buffer, size, format = self:CreateBuffer(format_override)

	self:_Download(mip_map_level, buffer, size, format)

	return {
		type = format.number_type.friendly,
		buffer = buffer,
		width = self.Size.x,
		height = self.Size.y,
		format = format.preferred_upload_format,
		mip_map_level = mip_map_level,
		size = self.Size.x * self.Size.y * ffi.sizeof(format.ctype),
		length = (self.Size.x * self.Size.y) - 1, -- for i = 0, data.length do
		channels = #format.bits,
	}
end

function META:Clear(mip_map_level)
	error("nyi", 2)
end

function META:Fill(callback)
	check(callback, "function")

	local image = self:Download()

	local x = 0
	local y = 0
	local buffer = image.buffer

	for i = 0, image.length do
		if x >= image.width then
			y = y + 1
			x = 0
		end

		local r,g,b,a

		if image.format == "bgra" then
			r,g,b,a = callback(x, y, i, buffer[i].b, buffer[i].g, buffer[i].r, buffer[i].a)
		elseif image.format == "rgba" then
			r,g,b,a = callback(x, y, i, buffer[i].r, buffer[i].b, buffer[i].g, buffer[i].a)
		elseif image.format == "bgr" then
			b,g,r = callback(x, y, i, buffer[i].b, buffer[i].g, buffer[i].r)
		elseif image.format == "rgb" then
			r,g,b = callback(x, y, i, buffer[i].r, buffer[i].g, buffer[i].b)
		elseif image.format == "red" then
			r = callback(x, y, i, buffer[i].r)
		end

		if r then buffer[i].r = r end
		if g then buffer[i].g = g end
		if b then buffer[i].b = b end
		if a then buffer[i].a = a end

		x = x + 1
	end

	self:Upload(image)

	return self
end

function META:GetPixelColor(x, y)
	x = math.clamp(math.floor(x), 1, self.Size.x)
	y = math.clamp(math.floor(y), 1, self.Size.y)

	y = self.Size.y - y

	local i = y * self.Size.x + x

	local image = self.downloaded_image or self:Download()
	self.downloaded_image = image

	local buffer = image.buffer

	if image.format == "bgra" then
		return buffer[i].b, buffer[i].g, buffer[i].r, buffer[i].a
	elseif image.format == "rgba" then
		return buffer[i].r, buffer[i].b, buffer[i].g, buffer[i].a
	elseif image.format == "bgr" then
		return buffer[i].b, buffer[i].g, buffer[i].r
	elseif image.format == "rgb" then
		return buffer[i].r, buffer[i].g, buffer[i].b
	elseif image.format == "red" then
		return buffer[i].r
	end
end

function META:BeginWrite()
	local fb = self.fb or render.CreateFrameBuffer()
	fb:SetSize(self:GetSize():Copy())
	fb:SetTexture(1, self)
	self.fb = fb

	fb:Begin()
	surface.PushMatrix()
	surface.LoadIdentity()
	surface.Scale(self.Size.x, self.Size.y)
end

function META:EndWrite()
	surface.PopMatrix()
	self.fb:End()
end

function META:GetID()
	error("nyi", 2)
end

do
	local template = [[
		out vec4 out_color;

		vec4 shade()
		{
			%s
		}

		void main()
		{
			out_color = shade();
		}
	]]

	function META:Shade(fragment_shader, vars, blend_mode)
		blend_mode = blend_mode or "alpha"
		if not surface.IsReady() then
			event.AddListener("SurfaceInitialized", self, function()
				self:Shade(fragment_shader, vars)
			end, {remove_after_one_call = true})
			return
		end

		self.shaders = self.shaders or {}

		local name = "shade_texture_" .. tostring(self:GetID()) .. "_" .. crypto.CRC32(fragment_shader)
		local shader = self.shaders[name]


		if not self.shaders[name] then
			local data = {
				name = name,
				shared = {
					variables = vars,
				},
				fragment = {
					variables = {
						self = self,
						size = self:GetSize(),
					},
					mesh_layout = {
						{uv = "vec2"},
					},
					source = template:format(fragment_shader),
				}
			}

			shader = render.CreateShader(data)

			self.shaders[name] = shader
		end

		render.SetBlendMode(blend_mode)

		self:BeginWrite()
			if vars then
				for k,v in pairs(vars) do
					shader[k] = v
				end
			end

			render.SetShaderOverride(shader)
			surface.rect_mesh:Draw()
			render.SetShaderOverride()
		self:EndWrite()

		return self
	end
end

if OPENGL then
	include("opengl/texture.lua", render, META)
end

META:Register()

function render.CreateTexture(type)
	local self = prototype.CreateObject(META)

	if type then
		self.StorageType = type
	end

	render._CreateTexture(self, type)

	return self
end

render.texture_path_cache = {}

function render.CreateTextureFromPath(path, srgb)
	if render.texture_path_cache[path] then
		return render.texture_path_cache[path]
	end

	local self = render.CreateTexture("2d")
	if srgb then self:SetSRGB(srgb) end
	self:SetPath(path)

	render.texture_path_cache[path] = self

	return self
end

function render.CreateBlankTexture(size, shade)
	local self = render.CreateTexture("2d")
	self:SetSize(size:Copy())
	self:SetupStorage()
	self:Clear()

	if shade then
		self:Shade(shade)
		self:GenerateMipMap()
		self.fb = nil
		self.shaders = nil
	end

	return self
end