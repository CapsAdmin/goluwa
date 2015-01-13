local PASS = {}

PASS.Name = "hdr"
PASS.Default = false

PASS.Variables = {
	tex_extracted = "sampler2D",
}

function PASS:Initialize()
	self.fb = render.CreateFrameBuffer(render.GetWidth()/2, render.GetHeight()/2)
	
	self.extract = render.CreateShader([[				
		if (dot(vec4(0.30, 0.59, 0.11, 0.0), texture(self, uv)) > 0.5)
		{
			return texture(self, uv);
		}
		
		return vec4(0.0, 0.0, 0.0, 1.0);
	]], {self = self.fb:GetTexture()})
	
	self.blur = render.CreateShader([[
		float dx = blur_size / size.x;
		float dy = blur_size / size.y;
		
		vec4 color = 4.0 * texture(self, uv);
		color += texture(self, uv + vec2(+dx, 0.0)) * 2.0;
		color += texture(self, uv + vec2(-dx, 0.0)) * 2.0;
		color += texture(self, uv + vec2(0.0, +dy)) * 2.0;
		color += texture(self, uv + vec2(0.0, -dy)) * 2.0;
		color += texture(self, uv + vec2(+dx, +dy));
		color += texture(self, uv + vec2(-dx, +dy));
		color += texture(self, uv + vec2(-dx, -dy));
		color += texture(self, uv + vec2(+dx, -dy));
		
		color.rgb /= 16;
		color.a = 1;
		
		return color;
	]], {
		self = self.fb:GetTexture(), 
		size = Vec2(render.GetWidth(), render.GetHeight()), 
		blur_size = 1,
	})
end

function PASS:Update()
	self.fb:Copy(render.gbuffer_mixer_buffer)
	
	surface.PushMatrix(0, 0, self.fb.w, self.fb.h)
		self.fb:Begin()
			self.extract:Bind()
			surface.rect_mesh:Draw()
		self.fb:End()
		
		for i = 1, 4 do
			self.blur.blur_size = i * 2
			self.fb:Begin()
				self.blur:Bind()
				surface.rect_mesh:Draw()
			self.fb:End()
		end
	surface.PopMatrix()
	
	self.shader.tex_extracted = self.fb:GetTexture()
end


PASS.Source = [[
	out vec4 out_color;
	
	float exposure = 1;
	float bloomFactor = 1;
	float brightMax = 2;
	
	void main() 
	{ 		
		vec4 original_image = texture(self, uv); 
		vec4 downsampled_extracted_bloom = texture(tex_extracted, uv);
		
		vec4 color = original_image + downsampled_extracted_bloom * bloomFactor;
		
		// Perform tone-mapping
		float Y = dot(vec4(0.30, 0.59, 0.11, 0.0), color);
		float YD = exposure * (exposure/brightMax + 1.0) / (exposure + 1.0);
		color *= YD;
		
		color.a = 1;
		
		out_color = color;
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)