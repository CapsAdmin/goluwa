local world = gui.CreatePanel("base", nil, "sheep_world")
world:SetTexture(
	render.CreateTextureFromPath(
		"http://fc04.deviantart.net/fs70/f/2010/279/8/4/yoshi__s_island_background_by_twilight_kibeti-d308kyb.png"
	)
)
local sheep = world:CreatePanel("sheep", nil)
local sheep = world:CreatePanel("sheep", nil)
local rand = math.random(10, 80)
--sheep:SetSize(Vec2()+rand)
world:SetThreeDee(true)
world:SetThreeDeeScale(Vec3() + 5)
world:SetSize(Vec2() + 500)
local world = gui.CreatePanel("base", nil, "sheep_world2")
world:SetTexture(
	render.CreateTextureFromPath(
		"http://41.media.tumblr.com/8dfd7eaed633373c13dea2c2b8a2ddd8/tumblr_mhmabftdcN1rrftcdo1_1280.png"
	)
)
world:SetThreeDee(true)
world:SetThreeDeeAngles(Deg3(-90, 0, 0))
world:SetThreeDeePosition(Vec3(0, 0, 2.5))
world:SetThreeDeeScale(Vec3() + 5)
world:SetSize(Vec2() + 500)
render3d.camera:SetPosition(Vec3(-41.939414978027, -14.009494781494, 21.862697601318))
render3d.camera:SetAngles(Ang3(1.1255850791931, -0.16156056523323, 0))