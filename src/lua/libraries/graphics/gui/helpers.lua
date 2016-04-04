local gui = ... or _G.gui

function gui.StringInput(msg, default, callback, check)
	msg = msg or "no message"
	default = default or " "
	callback = callback or logn

	local frame = gui.CreatePanel("frame")
	frame:SetTitle("Text Input Request")
	frame:SetSize(Vec2(250, 120)) -- Should probably be based off their screen size...

	local pad = Rect()+frame:GetSkin().scale*4

	local label = frame:CreatePanel("text")
	label:SetText(msg)
	label:SetPadding(pad)
	label:SetupLayout("bottom", "left", "top")

	local textinput = frame:CreatePanel("text_edit")
	textinput:SetText(default)
	textinput:SizeToText()
	textinput:SetPadding(pad)
	textinput:SetupLayout("bottom", "left", "top", "fill_x")

	local text_button = frame:CreatePanel("text_button")
	text_button:SetText("Ok")
	text_button:SizeToText()
	text_button:SetPadding(pad)
	text_button:SetupLayout("bottom", "left", "top", "fill_x")

	text_button.OnPress = function(self)
		callback(textinput:GetText())
		frame:Remove()
	end

	textinput.OnEnter = function(self)
		local str = textinput:GetText()
		if not check or check(str, self) ~= false then
			callback(str)
			frame:Remove()
		end
	end

	frame:Center()

	return frame
end

function gui.CreateMenu(options, parent)
	local menu = gui.CreatePanel("menu")

	if parent then
		if parent.Skin then
			menu:SetSkin(parent:GetSkin())
		end
		parent:CallOnRemove(function() gui.RemovePanel(menu) end, menu)
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
	local area = gui.CreatePanel("base", parent, padding)
	area:SetStack(true)
	area:SetStackRight(false)
	area:SetNoDraw(true)

	for i, v in ipairs(list) do
		local pnl = area:CreatePanel("checkbox_label")
		pnl:SetText(v)
		if padding then pnl:SetPadding(padding) end
		pnl:SizeToText()
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