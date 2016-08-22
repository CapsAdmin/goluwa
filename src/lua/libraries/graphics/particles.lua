local META = prototype.CreateTemplate("particle_META")

META:GetSet("Speed", 1)
META:GetSet("Rate", 0.1)
META:GetSet("EmitCount", 1)
META:GetSet("Mode2D", true)
META:GetSet("Position", Vec3(0, 0, 0))
META:GetSet("Additive", true)
META:GetSet("ThinkTime", 0.1)
META:GetSet("CenterAttractionForce", 0)
META:GetSet("PosAttractionForce", 0)
META:GetSet("MoveResolution", 0)
META:GetSet("Texture", NULL)
META:GetSet("ScreenRect", Rect())

function ParticleEmitter(max)
	max = max or 1000

	local self = META:CreateObject()

	self.max = max
	self.particles = {}
	self.last_emit = 0
	self.next_think = 0
	self.poly = surface.CreatePoly(max * 6)

	return self
end

local table_insert = table.insert
local table_remove = table.remove
local math_deg = math.deg
local math_lerp = math.lerp
local math_ceil = math.ceil
local math_randomf = math.randomf

function META:Update(dt)
	local time = system.GetElapsedTime()

	if self.Rate == 0 then
		self:Emit()
	elseif self.Rate ~= -1 then
		if self.last_emit < time then
			self:Emit()
			self.last_emit = time + self.Rate
		end
	end

	local remove_these = {}

	local center = Vec3(0,0,0)

	dt = dt * self.Speed

	local cull = not self.ScreenRect:IsZero()

	for i = 1, self.max do
		local p = self.particles[i]

		if not p then break end

		if p.life_end < time or (not p.Jitter and p.life_mult < 0.001) then
			table_insert(remove_these, i)
		else

			if self.CenterAttractionForce ~= 0 and self.attraction_center then
				p.Velocity.x = p.Velocity.x + (self.attraction_center.x - p.Position.x) * self.CenterAttractionForce
				p.Velocity.y = p.Velocity.y + (self.attraction_center.y - p.Position.y) * self.CenterAttractionForce
				p.Velocity.z = p.Velocity.z + (self.attraction_center.z - p.Position.z) * self.CenterAttractionForce
			end

			if self.PosAttractionForce ~= 0 then
				p.Velocity.x = p.Velocity.x + (self.Position.x - p.Position.x) * self.PosAttractionForce
				p.Velocity.y = p.Velocity.y + (self.Position.y - p.Position.y) * self.PosAttractionForce
				p.Velocity.z = p.Velocity.z + (self.Position.z - p.Position.z) * self.PosAttractionForce
			end


			-- velocity
			if p.Velocity.x ~= 0 then
				p.Position.x = p.Position.x + (p.Velocity.x * dt)
				p.Velocity.x = p.Velocity.x * p.Drag
			end

			if p.Velocity.y ~= 0 then
				p.Position.y = p.Position.y + (p.Velocity.y * dt)
				p.Velocity.y = p.Velocity.y * p.Drag
			end

			if not self.Mode2D and p.Velocity.z ~= 0 then
				p.Position.z = p.Position.z + (p.Velocity.z * dt)
				p.Velocity.z = p.Velocity.z * p.Drag
			end

			p.life_mult = (p.life_end - time) / p.LifeTime

			if self.CenterAttractionForce ~= 0 then
				center = center + p.Position
			end

			if cull then
				if
					p.Position.x > self.ScreenRect.w or
					p.Position.y > self.ScreenRect.h or
					p.Position.x < self.ScreenRect.x or
					p.Position.y < self.ScreenRect.y
				then
					table_insert(remove_these, i)
				end
			end
		end

	end
	self.attraction_center = center / #self.particles

	table.multiremove(self.particles, remove_these)
end

function META:Draw()
	render.SetBlendMode(self.Additive and "additive" or "alpha")

	if self.Texture:IsValid() then
		surface.SetTexture(self.Texture)
	else
		surface.SetWhiteTexture()
	end

	surface.SetColor(1,1,1,1)

	if self.Mode2D then
		for i = 1, self.max do
			local p = self.particles[i]

			if not p then break end

			local size = math_lerp(p.life_mult, p.EndSize, p.StartSize)
			local alpha = math_lerp(p.life_mult, p.EndAlpha, p.StartAlpha)
			local length_x = math_lerp(p.life_mult, p.EndLength.x, p.StartLength.x)
			local length_y = math_lerp(p.life_mult, p.EndLength.y, p.StartLength.y)
			local jitter = math_lerp(p.life_mult, p.EndJitter, p.StartJitter)

			if jitter ~= 0 then
				size = size + math_randomf(-jitter, jitter)
				alpha = alpha + math_randomf(-jitter, jitter)
			end

			local w = size * p.Size.x
			local h = size * p.Size.y
			local a = 0


			if not (length_x == 0 and length_y == 0) and self.Mode2D then
				a = math_deg(p.Velocity:GetAngles().y)

				if length_x ~= 0 then
					w = w * length_x
				end

				if length_y ~= 0 then
					h = h * length_y
				end
			end

			local ox, oy = w*0.5, h*0.5

			self.poly:SetColor(p.Color.r, p.Color.g, p.Color.b, p.Color.a * alpha)

			local x, y = p.Position.x, p.Position.y

			if self.MoveResolution ~= 0 then
				x = math_ceil(x * self.MoveResolution) / self.MoveResolution
				y = math_ceil(y * self.MoveResolution) / self.MoveResolution
			end

			self.poly:SetRect(
				i,
				x,
				y,
				w,
				h,
				p.Angle + a,
				ox, oy
			)

		end

		self.poly:Draw()
	else
		-- 3d here
	end
end

function META:GetParticles()
	return self.particles
end

local create_particle

do
	local META = prototype.CreateTemplate("particle")

	META:GetSet("Position", Vec3(0,0,0))
	META:GetSet("Velocity", Vec3(0,0,0))
	META:GetSet("Drag", 0.98)
	META:GetSet("Size", Vec2(1,1))
	META:GetSet("Angle", 0)

	META:GetSet("StartJitter", 0)
	META:GetSet("EndJitter", 0)

	META:GetSet("StartSize", 10)
	META:GetSet("EndSize", 0)

	META:GetSet("StartLength", Vec2(0, 0))
	META:GetSet("EndLength", Vec2(0, 0))

	META:GetSet("StartAlpha", 1)
	META:GetSet("EndAlpha", 0)

	META:GetSet("LifeTime", 1)
	META:GetSet("Color", Color(1,1,1,1))

	function META:SetLifeTime(n)
		self.LifeTime = n
		self.life_end = system.GetElapsedTime() + n
	end

	META:Register()

	META.__index = META

	create_particle = function()
		return setmetatable({Position = Vec2()}, META) -- META:CreateObject()
	end
end

function META:AddParticle()
	local p = create_particle()
	p.Position.x = self.Position.x
	p.Position.y = self.Position.y

	p.life_mult = 1

	p:SetLifeTime(1)

	if #self.particles >= self.max then
		table_remove(self.particles, 1)
	end

	table_insert(self.particles, p)

	return p
end

function META:Emit()
	for _ = 1, self.EmitCount do
		local p = self:AddParticle()

		if self.OnEmit then
			self:OnEmit(p)
		end
	end
end

prototype.Register(META)