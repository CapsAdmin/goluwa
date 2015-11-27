local gui = ... or _G.gui

local PANEL = {}
PANEL.ClassName = "frame"

prototype.GetSet(PANEL, "Title", "no title")
prototype.GetSet(PANEL, "Icon", "textures/silkicons/heart.png")

function PANEL:Initialize()
	self:SetDraggable(true)
	self:SetResizable(true)
	self:SetBringToFrontOnClick(true)
	self:SetCachedRendering(true)
	self:SetStyle("frame2")

	local bar = self:CreatePanel("base", "bar")
	bar:SetObeyMargin(false)
	bar:SetStyle("frame_bar")
	bar:SetClipping(true)
	bar:SetSendMouseInputToPanel(self)
	bar:SetupLayout("top", "fill_x")
	--bar:SetDrawScaleOffset(Vec2()+2)

	local close = bar:CreatePanel("button")
	close:SetStyle("close_inactive")
	close:SetStyleTranslation("button_active", "close_active")
	close:SetStyleTranslation("button_inactive", "close_inactive")
	close:SetupLayout("right", "center_y_simple")
	close.OnRelease = function()
		self:Remove()
	end
	self.close = close

	local max = bar:CreatePanel("button")
	max:SetStyle("maximize2_inactive")
	max:SetStyleTranslation("button_active", "maximize2_active")
	max:SetStyleTranslation("button_inactive", "maximize2_inactive")
	max:SetupLayout("right", "center_y_simple")
	max.OnRelease = function()
		self:Maximize()
	end
	self.max = max

	local min = bar:CreatePanel("text_button")
	min:SetStyle("minimize_inactive")
	min:SetStyleTranslation("button_active", "minimize_active")
	min:SetStyleTranslation("button_inactive", "minimize_inactive")
	min:SetupLayout("right", "center_y_simple")
	min.OnRelease = function()
		self:Minimize()
	end
	self.min = min

	self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))

	self:SetIcon(self:GetIcon())
	self:SetTitle(self:GetTitle())

	self:CallOnRemove(function()
		if gui.task_bar:IsValid() then
			gui.task_bar:RemoveButton(self)
		end
		prototype.SafeRemove(self.os_window)
	end)
end

function PANEL:ToWindow()
	local gl = require("graphics.ffi.opengl")
	local window = system.CreateWindow(self:GetSize().x, self:GetSize().y, nil, {"borderless"})
	local world = gui.CreateWorld()

	world:SetSize(Vec2(1680*2,1050))

	local pnl = self
	window.global_mouse = true

	function window:OnUpdate()
		local old_world = gui.world
		gui.world = world

		render.PushWindow(self)
			--render.GetScreenFrameBuffer():Clear()
			render.EnableDepth(false)
			render.SetBlendMode("alpha")

			local x,y = pnl:GetPosition():Unpack()
			render.camera_2d:TranslateWorld(-x,-y, 0)
			gui.UpdateMousePosition()
			world:Draw()
			render.camera_2d:TranslateWorld(x,y, 0)

			self:SetPosition(pnl:GetPosition())
			self:SetSize(pnl:GetSize())

			render.SwapBuffers()
		render.PopWindow()

		gui.world = old_world
	end

	function window:OnMouseInput(button, press)
		local old_world = gui.world
		gui.world = world

		gui.UpdateMousePosition()
		gui.MouseInput(button, press)

		gui.world = old_world
	end

	function window:OnClose()
		self:Remove()
		world:Remove()
	end

	local pos = self:GetPosition()

	self:SetParent(world)
	window:SetPosition(pos)

	self.os_window = window
end

function PANEL:OnLayout(S)
	self:SetMargin(Rect(S,S,S,S))

	self.bar:SetLayoutSize(Vec2()+10*S)
	self.bar:SetMargin(Rect()+S)
	self.bar:SetPadding(Rect()-S)

	self.min:SetPadding(Rect()+S)
	self.max:SetPadding(Rect()+S)
	self.close:SetPadding(Rect()+S)
	self.title:SetPadding(Rect()+S)

	self.icon:SetLayoutSize(Vec2(math.min(S*8, self.icon.Texture.w), math.min(S*8, self.icon.Texture.h)))
end

function PANEL:Maximize(b)
	local max = self.max

	if not self.maximized or b then
		self.maximized = {size = self:GetSize():Copy(), pos = self:GetPosition():Copy()}
		max:SetStyle("maximize_inactive")
		max:SetStyleTranslation("button_active", "maximize_active")
		max:SetStyleTranslation("button_inactive", "maximize_inactive")
		self:FillX()
		self:FillY()
	else
		self:SetSize(self.maximized.size)
		self:SetPosition(self.maximized.pos)
		self.maximized = nil
		max:SetStyle("maximize2_inactive")
		max:SetStyleTranslation("button_active", "maximize2_active")
		max:SetStyleTranslation("button_inactive", "maximize2_inactive")
	end
end

function PANEL:IsMaximized()
	return self.maximized
end

function PANEL:Minimize(b)
	if b ~= nil then
		self:SetVisible(b)
	else
		self:SetVisible(not self.Visible)
	end
end

function PANEL:IsMinimized()
	return self.Visible
end

function PANEL:SetIcon(str)
	self.Icon = str

	local icon = self.bar:CreatePanel("base", "icon")
	icon:SetTexture(Texture(str))
	icon:SetSize(icon.Texture:GetSize())
	icon:SetupLayout("right", "left", "center_y_simple")
	icon.OnRightClick = function()
		local skins = gui.GetRegisteredSkins()
		for i, name in ipairs(skins) do
			skins[i] = {name, function() self:SetSkin(name) end, "textures/silkicons/paintbrush.png"}
		end
		gui.CreateMenu({{"skins", skins, "textures/silkicons/palette.png"}}, self)
	end
	self.icon = icon
end

function PANEL:SetTitle(str)
	self.Title = str

	local title = self.bar:CreatePanel("text", "title")
	title:SetText(str)
	title:SetupLayout("center_y_simple", "center_x")
	self.title = title

	if gui.task_bar:IsValid() then
		gui.task_bar:AddButton(self:GetTitle(), self, function(button)
			self:Minimize(not self:IsMinimized())
		end, function(button)
			gui.CreateMenu({
				{L"remove", function() self:Remove() end, self:GetSkin().icons.delete},
			})
		end)
	end
end

function PANEL:OnMouseInput()
	self:MarkCacheDirty()
end

gui.RegisterPanel(PANEL)
do return end
if RELOAD then
	local panel = gui.CreatePanel(PANEL.ClassName, nil, "test")
	panel:SetSize(Vec2(300, 300))
	panel:ToWindow()
end