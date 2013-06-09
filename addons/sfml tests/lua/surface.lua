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

event.AddListener("OnDraw", "surface", function()
	surface.SetWindow(window)
		
	local t = os.clock()
	local W, H = surface.GetWindowSize() 

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
	
	local x, y = surface.GetMousePos();
	
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
