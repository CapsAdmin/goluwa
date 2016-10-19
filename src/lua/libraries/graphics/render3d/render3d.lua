local render3d = _G.render3d or {}

include("gbuffer.lua", render3d)
include("scene.lua", render3d)
include("sky.lua", render3d)
include("environment_probe.lua", render3d)
include("shadow_map.lua", render3d)
include("debug.lua", render3d)

function render3d.GenerateTextures()
	if not render3d.environment_probe_texture then
		local tex = render.CreateTexture("cube_map")
		tex:SetMipMapLevels(1)

		render3d.environment_probe_texture = tex
	end
end

function render3d.GetEnvironmentProbeTexture()
	return render3d.environment_probe_texture
end

return render3d