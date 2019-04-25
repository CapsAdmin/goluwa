console = _G.console or {}

console.panel = console.panel or NULL

function console.Close()
	if console.panel:IsValid() then
		console.panel:SetVisible(false)
	end

	window.SetMouseTrapped(true)
end

function console.Open()
	window.SetMouseTrapped(false)

	if console.panel:IsValid() then
		console.panel:SetVisible(true)
		console.panel.edit:RequestFocus()
		return
	end

	console.font = fonts.CreateFont({path = "fonts/unifont.ttf", size = 12.5})

	local frame = gui.CreatePanel("frame", menu.panel, "console")
	frame:SetSize(Vec2(render.GetScreenSize().x / 2, render.GetScreenSize().y / 1.25))
	frame:NoCollide()
	frame:SetPadding(Rect()+20)
	frame:MoveRight()
	frame:MoveUp()

	do -- edit line
		local edit = frame:CreatePanel("text_input")

		edit:SetMargin(Rect() + 3)
		edit:SetHeight(20)
		edit:SetHistoryPath("data/console_history.txt")


		function edit:OnEscape()
			self:SetText("")
			self:Unfocus()
			--console.Close()
		end

		function edit:OnFinish(str)
			logn("> ", str)
			commands.RunString(str, nil, true, true)
			self:SetText("")
			frame:Layout(true)
			return false
		end

		function edit:OnHeightChanged()
			self:SetupLayout("bottom", "fill_x")
		end

		edit:SetupLayout("bottom", "fill_x")
		edit:RequestFocus()
		frame.edit = edit
	end

	local scroll = frame:CreatePanel("scroll")
	scroll:SetupLayout("center_simple", "fill")

	local text = scroll:SetPanel(gui.CreatePanel("text"))
	--text.markup:SetSuperLightMode(true)
	--text:SetLightMode(true)
	--text:SetCopyTags(false)
	text:SetTextWrap(true)
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
	end

	--text.markup:AddString(vfs.Read("logs/console_" .. jit.os:lower() .. ".txt"))
end

input.Bind("|", "show_chat_console", function()
	console.Open()
end)

if RELOAD then
	prototype.SafeRemove(console.panel)
	console.panel = NULL
	console.Open()
end