local render = ... or _G.render

local PASS = render.CreateGBufferPass("lens_flare", FILE_NAME:sub(1, 1))
PASS:AddBuffer("lens_flare", "RGBA16F")

function PASS:Draw2D()
	render.SetCullMode("front")
	render.gbuffer:Begin("lens_flare")
		--render.gbuffer:Clear(0,0,0,0, "lens_flare")
		event.Call("DrawLensFlare", render.gbuffer_lens_flare_shader)
	render.gbuffer:End()
	render.SetCullMode("back")			
	
	render.SetBlendMode("alpha")
end
	
PASS:ShaderStage("vertex", { 
	uniform = {
		pvm_matrix = {mat4 = render.GetPVWMatrix2D},
	},			
	attributes = {
		{pos = "vec3"},
		{normal = "vec3"},
		{uv = "vec2"},
		{texture_blend = "float"},
	},	
	source = "gl_Position = pvm_matrix * vec4(pos*7.50, 1);"
})

PASS:ShaderStage("fragment", { 
	uniform = {				
		tex_depth = "sampler2D",
		tex_diffuse = "sampler2D",
		tex_normal = "sampler2D",
		tex_position = "sampler2D",
		
		tex_noise = render.GetNoiseTexture(),
		noise_tex_size = render.GetNoiseTexture():GetSize(),

		screen_pos = Vec2(0,0),
		intensity = 1,
		
		screen_size = {vec2 = render.GetGBufferSize},
		light_color = Color(1,1,1,1),				
		light_diffuse_intensity = 0.5,
		light_radius = 1000,
		
		
		inverse_projection = "mat4",
		cam_nearz = {float = function() return render.camera.nearz end},
		cam_farz = {float = function() return render.camera.farz end},
		view_matrix = {mat4 = function() return render.matrices.view_3d.m end},
	},
	source = [[			
		out vec4 out_color;
		
		vec2 get_uv()
		{
			return gl_FragCoord.xy / screen_size;
		}
							
		float get_depth(vec2 uv) 
		{
			return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, uv).r * (cam_farz - cam_nearz));
		}
		
		vec3 get_pos(vec2 uv)
		{
			float z = -texture2D(tex_depth, uv).r;
			vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
			sPos = inverse_projection * sPos;

			return (sPos.xyz / sPos.w);
		}
		
		/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

		 Trying to get some interesting looking lens flares.

		 13/08/13: 
			published

		muuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuusk!*/

		float noise(float t)
		{
			return texture2D(tex_noise,vec2(t,.0)/noise_tex_size).x;
		}
		float noise(vec2 t)
		{
			return texture2D(tex_noise,t/noise_tex_size).x;
		}

		vec3 lensflare(vec2 uv,vec2 pos)
		{
			vec2 main = uv-pos;
			vec2 uvd = uv*(length(uv));
			
			float ang = atan(main.x,main.y);
			float dist=length(main); dist = pow(dist,.1);
			float n = noise(vec2(ang*16.0,dist*32.0));
			
			float f0 = 1.0/(length(uv-pos)*16.0+1.0);
			
			f0 = f0+f0*(sin(noise((pos.x+pos.y)*2.2+ang*4.0+5.954)*16.0)*.1+dist*.1+.8);
			
			float f1 = max(0.01-pow(length(uv+1.2*pos),1.9),.0)*7.0;

			float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
			float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
			float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;
			
			vec2 uvx = mix(uv,uvd,-0.5);
			
			float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
			float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
			float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;
			
			uvx = mix(uv,uvd,-.4);
			
			float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
			float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
			float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;
			
			uvx = mix(uv,uvd,-0.5);
			
			float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
			float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
			float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;
			
			vec3 c = vec3(.0);
			
			c.r+=f2+f4+f5+f6; 
			c.g+=f22+f42+f52+f62; 
			c.b+=f23+f43+f53+f63;
			
			c = c*1.3 - vec3(length(uvd)*.05);
			c+=vec3(f0);
			
			return c;
		}

		vec3 cc(vec3 color, float factor,float factor2) // color modifier
		{
			float w = color.x+color.y+color.z;
			return mix(color,vec3(w)*factor,w*factor2);
		}
		
		void main()
		{					
			vec2 uv = get_uv();
								
			if (screen_pos != vec2(-2, -2))
			{					
				vec3 color = light_color.rgb*lensflare(uv-vec2(0.5), screen_pos/2);
				color -= noise(gl_FragCoord.xy)*0.015;
				color = cc(color, 0.5, 0.1)*intensity*0.75;
				
				out_color.rgb = color;
				out_color.a = 1;
			}
		}
	]]  
})