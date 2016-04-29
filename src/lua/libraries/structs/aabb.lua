local structs = (...) or _G.structs

local META = {}

META.ClassName = "AABB"

META.NumberType = "float"
META.Args = {"min_x", "min_y", "min_z", "max_x", "max_y", "max_z"}

structs.AddAllOperators(META)

function META:IsBoxInside(box)
	return
		self.min_x <= box.min_x and
		self.min_y <= box.min_y and
		self.min_z <= box.min_z and

		self.max_x >= box.max_x and
		self.max_y >= box.max_y and
		self.max_z >= box.max_z
end

function META:IsSphereInside(pos, radius)
	if pos.x - radius < self.min_x then return false end
	if pos.y - radius < self.min_y then return false end
	if pos.z - radius < self.min_z then return false end
	if pos.x + radius > self.max_x then return false end
	if pos.y + radius > self.max_y then return false end
	if pos.z + radius > self.max_z then return false end

	return true
end

function META:IsOverlappedSphereInside(pos, radius)
	if
		pos.x > self.min_x and
		pos.x < self.max_x and
		pos.y > self.min_y and
		pos.y < self.max_y and
		pos.z > self.min_z and
		pos.z < self.max_z
	then
		return true
	end

	if pos.x + radius < self.min_x then return false end
	if pos.y + radius < self.min_y then return false end
	if pos.z + radius < self.min_z then return false end
	if pos.x - radius > self.max_x then return false end
	if pos.y - radius > self.max_y then return false end
	if pos.z - radius > self.max_z then return false end

	return true
end

function META:IsPointInside(pos)

	if pos.x < self.min_x then return false end
	if pos.y < self.min_y then return false end
	if pos.z < self.min_z then return false end
	if pos.x > self.max_x then return false end
	if pos.y > self.max_y then return false end
	if pos.z > self.max_z then return false end

	return true
end

function META:IsBoxIntersecting(box)
	if self.min_x > box.max_x or box.min_x > self.max_x then return false end
	if self.min_y > box.max_y or box.min_y > self.max_y then return false end
	if self.min_z > box.max_z or box.min_z > self.max_z then return false end

	return true
end

function META:ExtendMax(pos)
	if pos.x > self.max_x then self.max_x = pos.x end
	if pos.y > self.max_y then self.max_y = pos.y end
	if pos.z > self.max_z then self.max_z = pos.z end
end

function META:ExtendMin(pos)
	if pos.x < self.min_x then self.min_x = pos.x end
	if pos.y < self.min_y then self.min_y = pos.y end
	if pos.z < self.min_z then self.min_z = pos.z end
end

function META:SetMin(pos)
	self.min_x = pos.x
	self.min_y = pos.y
	self.min_z = pos.z
end

function META:SetMax(pos)
	self.max_x = pos.x
	self.max_y = pos.y
	self.max_z = pos.z
end

structs.Register(META)
