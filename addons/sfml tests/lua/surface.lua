local test = Texture("file", R"textures/blowfish.png",  IntRect(0, 0, 100, 100))
local arrow = Texture("file", R"textures/arrow.png", IntRect(0, 0, 64, 64));

local font = Font("file", R"fonts/arial.ttf")  
local window = asdfml.OpenWindow()

local vertex = [[
	uniform vec3 pos;
	
	void main()
	{
		gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex + vec4(pos.x,pos.y,0,pos.z);
	}
]] 
 
local fragment = [[
	uniform vec3 color;
	uniform float alpha;
	  
	void main()
	{
		gl_FragColor = vec4(color, alpha);
		
	}
]]  
     
local shader = Shader(vertex, fragment) 
 
local icons   = {}

-- boo aahh isn't mounted
for k,v in vfs.Iterate("addons/aahh/textures/silkicons/.+%.png") do
	table.insert(icons, Texture("file", R(v), IntRect(0,0,16,16)))
end

event.AddListener("OnDraw", "surface", function()
	surface.SetWindow(window)
	local t = os.clock()
	local x, y = surface.GetMousePos();
	local W, H = surface.GetWindowSize() 
 
	local lastX, lastY = 0, 0;

	for k,v in pairs(icons) do
		if (k % 32 == 1) then
			lastX = 0;
			lastY = lastY + 20;
		else
			lastX = lastX + 20;
		end;

		surface.SetAngle(math.deg(math.atan2(lastY - y, lastX - x)));
		surface.SetOrigin(8, 8);
		surface.SetTexture(v)
		local size = Vec2(lastX, lastY):Distance(Vec2(x, y)) / 300
		size = -size + 2
		size = size ^ 5
		surface.DrawRect(lastX, lastY, size, size)
	end
	
	
	shader:SetFloatParameter("alpha", 0.25)
	
	surface.SetShaderTexture(test)
	surface.SetShader(shader)
	surface.SetBlendMode(e.BLEND_ALPHA)
	surface.SetColor(20, 255, 0, 255) 
	
	surface.SetOrigin(64, 64)
	
	for i = 1, 5 do
		surface.SetColor(255, 255, 255, 255) 
		shader:SetVector3Parameter("pos", Vector3f(0,0,math.sin(t + i) / 2))
		shader:SetVector3Parameter("color", Vector3f(math.sin(t*i),math.sin(t*i*i),math.sin(t*5*i)))
		surface.SetAngle(i * math.sin(os.clock() * 0.5)*16);
		surface.DrawRect(W/2, 256, 128, 128) 	
	end

	
	surface.SetShader()
	surface.SetBlendMode(e.BLEND_ALPHA)
	
	surface.SetFont(font)
	surface.SetTextColor(255, 255, 255, 50)
	surface.SetTextSize(20)
		
	for i = 1, 100 do
		surface.SetTextPosition(x + i*math.sin(os.clock() * 0.2)*5, y + i*10)
		surface.SetTextAngle(i * math.sin(os.clock() * 0.2)*18)
		surface.DrawText("VVVVVVVVVVVVV")
	end
 
	surface.SetColor(255, 255, 255, 255);
	surface.SetAngle(math.deg(math.atan2(y - H/2, x - W/2)));
	surface.SetOrigin(32, 32);
	surface.SetTexture(arrow);
	surface.DrawRect(W/2, H/2, 64, 64);
end) 
