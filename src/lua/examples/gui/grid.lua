steam.MountSourceGame("gmod")

local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+1024)
base:CenterSimple()
base:SetStack(true)
base:SetResizable(true)

local i = 0

for _, path in pairs(chathud.emote_shortucts) do
	local url = path:match("<texture=(.+)>")
	local icon = base:CreatePanel("image")
	icon:SetPath(url)
	icon:SetSize(Vec2()+16)
	i = i + 1
end

do return end

for _, path in ipairs(vfs.Find("materials/icon16/", true)) do
	local icon = base:CreatePanel("image")
	icon:SetPath(path)
	icon:SetSize(Vec2()+16)
end

