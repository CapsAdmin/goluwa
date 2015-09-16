local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
PASS.Default = false

local size = 4
local exposure = 1

PASS.Variables = {
	tex_area = "texture",
}

function PASS:Initialize()
	self.area = render.CreateFrameBuffer(size, size)
	self.shader.tex_area = self.area:GetTexture()
end

function PASS:PostRender()
	local tex = render.gbuffer_mixer_buffer:GetTexture()
	self.area:Begin()
		surface.SetColor(1,1,1,0.05)
		surface.SetTexture(tex)
		surface.DrawRect(0,0,size,size)
	self.area:End()
end

PASS.Source = [[
	out vec3 out_color;
		
	void main() 
	{ 	
		float prev_exposure = 0;
		
		]] .. 
		(function() 
			local out = ""
			
			for x = 0, size do
			for y = 0, size do
				out = out .. ("prev_exposure += length(textureOffset(tex_area, vec2(0,0), ivec2(%f, %f)).rgb)/3;\n"):format(x, y)
			end
			end
			
			out = out .. "prev_exposure /= " .. size*size .. ";"
			
			return out
		end)() ..
		[[
		
		prev_exposure = (-prev_exposure + 1) * 2;
		
		out_color = vec3(1.0, 1.0, 1.0) - exp2(-prev_exposure * texture(self, uv).rgb);
		
	}
]]

render.AddGBufferShader(PASS)