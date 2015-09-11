local tex = render.CreateTexture("2d")

tex:SetPath("textures/greendog.png")

local function blur_texture(dir)
	tex:Shade([[
		//this will be our RGBA sum
		vec4 sum = vec4(0.0);

		//the amount to blur, i.e. how far off center to sample from 
		//1.0 -> blur by one pixel
		//2.0 -> blur by two pixels, etc.
		float blur = radius/resolution.x; 

		//the direction of our blur
		//(1.0, 0.0) -> x-axis blur
		//(0.0, 1.0) -> y-axis blur
		float hstep = dir.x;
		float vstep = dir.y;

		//apply blurring, using a 9-tap filter with predefined gaussian weights

		sum += texture(self, vec2(uv.x - 4.0*blur*hstep, uv.y - 4.0*blur*vstep)) * 0.0162162162;
		sum += texture(self, vec2(uv.x - 3.0*blur*hstep, uv.y - 3.0*blur*vstep)) * 0.0540540541;
		sum += texture(self, vec2(uv.x - 2.0*blur*hstep, uv.y - 2.0*blur*vstep)) * 0.1216216216;
		sum += texture(self, vec2(uv.x - 1.0*blur*hstep, uv.y - 1.0*blur*vstep)) * 0.1945945946;

		sum += texture(self, vec2(uv.x, uv.y)) * 0.2270270270;

		sum += texture(self, vec2(uv.x + 1.0*blur*hstep, uv.y + 1.0*blur*vstep)) * 0.1945945946;
		sum += texture(self, vec2(uv.x + 2.0*blur*hstep, uv.y + 2.0*blur*vstep)) * 0.1216216216;
		sum += texture(self, vec2(uv.x + 3.0*blur*hstep, uv.y + 3.0*blur*vstep)) * 0.0540540541;
		sum += texture(self, vec2(uv.x + 4.0*blur*hstep, uv.y + 4.0*blur*vstep)) * 0.0162162162;

		return sum;
	]], { 
		radius = 1, 
		resolution = render.GetScreenSize(),
		dir = dir,
	})  
end

blur_texture(Vec2(0,5))
blur_texture(Vec2(5,0))

local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			cam_dir = {vec3 = function() return render.camera_3d:GetAngles():GetForward() end},
			tex = tex,
		},
		mesh_layout = {
			{uv = "vec2"},
		},			
		source = [[
			out highp vec4 frag_color;
			
			void main()
			{	
				vec4 tex_color = texture(tex, uv); 
				//vec4 tex_color = texture(tex, cam_dir); 
				
				frag_color = tex_color;
			}
		]],
	}
})

serializer.WriteFile("msgpack", "lol.wtf", tex:Download())
local info = serializer.ReadFile("msgpack", "lol.wtf")
info.flip_y = true
info.flip_x = true
tex:Upload(info)
--[[local size = 16
tex:Fill(function(x, y)
	if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
		return 255, 0, 255, 255
	else
		return 0, 0, 0, 255
	end
end)
--tex:Clear()
]]

--[[tex:Upload({
	x = 50,
	y = 50,
	buffer = image,
	width = 8,
	height = 8,
})]]

local d = ColorBytes(178, 179, 175)
local m = ColorBytes(203, 203, 202)
local l = ColorBytes(226, 227, 225)

local grad = Texture()
grad:SetSize(Vec2(5, 5))
--grad:SetMinFilter("nearest")
grad:SetMagFilter("nearest")
grad:Upload({
	width = 5,
	height = 5,
	buffer = {
		d, d, d, d, m,
		d, d, d, m, m,
		d, d, m, m, m,
		d, m, m, m, l,
		m, m, m, l, l,
	},
})

event.AddListener("PostDrawMenu", "lol", function()
	--surface.PushMatrix(0, 0, tex:GetSize():Unpack())
		--render.SetShaderOverride(shader)
		--surface.rect_mesh:Draw()
		--render.SetShaderOverride()
	--surface.PopMatrix()
	
	surface.SetFont("zsnes_gui_font")
	surface.DrawText("p", 64, 64)
	
	--surface.SetTexture(grad)
	--surface.SetColor(1,1,1,1)
	--surface.DrawRect(64,64,grad.w*32,grad.h*32)
	
	--surface.SetTexture(tex)
	--surface.DrawRect(0,0,tex.w,tex.h)
	
	--surface.SetWhiteTexture()
	--surface.SetColor(ColorBytes(tex:GetPixelColor(surface.GetMousePosition())))
	--surface.DrawRect(50,50,50,50)
end)
