local function random_dir()
	local num = math.random() > 0.5 and 1 or -1
	local axis = math.random(3)
	if axis == 1 then
		return Vec3(num, 0, 0)
	elseif axis == 2 then
		return Vec3(0, num, 0)
	elseif axis == 3 then
		return Vec3(0, 0, num)
	end
end

local function random_angle()
	local ang = 0
	for i = 1, math.random(8) do
		if math.random() > 0.5 then
			ang = ang + 45
		else
			ang = ang - 45
		end
	end
	return ang
end

for i = 1, 10 do
	math.randomseed(i)
	local ang = Deg3(random_angle(), random_angle(), random_angle())

	local dir = random_dir()
	local deg = random_angle()
	if deg == 0 then deg = 45 end

	local before = ang:GetDeg()
	ang:RotateAroundAxis2(dir, math.rad(deg))
	local after = ang:GetDeg()

	print("===========")
	print(deg, dir)
	print(before)
	print(after)
end