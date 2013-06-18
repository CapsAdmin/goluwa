#version 330

out vec4 frag_color;

uniform float time;
uniform sampler2D texture;
uniform vec3 cam_pos;

in vec3 vertex_color;
in vec2 vertex_texcoords;
in vec3 vertex_normal;
in vec3 vertex_pos;

vec3 light_direction = normalize(vec3(sin(time), sin(time * 1.234), cos(time)));
vec3 viewer_direction = normalize(cam_pos - vertex_pos);	

vec4 texel = texture2D(texture, vertex_texcoords);

vec3 normal = normalize(vertex_normal);

vec3 get_specular()
{		
	float factor = clamp(dot(reflect(light_direction, normal), viewer_direction) * 0.96, 0.0, 1.0);
	float value = pow(factor, 32.0);
	return texel.xyz * value;
}

vec3 get_diffuse()
{
	return texel.xyz * clamp(dot(normal, light_direction), 0.0, 1.0);
}

vec3 get_ambient()
{
	return texel.xyz * 0.15;
}

void main()
{
	frag_color = 
	vec4(
		get_ambient() +
		get_diffuse() +
		get_specular(), 
		texel.w
	);
}
