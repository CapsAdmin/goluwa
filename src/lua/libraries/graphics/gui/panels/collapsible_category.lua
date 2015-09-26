local gui = ... or _G.gui

local PANEL = {}

PANEL.ClassName = "collapsible_category"

function PANEL:Initialize()
	self:SetNoDraw(true)

	local bar = self:CreatePanel("button", "bar")
	bar:SetObeyMargin(false)
	bar:SetupLayout("top", "fill_x")
	bar:SetClipping(true)
	bar:SetMode("toggle")

	bar.OnStateChanged = function(_, pressed)
		if pressed then
			self.last_height = self.last_height or self:GetHeight()
			self:SetHeight((10*self:GetLayoutScale()) - 1)
			self.content:SetVisible(false)
		elseif self.last_height then
			self:SetHeight(self.last_height)
			self.last_height = nil
			self.content:SetVisible(true)
		end
		if self:HasParent() then
			self:GetParent():Layout()
		end
	end

	local content = self:CreatePanel("base", "content")
	--content:SetNoDraw(true)
	content:SetupLayout("fill")
	self:SetStyle("frame")
	self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
	self:SetTitle("no title")
end

function PANEL:SetPanel(panel)
	panel:SetParent(self.content)
end

function PANEL:SizeToContents()
	self:SetSize(self.content:GetSizeOfChildren() + self.bar:GetSize())
end

function PANEL:OnLayout(S)
	self.bar:SetLayoutSize(Vec2()+10*S)
end

function PANEL:SetTitle(str)
	gui.RemovePanel(self.title)
	local title = self.bar:CreatePanel("text")

	title:SetHeight(self.bar:GetHeight())
	title:SetText(str)
	title:CenterY()
	title:SetNoDraw(true)
	title:SetIgnoreMouse(true)
	title:SetupLayout("center_left")
	self.title = title
end

gui.RegisterPanel(PANEL)

if RELOAD then
	local frame = gui.CreatePanel("frame", nil, PANEL.ClassName .. "_test")
	frame:SetSize(Vec2(200, 400))

	local scroll = frame:CreatePanel("scroll")
	scroll:SetupLayout("fill")

	local list = gui.CreatePanel("base")
	list:SetStack(true)
	list:SetStackRight(false)
	list:SetNoDraw(true)

	scroll:SetPanel(list)

	local a = gui.CreatePanel(PANEL.ClassName, list)
	a:SetSize(Vec2(100,100))
	local b = gui.CreatePanel(PANEL.ClassName, list)
	b:SetSize(Vec2(100,100))

	list:SetSize(Vec2(100, 500))
end