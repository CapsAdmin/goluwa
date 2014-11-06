local structs = (...) or _G.structs

local META = {}

META.ClassName = "Vec2"

META.NumberType = "float"
META.Args = {{"x", "w", "p"}, {"y", "h", "y"}}

structs.AddAllOperators(META) 

-- length stuff
do 
	function META:GetLengthSquared()
		return self.x * self.x + self.y * self.y
	end

	function META:SetLength(num)
		local scale = num * 1/math.sqrt(self:GetLengthSquared())
		
		self.x = self.x * scale
		self.y = self.y * scale
	end

	function META:GetLength()
		return math.sqrt(self:GetLengthSquared())
	end

	META.__len = META.GetLength

	function META.__lt(a, b)
		if ffi.istype(a, b) and type(b) == "number" then
			return a:GetLength() < b
		elseif ffi.istype(b, a) and type(a) == "number" then
			return b:GetLength() < a
		end
	end

	function META.__le(a, b)
		if ffi.istype(a, b) and type(b) == "number" then
			return a:GetLength() <= b
		elseif ffi.istype(b, a) and type(a) == "number" then
			return b:GetLength() <= a
		end
	end

	function META:SetMaxLength(num)
		local length = self:GetLengthSquared()
		
		if length * length > num then
			local scale = num * 1/math.sqrt(length)
			
			self.x = self.x * scale
			self.y = self.y * scale
		end
	end
	
	function META.Distance(a, b)
		return (a - b):GetLength()
	end
end

function META:Rotate(angle)
	local cs = math.cos(angle);
	local sn = math.sin(angle);

	local xx = self.x * cs - self.y * sn;
	local yy = self.x * sn + self.y * cs;
	
	self.x = xx
	self.y = yy
	
	return self
end

structs.AddGetFunc(META, "Rotate", "Rotated")

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	
	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META.GetDot(a, b)
	return
		a.x * b.x +
		a.y * b.y
	end

function META:Normalize()
	local inverted_length = 1/math.sqrt(self:GetLengthSquared())
	
	self.x = self.x * inverted_length
	self.y = self.y * inverted_length
	
	return self
end

function META.GetCrossed(a, b)
	return a.x * b.y - a.y * b.x
end

function META:Rotate90CCW()
	local x, y = self:Unpack()

	self.x = -y
	self.y = x
	
	return self
end

function META:Rotate90CW()
	local x, y = self:Unpack()

	self.x = y
	self.y = -x
	
	return self
end

function META:GetRad()
	return math.atan2(self.x, self.y)
end

function META:GetDeg()
	return math.deg(self:GetRad())
end

structs.AddGetFunc(META, "Normalize", "Normalized")

--[[
Give this function the coordinates of a pixel on your screen, and it will return a unit vector pointing
in the direction that the camera would project that pixel in.

Useful for converting mouse positions to aim vectors for traces.

iScreenX is the x position of your cursor on the screen, in pixels.
iScreenY is the y position of your cursor on the screen, in pixels.
iScreenW is the width of the screen, in pixels.
iScreenH is the height of the screen, in pixels.
angCamRot is the angle your camera is at
fFoV is the Field of View (FOV) of your camera in ___radians___
    Note: This must be nonzero or you will get a divide by zero error.
 ]]
function META:ToWorld(pos, ang, fov, w, h)
	pos = pos or render.GetCameraPosition()
	ang = ang or render.GetCameraAngles()
	fov = fov or (render.GetCamFOV() + math.rad(15))
	w = w or render.GetWidth()
	h = h or render.GetHeight()
	
    --This code works by basically treating the camera like a frustrum of a pyramid.
    --We slice this frustrum at a distance "d" from the camera, where the slice will be a rectangle whose width equals the "4:3" width corresponding to the given screen height.
    local d = 4 * h / (6 * math.tan(0.5 * fov))

    --Forward, right, and up vectors (need these to convert from local to world coordinates
    local fwd = ang:GetForward()
    local rgt = ang:GetRight()
    local upw = ang:GetUp()

    --Then convert vec to proper world coordinates and return it
	local dir = (fwd * d) + (rgt * (0.5 * w - self.x)) + (upw * (0.5 * h - self.y))
	dir:Normalize()
    return dir
end

structs.Register(META)
