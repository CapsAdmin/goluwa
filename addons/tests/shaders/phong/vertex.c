#version 330

uniform mat4 camera_matrix;
uniform mat4 model_matrix;

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
	gl_Position = camera_matrix * model_matrix * vec4(vertex_pos, 1.0);
}
