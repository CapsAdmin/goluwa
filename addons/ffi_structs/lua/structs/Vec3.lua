local META = {}

META.ClassName = "Vec3"

META.NumberType = "float"
META.Args = {"x", "y", "z"}

structs.AddAllOperators(META) 

-- length stuff
do 
	function META:GetLengthSquared()
		return self.x * self.x + self.y * self.y + self.z * self.z
	end

	function META:SetLength(num)
		if num == 0 then 
			self.x = 0
			self.y = 0
			self.z = 0
			return
		end
		
		local scale = math.sqrt(self:GetLengthSquared()) * num
		
		self.x = self.x / scale
		self.y = self.y / scale
		self.z = self.z / scale
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
			local scale = math.sqrt(length) * num
			
			self.x = self.x / scale
			self.y = self.y / scale
			self.z = self.z / scale
		end
	end
	
	function META.Distance(a, b)
		return (a - b):GetLength()
	end
end

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	a.z = (b.z - a.z) * mult + a.z
	
	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:Normalize()
	local sqr = self:GetLengthSquared()
	
	if sqr == 0 then return self end
	
	local len = math.sqrt(sqr)
	
	self.x = self.x / len
	self.y = self.y / len
	self.z = self.z / len
	
	return self
end

structs.AddGetFunc(META, "Normalize", "Normalized")

function META.Cross(a, b)
	local x, y, z = a.x, a.y, a.z
	a.x = y * b.z - z * b.y
	a.y = z * b.x - x * b.z
	a.z = x * b.y - y * b.x
	return a
end

structs.AddGetFunc(META, "Cross")

function META.GetDot(a, b)
	return 
		a.x * b.x + 
		a.y * b.y +
		a.z * b.z 
end

function META:GetVolume()
	return self.x * self.y * self.z
end

function META:GetAng3()
	local n = self:GetNormalized()
	
	local p = math.atan2(math.sqrt((n.x ^ 2) + (n.y ^ 2)), n.z)
	local y = math.atan2(self.y, self.x)
	
	return structs.Ang3(p,y,0)
end

--[[
Give this function a vector, pointing from the camera to a position in the world,
and it will return the coordinates of a pixel on your screen - this is where the world position would be projected onto your screen.

Useful for finding where things in the world are on your screen (if they are at all).

vDir is a direction vector pointing from the camera to a position in the world
iScreenW is the width of the screen, in pixels.
iScreenH is the height of the screen, in pixels.
angCamRot is the angle your camera is at
fFoV is the Field of View (FOV) of your camera in ___radians___
    Note: This must be nonzero or you will get a divide by zero error.

Returns x, y, iVisibility.
    x and y are screen coordinates.
    iVisibility will be:
        1 if the point is visible
        0 if the point is in front of the camera, but is not visible
        -1 if the point is behind the camera
]]


function META:ToScreen(dir, w, h, ang, fov)
	local cam = engine3d.GetCurrentCamera()
	local _w, _h = render.GetScreenSize()
	
	dir =  self:Copy() - cam:GetPos()
	dir:Normalize()
	
	w = w or _w
	h = h or _h

	if not ang then
		local a = cam:GetAngles()
		
		ang = Ang3(a.y, a.r, a.p)
	end
	
	fov = fov or cam:GetFov() + math.rad(15)
	
    --Same as we did above, we found distance the camera to a rectangular slice of the camera's frustrum, whose width equals the "4:3" width corresponding to the given screen height.
    local d = 4 * h / (6 * math.tan(0.5 * fov))
    local fdp = ang:GetForward():Dot(dir)

    --fdp must be nonzero ( in other words, vDir must not be perpendicular to angCamRot:Forward() )
    --or we will get a divide by zero error when calculating vProj below.
    if fdp == 0 then
        return 0, 0, -1
    end

    --Using linear projection, project this vector onto the plane of the slice
    local proj = dir * (d / fdp)

    --Dotting the projected vector onto the right and up vectors gives us screen positions relative to the center of the screen.
    --We add half-widths / half-heights to these coordinates to give us screen positions relative to the upper-left corner of the screen.
    --We have to subtract from the "up" instead of adding, since screen coordinates decrease as they go upwards.
    local x = 0.5 * w + ang:GetRight():Dot(proj)
    local y = 0.5 * h - ang:GetUp():Dot(proj)

    --Lastly we have to ensure these screen positions are actually on the screen.
    local vis
	
	--Simple check to see if the object is in front of the camera
    if fdp < 0 then 
        vis = -1
    elseif x < 0 or x > w or y < 0 or y > h then  --We've already determined the object is in front of us, but it may be lurking just outside our field of vision.
        vis = 0
    else
        vis = 1
    end

    return Vec2(x, y), vis
end


structs.Register(META)