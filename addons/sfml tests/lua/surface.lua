local test = Texture("file", R"textures/blowfish.png",  IntRect(0, 0, 100, 100))
local font = Font("file", R"fonts/arial.ttf")  
local window = asdfml.OpenWindow()

local vertex = [[
	void main()
	{
		gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
	}
]] 
 
local fragment = [[
	uniform vec3 color;

	void main()
	{
		gl_FragColor = vec4(color, 0.5); 
	}
]]
   
local shader = Shader(vertex, fragment) 

event.AddListener("OnDraw", "surface", function()
	surface.SetWindow(window)
		
	local W, H = surface.GetWindowSize() 

	shader:SetVector3Parameter("color", Vector3f(0,1,0))
	
	surface.SetShaderTexture(test)
	surface.SetShader(shader)
	surface.SetBlendMode(e.BLEND_ALPHA)
	surface.SetColor(20, 255, 0, 255) 
	
	surface.SetOrigin(64, 64)
	
	for i = 1, 5 do
		surface.SetColor(255, 255, 255, 255) 
		surface.SetAngle(i * math.sin(os.clock() * 0.5)*16);
		surface.DrawRect(W/2, 256, 128, 128) 	
	end

	
	surface.SetShader()
	surface.SetBlendMode(e.BLEND_ALPHA)
	
	surface.SetFont(font)
	surface.SetTextColor(255, 255, 255, 50)
	surface.SetTextSize(20)
	
	for i = 1, 100 do
		surface.SetTextPosition(W/2 + i*math.sin(os.clock() * 0.2)*5, W/2 + i*10)
		surface.SetTextAngle(i * math.sin(os.clock() * 0.2)*18)
		surface.DrawText("VVVVVVVVVVVVV")
	end
	
end)
