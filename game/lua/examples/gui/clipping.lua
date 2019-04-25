local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+128)
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.5,0.5,0.5,1))
base:SetMargin(Rect()+4)
base:SetName("base")

base:SetClipping(true)

local image = base:CreatePanel("image")
image:SetSizeToImage(true)
image:SetPath("http://1.bp.blogspot.com/-LulO5dAGVns/T16_9ZZb6mI/AAAAAAAAAGI/J1lVGOhP9wU/s1600/multiplication+table+-+step+9.jpg")
image:SetIgnoreMouse(true)

base:SetScrollable(true)

base:SetScroll(Vec2() + 256)