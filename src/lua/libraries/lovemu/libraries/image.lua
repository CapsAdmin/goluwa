if not GRAPHICS then return end

local love = ... or love

local textures = lovemu.textures
local FILTER = "nearest"

love.image = {}

do -- image data

	local ImageData = {}
	ImageData.Type = "ImageData"

	function ImageData:getSize()
		return #buffer
	end

	function ImageData:getWidth()
		return self.tex.w
	end

	function ImageData:getHeight()
		return self.tex.h
	end

	function ImageData:getDimensions()
		return self.tex.w, self.tex.h
	end

	function ImageData:setFilter()

	end

	function ImageData:paste(source, dx, dy, sx, sy, sw, sh)

	end

	function ImageData:encode(outfile)

	end

	function ImageData:getString()
		return buffer
	end

	function ImageData:setWrap()

	end

	function ImageData:getWrap()

	end

	function ImageData:getPixel(x,y, r,g,b,a)
		do return math.random(255), math.random(255), math.random(255), math.random(255) end
		local rr, rg, rb, ra
		self.tex:Fill(function(_x,_y, i, r,g,b,a)
			if _x == x and _y == y then
				rr = r
				rg = g
				rb = b
				ra = a
				return true
			end
		end, nil, true)
		return rr or 0, rg or 0, rb or 0, ra or 0
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

	local freeimage = require("graphics.ffi.freeimage")

	function love.image.newImageData(a, b) --partial
		if lovemu.Type(a) == "ImageData" then
			return a -- uhhh
		end

		check(a, "string", "number")
		check(b, "number", "nil")

		local w
		local h
		local buffer

		if type(a) == "number" and type(b) == "number" then
			w = a
			h = a
		elseif not b and type(a) == "string" then
			buffer, w, h = freeimage.LoadImage(a)
			if not buffer then
				a = vfs.Read(a, "rb")
				buffer, w, h = freeimage.LoadImage(a)
			end
		end

		local self = lovemu.CreateObject(ImageData)

		local tex = render.CreateTexture("2d")
		tex:SetSize(Vec2(w, h))
		tex:SetMinFilter(FILTER)
		tex:SetMagFilter(FILTER)

		lovemu.textures[self] = tex

		self.tex = tex

		return self
	end
end