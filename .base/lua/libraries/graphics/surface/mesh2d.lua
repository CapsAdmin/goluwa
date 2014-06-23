local surface = (...) or _G.surface

local SHADER = {	
	name = "mesh_2d",
	vertex = {
		uniform = {
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
			{color = "vec4"},
		},
		source = "gl_Position = pvm_matrix * vec4(pos, 0, 1);"
	},
	
	fragment = { 
		uniform = {
			global_color = Color(1, 1, 1, 1), 
			tex = "sampler2D",
			alpha_multiplier = 1,
		},
		attributes = {
			{uv = "vec2"},
			{color = "vec4"},
		},			
		source = [[
			out highp vec4 frag_color;

			highp vec4 texel = texture(tex, uv);

			void main()
			{	
				frag_color = texel * color * global_color;
				frag_color.a = frag_color.a * alpha_multiplier;
			}
		]]
	} 
}

local RECT = {
	{pos = {0, 0}, uv = {0, 1}, color = {1,1,1,1}},
	{pos = {0, 1}, uv = {0, 0}, color = {1,1,1,1}},
	{pos = {1, 1}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {1, 1}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {1, 0}, uv = {1, 1}, color = {1,1,1,1}},
	{pos = {0, 0}, uv = {0, 1}, color = {1,1,1,1}},
}

function surface.CreateMesh(vertices, indices)
	vertices = vertices or RECT
	
	if not surface.mesh_2d_shader or not surface.mesh_2d_shader:IsValid() then
		local shader = render.CreateShader(SHADER)
		
		shader.pvm_matrix = render.GetPVWMatrix2D
		
		surface.mesh_2d_shader = shader
	end
	
	return surface.mesh_2d_shader:CreateVertexBuffer(vertices, indices)
end

-- for reloading
if RELOAD then
	surface.mesh_2d_shader:Remove()
	surface.rect_mesh = surface.CreateMesh()
	surface.Initialize()
end