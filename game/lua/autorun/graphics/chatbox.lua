if not chat then return end

chat.panel = chat.panel or NULL

function chat.IsVisible()
	return chat.panel:IsValid() and chat.panel:IsVisible()
end

function chat.SetInputText(str)
	if not chat.panel:IsValid() then return end
	chat.panel:SetText(str)
end

function chat.GetInputText()
	if not chat.panel:IsValid() then return "" end
	return chat.panel:GetText()
end

function chat.GetInputPosition()
	if not chat.panel:IsValid() then return 0, 0 end
	return chat.panel:GetPosition()
end


function chat.CreateEditPanel(history_path, autocomplete_list)

	return edit
end


function chat.GetPanel()
	if chat.panel:IsValid() then return chat.panel end

	local frame = gui.CreatePanel("frame")
	chat.panel = frame
	frame:CallOnRemove(chat.Close)

	frame:SetSize(Vec2(400, 250))
	frame:SetPosition(Vec2(50, window.GetSize().y - frame:GetHeight() - 50))

	frame:SetTitle("chat")
	frame:SetIcon("textures/silkicons/user_comment.png")

	do -- edit line
		local edit = frame:CreatePanel("text_input")

		edit:SetMargin(Rect() + 3)
		edit:SetHeight(20)
		edit:SetAutocomplete("chatsounds")
		edit:SetHistoryPath("data/chat_history.txt")

		function edit:OnEscape()
			chat.Close()
		end

		function edit:OnFinish(str)
			chat.Say(str)
			self:SetText("")
			self:Unfocus()
			chat.Close()
			return false
		end

		function edit:OnHeightChanged()
			self:SetupLayout("bottom", "fill_x")
		end

		function edit:OnTextChanged(str)
			event.Call("ChatTextChanged", str)
		end

		edit:SetupLayout("bottom", "fill_x")
		frame.edit = edit
	end

	do -- chat history
		local scroll = frame:CreatePanel("scroll")
		scroll:SetXScrollBar(false)
		scroll:SetupLayout("center_simple", "fill")

		local text = scroll:SetPanel(gui.CreatePanel("text"))
		text.markup:SetLineWrap(true)
		text:AddEvent("ChatAddText", true)
		frame.text = text

		local old = text.OnStyleChanged -- API ME
		function text:OnStyleChanged(skin)
			text:SetPadding(Rect() + skin:GetScale() * 2)
			old(self, skin)
		end

		function text:OnTextChanged()
			scroll:Layout()
			scroll:ScrollToFraction(Vec2(0,1))
		end

		function text:OnChatAddText(args)
			self.markup:AddFont(self:GetSkin().default_font)
			self.markup:AddTable(args, true)
			self.markup:AddTagStopper()
			self.markup:AddString("\n")
		end
	end

	return frame
end

local old_mouse_trap

function chat.Open()
	if event.Call("ChatOpen") == false then return end

	local panel = chat.GetPanel()
	panel:SetVisible(true)
	panel.edit:RequestFocus()

	window.SetMouseTrapped(false)
end

function chat.Close()
	local panel = chat.GetPanel()

	panel:SetVisible(false)

	window.SetMouseTrapped(true)
end

input.Bind("y", "show_chat", function()
	chat.Open()
end)

if RELOAD then
	--chat.Close()
	gui.RemovePanel(chat.panel)
	chat.panel = NULL
	chat.Open()
end