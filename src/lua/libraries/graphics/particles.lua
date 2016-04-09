local lerp,deg,randomf,clamp = math.lerp,math.deg,math.randomf,math.clamp

local PARTICLE = prototype.CreateTemplate("particle")

prototype.GetSet(PARTICLE, "Position", Vec3(0,0,0))
prototype.GetSet(PARTICLE, "Velocity", Vec3(0,0,0))
prototype.GetSet(PARTICLE, "Drag", 0.98)
prototype.GetSet(PARTICLE, "Size", Vec2(1,1))
prototype.GetSet(PARTICLE, "Angle", 0)

prototype.GetSet(PARTICLE, "StartJitter", 0)
prototype.GetSet(PARTICLE, "EndJitter", 0)

prototype.GetSet(PARTICLE, "StartSize", 10)
prototype.GetSet(PARTICLE, "EndSize", 0)

prototype.GetSet(PARTICLE, "StartLength", Vec2(0, 0))
prototype.GetSet(PARTICLE, "EndLength", Vec2(0, 0))

prototype.GetSet(PARTICLE, "StartAlpha", 1)
prototype.GetSet(PARTICLE, "EndAlpha", 0)

prototype.GetSet(PARTICLE, "LifeTime", 1)
prototype.GetSet(PARTICLE, "Color", Color(1,1,1,1))

function PARTICLE:SetLifeTime(n)
	self.LifeTime = n
	self.life_end = system.GetElapsedTime() + n
end

prototype.Register(PARTICLE)

local EMITTER = prototype.CreateTemplate("particle_emitter")

prototype.GetSet(EMITTER, "Speed", 1)
prototype.GetSet(EMITTER, "Rate", 0.1)
prototype.GetSet(EMITTER, "EmitCount", 1)
prototype.GetSet(EMITTER, "Mode2D", true)
prototype.GetSet(EMITTER, "Position", Vec3(0, 0, 0))
prototype.GetSet(EMITTER, "Additive", true)
prototype.GetSet(EMITTER, "ThinkTime", 0.1)
prototype.GetSet(EMITTER, "CenterAttractionForce", 0)
prototype.GetSet(EMITTER, "PosAttractionForce", 0)
prototype.GetSet(EMITTER, "MoveResolution", 0)
prototype.GetSet(EMITTER, "Texture", NULL)
prototype.GetSet(EMITTER, "ScreenRect", Rect())

function ParticleEmitter(max)
	max = max or 1000

	local self = prototype.CreateObject(EMITTER)

	self.max = max
	self.particles = {}
	self.last_emit = 0
	self.next_think = 0
	self.poly = surface.CreatePoly(max * 6)

	return self
end

function EMITTER:Update(dt)
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

	local w, h = surface.GetSize()
	local cull = not self.ScreenRect:IsZero()

	for i = 1, self.max do
		local p = self.particles[i]

		if not p then break end

		if p.life_end < time or (not p.Jitter and p.life_mult < 0.001) then
			table.insert(remove_these, i)
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

			p.life_mult = clamp((p.life_end - time) / p.LifeTime, 0, 1)

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
					table.insert(remove_these, i)
				end
			end
		end

	end
	self.attraction_center = center / #self.particles

	table.multiremove(self.particles, remove_these)
end

function EMITTER:Draw()
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

			local size = lerp(p.life_mult, p.EndSize, p.StartSize)
			local alpha = lerp(p.life_mult, p.EndAlpha, p.StartAlpha)
			local length_x = lerp(p.life_mult, p.EndLength.x, p.StartLength.x)
			local length_y = lerp(p.life_mult, p.EndLength.y, p.StartLength.y)
			local jitter = lerp(p.life_mult, p.EndJitter, p.StartJitter)

			if jitter ~= 0 then
				size = size + randomf(-jitter, jitter)
				alpha = alpha + randomf(-jitter, jitter)
			end

			local w = size * p.Size.x
			local h = size * p.Size.y
			local a = 0


			if not (length_x == 0 and length_y == 0) and self.Mode2D then
				a = deg(p.Velocity:GetAngles().y)

				if length_x ~= 0 then
					w = w * length_x
				end

				if length_y ~= 0 then
					h = h * length_y
				end
			end

			local ox, oy = w*0.5, h*0.5

			self.poly:SetColor(p.Color.r, p.Color.g, p.Color.b, p.Color.a * alpha)

			local x, y = p.Position:Unpack()

			if self.MoveResolution ~= 0 then
				x = math.ceil(x * self.MoveResolution) / self.MoveResolution
				y = math.ceil(y * self.MoveResolution) / self.MoveResolution
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

function EMITTER:GetParticles()
	return self.particles
end

PARTICLE.__index = PARTICLE

function EMITTER:AddParticle(...)
	local p = setmetatable({}, PARTICLE) -- prototype.CreateObject(PARTICLE)
	p:SetPosition(self:GetPosition():Copy())
	p.life_mult = 1

	p:SetLifeTime(1)

	if #self.particles >= self.max then
		table.remove(self.particles, 1)
	end

	table.insert(self.particles, p)

	return p
end

function EMITTER:Emit(...)
	for i = 1, self.EmitCount do
		self:AddParticle(...)

		if self.OnEmit then
			self:OnEmit(p, ...)
		end
	end
end

prototype.Register(EMITTER)