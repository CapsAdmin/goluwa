local PANEL = {}

PANEL.ClassName = "frame"
PANEL.Base = "draggable"

aahh.GetSet(PANEL, "Title", "no title")

function PANEL:SetTitle(str)
	self.title:SetText(str)
end

function PANEL:CanDrag(button, press, pos)
	return
		button == "mouse1" and
		self:SkinCall("FrameCanDrag", pos)
end

function PANEL:Initialize()
	-- close button
	self.close = aahh.Create("button", self)
		self.close.OnPress = function()
			self:SetDraggingAllowed(false)
			self:OnClose()
		end
	self.close.OnRelease = function() self:OnClose() end
	self.close.OnDraw = function(self) self:DrawHook("FrameCloseButtonDraw") end
	
	-- title
	self.title = aahh.Create("label", self)
	self.title:SetText(self.Title)
	self.title:SizeToText()
	
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

aahh.RegisterPanel(PANEL)