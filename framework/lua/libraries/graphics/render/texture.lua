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
	META:GetSet("MipMapLevels", 0)
	META:GetSet("Path", "")
	META:GetSet("Multisample", 0)
	META:GetSet("InternalFormat", "rgba8")
	META:IsSet("SRGB", true)
	META:GetSet("DepthTextureMode")
	META:GetSet("BaseLevel", 0)
	META:GetSet("CompareFunc", "never")
	META:GetSet("MinFilter", "nearest")
	META:GetSet("MagFilter", "nearest")
	META:GetSet("MaxLevel", 0)
	META:GetSet("WrapS", "repeat")
	META:GetSet("WrapT", "repeat")
	META:GetSet("WrapR", "repeat")
	META:GetSet("LoadingTexture")
META:EndStorable()

META:IsSet("Loading", false)

local function parse_path(str)
	local flags, rest = str:match("^(%b[])(.+)")
	if flags then
		local temp = {}
		for i,v in ipairs(flags:sub(2,-2):split(",")) do
			local b = true
			if v:startswith("~") then
				v = v:sub(2)
				b = false
			end
			temp[v] = b
		end
		return rest, temp
	end

	return str
end

function META:__copy()
	return self
end

function META:GetSuggestedMipMapLevels()
	return math.floor(math.log(math.max(self.Size.x, self.Size.y)) / math.log(2)) + 1
end

function META:SetPath(path)
	self.Path = path
	local path, flags = parse_path(path)

	if flags then
		if flags.srgb ~= nil then
			self:SetSRGB(flags.srgb)
		end
	end

	self:LoadTextureFromPath(path)
end

