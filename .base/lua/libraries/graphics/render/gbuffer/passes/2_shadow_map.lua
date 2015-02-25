local render = ... or _G.render

local PASS = render.CreateGBufferPass("shadow", FILE_NAME:sub(1, 1))

function PASS:Draw3D()
	event.Call("DrawShadowMaps", render.gbuffer_shadow_shader)
end

function PASS:DrawDebug(i,x,y,w,h,size)
	for name, map in pairs(render.shadow_maps) do
		local tex = map:GetTexture("depth")
	
		surface.SetWhiteTexture()
		surface.SetColor(1, 1, 1, 1)
		surface.DrawRect(x, y, w, h)
		
		surface.SetColor(1,1,1,1)
		surface.SetTexture(tex)
		surface.DrawRect(x, y, w, h)
		
		surface.SetTextPosition(x, y + 5)
		surface.DrawText(tostring(name))
		
		if i%size == 0 then
			y = y + h
			x = 0
		else
			x = x + w
		end
		
		i = i + 1
	end
	
	return i,x,y,w,h
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
	source = "gl_Position = pvm_matrix * vec4(pos, 1);"
})