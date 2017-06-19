steam.MountSourceGame("csgo")

local normal_tex = render.CreateTextureFromPath("materials/asphalt/asphalt_b2_normals.vtf")

local alpha_tex = render.CreateTexture("2d")
alpha_tex:SetSize(normal_tex:GetSize():Copy())
alpha_tex:SetupStorage()


function goluwa.PreDrawGUI()
	gfx.DrawRect(50, 50, normal_tex:GetSize().x, normal_tex:GetSize().y, normal_tex)
end