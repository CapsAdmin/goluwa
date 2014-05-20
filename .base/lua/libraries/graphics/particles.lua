local lerp,deg,randomf,clamp = math.lerp,math.deg,math.randomf,math.clamp

local PARTICLE = utilities.CreateBaseMeta("particle")

class.GetSet(PARTICLE, "Pos", Vec3(0,0,0))
class.GetSet(PARTICLE, "Velocity", Vec3(0,0,0))
class.GetSet(PARTICLE, "Drag", 0.98)
class.GetSet(PARTICLE, "Size", Vec2(1,1))
class.GetSet(PARTICLE, "Angle", 0)

class.GetSet(PARTICLE, "StartJitter", 0)
class.GetSet(PARTICLE, "EndJitter", 0)

class.GetSet(PARTICLE, "StartSize", 10)
class.GetSet(PARTICLE, "EndSize", 0)

class.GetSet(PARTICLE, "StartLength", Vec2(0, 0))
class.GetSet(PARTICLE, "EndLength", Vec2(0, 0))

class.GetSet(PARTICLE, "StartAlpha", 1)
class.GetSet(PARTICLE, "EndAlpha", 0)

class.GetSet(PARTICLE, "LifeTime", 1)
class.GetSet(PARTICLE, "Texture", NULL)
class.GetSet(PARTICLE, "Color", Color(1,1,1,1))

function PARTICLE:SetLifeTime(n)
	self.LifeTime = n
	self.life_end = os.clock() + n
end

local EMITTER = utilities.CreateBaseMeta("particle_emitter")

class.GetSet(EMITTER, "Speed", 1)
class.GetSet(EMITTER, "Rate", 0.1)
class.GetSet(EMITTER, "EmitCount", 1)
class.GetSet(EMITTER, "Mode2D", true)
class.GetSet(EMITTER, "Pos", Vec3(0, 0, 0))
class.GetSet(EMITTER, "Additive", true)
class.GetSet(EMITTER, "ThinkTime", 0.1)
class.GetSet(EMITTER, "CenterAttractionForce", 0)
class.GetSet(EMITTER, "PosAttractionForce", 0)

local emitters = {}
 
function ParticleEmitter()
	local self = EMITTER()
	
	self.particles = {}
	self.last_emit = 0
	self.next_think = 0

	emitters[#emitters+1] = self
	
	return self
end

function EMITTER:OnRemove()
	for k,v in pairs(emitters) do 
		if v == self then 
			--table.remove(emitters, k) 
			emitters[k] = nil
			break 
		end 
	end
end
 
function EMITTER:Think(dt)
	local time = os.clock()
	
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
	
	for i = 1, #self.particles do
		local p = self.particles[i]
		
		if p.life_end < time or (not p.Jitter and p.life_mult < 0.001) then
			remove_these[#remove_these + 1] = i
		else
			
			if self.CenterAttractionForce ~= 0 and self.attraction_center then
				p.Velocity.x = p.Velocity.x + (self.attraction_center.x - p.Pos.x) * self.CenterAttractionForce
				p.Velocity.y = p.Velocity.y + (self.attraction_center.y - p.Pos.y) * self.CenterAttractionForce
				p.Velocity.z = p.Velocity.z + (self.attraction_center.z - p.Pos.z) * self.CenterAttractionForce
			end		
			
			if self.PosAttractionForce ~= 0 then
				p.Velocity.x = p.Velocity.x + (self.Pos.x - p.Pos.x) * self.PosAttractionForce
				p.Velocity.y = p.Velocity.y + (self.Pos.y - p.Pos.y) * self.PosAttractionForce
				p.Velocity.z = p.Velocity.z + (self.Pos.z - p.Pos.z) * self.PosAttractionForce
			end
			
		
			-- velocity
			if p.Velocity.x ~= 0 then			
				p.Pos.x = p.Pos.x + (p.Velocity.x * dt)
				p.Velocity.x = p.Velocity.x * p.Drag
			end
			
			if p.Velocity.y ~= 0 then
				p.Pos.y = p.Pos.y + (p.Velocity.y * dt)
				p.Velocity.y = p.Velocity.y * p.Drag
			end
			
			if not self.Mode2D and p.Velocity.z ~= 0 then
				p.Pos.z = p.Pos.z + (p.Velocity.z * dt)
				p.Velocity.z = p.Velocity.z * p.Drag
			end
		
			p.life_mult = clamp((p.life_end - time) / p.LifeTime, 0, 1)

			if self.CenterAttractionForce ~= 0 then
				center = center + p.Pos
			end
		end
		
	end
	self.attraction_center = center / #self.particles
		
	table.multiremove(self.particles, remove_these)
end  
  
function EMITTER:Draw()
	render.SetBlendMode(self.Additive and "additive" or alpha)
	
	if self.Mode2D then
		for i = 1, #self.particles do
			local p = self.particles[i]
			
			if p.Texture:IsValid() then
				surface.SetTexture(p.Texture)
			else
				surface.SetWhiteTexture()
			end
		
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
				a = deg(p.Velocity:GetAng3().y)
				
				if length_x ~= 0 then
					w = w * length_x
				end

				if length_y ~= 0 then
					h = h * length_y
				end
			end

			local ox, oy = w*0.5, h*0.5

			surface.Color(p.Color.r, p.Color.g, p.Color.b, p.Color.a * alpha)
		
			surface.DrawRect(
				p.Pos.x, 
				p.Pos.y, 
				w, 
				h,
				p.Angle + a,
				ox, oy
			)			
		end
	else	
		-- 3d here	
	end
	
	render.SetBlendMode("alpha")
end  

function EMITTER:GetParticles()
	return self.particles
end
  
function EMITTER:AddParticle(...)
	local p = PARTICLE()
	p:SetPos(self:GetPos():Copy())
	p.life_mult = 1	
	
	p:SetLifeTime(1)
	
	self.particles[#self.particles + 1] = p
	
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
 
event.AddListener("OnDraw2D", "particles", function(dt)	
	for _, emitter in pairs(emitters) do
		emitter:Draw()
	end
end) 
 
event.AddListener("OnUpdate", "particles", function(dt)	
	for _, emitter in pairs(emitters) do
		emitter:Think(dt) 
	end
end)