local META = {}

META.ClassName = "Ang3"

META.NumberType = "float"
META.Args = {{"p", "x", "pitch"}, {"y", "yaw"}, {"r", "z", "roll"}}

structs.AddAllOperators(META)

local sin = math.sin
local cos = math.cos

function META.GetRight(a)
	return Vec3(
		cos(a.z) * cos(a.y),
		sin(a.z) * cos(a.y),
	   -sin(a.y)
	)
end

function META.GetUp(a)
	return Vec3(
		sin(a.z) * sin(a.x) + cos(a.z) * sin(a.y) * cos(a.x),
	   -cos(a.z) * sin(a.x) + sin(a.z) * sin(a.y) * cos(a.x),
		cos(a.y) * cos(a.x)
	)
end

function META.GetForward(a)
	return Vec3(
	   -sin(a.z) * cos(a.x) + cos(a.z) * sin(a.y) * sin(a.x),
		cos(a.z) * cos(a.x) + sin(a.z) * sin(a.y) * sin(a.x),
		cos(a.y) * sin(a.x)
	)
end

if false then
	--[[
	
	GMOD
	
	======90 0 0======
	FORWARD = -1 -0 -1
	RIGHT = 0 -1 0
	UP = 1 0 -1
	==================
	
	======0 90 0======
	FORWARD = -1 1 -0
	RIGHT = 1 0 -0
	UP = 0 0 1
	==================
	
	======0 0 90======
	FORWARD = 1 0 -0
	RIGHT = -0 0 -1
	UP = 0 -1 -1
	==================		
	]]
	
	--[[
	
	ASDFML
	
	======90 0 0======
	FORWARD = 0 -1 1
	RIGHT = 1 0 -0
	UP = 0 -1 -1
	==================


	======0 90 0======
	FORWARD = 0 1 -0
	RIGHT = -1 -0 -1
	UP = 1 0 -1
	==================


	======0 0 90======
	FORWARD = -1 -1 0
	RIGHT = -1 1 -0
	UP = 0 0 1
	==================


	]]

	local msg = gmod and MsgN or logn

	local printv = function(str, v)
		msg(str .. " = " .. math.floor(v.x) .. " " .. math.floor(v.y) .. " " .. math.floor(v.z)) 
	end

	function PrintDirectons(p, y, r) 
		local ang = gmod and Angle(p,y,r) or Ang3(math.rad(p),math.rad(y),math.rad(r)) 

		msg("\n======" .. p .. " " .. y .. " " .. r .. "======")
		if gmod then 		
			printv("FORWARD", ang:Forward()) 
			printv("RIGHT", ang:Right()) 
			printv("UP", ang:Up()) 
		else 
			printv("FORWARD", ang:GetForward()) 
			printv("RIGHT", ang:GetRight()) 
			printv("UP", ang:GetUp()) 
		end
		msg("==================\n")
	end

	PrintDirectons(0, 0, 0)
	PrintDirectons(180, 0, 0)
	PrintDirectons(0, 0, 180)
end


local PI1 = math.pi
local PI2 = math.pi * 2
local function normalize(a, b)
	return (a + PI1) % PI2 - PI1
end

function META:Normalize()
	self.p = normalize(self.p)
	self.y = normalize(self.y)
	self.r = normalize(self.r)
	
	return self
end 

structs.AddGetFunc(META, "Normalize", "Normalized")

function META.AngleDifference(a, b)
	a.p = normalize(a.p - b.p)
	a.y = normalize(a.y - b.y)
	a.r = normalize(a.r - b.r)
	
	a.p = a.p < PI2 and a.p or a.p - PI2
	a.y = a.y < PI2 and a.y or a.y - PI2
	a.r = a.r < PI2 and a.r or a.r - PI2
	
	return a
end

structs.AddGetFunc(META, "AngleDifference")

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	a.z = (b.z - a.z) * mult + a.z
	
	a:Normalize()
	
	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:Rad()
	self.p = math.rad(self.p)
	self.y = math.rad(self.y)
	self.r = math.rad(self.r)
	
	return self
end

structs.AddGetFunc(META, "Rad")

function META:Deg()
	self.p = math.deg(self.p)
	self.y = math.deg(self.y)
	self.r = math.deg(self.r)
	
	return self
end

structs.AddGetFunc(META, "Deg")

structs.Register(META)