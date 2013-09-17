
--if os.getenv("USERNAME") ~= "capsadmin" then return end

local PANEL = {}

PANEL.ClassName = "textinput"

aahh.GetSet(PANEL, "ChokeTime", 0.5)
aahh.GetSet(PANEL, "CaretPos", 0)
aahh.GetSet(PANEL, "MultiLine", false)
aahh.GetSet(PANEL, "DrawBackground", true)
aahh.GetSet(PANEL, "TextSize", 8)
aahh.GetSet(PANEL, "BorderWidth", 1)
aahh.GetSet(PANEL, "Text")
aahh.GetSet(PANEL, "Font", "tahoma.ttf")

function PANEL:Initialize()
	self:Clear()
	self:SetCursor(e.IDC_HELP)
end

function PANEL:Clear()
	self.Text = ""
	self.Lines = 1
	self.CaretPos = 1
end

function PANEL:SuppressNextChar()
	self.suppress_char = true
end

function PANEL:SuppressNextKey()
	self.suppress_key = true
end

function PANEL:GetChar(pos)
	return self.Text:sub(pos, pos)
end

function PANEL:InsertNewline()

end

function PANEL:InsertChar(char)
	if char == "\n" then
		self:InsertNewline()
	else
		if self.CaretPos == #self.Text then
			self.Text = self.Text .. char
			self:SetCaretPos(self:GetCaretPos() + 1)
		else
			self.Text = self.Text:sub(1, self.CaretPos) .. char .. self.Text:sub(self.CaretPos+1)
		end
	end
end

function PANEL:SetCaretPos(pos)
	self.CaretPos = math.clamp(pos, 0, #self.Text)
end

function PANEL:DoChoke(time)
	self.Choke = os.clock() + (time or self.ChokeTime)
end

function PANEL:IsChoked()
	return self.Choke > os.clock()
end

function PANEL:OnMouseInput(key, press, pos)
	if press then	
		self.CaretPos = math.clamp(math.ceil(((pos.x / self:GetTextSize().w) * #self.Text)), 0, #self.Text)
		self:MakeActivePanel()
	end
end

function PANEL:HandleKey(key)
	if key == "v" and input.IsKeyDown("lctrl") then
		local str = clipboard.GetText()
		if #str > 0 then
			if not self.MultiLine then	 	
				str = str:gsub("\n", "")
			end
		
			self:InsertChar(str)
			self:SetCaretPos(self:GetCaretPos() + #str)
			self:SuppressNextChar()
		end
		return
	end

	if key == "right" then
		local pos = self.CaretPos + 1

		if input.IsKeyDown("lctrl") then
			pos = (select(2, self.Text:find("[%s%p].-[^%p%s]", self.CaretPos+1)) or 1) - 1
			if pos < self.CaretPos then
				pos = #self.Text
			end
		end
		
		self:SetCaretPos(pos)
		return
	elseif key == "left" then
		local pos = self.CaretPos - 1
		
		if input.IsKeyDown("lctrl") then
			pos = (select(2, self.Text:sub(1, self.CaretPos):find(".*[%s%p].-[^%p%s]")) or 1) - 1
		end
		
		self:SetCaretPos(pos)
		return
	elseif key == "end" then
		self:SetCaretPos(#self.Text)
		return
	elseif key == "home" then
		self:SetCaretPos(0)
		return
	end

	if key == "delete" then
		if input.IsKeyDown("lctrl") then
			local pos = (select(2, self.Text:find("[%s%p].-[^%p%s]", self.CaretPos+1)) or #self.Text+1) - 1
			self.Text = self.Text:sub(1, self.CaretPos) .. self.Text:sub(pos+1)
		else
			self.Text = self.Text:sub(1, self.CaretPos) .. self.Text:sub(self.CaretPos+2)
		end
	elseif key == "backspace" then
		if self.CaretPos == 0 then return end
		if input.IsKeyDown("lctrl") then
			local pos = (select(2, self.Text:sub(1, self.CaretPos):find(".*[%s%p].-[^%p%s]")) or 1) - 1
			self.Text = self.Text:sub(1, pos) .. self.Text:sub(self.CaretPos+1)
			self:SetCaretPos(pos-1)
		else
			self.Text = self.Text:sub(1, self.CaretPos-1) .. self.Text:sub(self.CaretPos+1)
			self:HandleKey("left")
		end
	elseif key == "space" then
		self:InsertChar(" ")
		self:HandleKey("right")
	--elseif key == "tab" then
		--self:InsertChar("\t")
		--self:HandleKey("right")
	elseif key == "pgdn" then
		self:InsertChar("\n")
		self:HandleKey("right")
	elseif key == "enter" or key == "np_enter" then
		if self.MultiLine then
			self:InsertChar("\n")
		else
			self:OnEnter(self.Text)
		end
	else
		self:OnUnhandledKey(key)
	end

	self.Lines = #self.Text:explode("\n")
end

function PANEL:HandleChar(char)
	local byte = char:byte()

	if byte > 32 then
		self:InsertChar(char)
		self:HandleKey("right")
	elseif byte == 32 then
		self:HandleKey("space")
	else
		self:OnUnhandledChar(char)
	end
end

function PANEL:OnKeyInput(key, press)
	
	if key == "space" then return end
	
	if self.suppress_key then
		self.suppress_key = false
		return
	end
	
	if press then
		self.Key = key
		self:HandleKey(key)
		self:DoChoke()
	else
		self.Key = nil
	end
end

function PANEL:OnCharInput(char, press)
	
	if self.suppress_char then
		self.suppress_char = false
		return
	end
		
	--if press then
		self.Char = char
		self:HandleChar(char)
		--self:DoChoke()
	--else
	--	self.Char = nil
	--end
end

function PANEL:GetTextSize(from_caret)
	return aahh.GetTextSize(self.Font, from_caret and self.Text:sub(1, self.CaretPos) or self.Text) * self.TextSize
end

function PANEL:OnDraw()
	self:DrawHook("TextInputDraw")
end

function PANEL:OnThink()
	if self.Key and not self:IsChoked() and INTERVAL(0.02) then
		self:HandleKey(self.Key)
	end

	if self.Text ~= self.last_text then
		self:OnTextChanged(self.Text, self.last_text)		
		self.last_text = self.Text
	end
end

function PANEL:OnEnter(str)
	self:Clear()
end

function PANEL:OnUnhandledKey(key)
end

function PANEL:OnTextChanged()

end

function PANEL:OnUnhandledChar(char)

end

aahh.RegisterPanel(PANEL)