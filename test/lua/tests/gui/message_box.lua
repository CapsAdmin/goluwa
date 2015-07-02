
local frame = gui.CreatePanel("frame")
frame:SetSize(Vec2(250, 140))
frame:SetTitle("Confirm Save As")
	local info = frame:CreatePanel("base")
	info:SetStyle("frame")
	info:SetHeight(85)
		
		local area = info:CreatePanel("base")
		area:SetSize(Vec2(500,500))
		area:SetColor(Color(0,0,0,0))
			local tex = Texture("https://dl.dropboxusercontent.com/u/244444/ShareX/2015-07/2015-07-02_15-07-48.png")
			local image = area:CreatePanel("image")
			image:SetTexture(tex)
			image:SetSize(tex:GetSize())
			image:SetupLayout("left")
			
			local text = area:CreatePanel("text", "temp.txt already exist.\nDo you want to replace it?")
			text:SetPadding(Rect()+5) 
			text:SetText("temp.txt already exist.\nDo you want to replace it?")
			text:SetupLayout("left")
		area:SetupLayout("size_to_width", "size_to_height", "center_x_simple", "center_y")
	
	info:SetupLayout("top", "fill_x")
	
local yes = frame:CreatePanel("text_button")
yes.label:SetupLayout("center_simple")
yes:SetPadding(Rect()+5)
yes:SetText("Yes")
yes:SetSize(Vec2(90, 25))
yes:SetupLayout("top", "right")

local no = frame:CreatePanel("text_button")
no.label:SetupLayout("center_simple")
no:SetPadding(Rect()+5)
no:SetSize(Vec2(90, 25))
no:SetText("No")
no:SetupLayout("top", "right")

