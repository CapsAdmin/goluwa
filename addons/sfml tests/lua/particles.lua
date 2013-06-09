local particles = {};

local function newParticle()
	local particle = {};
		particle.pos = Vec2(256, 256);
		particle.vel = Vec2(0, 0);

		table.insert(particles, particle);
	return particle; 
end;

local function update()
	for k, v in pairs(particles) do
		particle.pos = particle.pos + particle.vel;
	end;
end;

for i = 1, 100 do
	local part = newParticle();
	part.vel = Vec2(math.random(-4, 4), math.random(-4, 4));
end;

local window = asdfml.OpenWindow();

event.AddListener("OnDraw", "particles2", function()
	surface.SetWindow(window)

	for k, v in pairs(particles) do
		surface.SetColor(255, 255, 255, 255);
		surface.DrawRect(v.pos.x - 8, v.pos.y - 8, 16, 16);
	end;
end);

event.AddListener("OnUpdate", "particles", function()
	update();
end);