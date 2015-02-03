local structs = (...) or _G.structs

local META = {}

META.ClassName = "Quat"

META.NumberType = "float"
META.Args = {"x", "y", "z", "w"}

structs.AddAllOperators(META)

function META:Identity()
	self.x = 0
	self.y = 0
	self.z = 0
	self.w = 1
end

function META.Multiply(a, b)

	if type(b) == "number" then
		a.x = a.x * b
		a.y = a.y * b
		a.z = a.z * b
		a.w = a.w * b
	elseif type(a) == "number" then
		return META.Multiply(b, a)
	else
		a.x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y
		a.y = a.w*b.y + a.y*b.w + a.z*b.x - a.x*b.z
		a.z = a.w*b.z + a.z*b.w + a.x*b.y - a.y*b.x
		a.w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z
	end
	
	return a
end

function META.Divide(a, b)

	if type(b) == "number" then
		a.x = a.x * b
		a.y = a.y * b
		a.z = a.z * b
		a.w = a.w * b
	elseif type(a) == "number" then
		return META.Multiply(b, a)
	else
		--return self:GetConjugated():Multiply(self:Dot(self))
	end
	
	return a
end

function META:Conjugate()
	self.x = -self.x
	self.y = -self.y
	self.z = -self.z
end

structs.AddGetFunc(META, "Conjugate", "Conjugated")

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	a.z = (b.z - a.z) * mult + a.z
	a.w = (b.w - a.w) * mult + a.w
	
	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:Dot(vec)
	return self.w*vec.w + self.x*vec.x + self.y*vec.y + self.z*vec.z
end

function META:GetLength()
	return math.sqrt(self:Dot(self))
end

function META:Normalize()
	local len = self:Length()
	
	if len > 0 then
		local div = 1 / len
		self.x = self.x * div
		self.y = self.y * div
		self.z = self.z * div
		self.w = self.w * div
	else
		self:Identity()
	end
	
	return self
end

structs.AddGetFunc(META, "Normalize", "Normalized")


-- https://github.com/grrrwaaa/gct753/blob/master/modules/quat.lua#L193

function META:SetAngles(ang)
	local c1 = math.cos(ang.r * 0.5)
	local c2 = math.cos(ang.p * 0.5)
	local c3 = math.cos(ang.y * 0.5)
	
	local s1 = math.sin(ang.r * 0.5)
	local s2 = math.sin(ang.p * 0.5)
	local s3 = math.sin(ang.y * 0.5)
	
	-- equiv Q1 = Qy * Qx; -- since many terms are zero
	local tw = c1*c2
	local tx = c1*s2
	local ty = s1*c2
	local tz =-s1*s2
	
	-- equiv Q2 = Q1 * Qz; -- since many terms are zero
	self.x = tx*c3 + ty*s3
	self.y = ty*c3 - tx*s3
	self.z = tw*s3 + tz*c3
	self.w = tw*c3 - tz*s3
	
	return self
end

-- https://github.com/grrrwaaa/gct753/blob/master/modules/quat.lua#L465

function META:GetAngles()
	-- http:--www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/quaternionstoeulerangles.html
	
	local sqw = self.w*self.w
	local sqx = self.x*self.x
	local sqy = self.y*self.y
	local sqz = self.z*self.z
	
	return
		Ang3(
			math.asin (-2.0 * (self.x*self.z - self.w*self.y)),
			math.atan2( 2.0 * (self.x*self.y + self.w*self.z), (sqw + sqx - sqy - sqz)),
			math.atan2( 2.0 * (self.y*self.z + self.w*self.x), (sqw - sqx - sqy + sqz))
		)
end


function META:GetAnglesSafe()
	-- http:--www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/quaternionstoeulerangles.html

    local sqw = self.w*self.w
    local sqx = self.x*self.x
    local sqy = self.y*self.y
    local sqz = self.z*self.z
	local unit = sqx + sqy + sqz + sqw -- if normalised is one, otherwise is correction factor
	local test = self.x*self.y + self.z*self.w
	
	local heading
	local attitude
	local bank
	
	if test > 0.499*unit then -- singularity at north pole
		heading = 2 * math.atan2(self.x, self.w)
		attitude = math.pi/2
		bank = 0
	elseif test < -0.499 * unit then -- singularity at south pole
		heading = -2 * math.atan2(self.x,self.w)
		attitude = -math.pi/2
		bank = 0
	else
		heading = math.atan2(2*self.y*self.w-2*self.x*self.z , sqx - sqy - sqz + sqw)
		attitude = math.asin(2*test/unit)
		bank = math.atan2(2*self.x*self.w-2*self.y*self.z , -sqx + sqy - sqz + sqw)
	end		
	
	return Ang3(heading, attitude, bank)
end

structs.Register(META) 
