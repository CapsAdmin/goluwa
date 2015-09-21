local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Variables = {
	sun_direction = {vec3 = function()
		if SUN and SUN:IsValid() then
			local dir = SUN:GetTRPosition():GetNormalized()
			
			return Vec3(-dir.y, dir.z, -dir.x)
		end
		
		return Vec3()
	end},
}

PASS.Source = [[
out vec3 out_color;

void main(void) 
{
	out_color = texture(self, uv).rgb + get_sky(uv, sun_direction, get_depth(uv));
}
]]

render.AddGBufferShader(PASS)