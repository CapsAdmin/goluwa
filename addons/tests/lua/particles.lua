local W, H = 1024, 768 

window.Open(W, H) 

local trail_tex = Texture(1, 255):Fill(function(x, y) return 255, 255, 255, y end)
local head_tex = Texture(512, 512):Fill(function(x, y) 
	x = x / 512
	y = y / 512
	
	x = x - 1
	y = y - 1.5
	
	x = x * math.pi
	y = y * math.pi
		
	local a = math.sin(x) * math.cos(y)
	
	a = a ^ 32
		
	return 255, 255, 255, a * 128
end)

local glow_size = 32
local glow_brightness = 4
local glow_alpha = 1
local random_force = 0.5
local max_sand = 1024*2
local gravity = 0.25
local sand = {}
 
for i = 1, max_sand do
	sand[i] = {
		px = math.random(W),
		py = math.random(H),
		
		vx = 0,
		vy = 0,
		
		drag = math.clamp((i/max_sand) ^ 0.1, 0.98, 0.99),
		
		size = 1,
		
		r = i/max_sand,
		g = math.sin(i/(max_sand/3)),
		b = math.tan(i/(max_sand/5)),
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
gl.Enable(e.GL_BLEND)
gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE)

event.AddListener("OnDraw2D", "sand", function(dt)
	dt = dt  * 25
			
	local ext_vel_x, ext_vel_y = (window.GetMouseDelta()*0.1):Unpack()
	
	for i = 1, max_sand do
		local p = sand[i]
		
		p.vx = p.vx + math.randomf(-random_force, random_force) + ext_vel_x
        p.vy = p.vy + math.randomf(-random_force, random_force) + gravity + ext_vel_y
		
		p.px = p.px + (p.vx * dt)
        p.py = p.py + (p.vy * dt)

        p.vx = p.vx * p.drag
        p.vy = p.vy * p.drag
		
		calc_collision(p)

		surface.Color(p.r, p.g, p.b, 1)
		surface.SetTexture(tex)
		surface.DrawLine(
			p.px, 
			p.py, 
			
			p.px + (p.vx*-2), 
			p.py + (p.vy*-2), 
			
			p.size, true
		)
		
		
		surface.Color(p.r*glow_brightness, p.g*glow_brightness, p.b*glow_brightness, glow_alpha)
		surface.SetTexture(head_tex)
		
		local size = p.size*glow_size
		
		surface.DrawRect(
			p.px - (size*0.5), 
			p.py - (size*0.5), 
			
			size, size
		)		
	end
end)                