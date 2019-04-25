local structs = (...) or _G.structs

local META = prototype.CreateTemplate("AABB")

META.NumberType = "double"
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

function META:GetMin()
	return Vec3(self.min_x, self.min_y, self.min_z)
end

function META:SetMax(pos)
	self.max_x = pos.x
	self.max_y = pos.y
	self.max_z = pos.z
end

function META:GetMax()
	return Vec3(self.max_x, self.max_y, self.max_z)
end

function META.Expand(a, b)
	if b.min_x < a.min_x then a.min_x = b.min_x end
	if b.min_y < a.min_y then a.min_y = b.min_y end
	if b.min_z < a.min_z then a.min_z = b.min_z end

	if b.max_x > a.max_x then a.max_x = b.max_x end
	if b.max_y > a.max_y then a.max_y = b.max_y end
	if b.max_z > a.max_z then a.max_z = b.max_z end
end

function META:ExpandVec3(vec)
	if vec.x < self.min_x then self.min_x = vec.x end
	if vec.y < self.min_y then self.min_y = vec.y end
	if vec.z < self.min_z then self.min_z = vec.z end

	if vec.x > self.max_x then self.max_x = vec.x end
	if vec.y > self.max_y then self.max_y = vec.y end
	if vec.z > self.max_z then self.max_z = vec.z end
end

function META:GetLength()
	return self:GetMin():Distance(self:GetMax())
end

structs.Register(META)
