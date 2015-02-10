chat.panel = chat.panel or NULL

function chat.IsVisible()
	return chat.panel:IsValid()
end
	
function chat.SetInputText(str)
	if not chat.IsVisible() then return end
	chat.panel:SetText(str)
end

function chat.GetInputText()
	if not chat.IsVisible() then return "" end
	return chat.panel:GetText()
end	

function chat.GetInputPosition()
	if not chat.IsVisible() then return 0, 0 end
	return chat.panel:GetPosition()
end

function chat.GetPanel()
	if chat.panel:IsValid() then return chat.panel end
		
	local frame = gui.CreatePanel("frame")
	frame:SetTitle("chatbox")
	frame:SetSize(Vec2(400, 250))
	frame:SetPosition(Vec2(20, render.GetHeight()-frame:GetHeight()-20))
	
	frame:CallOnRemove(chat.Close)
	
	local S = gui.skin.scale
	
	local edit = frame:CreatePanel("text_edit")
	edit:SetHeight(9*S)
	edit:SetupLayout("bottom", "fill_x")
	frame.edit = edit
	
	local tab = frame:CreatePanel("tab")
	tab:SetSize(Vec2())
	tab:SetupLayout("fill_x", "fill_y")
	frame.tab = tab
	
	local page = tab:AddTab("chat")
	
	local scroll = page:CreatePanel("scroll")
	scroll:SetXScrollBar(false)
	scroll:SetupLayout("fill_x", "fill_y")
	page.scroll = scroll

	local text = scroll:SetPanel(gui.CreatePanel("text"))
	text:SetPosition(Vec2()+S*2)

	text.markup:SetLineWrap(true)
	text:AddEvent("ChatAddText")

	function text:OnChatAddText(args)
		self.markup:AddFont(gui.skin.default_font)
		self.markup:AddTable(args, true)
		self.markup:AddTagStopper()
		self.markup:AddString("\n")
		
		page.scroll.scroll_area:SetScrollFraction(Vec2(0,1))
	end
	
	function text:OnLayout()
		self.markup:SetMaxWidth(self.Parent:GetWidth())
	end
	
	text:Layout()

	edit:RequestFocus()
	--edit:SetMultiline(true)
	
	local i = 1
	local history = {}
	local last_history
	local found_autocomplete
	
	-- autocomplete should be done after keys like space and backspace are pressed
	-- so we can use the string after modifications
	edit.OnPostKeyInput = function(self, key, press)
		if not press then return end
		
		local str = self:GetText():trim()
		
		local scroll = 0
		 
		if key == "tab" then
			scroll = input.IsKeyDown("left_shift") and -1 or 1
		end
		
		found_autocomplete = autocomplete.Query("chatsounds", str, scroll)
							
		if key == "tab" and found_autocomplete then
			edit:SetText(found_autocomplete[1])
			return false
		end
	end
	
	edit.OnPreKeyInput = function(self, key, press)	
		if not press then return end
		
		local str = self:GetText()
		
		local ctrl = input.IsKeyDown("left_control") or input.IsKeyDown("right_control")
		
		if ctrl or str == "" or str == last_history then
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

		if key == "enter" and not ctrl or key == "escape" then
		
			if key ~= "escape" then
				i = 0
				if #str > 0 then
					chat.Say(str)
					if history[1] ~= str then
						table.insert(history, 1, str)
					end
				end
			end
			
			chat.Close()
			
			return
		end	
		
		event.Call("ChatTextChanged", str)
	end
		
	edit.OnTextChanged = function(_, str)
		event.Call("ChatTextChanged", str)
		event.Delay(0, function()
			if frame:IsValid() then
				edit:SizeToText()
				edit:SetupLayout("bottom", "fill_x")
				frame:Layout()
			end
		end)
	end
	
	edit.OnPostDraw = function()
		if found_autocomplete and #found_autocomplete > 0 then
			autocomplete.DrawFound(0, edit:GetHeight(), found_autocomplete, nil, 2) 
		end
	end
	
	local page = tab:AddTab("console")	
	page:SetColor(gui.skin.font_edit_background)
	
	local scroll = page:CreatePanel("scroll")
	scroll:SetXScrollBar(false)
	scroll:SetupLayout("fill_x", "fill_y")
	page.scroll = scroll

	local text = scroll:SetPanel(gui.CreatePanel("text"))
	text:SetPosition(Vec2()+S*2)
	text.markup:SetLineWrap(true)
	text:AddEvent("ConsolePrint")

	function text:OnConsolePrint(str)
		self.markup:AddFont(gui.skin.default_font)
		self.markup:AddString(str, true)
		self.markup:AddTagStopper()
		
		page.scroll.scroll_area:SetScrollFraction(Vec2(0,1))
	end
	
	for i, v in pairs(console.history) do
		text:OnConsolePrint(v)
	end
	
	function text:OnLayout()
		self.markup:SetMaxWidth(self.Parent:GetWidth())
	end
	
		
	chat.panel = frame
	
	return frame
end

local old_mouse_trap

function chat.Open()
	old_mouse_trap = window.GetMouseTrapped()
	
	local panel = chat.GetPanel()
	
	panel.tab:SelectTab("chat")
	panel:Minimize(true)
	panel.edit:SetText("")
	panel.edit:RequestFocus()
	panel:Layout(true)
	
	input.DisableFocus = true
	window.SetMouseTrapped(false)
end

function chat.Close()
	local panel = chat.GetPanel()
	
	panel:Minimize(false)		
	panel.edit:SetText("")
	panel.edit:Unfocus()
	
	input.DisableFocus = false
	window.SetMouseTrapped(old_mouse_trap) 
	
end

input.Bind("y", "showchat", function()
	chat.Open()
end)