local PANEL = {}

PANEL.ClassName = "frame"
PANEL.Base = "draggable"

gui.GetSet(PANEL, "Title", "no title")

PANEL.close = NULL
PANEL.title = NULL

function PANEL:SetTitle(str)
	self.Title = str
	if self.title:IsValid() then
		self.title:SetText(str)
	end
end

function PANEL:CanDrag(button, press, pos)
	return
		button == "button_1" and
		self:SkinCall("FrameCanDrag", pos)
end

function PANEL:Initialize()
	-- close button
	self.close = gui.Create("button", self)
		self.close.OnPress = function()
			self:SetDraggingAllowed(false)
			self:OnClose()
		end
	self.close.OnRelease = function() self:OnClose() end
	self.close.OnDraw = function(self) self:DrawHook("FrameCloseButtonDraw") end
	
	-- title
	self.title = gui.Create("label", self)
	self.title:SetText(self.Title)
	self.title:SizeToText()
	self.title:SetAlignNormal(e.ALIGN_CENTERY)
	
	self:SkinCall("FrameInit")
end

function PANEL:OnClose()
	self:Remove()
end

function PANEL:OnDraw()
	self:DrawHook("FrameDraw")
end

function PANEL:OnPostDraw()
	self:DrawHook("PanelDrawInactive")
end

function PANEL:OnRequestLayout()
	self:LayoutHook("FrameLayout")
end

gui.RegisterPanel(PANEL)