local render2d = ... or _G.render2d

render2d.shader_data = {
	name = "mesh_2d",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{color = "vec4"},
		},
		source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
	},
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
			{color = "vec4"},
		},
		source = [[
			out highp vec4 frag_color;

			void main()
			{
				vec4 tex_color = texture(lua[tex = "sampler2D"], uv);
				vec4 override = lua[color_override = Color(0,0,0,0)];

				if (override.r > 0) tex_color.r = override.r;
				if (override.g > 0) tex_color.g = override.g;
				if (override.b > 0) tex_color.b = override.b;
				if (override.a > 0) tex_color.a = override.a;

				frag_color = tex_color * color * lua[global_color = Color(1,1,1,1)];
				frag_color.a = frag_color.a * lua[alpha_multiplier = 1];

				vec3 hsv_mult = lua[hsv_mult = Vec3(1,1,1)];

				if (hsv_mult != vec3(1,1,1))
				{
					frag_color.rgb = hsv2rgb(rgb2hsv(frag_color.rgb) * hsv_mult);
				}
			}
		]]
	}
}

function render2d.CreateMesh(vertices, indices)
	return render.CreateVertexBuffer(render2d.shader, vertices, indices)
end

render2d.shader = render2d.shader or NULL

render.rectangle_mesh_data = {
	{pos = {0, 1, 0}, uv = {0, 0}, color = {1,1,1,1}},
	{pos = {0, 0, 0}, uv = {0, 1}, color = {1,1,1,1}},
	{pos = {1, 1, 0}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {1, 0, 0}, uv = {1, 1}, color = {1,1,1,1}},
	{pos = {1, 1, 0}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {0, 0, 0}, uv = {0, 1}, color = {1,1,1,1}},
}

function render2d.SetHSV(h,s,v)
	render2d.shader.hsv_mult.x = h
	render2d.shader.hsv_mult.y = s
	render2d.shader.hsv_mult.z = v
end

function render2d.GetHSV()
	return render2d.shader.hsv_mult:Unpack()
end

utility.MakePushPopFunction(render2d, "HSV")

function render2d.SetColor(r, g, b, a)
	render2d.shader.global_color.r = r
	render2d.shader.global_color.g = g
	render2d.shader.global_color.b = b
	render2d.shader.global_color.a = a or render2d.shader.global_color.a
end

function render2d.GetColor()
	return render2d.shader.global_color:Unpack()
end

utility.MakePushPopFunction(render2d, "Color")

function render2d.SetAlpha(a)
	render2d.shader.global_color.a = a
end

function render2d.GetAlpha()
	return render2d.shader.global_color.a
end

utility.MakePushPopFunction(render2d, "Alpha")

function render2d.SetAlphaMultiplier(a)
	render2d.shader.alpha_multiplier = a or render2d.shader.alpha_multiplier
end

function render2d.GetAlphaMultiplier()
	return render2d.shader.alpha_multiplier
end

utility.MakePushPopFunction(render2d, "AlphaMultiplier")

function render2d.SetTexture(tex)
	render2d.shader.tex = tex or render.GetWhiteTexture()
end

function render2d.GetTexture()
	return render2d.shader.tex
end

utility.MakePushPopFunction(render2d, "Texture")