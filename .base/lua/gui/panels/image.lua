local PANEL = {}

PANEL.ClassName = "image"

gui.GetSet(PANEL, "Texture", NULL)
gui.GetSet(PANEL, "UV")
gui.GetSet(PANEL, "Color")
gui.GetSet(PANEL, "Scale", Vec2(1,1))
gui.GetSet(PANEL, "Filter", true)
gui.GetSet(PANEL, "ResizePanelWithImage", true)

function PANEL:Initialize()
	self.Texture = Texture("textures/gui/pac.png")
end

function PANEL:SizeToContent()
	local siz = self.Texture:GetSize() * self.Scale
	self:SetMinSize(siz)
	self:SetSize(siz)
end

function PANEL:SetTexture(tex)
	self.Texture = tex
	
	if self.ResizePanelWithImage then
		self:SizeToContent()
	end
end

function PANEL:OnDraw()
	self:DrawHook("ImageDraw")
end

function PANEL:OnRequestLayout()
	self:LayoutHook("ImageLayout")
	
	if self.ResizePanelWithImage then
		self:SizeToContent()
	end
end

gui.RegisterPanel(PANEL)