local gui = ... or _G.gui

local META = prototype.CreateTemplate("frame")

META:GetSet("Title", "no title")
META:GetSet("Icon", "textures/silkicons/heart.png")

function META:Initialize()
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
	bar:SetObeyMargin(false)
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

function META:ToWindow()
	local gl = system.GetFFIBuildLibrary("opengl", true)
	local window = window.CreateWindow(self:GetSize().x, self:GetSize().y, nil, {"borderless"})
	local world = gui.CreateWorld()

	world:SetSize(Vec2(1680*2,1050))

	local pnl = self
	window.global_mouse = true

	function window:OnUpdate()
		local old_world = gui.world
		gui.world = world

		render.PushWindow(self)
			--render.GetScreenFrameBuffer():Clear()
			render.SetDepth(false)
			render.SetPresetBlendMode("alpha")

			local x,y = pnl:GetPosition():Unpack()
			render2d.camera:TranslateWorld(-x,-y, 0)
			gui.UpdateMousePosition()
			world:Draw()
			render2d.camera:TranslateWorld(x,y, 0)

			self:SetPosition(pnl:GetPosition())
			self:SetSize(pnl:GetSize())

			render.SwapBuffers(self)
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

function META:OnLayout(S)
	self:SetMargin(Rect(S,S,S,S)*2)

	self.bar:SetLayoutSize(Vec2()+10*S)
	self.bar:SetMargin(Rect(S,S,S,S))

	self.min:SetPadding(Rect()+S)
	self.max:SetPadding(Rect()+S)
	self.close:SetPadding(Rect()+S)
	self.title:SetPadding(Rect()+S)

	self.icon:SetLayoutSize(Vec2(math.min(S*8, self.icon.Texture:GetSize().x), math.min(S*8, self.icon.Texture:GetSize().y)))
end

function META:Maximize(b)
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

function META:IsMaximized()
	return self.maximized
end

function META:Minimize(b)
	if b ~= nil then
		self:SetVisible(b)
	else
		self:SetVisible(not self.Visible)
	end
end

function META:IsMinimized()
	return self.Visible
end

function META:SetIcon(str)
	self.Icon = str

	local icon = self.bar:CreatePanel("base", "icon")
	icon:SetTexture(render.CreateTextureFromPath(str))
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

function META:SetTitle(str)
	self.Title = str

	local title = self.bar:CreatePanel("text", "title")
	title:SetText(str)
	title:SetupLayout("center_y_simple", "center_x")
	title:SetSendMouseInputToPanel(self)
	self.title = title

	if gui.GetTaskBar then
		gui.GetTaskBar():AddButton(self:GetTitle(), self, function(button)
			self:Minimize(not self:IsMinimized())
		end, function(button)
			gui.CreateMenu({
				{L"remove", function() self:Remove() end, self:GetSkin().icons.delete},
			})
		end)
	end
end

function META:OnMouseInput(button, press)
	self:MarkCacheDirty()

	if button == "button_1" and press then
		if self.last_click and self.last_click > system.GetTime() then
			self:Maximize(not self:IsMaximized())
			self.last_click = nil
		end
	end

	self.last_click = system.GetTime() + 0.2
end

gui.RegisterPanel(META)

if RELOAD then
	local panel = gui.CreatePanel(META.ClassName, nil, "test")
	panel:SetPosition(Vec2()+50)
	panel:SetSize(Vec2(300, 300))
	local pnl = gui.CreateMenuBar({name = "lol", options = {}}, panel)
	pnl:SetHeight(20)
	pnl:SetupLayout("center_simple", "top")

end
