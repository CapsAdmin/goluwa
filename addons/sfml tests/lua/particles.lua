do
	Particle = {};
	Particle.__index = Particle;
	Particle.pos = Vec2(128, 128);
	Particle.dieTime = 0;

	function Particle:SetVelocity(x, y)
		self.vel = Vec2(x or 0, y or 0);
	end;

	function Particle:SetDieTime(time)
		self.dieTime = os.clock() + time;
	end;

	function Particle:SetStartSize(size)
		self.size = size;
	end;

	function Particle:SetEndSize(size)
		self.endSize = size;
	end;

	function Particle:Draw()
		surface.DrawRect(self.pos.x, self.pos.y, self.size or 1, self.size or 1);
	end;

	function Particle:Update()
		if (self.size and self.endSize) then
			local curTime = os.clock();
			local fraction = (curTime - self.size) / (self.endSize - self.size);

			self.size = fraction * self.size;
		end;

		self.pos = self.pos + self.vel;
	end;

	setmetatable(Particle, {
		__call = function(this)
			return setmetatable({
				dieTime = os.clock() + 2,
				vel = Vec2(math.random() + math.random(-1, 1), math.random() + math.random(-1, 1))
			}, Particle);
		end;
	});
end;

do
	ParticleSystem = {};
	ParticleSystem.__index = ParticleSystem;

	local buffer = {};

	function ParticleSystem:Add()
		local particle = Particle();
			table.insert(buffer, particle);
		return particle;
	end;

	function ParticleSystem:Update()
		for k, v in pairs(buffer) do
			v:Update();

			if (v.dieTime < os.clock()) then
				table.remove(buffer, k);
			end;
		end;
	end;

	function ParticleSystem:Draw()
		for k, v in pairs(buffer) do
			v:Draw();
		end;
	end;

	setmetatable(ParticleSystem, {
		__call = function(this)
			return setmetatable({}, ParticleSystem);
		end;
	});
end;

local window = asdfml.OpenWindow();
local particleSystem = ParticleSystem();

for i = 1, 2500 do
	local p = particleSystem:Add();
	p:SetDieTime(math.random(4, 8));
	p:SetStartSize(4);
end;

event.AddListener("OnDraw", "particles", function()
	surface.SetWindow(window)

	particleSystem:Draw();
end);

event.AddListener("OnUpdate", "particles", function()
	if (window:IsOpen()) then
		particleSystem:Update();
	end;
end);