function META:LoadTextureFromPath(path, face)
	self.Loading = true

	resource.Download(path, function(full_path)
		local val, err = vfs.Read(full_path)
		if val then
			local info, err = render.DecodeTexture(val, full_path)

			if info then
				info.face = info.face or face

				if self.Size:IsZero() then
					self:SetSize(Vec2(info.width, info.height))
				end
				self:Upload(info)
			else
				wlog("[%s] unable to decode %s: %s\n", self, path, err)
			end
		else
			wlog("[%s] unable to read %s: %s\n", self, full_path, err)
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
			local path_face = path:gsub("(%..+)", function(rest) return face .. rest end)
			if vfs.IsFile(path_face) then
				if path_face:endswith(".vmt") then
					local _, vmt = next(utility.VDFToTable(vfs.Read(path_face), function(key) return (key:lower():gsub("%$", "")) end))
					if vmt.basetexture then
						path_face = "materials/" .. vmt.basetexture .. ".vtf"
					elseif vmt.hdrcompressedtexture then
						path_face = "materials/" .. vmt.hdrcompressedtexture .. ".vtf"
					end
					if vfs.IsFile(path_face) then
						self:LoadTextureFromPath(path_face, i)
					else
						wlog("tried to load cubemap %s but %s does not exist", path, path_face)
					end
				else
					self:LoadTextureFromPath(vmt.basetexture, i)
				end
			else
				wlog("tried to load cubemap %s but %s does not exist", path, path_face)
				break
			end
		end
	end
end

function META:SetupStorage()

end

function META:Upload(data)
	if not data and self.downloaded_image then
		data = self.downloaded_image
	end

	data.mip_map_level = data.mip_map_level or 1
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

	self:_Upload(data, y)

	self.downloaded_image = nil

	return self
end

function META:GenerateMipMap()

end

function META:DumpInfo()
	logn("==================================")
		logn("storage type = ", self.StorageType)
		logn("internal format = ", self.InternalFormat)
		if self.MipMapLevels < 1 then
			logn("mip map levels = ", math.floor(math.log(math.max(self.Size.x, self.Size.y)) / math.log(2)) + 1, "(", self, ".MipMapLevels = ", self.MipMapLevels ,")")
		else
			logn("mip map levels = ", self.MipMapLevels)
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

function META:CreateBuffer(mip_map_level, format_override)
	mip_map_level = mip_map_level or 1

	local size = self:GetMipSize(mip_map_level)

	local format = render.GetTextureFormatInfo(format_override or self.InternalFormat)
	local byte_size = size.x * size.y * size.z * ffi.sizeof(format.ctype)

	return format.ctype_array(byte_size), nil, byte_size, format
end

function META:Download(mip_map_level, format_override)
	mip_map_level = mip_map_level or 1
	local size = self:GetMipSize(mip_map_level)

	local buffer, ref, byte_size, format = self:CreateBuffer(mip_map_level, format_override)

	self:_Download(mip_map_level, buffer, byte_size, format)

	return {
		type = format.number_type.friendly,
		buffer = buffer,
		width = size.x,
		height = size.y,
		depth = size.z,
		format = format.preferred_upload_format,
		mip_map_level = mip_map_level,
		size = size.x * size.y * size.z * ffi.sizeof(format.ctype),
		length = (size.x * size.y * size.z) - 1, -- for i = 0, data.length do
		channels = #format.bits,
		__ref = ref,
	}
end

function META:Save(format_override)
	local mip_map_levels = self.MipMapLevels

	if mip_map_levels < 1 then
		mip_map_levels = self:GetSuggestedMipMapLevels()
	end

	local data = {variables = self:GetStorableTable(), mip_maps = {}}
	data.variables.Path = nil

	for i = 1, mip_map_levels do
		data.mip_maps[i] = self:Download(i, format_override, true)
	end

	data.variables = serializer.Encode("luadata", data.variables)

	return data
end

function META:Load(data)
	data.variables = serializer.Decode("luadata", data.variables)
	self:SetStorableTable(data.variables)
	self:SetupStorage()
	for i, data in ipairs(data.mip_maps) do
		self:Upload(data)
	end
end

function META:Clear(mip_map_level)
	error("nyi", 2)
end

function META:IteratePixels()
	local image = self.downloaded_image or self:Download()
	self.downloaded_image = image

	local x = 0
	local y = 0
	-- z ?
	local i = 0

	local buffer = image.buffer

	x = x - 1
	i = i - 1

	return function()
		if i < image.length then

			if x >= image.width then
				y = y + 1
				x = 0
			end

			x = x + 1
			i = i + 1

			local y = -y + image.height

			if image.format == "bgra" then
				return x, y, i, buffer[i].b, buffer[i].g, buffer[i].r, buffer[i].a
			elseif image.format == "rgba" then
				return x, y, i, buffer[i].r, buffer[i].b, buffer[i].g, buffer[i].a
			elseif image.format == "bgr" then
				return x, y, i, buffer[i].b, buffer[i].g, buffer[i].r
			elseif image.format == "rgb" then
				return x, y, i, buffer[i].r, buffer[i].g, buffer[i].b
			elseif image.format == "red" then
				return x, y, i, buffer[i].r
			end
		end
	end
end

function META:GetRawPixelColor(x, y)
	local image = self.downloaded_image or self:Download()
	self.downloaded_image = image

	x = math.clamp(math.floor(x), 0, image.width)
	y = math.clamp(math.floor(y), 0, image.height)

	y = -y + image.height

	local i = y * image.width + x

	if image.format == "bgra" then
		return image.buffer[i].b, image.buffer[i].g, image.buffer[i].r, image.buffer[i].a
	elseif image.format == "rgba" then
		return image.buffer[i].r, image.buffer[i].g, image.buffer[i].b, image.buffer[i].a
	elseif image.format == "bgr" then
		return image.buffer[i].b, image.buffer[i].g, image.buffer[i].r
	elseif image.format == "rgb" then
		return image.buffer[i].r, image.buffer[i].g, image.buffer[i].b
	elseif image.format == "red" then
		return image.buffer[i].r
	end
end

function META:SetRawPixelColor(x, y, r,g,b,a)
	local image = self.downloaded_image or self:Download()
	self.downloaded_image = image

	x = math.clamp(math.floor(x), 0, image.width)
	y = math.clamp(math.floor(y), 0, image.height)

	y = -y + image.height

	local i = y * image.width + x

	if image.format == "bgra" then
		image.buffer[i].b = r
		image.buffer[i].g = g
		image.buffer[i].r = b
		image.buffer[i].a = a
	elseif image.format == "rgba" then
		image.buffer[i].r = r
		image.buffer[i].b = g
		image.buffer[i].g = b
		image.buffer[i].a = a
	elseif image.format == "bgr" then
		image.buffer[i].b = r
		image.buffer[i].g = g
		image.buffer[i].r = b
	elseif image.format == "rgb" then
		image.buffer[i].r = r
		image.buffer[i].g = g
		image.buffer[i].b = b
	elseif image.format == "red" then
		image.buffer[i].r = r
	end
end

function META:SetPixelColor(x,y, color)
	self:SetRawPixelColor(x,y, color.r*255, color.g*255, color.b*255, color.a*255)
end

function META:GetPixelColor(x, y)
	return ColorBytes(self:GetRawPixelColor(x, y))
end

function META:Fill(callback)
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
function META:BeginWrite()
	local fb = self.fb or render.CreateFrameBuffer()
	fb.Size.x = self.Size.x
	fb.Size.y = self.Size.y
	fb:SetTexture(1, self)
	self.fb = fb

	fb:Begin()
	render2d.PushMatrix()
	render2d.LoadIdentity()
	render2d.Scale(self.Size.x, self.Size.y)
end

function META:EndWrite()
	render2d.PopMatrix()
	self.fb:End()
end

function META:GetID()
	error("nyi", 2)
end

function META:ToTGA(pixel_callback)
	local data = self:Download(1, "bgra8")

	local buffer = utility.CreateBuffer()
	buffer:WriteByte(0) -- id length
	buffer:WriteByte(0) -- color map type
	buffer:WriteByte(2) -- data type code
	buffer:WriteShort(0) -- color map origin
	buffer:WriteShort(0) -- color map length
	buffer:WriteByte(0) -- color map depth
	buffer:WriteShort(0) -- x origin
	buffer:WriteShort(0) -- y origin
	buffer:WriteShort(data.width) -- width
	buffer:WriteShort(data.height) -- height
	buffer:WriteByte(data.channels * 8) -- bits per pixel
	buffer:WriteByte(8) -- image descriptor

	if pixel_callback then
		local x = 0
		local y = 0
		local buffer = data.buffer

		for i = 0, data.length do
			if x >= data.width then
				y = y + 1
				x = 0
			end

			local r,g,b,a

			if data.format == "bgra" then
				b,g,r,a = pixel_callback(x, y, i, buffer[i].b, buffer[i].g, buffer[i].r, buffer[i].a)
			elseif data.format == "rgba" then
				r,g,b,a = pixel_callback(x, y, i, buffer[i].r, buffer[i].b, buffer[i].g, buffer[i].a)
			elseif data.format == "bgr" then
				b,g,r = pixel_callback(x, y, i, buffer[i].b, buffer[i].g, buffer[i].r)
			elseif data.format == "rgb" then
				r,g,b = pixel_callback(x, y, i, buffer[i].r, buffer[i].g, buffer[i].b)
			elseif data.format == "red" then
				r = pixel_callback(x, y, i, buffer[i].r)
			end

			if r then buffer[i].r = r end
			if g then buffer[i].g = g end
			if b then buffer[i].b = b end
			if a then buffer[i].a = a end

			x = x + 1
		end
	end

	buffer:WriteString(ffi.string(data.buffer, data.size))

	return buffer:GetString()
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

	local template2 = [[
		%s

		out vec4 out_color;

		void main()
		{
			out_color = shade();
		}
	]]

	function META:Shade(fragment_shader, vars, blend_mode)
		blend_mode = blend_mode or "alpha"
		if not render2d.IsReady() then
			event.AddListener("2DReady", self, function()
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
					source = fragment_shader:find("vec4 shade") and template2:format(fragment_shader) or template:format(fragment_shader),
				}
			}

			shader = render.CreateShader(data)

			self.shaders[name] = shader
		end

		render.SetPresetBlendMode(blend_mode)

		self:BeginWrite()
			if vars then
				for k,v in pairs(vars) do
					shader[k] = v
				end
			end

			shader:Bind()
			render2d.rectangle:Draw(render2d.rectangle_indices)
		self:EndWrite()

		return self
	end
end

META:Register()

function render.CreateTexture(type)
	local self = META:CreateObject()

	if type then
		self.StorageType = type
	end

	render._CreateTexture(self, type)

	return self
end

render.texture_path_cache = render.texture_path_cache or {}

function render.CreateTextureFromPath(str, ...)
	if render.texture_path_cache[str] then
		return render.texture_path_cache[str]
	end

	local self = render.CreateTexture("2d")

	self:SetPath(str, ...)

	render.texture_path_cache[str] = self

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

serializer.GetLibrary("luadata").SetModifier("texture", function(var) return ("Texture(%q)"):format(var:GetPath()) end, render.CreateTextureFromPath, "Texture")