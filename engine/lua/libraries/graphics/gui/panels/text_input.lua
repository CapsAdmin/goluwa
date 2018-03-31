local gui = ... or _G.gui

local META = prototype.CreateTemplate("text_input")

META.Base = "text_edit"

META:GetSet("HistoryPath")
META:GetSet("Autocomplete")

function META:Initialize()
	META.BaseClass.Initialize(self)

	self.history_i = 1
end

function META:SetAutocomplete(str)
	self.Autocomplete = str

	if not str then
		self:RemoveEvent("PostDrawGUI")

		return
	end

	self:AddEvent("PostDrawGUI")
	self:CallOnVisibilityChanged(function(b)
		if b then
			self:AddEvent("PostDrawGUI")
		else
			self:RemoveEvent("PostDrawGUI")
		end
	end, "hide_autocomplete")
end

-- autocomplete should be done after keys like space and backspace are pressed
-- so we can use the string after modifications
function META:OnPostKeyInput(key, press)
	if not self.Autocomplete then return end
	if not press then return end

	local str = self:GetText():trim()
	if not str:find("\n") and self:GetCaretPosition().x == #self:GetText() then
		local scroll = 0

		if key == "tab" then
			scroll = input.IsKeyDown("left_shift") and -1 or 1
		end

		self.found_autocomplete = autocomplete.Query(self.Autocomplete, str, scroll)

		if key == "tab" and self.found_autocomplete[1] then
			self:SetText(self.found_autocomplete[1])
			self:SetCaretPosition(Vec2(math.huge, 0))
			return false
		end
	end

	local width = self:GetWidth()
	self:SizeToText()
	self:SetWidth(width)

	self:OnHeightChanged()
end

function META:OnPreKeyInput(key, press)
	if not press then return end

	local ctrl = input.IsKeyDown("left_shift") or input.IsKeyDown("right_shift")
	local str = self:GetText()

	if str ~= "" and ctrl then
		self:SetMultiline(true)
		return
	end

	if self.HistoryPath then
		self.history = serializer.ReadFile("luadata", self.HistoryPath) or {}

		if str == history_last or str == "" or not str:find("\n") then
			local browse = false

			if key == "up" then
				self.history_i = math.clamp(self.history_i + 1, 1, #self.history)
				browse = true
			elseif key == "down" then
				self.history_i = math.clamp(self.history_i - 1, 1, #self.history)
				browse = true
			end

			local found = self.history[self.history_i]
			if browse and found then
				self:SetText(found)
				self:SetCaretPosition(Vec2(math.huge, 0))
				history_last = found
			end
		end
	end

	if key == "escape" then
		self:OnEscape()
	elseif key == "enter" or key == "keypad_enter" then
		if self.HistoryPath then
			self.history_i = 0

			if #str > 0 then
				if self.history[1] ~= str then
					table.insert(self.history, 1, str)
					serializer.WriteFile("luadata", self.HistoryPath, self.history)
				end
			end
		end

		local ret = self:OnFinish(str)

		if ret ~= nil then
			return ret
		end

		return
	end

	self:OnTextChanged(str)
end

function META:OnHeightChanged()

end

function META:OnFinish()

end

function META:OnEscape()

end

function META:OnPostDrawGUI()
	if self.found_autocomplete and #self.found_autocomplete > 0 then
		local pos = self:GetWorldPosition()
		gfx.SetFont(self:GetSkin().default_font)
		autocomplete.DrawFound(self.Autocomplete, pos.x, pos.y + self:GetHeight(), self.found_autocomplete)
	end
end

gui.RegisterPanel(META)