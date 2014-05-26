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
		--	{color = "vec4"},
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
		--	{color = "vec4"},
		},			
		source = [[
			out highp vec4 frag_color;

			highp vec4 texel = texture(tex, uv);

			void main()
			{	
				frag_color = texel * global_color;
				frag_color.a = frag_color.a * alpha_multiplier;
			}
		]]
	} 
}

function surface.CreateMesh(data)
	if not surface.mesh_2d_shader then
		local shader = render.CreateShader(SHADER)
		
		shader.pvm_matrix = render.GetPVWMatrix2D
		
		surface.mesh_2d_shader = shader
	end
	
	return surface.mesh_2d_shader:CreateVertexBuffer(data)
end

-- for reloading
if surface.mesh_2d_shader then
	surface.mesh_2d_shader = surface.CreateShader(SHADER)
	surface.Initialize()
end