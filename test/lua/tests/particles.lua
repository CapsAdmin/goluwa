local glow_size = 32
local glow_brightness = 4
local glow_alpha = 1
local random_force = 0.5
local particle_count = 5000
local gravity = 0.25

local trail_tex = Texture(1, 255):Fill(function(x, y) 
	return 255, 255, 255, y 
end)

local head_tex = Texture(128, 128):Fill(function(x, y) 
	x = x / 128
	y = y / 128
	
	x = x - 1
	y = y - 1.5
	
	x = x * math.pi
	y = y * math.pi
		
	local a = math.sin(x) * math.cos(y)
	
	a = a ^ 32
		
	return 255, 255, 255, a * 128
end)

local particles = {}

local poly_head = surface.CreatePoly(particle_count)
local poly_tail = surface.CreatePoly(particle_count)
local W, H = surface.GetSize()
 
for i = 1, particle_count do
	particles[i] = {
		px = math.random(W),
		py = math.random(H),
		
		vx = 0,
		vy = 0,
		
		drag = math.clamp((i/particle_count) ^ 0.1, 0.99, 0.999),
		
		size = (-(i/particle_count)+1) * 3,
		
		r = i/particle_count,
		g = math.sin(i/(particle_count/3)),
		b = math.tan(i/(particle_count/5)),
	}
end
	
local function play_sound()

end
	
local function calc_collision(p)
	if p.px - p.size < 0 then
		play_sound(p)
		p.px = p.size
		p.vx = p.vx * -p.drag
	end
	
	if p.px + p.size > W then
		play_sound(p)
		p.px = W - p.size
		p.vx = p.vx * -p.drag
	end
	
	if p.py - p.size < 0 then
		play_sound(p)
		p.py = p.size
		p.vy = p.vy * -p.drag
	end
	
	if p.py + p.size > H then
		play_sound(p)
		p.py = H - p.size
		p.vy = p.vy * -p.drag
	end
end

render.SetClearColor(0,0,0,0)

event.AddListener("Draw2D", "particles", function(dt)
	dt = dt  * 25
	
	render.SetBlendMode("additive")
	
	W,H = surface.GetSize()
	surface.SetTexture(head_tex)
			
	local ext_vel_x, ext_vel_y = surface.GetMouseVel()
	ext_vel_x = ext_vel_x * 0.1
	ext_vel_y = ext_vel_y * 0.1
	
	for i = 1, particle_count do
		local p = particles[i]
		
		p.vx = p.vx + math.randomf(-random_force, random_force) + ext_vel_x
        p.vy = p.vy + math.randomf(-random_force, random_force) + gravity + ext_vel_y
		
		p.px = p.px + (p.vx * dt)
        p.py = p.py + (p.vy * dt)

        p.vx = p.vx * p.drag
        p.vy = p.vy * p.drag
		
		calc_collision(p)
      
		poly_tail:SetColor(i, p.r, p.g, p.b, 1)
		poly_tail:DrawLine(i, p.px, p.py, p.px + (p.vx*-2), p.py + (p.vy*-2), p.size)
		
		poly_head:SetColor(p.r*glow_brightness, p.g*glow_brightness, p.b*glow_brightness, glow_alpha)
		
		local size = p.size*glow_size
		if math.random() > 0.5 then
			size = size + math.random()
		end
		poly_head:SetRect(i, p.px - (size*0.5), p.py - (size*0.5), size, size)
	end
	
	surface.SetColor(1,1,1,1)
	
	surface.SetTexture(trail_tex)
	poly_tail:Draw()
	
	surface.SetTexture(head_tex)
	poly_head:Draw()
	
	render.SetBlendMode("alpha")
	
end)                