local PASS = {}

PASS.Name = "hdr"
PASS.Default = false

PASS.Variables = {
	tex_extracted = "sampler2D",
	bloom_factor = 0.2,
	exposure = 1,
}

function PASS:Initialize()
	self.fb = render.CreateFrameBuffer(render.GetWidth()/4, render.GetHeight()/4)
	self.area = render.CreateFrameBuffer(1,1)
	
	self.exposure = 1
	self.smooth_exposure = 1
	
	self.extract = render.CreateShader([[				
		vec4 color = vec4(1,1,1,1);
		color.rgb = pow(texture(self, uv).rgb, vec3(1.25))*1.25;
		return color;
	]], {self = self.fb:GetTexture(), exposure = 1})
	
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
	
	render.SetBlendMode("alpha")
	
	surface.PushMatrix(0, 0, self.fb.w, self.fb.h)
		self.fb:Begin()
			self.shader.exposure = self.smooth_exposure
			self.extract:Bind()
			surface.rect_mesh:Draw()
		self.fb:End()
		
		for i = 1, 3 do
			self.blur.blur_size = i*2
			self.fb:Begin()
				self.blur:Bind()
				surface.rect_mesh:Draw()
			self.fb:End()
		end
	surface.PopMatrix()
	
	
	if not self.next_update or self.next_update < system.GetTime() then
		self.area:Copy(self.fb)
		self.area:Begin()	
			local r,g,b = render.ReadPixels(0,0, 1,1)
			self.exposure = math.clamp((-math.max(r,g,b)+1) * 2, 0.1, 1) ^ 0.75
		self.area:End()
		self.next_update = system.GetTime() + 1/30
	end
		
	self.smooth_exposure = self.smooth_exposure or 0
	self.smooth_exposure = math.lerp(render.delta, self.smooth_exposure, self.exposure)
		

	self.shader.tex_extracted = self.fb:GetTexture()
end


PASS.Source = [[
	out vec4 out_color;
		
	void main() 
	{ 	
		out_color.rgb = 1 - exp2(-(texture(self, uv).rgb + bloom_factor * texture(tex_extracted, uv).rgb) * exposure);
		out_color.rgb *= 2;
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)