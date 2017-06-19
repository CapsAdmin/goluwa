steam.MountSourceGame("csgo")
local tex = render.CreateTextureFromPath("materials/skybox/sky_cs15_daylight02_hdrbk.vtf")
--local tex = render.CreateTextureFromPath("textures/hdr/Arches_E_PineTree_3k.hdr")
local gl = require"opengl"
function goluwa.PreDrawGUI()
	gl.Disable("GL_BLEND")
	gfx.DrawRect(10, 10, tex:GetSize().x*3, tex:GetSize().y*3, tex)
	gl.Enable("GL_BLEND")
end