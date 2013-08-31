local window = glw.OpenWindow(1280, 720)

local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)

local function calc_camera(window, dt)

	cam_ang:Normalize()
	local speed = dt * 10

	local delta = input.GetMouseDelta() * dt / 2
	cam_ang.p = cam_ang.p + delta.y
	cam_ang.y = cam_ang.y + delta.x
	cam_ang.p = math.clamp(cam_ang.p, -math.pi/2, math.pi/2)

	if input.IsKeyDown("left_shift") then
		speed = speed * 4
	elseif input.IsKeyDown("left_control") then
		speed = speed / 4
	end

	if input.IsKeyDown("space") then
		cam_pos = cam_pos - Vec3(0, speed, 0);
	end

	local offset = cam_ang:GetUp() * speed;
	offset.x = -offset.x;
	offset.y = -offset.y

	if input.IsKeyDown("w") then
		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - offset
	end

	offset = cam_ang:GetRight() * speed
	offset.z = -offset.z

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - offset
	end

	speed = dt * 5

	if input.IsKeyDown("up") then
		cam_ang.p = cam_ang.p - speed 
	elseif input.IsKeyDown("down") then
		cam_ang.p = cam_ang.p + speed
	end

	if input.IsKeyDown("left") then
		cam_ang.y = cam_ang.y - speed
	elseif input.IsKeyDown("right") then
		cam_ang.y = cam_ang.y + speed
	end
end

local mesh = Mesh(utilities.GenerateNormals(utilities.CreateCube()))

entities.world_entity:RemoveChildren()

for i=1, 100 do 
	do break end
	local box = Entity("model")
		box:SetMesh(mesh)
		
		box:SetSize(math.randomf(0.5, 1))
		box:SetPos(Vec3(math.randomf(-1,1), math.randomf(-1,1), 0) * 5)
		box:SetAngles(Ang3Rand():GetDeg())	
		box:SetTexture("face1.png")
		box.OnUpdate = function(self, dt)
			local ang = self:GetAngles()
			dt = dt * 0.25
			
			ang.p = ang.p + dt
			ang.y = ang.y + dt
			ang.r = ang.r + dt
			
			self:SetAngles(ang)	
		end
	entities.world_entity:AddChild(box)
end  

input.SetMouseTrapped(true)

-- load the shader sources
local vert = [[
#version 330

uniform mat4 proj_mat;
uniform mat4 view_mat;

uniform float time;

in vec3 position;
in vec3 normal;
in vec2 uv;

out vec3 vertex_color;
out vec2 vertex_texcoords;
out vec3 vertex_normal;
out vec3 vertex_pos;

void main()
{			
	vertex_texcoords = uv;
	vertex_color = vec3(1,1,1);
	vertex_normal = normal;
	vertex_pos = position;
				
	// multiply before passing to shader???
	gl_Position = proj_mat * view_mat * vec4(vertex_pos, 1.0);
}
]]

local frag = [[
#version 330

out vec4 frag_color;

uniform float time;
uniform sampler2D texture;
uniform vec3 cam_pos;

in vec3 vertex_color;
in vec2 vertex_texcoords;
in vec3 vertex_normal;
in vec3 vertex_pos;
 
vec4 texel = texture2D(texture, vertex_texcoords);

void main()
{
	frag_color = 
	vec4(
		texel.xyz,
		texel.w
	);
}
]]

local color_program = Program(Shader(e.GL_VERTEX_SHADER, vert), Shader(e.GL_FRAGMENT_SHADER, frag))
					
gl.BindAttribLocation(color_program, 0, "position")
gl.BindAttribLocation(color_program, 1, "normal")
gl.BindAttribLocation(color_program, 2, "uv")

local vert = [[
#version 120

uniform float u_farDistance;

varying vec3 v_normal;
varying vec2 v_texCoord;
varying float v_depth;

void main (void)
{
	vec4 viewSpaceVertex = gl_ModelViewMatrix * gl_Vertex;
	v_normal = gl_NormalMatrix * gl_Normal;
	v_texCoord = gl_MultiTexCoord0.st;
	v_depth = -viewSpaceVertex.z / u_farDistance;

	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
]]

local frag = [[
#version 120

uniform sampler2D u_texture;

varying vec3 v_normal;
varying vec2 v_texCoord;
varying float v_depth;

void main(void)
{
	vec3 diffuse = texture2D(u_texture, v_texCoord.st).rgb;
	gl_FragData[0] = vec4(diffuse, 1.0); // albedo
	gl_FragData[1] = vec4(normalize(v_normal), v_depth); // normals + depth
}
]] 

local diffuse_program = Program(Shader(e.GL_VERTEX_SHADER, vert), Shader(e.GL_FRAGMENT_SHADER, frag))
local tex = Texture("textures/face1.png")

event.AddListener("OnDraw", "gl", function(dt)
	entities.Call("OnUpdate", dt)
  	calc_camera(window, dt)

	render.Start(window)

		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)

		render.Start3D(cam_pos, cam_ang:GetDeg())
			
			render.BeginGeometryPass()
				render.SetProgram(diffuse_program)
					
					render.SetTexture(render.frame_buffers[e.GBUFFER_TEXTURE_COLOR], 0, "u_texture")
					gl.Uniform1f(gl.GetUniformLocation(diffuse_program, "u_farDistance"), 1000)
					entities.world_entity:Draw()	
				
				render.SetProgram()
			render.EndGeometryPass()

		render.Start2D()
			render.SetProgram(diffuse_program)
				render.SetTexture(render.frame_buffers[e.GBUFFER_TEXTURE_COLOR], 0, "u_texture")
				
				render.PushMatrix(Vec3(0, 0), Ang3(0), Vec3(200, 200))	
					gl.Color4f(1, 1, 1, 0.5) 
					render.DrawQuad()
				render.PopMatrix()
			render.SetProgram()
	render.End()
end)
