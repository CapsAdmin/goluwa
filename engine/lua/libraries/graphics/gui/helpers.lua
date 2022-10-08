local gui = ... or _G.gui

function gui.StringInput(title, msg, default, callback, check)
	title = title or "no title"
	msg = msg or "no message"
	default = default or ""
	callback = callback or logn
	local frame = gui.CreatePanel("frame")
	frame:SetSize(Vec2(250, 140))
	frame:SetTitle(title)
	local info = frame:CreatePanel("base")
	info:SetStyle("frame")
	info:SetHeight(85)
	local area = info:CreatePanel("base")
	area:SetSize(Vec2(500, 500))
	area:SetColor(Color(0, 0, 0, 0))
	local tex = render.CreateTextureFromPath(
		"https://dl.dropboxusercontent.com/u/244444/ShareX/2015-07/2015-07-02_15-07-48.png"
	)
	local image = area:CreatePanel("image")
	image:SetTexture(tex)
	image:SetSize(tex:GetSize())
	image:SetupLayout("left")
	local text = area:CreatePanel("text", "temp.txt already exist.\nDo you want to replace it?")
	text:SetPadding(Rect() + 5)
	text:SetText(msg)
	text:SetupLayout("left")
	area:SetupLayout("size_to_children", "center_simple")
	info:SetupLayout("top", "fill_x")
	local edit = frame:CreatePanel("text_edit")
	edit:SetText(default)
	edit:SetHeight(12)
	edit:SetupLayout("top", "fill_x")
	edit.OnEnter = function(self)
		local str = edit:GetText()

		if not check or check(str, self) ~= false then
			callback(str)
			frame:Remove()
		end
	end
	edit:RequestFocus()
	local no = frame:CreatePanel("text_button")
	no.label:SetupLayout("center_simple")
	no:SetPadding(Rect() + 5)
	no:SetSize(Vec2(90, 25))
	no:SetText(L("cancel"))
	no:SetupLayout("top", "right")
	no.OnRelease = function()
		frame:Remove()
	end
	local yes = frame:CreatePanel("text_button")
	yes.label:SetupLayout("center_simple")
	yes:SetPadding(Rect() + 5)
	yes:SetText(L("ok"))
	yes:SetSize(Vec2(90, 25))
	yes:SetupLayout("top", "right")
	yes.OnRelease = function()
		callback(edit:GetText())
		frame:Remove()
	end
	frame:SetupLayout("size_to_children_height")
	frame:CenterSimple()
	return frame
end

function gui.CreateMenu(options, parent)
	local menu = gui.CreatePanel("menu")

	if parent then
		if parent.Skin then menu:SetSkin(parent:GetSkin()) end

		parent:CallOnRemove(function()
			gui.RemovePanel(menu)
		end, menu)
	end

	local function add_entry(menu, val)
		for k, v in ipairs(val) do
			if type(v[2]) == "table" then
				local menu, entry = menu:AddSubMenu(v[1])

				if v[3] then entry:SetIcon(render.CreateTextureFromPath(v[3])) end

				add_entry(menu, v[2])
			elseif v[1] then
				local entry = menu:AddEntry(v[1], v[2])

				if v[3] then entry:SetIcon(render.CreateTextureFromPath(v[3])) end

				if not v[2] then entry:SetGreyedOut(true) end
			else
				menu:AddSeparator()
			end
		end
	end

	add_entry(menu, options)
	menu:Layout(true)
	menu:SetPosition(gui.world:GetMousePosition():Copy())
	gui.SetActiveMenu(menu)
	return menu
end

function gui.CreateChoices(list, default, parent, padding)
	local area = gui.CreatePanel("base", parent)
	area:SetStack(true)
	area:SetStackRight(false)
	area:SetNoDraw(true)
	area.OnCheck = function() end

	for i, v in ipairs(list) do
		local pnl = area:CreatePanel("checkbox_label")
		pnl:SetText(v)

		if padding then
			pnl:SetPadding(padding)
			pnl.checkbox:SetPadding(padding)
		end

		pnl:SizeToText()
		pnl.OnCheck = function(a)
			area:OnCheck(v, pnl)
		end
	end

	for i, a in ipairs(area:GetChildren()) do
		for i, b in ipairs(area:GetChildren()) do
			a:TieCheckbox(b)
		end
	end

	if default and area:GetChildren()[default] then
		area:GetChildren()[default]:SetState(true)
	else
		area:GetChildren()[1]:SetState(true)
	end

	area:SizeToChildren()
	return area
end

function gui.CreateMenuBar(bar, parent)
	local menu_bar = gui.CreatePanel("base", parent)
	menu_bar:SetStyle("property")
	local menu = NULL
	local current_button = NULL

	for _, info in ipairs(bar) do
		local button = menu_bar:CreatePanel("text_button")
		button:SetActiveStyle("menu_select")
		button:SetInactiveStyle("nodraw")
		button:SetSizeToTextOnLayout(true)
		button:SetText(info.name)
		button:SetMargin(Rect() + 4)
		button:SetupLayout("left", "center_y")
		button.OnPress = function()
			if menu:IsValid() and current_button == button then
				button.suppress = true
			end
		end
		button.OnRelease = function()
			if button.suppress then
				button.suppress = nil
				return
			end

			button:SetState(true)
			current_button = button
			menu = gui.CreateMenu(info.options, menu_bar)
			menu:SetPosition(button:GetWorldPosition() + Vec2(0, button:GetHeight()))

			menu:CallOnRemove(function()
				button:SetState(false)
			end)
		end
		button.OnMouseEnter = function()
			if menu:IsValid() and current_button ~= button then
				menu:Remove()
				button:OnRelease()
			end
		end
	end

	return menu_bar
end

function gui.TestWorld()
	local base = gui.CreatePanel("base", nil, "lol")
	base:SetSize(window.GetSize() * 0.5)
	base:CenterSimple()
	base:SetResizable(true)
	base:SetDraggable(true)
	base:SetColor(Color(0.1, 0.1, 0.1, 1))
	base:SetName("base")
	base:SetMargin(Rect(0, 0, 0, 0))
	return base
end