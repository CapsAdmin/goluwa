local render2d = ... or _G.render2d
render2d.shader_data = {
	name = "mesh_2d",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{color = "vec4"},
		},
		source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);",
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

				float alpha_test = lua[alpha_test_ref = 0];

				if (alpha_test > 0.0)
				{
					if (tex_color.a < alpha_test)
					{
						discard;
					}
				}

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

				vec2 size2 = _G.screen_size*0.25;
				vec2 fragCoord = (uv - vec2(0.5)) * _G.screen_size;
				
				vec2 ratio = vec2(1, 1);

				if (_G.screen_size.y > _G.screen_size.x) {
					ratio = vec2(1, _G.screen_size.y / _G.screen_size.x);
				} else {
					ratio = vec2(1, _G.screen_size.y / _G.screen_size.x);
				}

				float radius = lua[border_radius = 0];
				if (radius > 0) {
					float softness = 50;
					vec2 scale = vec2(g_world_2d[0][0], g_world_2d[1][1]);
					vec2 ratio2 = vec2(scale.y / scale.x, 1);
					vec2 size = scale;
					radius = min(radius, scale.x/2);
					radius = min(radius, scale.y/2);
					
					if (uv.x > 1.0 - radius/scale.x && uv.y > 1.0 - radius/scale.y) {
						float distance = 0;
						distance += length((uv - vec2(1, 1) + vec2(radius/scale.x, radius/scale.y)) * scale) * 1/radius;
						frag_color.a *= -pow(distance, softness)+1;
					}

					if (uv.x < radius/scale.x && uv.y > 1.0 - radius/scale.y) {
						float distance = 0;
						distance += length((uv - vec2(0, 1) + vec2(-radius/scale.x, radius/scale.y)) * scale) * 1/radius;
						frag_color.a *= -pow(distance, softness)+1;
					}

					if (uv.x > 1.0 - radius/scale.x && uv.y < radius/scale.y) {
						float distance = 0;
						distance += length((uv - vec2(1, 0) + vec2(radius/scale.x, -radius/scale.y)) * scale) * 1/radius;
						frag_color.a *= -pow(distance, softness)+1;
					}

					if (uv.x < radius/scale.x && uv.y < radius/scale.y) {
						float distance = 0;
						distance += length((uv - vec2(0, 0) + vec2(-radius/scale.x, -radius/scale.y)) * scale) * 1/radius;
						frag_color.a *= -pow(distance, softness)+1;
					}
				}
			}
		]],
	},
}

function render2d.CreateMesh(vertices)
	return render.CreateVertexBuffer(render2d.shader:GetMeshLayout(), vertices)
end

render2d.shader = render2d.shader or NULL
render2d.rectangle_mesh_data = {
	{pos = {0, 1, 0}, uv = {0, 0}, color = {1, 1, 1, 1}},
	{pos = {0, 0, 0}, uv = {0, 1}, color = {1, 1, 1, 1}},
	{pos = {1, 1, 0}, uv = {1, 0}, color = {1, 1, 1, 1}},
	{pos = {1, 0, 0}, uv = {1, 1}, color = {1, 1, 1, 1}},
	{pos = {1, 1, 0}, uv = {1, 0}, color = {1, 1, 1, 1}},
	{pos = {0, 0, 0}, uv = {0, 1}, color = {1, 1, 1, 1}},
}

function render2d.SetHSV(h, s, v)
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

function render2d.SetColorOverride(r, g, b, a)
	render2d.shader.color_override.r = r
	render2d.shader.color_override.g = g
	render2d.shader.color_override.b = b
	render2d.shader.color_override.a = a or render2d.shader.color_override.a
end

function render2d.GetColorOverride()
	return render2d.shader.color_override:Unpack()
end

utility.MakePushPopFunction(render2d, "ColorOverride")

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

function render2d.SetAlphaTestReference(num)
	if not num then num = 0 end

	render2d.shader.alpha_test_ref = num
end

function render2d.GetAlphaTestReference()
	return render2d.shader.alpha_test_ref
end

utility.MakePushPopFunction(render2d, "AlphaTestReference")

function render2d.SetBorderRadius(num)
	if not num then num = 0 end

	render2d.shader.border_radius = num
end

function render2d.GetBorderRadius()
	return render2d.shader.border_radius
end

utility.MakePushPopFunction(render2d, "BorderRadius")

function render2d.BindShader()
	if render2d.shader_override then
		render2d.shader_override:Bind()
	else
		render2d.shader:Bind()
	end
end

if RELOAD then render2d.Initialize() end