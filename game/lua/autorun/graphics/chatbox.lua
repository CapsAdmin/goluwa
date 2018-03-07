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
	local edit = gui.CreatePanel("text_edit")
	edit:SetMargin(Rect()+3)

	if autocomplete_list then
		edit:AddEvent("PostDrawGUI")
	end

	local i = 1
	local last_history
	local found_autocomplete

	if autocomplete_list then
		-- autocomplete should be done after keys like space and backspace are pressed
		-- so we can use the string after modifications
		edit.OnPostKeyInput = function(self, key, press)
			if not press then return end

			local str = self:GetText():trim()

			if not str:find("\n") and edit:GetCaretPosition().x == #self:GetText() then

				local scroll = 0

				if key == "tab" then
					scroll = input.IsKeyDown("left_shift") and -1 or 1
				end

				found_autocomplete = autocomplete.Query(autocomplete_list, str, scroll)

				if key == "tab" and found_autocomplete[1] then
					edit:SetText(found_autocomplete[1])
					edit:SetCaretPosition(Vec2(math.huge, 0))
					return false
				end
			end
		end
	end

	edit.OnPreKeyInput = function(self, key, press)
		if not press then return end

		local ctrl = input.IsKeyDown("left_shift") or input.IsKeyDown("right_shift")
		local str = self:GetText()

		if str ~= "" and ctrl then
			return
		end

		local history = serializer.ReadFile("luadata", history_path) or {}

		if str == last_history or str == "" or not str:find("\n") then
			local browse = false

			if key == "up" then
				i = math.clamp(i + 1, 1, #history)
				browse = true
			elseif key == "down" then
				i = math.clamp(i - 1, 1, #history)
				browse = true
			end

			local found = history[i]
			if browse and found then
				edit:SetText(found)
				edit:SetCaretPosition(Vec2(#found, 0))
				last_history = found
			end
		end

		if key == "escape" then
			chat.Close()
		elseif key == "enter" or key == "keypad_enter" then
			i = 0

			if #str > 0 then
				if history[1] ~= str then
					table.insert(history, 1, str)
					serializer.WriteFile("luadata", history_path, history)
				end
			end

			if self.OnEnter then
				local ret = self:OnEnter(str)
				if ret ~= nil then
					return ret
				end
			end

			return
		end

		if self.OnTextModified then
			self:OnTextModified(str)
		end
	end

	edit.OnTextChanged = function(self, str)
		if self.OnTextModified then
			self:OnTextModified(str)
		end
		self:SizeToText()
		self:SetupLayout("bottom", "fill_x")
	end

	if autocomplete_list then
		edit.OnPostDrawGUI = function()
			if not chat.IsVisible() then return end
			if found_autocomplete and #found_autocomplete > 0 then
				local pos = edit:GetWorldPosition()
				autocomplete.DrawFound("chatsounds", pos.x, pos.y + edit:GetHeight(), found_autocomplete)
			end
		end
	end

	return edit
end


function chat.GetPanel()
	if chat.panel:IsValid() then return chat.panel end

	chat.console_font = fonts.CreateFont({path = "Roboto", size = 12})

	local frame = gui.CreatePanel("frame")
	chat.panel = frame
	frame:CallOnRemove(chat.Close)

	frame:SetTitle("chatbox")
	frame:SetSize(Vec2(400, 250))
	frame:SetPosition(Vec2(50, window.GetSize().y - frame:GetHeight() - 50))

	local tab = frame:CreatePanel("tab")
	tab:SetSize(Vec2())
	tab:SetupLayout("fill")
	frame.tab = tab

	local S = gui.skin:GetScale()

	do -- chat tab
		local page = tab:AddTab("chat")

		function page:OnSelect()
			self.edit:RequestFocus()
			self.scroll:SetScrollFraction(Vec2(0,1))
		end

		do -- edit line
			do -- emotes
				local emotes = page:CreatePanel("button")
				emotes:SetSize(Vec2()+16)
				emotes:SetupLayout("bottom", "right")
				emotes.OnPress = function()
					local frame = gui.CreatePanel("frame")
					frame:SetSize(Vec2()+256)
					frame:SetPosition(emotes:GetWorldPosition())
					frame:SetTitle(L"smileys")

					local edit = frame:CreatePanel("text_edit")
					edit:SetMargin(Rect()+3)
					--edit:SetHeight(16)
					edit:SetupLayout("top", "fill_x")
					edit:RequestFocus()

					local scroll = frame:CreatePanel("scroll")
					scroll:SetupLayout("top", "fill")
					scroll:SetXScrollBar(false)

					local grid = scroll:SetPanel(gui.CreatePanel("base"))
					grid:SetStack(true)
					grid:SetNoDraw(true)

					edit.OnTextChanged = function(_, str)
						grid:RemoveChildren()

						local i = 0

						for name, path in pairs(chathud.emote_shortucts) do
							if name:find(str) then
								local url = path:match("<texture=(.+)>")
								local icon = grid:CreatePanel("button")
								icon:SetImagePath(url)
								icon:SetSize(Vec2()+32)
								if i > 100 then break end
								i = i + 1
							end
						end

						grid:Layout()
					end

					grid.OnLayout = function()
						grid:SetWidth(scroll:GetWidth())
						grid:SizeToChildrenHeight()
					end
				end

				local image = emotes:CreatePanel("image")
				image:SetSize(Vec2()+16)
				image:SetIgnoreMouse(true)
				image:SetPath("textures/silkicons/emoticon_smile.png")

				page.emotes = emotes
			end

			local edit = chat.CreateEditPanel("data/chat_history.txt", "chatsounds")

			function edit:OnEnter(str)
				chat.Say(str)
				self:SetText("")
				self:Unfocus()
				chat.Close()
				return false
			end

			function edit:OnTextModified(str)
				event.Call("ChatTextChanged", str)
			end

			edit:SetParent(page)
			edit:SetHeight(page.emotes:GetHeight())
			edit:SetupLayout("bottom", "fill_x")
			page.edit = edit
		end

		do -- chat history
			local scroll = page:CreatePanel("scroll")
			scroll:SetXScrollBar(false)
			scroll:SetupLayout("center_simple", "fill")
			page.scroll = scroll

			local old = scroll.OnLayout
			function scroll:OnLayout(...)
				page.text.markup:SetMaxWidth(self:GetAreaSize().x - page.text:GetPadding().x - page.text:GetPadding().w)
				return old(self, ...)
			end

			local text = scroll:SetPanel(gui.CreatePanel("text"))
			text:SetPadding(Rect() + S * 2)
			text.markup:SetLineWrap(true)
			text:AddEvent("ChatAddText")
			page.text = text

			function text:OnTextChanged()
				scroll:Layout()
				scroll:ScrollToFraction(Vec2(0,1))
			end

			function text:OnChatAddText(args)
				self.markup:AddFont(gui.skin.default_font)
				self.markup:AddTable(args, true)
				self.markup:AddTagStopper()
				self.markup:AddString("\n")
			end

			--runfile("lua/examples/2d/markup.lua", text.markup)
			--text.markup:AddString("\n")
		end
	end

	do -- console tab
		local page = tab:AddTab("console")
		--page:SetColor(gui.skin.font_edit_background)

		function page:OnSelect()
			self.edit:RequestFocus()
			self.scroll:SetScrollFraction(Vec2(0,1))
		end

		local edit = chat.CreateEditPanel("data/cmd_history.txt")

		function edit:OnEnter(str)
			logn("> ", str)
			commands.RunString(str, nil, true, true)
			self:SetText("")
			chat.panel:Layout(true)
			return false
		end

		edit:SetParent(page)
		edit:SetupLayout("bottom", "fill_x")
		page.edit = edit

		local scroll = page:CreatePanel("scroll")
		scroll:SetupLayout("center_simple", "fill")
		page.scroll = scroll

		local text = scroll:SetPanel(gui.CreatePanel("text"))
		text:SetPadding(Rect() + S * 2)
		text.markup:SetSuperLightMode(true)
		text.markup:AddFont(chat.console_font)
		text:SetLightMode(true)
		text:SetCopyTags(false)
		text:SetTextWrap(false)
		text:AddEvent("ReplPrint")
		text:AddEvent("ReplClear")
		--text:AddEvent("LogSection")

		text.OnTextChanged = function()
			scroll:ScrollToFraction(Vec2(0,1))
		end

		--[[function text:OnLogSection(type, b)
			if type == "lua error" then
				if b then
					self.markup:AddString("<texture=textures/silkicons/error.png> ", true)
					self.capture = ""
				else
					local error = self.capture:match("ERROR:%s-(%b{})")
					if error then
						self.markup:AddColor(Color(1,0,0,1))
						self.markup:AddString(error:sub(2, -2):trim())
						self.markup:AddString("\n")
					end
					self.capture = nil
				end
			end
		end]]

		function text:OnReplClear()
			self.markup:Clear()
		end

		function text:OnReplPrint(str)
			--if self.capture then
			--	self.capture = self.capture .. str
			--	return
			--end
			self.markup:AddString(str)
			--self.markup:AddTagStopper()
			self.markup:AddString("\n")
		end

		for _, line in ipairs(vfs.Read("logs/console_" .. jit.os:lower() .. ".txt"):split("\n")) do
			text:OnReplPrint(line:gsub("\r", ""))
		end
	end

	return frame
end

local old_mouse_trap

function chat.Open(tab)
	if event.Call("ChatOpen", tab) == false then return end

	tab = tab or "chat"
	old_mouse_trap = window.GetMouseTrapped()

	local panel = chat.GetPanel()

	if tab == "console" then
		panel:SetPosition(Vec2(0, 0))
		panel:SetHeight(300)
		panel:CenterSimple()
		panel:MoveUp()
		panel:FillX()
	end

	panel.tab:SelectTab(tab)

	panel:Minimize(true)

	window.SetMouseTrapped(false)
end

function chat.Close()
	local panel = chat.GetPanel()

	panel:Minimize(false)

	window.SetMouseTrapped(old_mouse_trap)
end

input.Bind("y", "show_chat", function()
	chat.Open()
end)

input.Bind("|", "show_chat_console", function()
	chat.Open("console")
end)

if RELOAD then
	--chat.Close()
	gui.RemovePanel(chat.panel)
	chat.panel = NULL
	chat.Open()
end