window = asdfml.OpenWindow()

gl.ClearColor(0, 0.25, 0.5, 1)
gl.LineWidth(1.5)
gl.Enable(e.GL_LINE_SMOOTH)
gl.Enable(e.GL_POINT_SMOOTH)
gl.PointSize(10)
gl.Enable(e.GL_BLEND)
gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)

local vertex = [[
	varying vec3 blah;

	void main()
	{
		blah = gl_Color.rgb;
		gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
	}
]]

local fragment = [[
	varying vec3 blah;
	uniform float lol;

	void main()
	{
		lol;
		gl_FragColor = vec4(blah, 1);
	}
]]

local mesh = {}
local data = vfs.Read("models/teapot.obj")

for line in data:gmatch("(.-)\n") do
	local parts = {}

	for part in line:gmatch("[^%s]+") do
		parts[#parts + 1] = part
	end

	if #parts >= 1 then
		if parts[1] == "v" then
			mesh[#mesh + 1] = tonumber(parts[2])
			mesh[#mesh + 1] = tonumber(parts[3])
			mesh[#mesh + 1] = tonumber(parts[4])
		end
	else
		print(parts[1])
	end
end

local shader = Shader("memory", vertex, fragment)

local params = Event()
local lol = 0

event.AddListener("OnUpdate", "test", function()
	lol = lol + 0.2
	shader:SetFloatParameter("lol", lol)

	if window:IsOpen() then
		if window:PollEvent(params) and params.type == e.EVT_CLOSED then
			window:Close()
			os.exit()
 		end
		
		gl.MatrixMode(e.GL_PROJECTION);
		gl.LoadIdentity()
		glu.Perspective(90, 1, 1, 100)
		gl.MatrixMode(e.GL_MODELVIEW)
		gl.LoadIdentity()
		gl.Translatef(0, 0, -30)
		gl.Rotatef(lol, 1, 0, 0)
		gl.Rotatef(lol * 1.323, 0, 1, 0)
		gl.Rotatef(lol * 2.4213, 0, 0, 1)
		
		gl.Clear(e.GL_COLOR_BUFFER_BIT)		
		
		shader:Bind()

		gl.Begin(e.GL_POINTS)
		
		for i = 1, #mesh / 3 do
			local offset = 1 + (i - 1) * 3
			gl.Color3f(1, 0, 0)
			gl.Vertex3f(mesh[offset + 0], mesh[offset + 1], mesh[offset + 2])
		end
		
		gl.End()

		--[[gl.Begin(e.GL_TRIANGLES)
			gl.Color4f(1, 0, 0, 0.5)
			gl.Vertex3f( 0, 1, 0)
			gl.Color4f(0, 1, 0, 0.75)
			gl.Vertex3f(-1, -1, 0)
			gl.Color4f(0, 0, 1, 1)
			gl.Vertex3f( 1, -1, 0)
		gl.End()
		
		gl.Scalef(math.sin(lol), math.sin(lol * 0.334), math.tan(lol * 0.1))
		
		gl.Begin(e.GL_LINE_STRIP)
			for i = 1, 256 do
				gl.Color4f(math.random(), math.random(), math.random(), math.random())
				gl.Vertex3f(math.randomf(), math.randomf(), math.randomf())
			end
		gl.End()]]

		window:Display()
	end
end)

utilities.MonitorFileInclude()