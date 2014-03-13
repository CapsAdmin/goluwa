local markup = Markup()

markup:Test()

markup:Invalidate()

if markup_frame and markup_frame:IsValid() then 
	markup_frame:Remove() 
end 
  
markup.chunk_fix = true
M = markup

local frame = aahh.Create("frame")
local panel = frame:CreatePanel("panel")

panel:Dock("fill")
window.SetSize(Vec2(1680, 1050))
timer.Delay(0.1, function()
frame:SetSize(1000, 1000)
end)
panel:MakeActivePanel()
frame:RequestLayout(true) 

markup_frame = frame

function panel:OnDraw(size)
	local w,h = size:Unpack()
	
	surface.Color(0.1, 0.1, 0.1, 1)
	surface.DrawRect(0,0, w, h)
	
	surface.Color(1, 1, 1, 0.1)
	surface.DrawRect(0,0, markup.width or w, markup.height or h)
	
	-- this is needed for proper mouse coordinates
	local x, y = self:GetWorldPos():Unpack()
	markup:Draw(x, y, size:Unpack())
end

function panel:OnRequestLayout()
	markup:SetMaxWidth(self:GetWidth()) 
end

function panel:OnMouseInput(button, press)
	markup:OnMouseInput(button, press, window.GetMousePos():Unpack())
end

function panel:OnKeyInput(key, press)
	
	if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) end
	if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) end
	
	if press then
		markup:OnKeyInput(key)
		
		if markup.ControlDown and key == "z" then
			include("tests/markup.lua")
		end
	end
end

function panel:OnCharInput(char)
	markup:OnCharInput(char)
end

