if not GRAPHICS then return end

local love = ... or _G.love
local ENV = love._line_env

local ffi = require("ffi")

local textures = ENV.textures

love.image = love.image or {}

do -- image data

	local ImageData = line.TypeTemplate("ImageData")

	function ImageData:getSize()
		return self.size
	end

	function ImageData:getWidth()
		return self.tex.Size.x
	end

	function ImageData:getHeight()
		return self.tex.Size.y
	end

	function ImageData:getDimensions()
		return self.tex.Size.x, self.tex.Size.y
	end

	function ImageData:setFilter()

	end

	function ImageData:paste(source, dx, dy, sx, sy, sw, sh)

	end

	function ImageData:encode(outfile)

	end

	function ImageData:getString()
		return ffi.string(self.buffer, self.size)
	end

	function ImageData:setWrap()

	end

	function ImageData:getWrap()

	end

	function ImageData:getPixel(x,y)
		return self.tex:GetRawPixelColor(x, y)
	end

	function ImageData:setPixel(x,y, r,g,b,a)
		self.tex:SetRawPixelColor(x,y,r,g,b,a)
	end

	function ImageData:mapPixel(cb)
		self.tex:Fill(function(x,y,i, r,g,b,a)
			cb(x,y,r,g,b,a)
		end, false, true)
	end

	local freeimage = system.GetFFIBuildLibrary("freeimage")

	function love.image.newImageData(a, b)
		if line.Type(a) == "ImageData" then
			return a -- uhhh
		end

		local self = line.CreateObject("ImageData")

		local tex = render.CreateTexture("2d")

		if type(a) == "number" and type(b) == "number" then
			tex:SetSize(Vec2(a, b))
		else
			local info, err = render.DecodeTexture(a)

			if not info then
				info, err = render.DecodeTexture(vfs.Read(a, "rb"))
			end

			if info then
				tex:SetSize(Vec2(info.width, info.height))

				tex:Upload({
					buffer = info.buffer,
					width = info.width,
					height = info.height,
					format = info.format,
					type = info.type,
				})
			end
			self.buffer = buffer
		end

		tex:SetMinFilter("nearest")
		tex:SetMagFilter("nearest")

		ENV.textures[self] = tex

		self.tex = tex

		return self
	end

	line.RegisterType(ImageData)
end
