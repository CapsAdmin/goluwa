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
		if typex(a) == META.Type and type(b) == "number" then
			return a:GetLength() < b
		elseif typex(b) == META.Type and type(a) == "number" then
			return b:GetLength() < a
		end
	end

	function META.__le(a, b)
		if typex(a) == META.Type and type(b) == "number" then
			return a:GetLength() <= b
		elseif typex(b) == META.Type and type(a) == "number" then
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
function META:ToWorld(w, h, ang, fov)
	local cam = engine3d.GetCurrentCamera()
	local _w, _h = render.GetScreenSize()
	
	w = w or _w
	h = h or _h
	if not ang then
		local a = cam:GetAngles()
		
		ang = Ang3(a.y, a.r, a.p)
	end
	fov = fov or cam:GetFov() + math.rad(15)
	
    --This code works by basically treating the camera like a frustrum of a pyramid.
    --We slice this frustrum at a distance "d" from the camera, where the slice will be a rectangle whose width equals the "4:3" width corresponding to the given screen height.
    local d = 4 * h / (6 * math.tan(0.5 * fov))

    --Forward, right, and up vectors (need these to convert from local to world coordinates
    local fwd = ang:GetForward()
    local rgt = ang:GetRight()
    local upw = ang:GetUp()

    --Then convert vec to proper world coordinates and return it
	local dir = (fwd * d) + (rgt * (self.x - 0.5 * w)) + (upw * (0.5 * h - self.y))
	dir:Normalize()
    return dir
end

structs.Register(META)
