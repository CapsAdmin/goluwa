local render = (...) or _G.render

local SHADER = {	
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
			uv = "vec2",
		--	color = "vec4",
		},			
		source = [[
			out vec4 frag_color;

			vec4 texel = texture(tex, uv);

			void main()
			{	
				frag_color = texel * global_color;
				frag_color.a = frag_color.a * alpha_multiplier;
			}
		]]
	} 
}

function render.CreateMesh2D(data)
	render.mesh_2d_shader = render.mesh_2d_shader or render.CreateSuperShader("mesh_2d", SHADER)
	
	local mesh = render.mesh_2d_shader:CreateVertexBuffer(data)
	
	mesh.pvm_matrix = render.GetPVWMatrix2D
	
	return mesh
end

-- for reloading
if render.mesh_2d_shader then
	render.mesh_2d_shader = render.CreateSuperShader("mesh_2d", SHADER)
	surface.Initialize()
end