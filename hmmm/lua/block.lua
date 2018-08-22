local normal_map = render.CreateBlankTexture(Vec2() + 128):Shade([[

	float Heightmap(float ox, float oy)
	{
		ox /= size.x;
		ox += uv.x;

		oy /= size.y;
		oy += uv.y;

		float x = sin(ox*PI);
		float y = cos((oy - 0.5)*PI);
		float z = x * y;

		return pow(z + 0.1, 2);
	}

	vec4 shade()
	{
		float s11 = Heightmap(0, 0);
		float s01 = Heightmap(-1, 0);
		float s21 = Heightmap(1, 0);
		float s10 = Heightmap(0, -1);
		float s12 = Heightmap(0, 1);

		vec3 va = normalize(vec3(vec2(1, 0), s21 - s01));
		vec3 vb = normalize(vec3(vec2(0, 1), s12 - s10));

		return vec4( s11,s11,s11, 1 );
	}
]])

function goluwa.PreDrawGUI()
	gfx.DrawRect(0, 0, render2d.GetSize())

	render2d.SetColor(1,1,1, 1)
	render2d.SetTexture(normal_map)
	render2d.DrawRect(0, 0, 128*4,128*4)
end