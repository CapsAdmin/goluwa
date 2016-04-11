if not GRAPHICS then return end

local love = ... or _G.love
local ENV = love._lovemu_env

local ffi = require("ffi")

local textures = ENV.textures

love.image = love.image or {}

do -- image data

	local ImageData = lovemu.TypeTemplate("ImageData")

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
		return self.tex:GetPixelColor(x, y)
	end

	function ImageData:setPixel(x,y, r,g,b,a)
		self.tex:Fill(function(_x,_y, i)
			if _x == x and _y == y then
				return r,g,b,a
			end
		end, true)
	end

	function ImageData:mapPixel(cb)
		self.tex:Fill(function(x,y,i, r,g,b,a)
			cb(x,y,r,g,b,a)
		end, false, true)
	end

	local freeimage = desire("libfreeimage")

	function love.image.newImageData(a, b)
		if lovemu.Type(a) == "ImageData" then
			return a -- uhhh
		end

		check(a, "string", "number")
		check(b, "number", "nil")

		local self = lovemu.CreateObject("ImageData")

		local tex = render.CreateTexture("2d")

		if type(a) == "number" and type(b) == "number" then
			tex:SetSize(Vec2(a, b))
		else
			local buffer, w, h, info = render.DecodeTexture(a)

			if not buffer then
				buffer, w, h, info = render.DecodeTexture(vfs.Read(a, "rb"))
			end

			if buffer then
				tex:SetSize(Vec2(w, h))

				tex:Upload({
					buffer = buffer,
					width = w,
					height = h,
					format = info.format or "bgra",
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

	lovemu.RegisterType(ImageData)
end