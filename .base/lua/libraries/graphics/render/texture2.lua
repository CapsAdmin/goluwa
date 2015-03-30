local TOENUM = function(str) return "GL_" .. str:upper() end

local gl = require("graphics.ffi.opengl")

local META = prototype.CreateTemplate("texture2")

META:GetSet("StorageType", "2d")
META:GetSet("Size", Vec2())
META:GetSet("InternalFormat", "rgba8")
META:GetSet("MipMapLevels", 3)

function META:OnRemove()
	self.id:Delete()
end

function META:Upload(data)
	data.mip_map_level = data.mip_map_level or 0
	data.format = data.format or "rgba"
	data.type = data.type or "unsigned_byte"
	
	if type(data.buffer) == "string" then 
		data.buffer = ffi.cast("uint8_t *", data.buffer) 
	end
	
	if self.StorageType == "1d" then
		data.x = data.x or 0
		
		self.id:Storage1D(self.MipMapLevels, TOENUM(self.InternalFormat), data.width)
		
		if data.image_size then
			self.id:CompressedSubImage1D(data.mip_map_level, data.x,  data.width, TOENUM(data.format), TOENUM(data.type), data.image_size, data.buffer)
		else
			self.id:SubImage1D(data.mip_map_level, data.x,  data.width, TOENUM(data.format), TOENUM(data.type), data.buffer)
		end
	elseif self.StorageType == "2d" then
		data.x = data.x or 0
		data.y = data.y or 0
		
		self.id:Storage2D(self.MipMapLevels, TOENUM(self.InternalFormat), data.width, data.height)
		
		if data.image_size then
			self.id:CompressedSubImage2D(data.mip_map_level, data.x, data.y, data.width, data.height, TOENUM(data.format), TOENUM(data.type), data.image_size, data.buffer)
		else
			self.id:SubImage2D(data.mip_map_level, data.x, data.y, data.width, data.height, TOENUM(data.format), TOENUM(data.type), data.buffer)
		end
	elseif self.StorageType == "3d" then
		data.x = data.x or 0
		data.y = data.y or 0
		data.z = data.z or 0
		
		self.id:Storage3D(self.MipMapLevels, TOENUM(self.InternalFormat), data.width, data.height, data.depth)
		
		if data.image_size then
			self.id:CompressedSubImage3D(data.mip_map_level, data.x, data.y, data.z, data.width, data.height, data.depth, TOENUM(data.format), TOENUM(data.type), data.image_size, data.buffer)
		else
			self.id:SubImage3D(data.mip_map_level, data.x, data.y, data.z, data.width, data.height, data.depth, TOENUM(data.format), TOENUM(data.type), data.buffer)
		end
	end
	
	self.id:GenerateMipmap()
	self.Size.w = data.width
	self.Size.h = data.height
end

function META:Download()
	self.id:GetImage(0, "GL_RGBA", "GL_UNSIGNED_BYTE", bufSize, pixels)
end

function META:Bind(location)
	gl.BindTextureUnit(location, self.id.id)
end

META:Register()

local function Texture(storage_type)	
	local self = prototype.CreateObject(META)
	if storage_type then self:SetStorageType(storage_type) end
	self.id = gl.CreateTexture("GL_TEXTURE_" .. self.StorageType:upper())
	
	return self
end

local tex = Texture()

sockets.Download("https://www.opengl.org/img/opengl_logo.jpg", function(buffer)
	local devil = require("graphics.ffi.devil")
	local buffer, w, h = devil.LoadImage(buffer, true)
		
	tex:Upload({
		buffer = buffer,
		width = w,		
		height = h,
		format = "bgra",
	})
end)

local shader = render.CreateShader({
	name = "test",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},			
		source = [[
			#version 420
			layout(binding = 0) uniform sampler2D tex1;
			out highp vec4 frag_color;
			
			void main()
			{	
				vec4 tex_color = texture(tex1, uv);
				
				frag_color = tex_color;
			}
		]],
	}
})

event.AddListener("PostDrawMenu", "lol", function()
	tex:Bind(0)
	surface.PushMatrix(0, 0, tex:GetSize():Unpack())
		render.SetShaderOverride(shader)
		surface.rect_mesh:Draw()
		render.SetShaderOverride()
	surface.PopMatrix()
end)
