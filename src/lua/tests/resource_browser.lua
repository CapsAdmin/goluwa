local frame = gui.CreatePanel("frame", nil, "lol")
frame:SetSize(Vec2()+512)
frame:CenterSimple()

local bottom = gui.CreatePanel("divider", frame)
bottom:SetStyle("frame")
bottom:SetupLayout("bottom", "fill_x", "fill_y")

local list = bottom:SetRight(gui.CreatePanel("list"))
list:SetupSorted("name", "type")
list:SizeColumnsToFit()

local scroll = bottom:SetLeft(gui.CreatePanel("scroll"))
scroll:SetWidth(200)

bottom:SetDividerPosition(200)

local tree = scroll:SetPanel(gui.CreatePanel("tree"))
tree:SetSize(Vec2() + 200)

for k,v in pairs(vfs.Find(".", nil, true)) do
	tree:AddNode(v)
	local name, ext = v:match("(.+)%.(.+)")
	list:AddEntry(name, ext)
end

tree:SizeToChildrenHeight()
