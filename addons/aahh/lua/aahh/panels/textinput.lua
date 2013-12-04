local PANEL = {}

PANEL.ClassName = "text_input"

class.GetSet(PANEL, "Text", "")
class.GetSet(PANEL, "Wrap", false)
class.GetSet(PANEL, "FixedHeight", true)
class.GetSet(PANEL, "LineSpacing", 3)
class.GetSet(PANEL, "CaretPos", Vec2())
class.GetSet(PANEL, "Font", "default")
class.GetSet(PANEL, "LineNumbers", false)
class.GetSet(PANEL, "MultiLine", false)


function PANEL:SetLineNumbers(b)
	self.LineNumbers = b
	self:InvalidateText()
end

function PANEL:OnTextChanged(str)

end

-- this function makes a table of characters for the line with some other info
-- but we only call this when we need it for performance reasons

local function check_char_table_cache(line, font)
	surface.SetFont(font)
	
	if not line.tbl then
		local tbl = {}
		local x = 0

		for pos, char in pairs(line.str:utotable()) do
			local w, h = surface.GetTextSize(char)
			x = x + w
			tbl[pos] = {char = char, pos = pos, x = x, w = w, h = h}
		end

		if #tbl == 0 then
			tbl[1] = {char = line, pos = 1, x = 0, w = 0, h = 0}
		end

		line.tbl = tbl
	end
end

local is_caret_move = {
	up = true,
	down = true,
	left = true,
	right = true,
	
	home = true,
	["end"] = true,
}

PANEL.real_x = 0

function PANEL:SetText(str)
	self.Text = str
	self:InvalidateText()
end

function PANEL:InvalidateText()
	surface.SetFont(self.Font)
	
	self.FixedHeight = false

	-- lol
	self.Text = self.Text:gsub("\r", "\n")
	
	if not self.MultiLine then
		self.Text = self.Text:gsub("\n", " ")
	end
	
	local lines = self.Text:explode("\n")
	local markup = {w = 0, h = 0, data = {}}
	local height = select(2, surface.GetTextSize("|"))  + self.LineSpacing

	local temp = {}

	for pos, line in pairs(lines) do
		for _, str in pairs(surface.WrapString(line, self.Wrap and self:GetSize().w)) do
			local w, h = surface.GetTextSize(str)

			table.insert(temp, {type = "string", str = str, pos = pos, w = w, h = h, x = 0, y = 0})
		end
	end
	

	local y = 0

	for i, data in pairs(temp) do
		data.y = y

		if self.FixedHeight then
			y = y + height
			data.h = height
		else
			y = y + data.h
		end

		markup.h = markup.h + data.h

		table.insert(markup.data, data)
	end

	self.markup = markup
	self.lines = lines
	
	if self.LineNumbers then
		self.margin_width = surface.GetTextSize(tostring(#self.markup.data)) + 4
	else
		self.margin_width = 0
	end
	
	if self.Text ~= self.last_text then
		self:OnTextChanged(self.Text)
		self.last_text = self.Text
	end
end

function PANEL:OnMouseInput(button, press, pos)
	if button == "button_1" then
		if press then
			pos.x = pos.x - self.margin_width
			local pos = self:PixelToCaretPos(pos)

			self:SetCaretPos(pos)

			if not self.mouse_shift_selecting then
				self.select_start = pos * 1
			end
			
			self:MakeActivePanel()

			self.mouse_selecting = true
			self.shift_selecting = false
		else
			self.mouse_selecting = false
		end
	end
end

function PANEL:SelectPos(pos)
	if self.markup.data[pos.y] then
		self.selected_line = self.markup.data[pos.y]
	else
		self.selected_line = self.markup.data[#self.markup.data]
	end

	check_char_table_cache(self.selected_line, self.Font)

	if self.selected_line.tbl[pos.x] then
		self.selected_char = self.selected_line.tbl[pos.x]
	else
		self.selected_char = self.selected_line.tbl[#self.selected_line.tbl]
	end
end

function PANEL:SetCaretPos(pos)
	self.CaretPos = pos

	if not self.markup then return end

	self:SelectPos(pos)

	if self.selected_line and self.selected_char then
		-- incase the pos is beyond the text
		if self.CaretPos.x > 1 then
			self.CaretPos.x = self.selected_char.pos
		end

		if self.CaretPos.y < 1 then
			self.selected_line = self.markup.data[1]
		end

		self.CaretPos.y = self.selected_line.pos
	end

	self.CaretPos.x = math.max(self.CaretPos.x, 0)
end

function PANEL:PixelToCaretPos(pos)
	if not self.markup then return end

	local out = Vec2()

	local selected_line

	for i, data in pairs(self.markup.data) do
		if pos.y > data.y then
			selected_line = data
		end
	end

	if selected_line then
		out.y = selected_line.pos

		check_char_table_cache(selected_line, self.Font)

		local selected_char

		for _, char in pairs(selected_line.tbl) do
			if char.x-char.w*0.5 < pos.x then
				selected_char = char
			end
		end

		if not selected_char then
			selected_char = selected_line.tbl[#selected_line.tbl]
		end

		if selected_char then
			if pos.x < selected_line.tbl[1].w then
				out.x = 0
			else
				out.x = selected_char.pos
			end
		end
	end

	return out
end


function PANEL:StartSelect(pos)
	self.select_start = self.select_start or pos
end

function PANEL:EndSelect(pos)
	self.select_end = self.select_end or pos
end

function PANEL:Unselect()
	self.select_start = nil
	self.select_end = nil
end

function PANEL:GetSelection()
	local start_pos = self:GetSubPosFromPos(self.select_start)
	local end_pos = self:GetSubPosFromPos(self.select_end)
	
	if start_pos > end_pos then
		local temp = end_pos
		end_pos = start_pos
		start_pos = temp
	end
	
	return self.Text:usub(start_pos+1, end_pos)
end

function PANEL:DeleteSelection()
	if self.select_start and self.select_end then
		local start_pos = self:GetSubPosFromPos(self.select_start)
		local end_pos = self:GetSubPosFromPos(self.select_end)
		
		if start_pos > end_pos then
			local temp = end_pos
			end_pos = start_pos
			start_pos = temp
			
			self.CaretPos = self.select_end * 1
		else
			self.CaretPos = self.select_start * 1
		end

		self.Text = self.Text:usub(1, start_pos) .. self.Text:usub(end_pos + 1)

		self.select_start = nil
		self.select_end = nil
		
		self:InvalidateText()

		return true
	end

	return false
end

function PANEL:GetSubPosFromPos(pos)

	if pos.x == math.huge and pos.y == math.huge then
		return self.Text:ulength()
	end

	if pos.x == 0 and pos.y == 0 then
		return 0
	end

	local length = 0

	for i, data in pairs(self.markup.data) do
		if i == pos.y then
			return length + data.str:usub(1, pos.x):ulength()
		else
			length = length + data.str:ulength() + 1
		end
	end

	return length
end

function PANEL:InsertString(str, skip_move)
	local sub_pos = self:GetSubPosFromPos(self.CaretPos)

	self:DeleteSelection()

	if #self.Text == 0 then
		self.Text = self.Text .. str
	elseif sub_pos == #self.Text then
		self.Text = self.Text .. str
	else
		self.Text = self.Text:usub(1, sub_pos) .. str .. self.Text:usub(sub_pos + 1)
	end

	self:InvalidateText()

	if not skip_move then
		self.CaretPos.x = self.CaretPos.x + str:ulength()
		self.CaretPos.y = self.CaretPos.y + str:count("\n")
		self.real_x = self.CaretPos.x
		self:SetCaretPos(self.CaretPos)
	end		
end

function PANEL:OnRequestLayout()
	self:InvalidateText()
end

function PANEL:OnCharInput(char)
	self:InsertString(char)
end

function PANEL:OnKeyInput(key, press, skip_mods)

	if not self.selected_line or not self.selected_char then
		self:SelectPos(Vec2(0, 0))
	end

	if is_caret_move[key] then
		self.shift_selecting = input.IsKeyDown("left_shift")
		self:StartSelect(self.CaretPos:Copy())
	end

	if press then
		local line = self.selected_line.str
		local sub_pos = self:GetSubPosFromPos(self.CaretPos)
		local ctrl_down =  not skip_mods and input.IsKeyDown("left_control") or input.IsKeyDown("right_control")

		do -- special characters
			if key == "tab" then
				if input.IsKeyDown("left_shift") then
					if self.Text:usub(sub_pos, sub_pos) == "\t" then
						self:OnKeyInput("backspace", true)
					else
						-- wip
						--print(self.Text:usub(sub_pos - #line, self.CaretPos.x):find("$\t-"))

					end
				else
					self:OnCharInput("\t")
				end
			elseif key == "enter" then
				if self.MultiLine then
					local space = line:match("^(%s+)") or ""

					self:InsertString("\n" .. space, true)
					self.CaretPos.x = #space
					self.real_x = #space
					self.CaretPos.y = self.CaretPos.y + 1
				elseif self.OnEnter then
					self:OnEnter(self.Text)
				end
			end
		end

		do -- clipboard
			if key == "c" and ctrl_down then
				system.SetClipboard(self:GetSelection())
			elseif key == "x" and ctrl_down then
				system.SetClipboard(self:GetSelection())
				self:DeleteSelection()
			elseif key == "v" and ctrl_down then
				local str = system.GetClipboard()

				str = str:gsub("\r", "\n")
				str = str:gsub("\n\n", "\n")

				if #str > 0 then
					self:InsertString(str)
				end
			end
		end

		do -- deletion
			if key == "backspace" then
				if sub_pos == 0 then return end

				local prev_line = self.markup.data[self.selected_line.pos-1]

				if not self:DeleteSelection() then
					if ctrl_down then
						local x = (select(2, self.Text:usub(sub_pos - #line, self.CaretPos.x):find(".*%f[_%a].-[%a]")) or 1) - 1
						self.Text = self.Text:usub(1, x) .. self.Text:usub(sub_pos + 1)

						self.CaretPos.x = x - 1
						self.real_x = self.CaretPos.x
					else
						self.Text = self.Text:usub(1, sub_pos - 1) .. self.Text:usub(sub_pos + 1)
					end

					if self.CaretPos.x == 0 then
						self.CaretPos.x = prev_line.str:ulength()+1
						self.real_x = prev_line.str:ulength()+1
						self.CaretPos.y = self.CaretPos.y - 1
					end

					self.CaretPos.x = self.CaretPos.x - 1
					self.real_x = self.CaretPos.x
				end

				self:InvalidateText()
			elseif key == "delete" then

				if not self:DeleteSelection() then
					if ctrl_down then
						local pos = (select(2, self.Text:find("[%a_].-[%a]", sub_pos + 1)) or self.Text:ulength() + 1) - 1
						self.Text = self.Text:usub(1, sub_pos) .. self.Text:usub(pos + 1)
					else
						self.Text = self.Text:usub(1, sub_pos) .. self.Text:usub(sub_pos + 2)
					end
				end

				self:InvalidateText()
			end
		end

		do -- caret movement
			if key == "right" then
				if ctrl_down then
					local x = (select(1, line:find("%f[_%a].-", self.CaretPos.x + 2)) or #line+1) - 1

					if x == self.CaretPos.x then
						x = math.huge -- go to the next line
					end

					self.CaretPos.x = x
				else
					self.CaretPos.x = self.CaretPos.x + 1
				end

				self.real_x = self.CaretPos.x
			elseif key == "left" then
				if ctrl_down then
					local x = (select(2, line:usub(1, self.CaretPos.x):find(".*%f[_%a].-[%a]")) or -1) - 1

					self.CaretPos.x = x
				else
					self.CaretPos.x = self.CaretPos.x - 1
				end

				self.real_x = self.CaretPos.x
			end

			if key == "up" then
				self.CaretPos.y = self.CaretPos.y - 1
				self.CaretPos.x = self.real_x
			elseif key == "down" then
				self.CaretPos.y = self.CaretPos.y + 1
				self.CaretPos.x = self.real_x
			end

			if key == "home" then
				local pos = (select(2, line:find("^%s+(.)")) or 1) - 1

				if self.CaretPos.x == pos then
					pos = 0
				end

				self.CaretPos.x = pos
				self.real_x = self.CaretPos.x
			elseif key == "end" then
				-- this should be #line if you compare to
				-- scintillia but in a way it makes sense to have it like this
				self.CaretPos.x = #line
				self.real_x = self.CaretPos.x
			end

			local x = self.CaretPos.x

			self:SetCaretPos(self.CaretPos)

			-- if we're at the end of the line, got to the next
			if x ~= self.CaretPos.x and #self.lines > 1 then
				if key == "right" then
					self.CaretPos.x = 0
					self.CaretPos.y = self.CaretPos.y + 1
					self:SetCaretPos(self.CaretPos)
				elseif key == "left" then
					self.CaretPos.x = math.huge
					self.CaretPos.y = self.CaretPos.y - 1
					self:SetCaretPos(self.CaretPos)
				end
			end
		end

		do -- other shortcuts
			if key == "a" and ctrl_down then
				self.select_start = Vec2(0,0)
				self.select_end = Vec2(math.huge,math.huge)
			end
		end
		
		if is_caret_move[key] then
			if not input.IsKeyDown("left_shift") then
				self:Unselect()
			end
		end

		self:SetCaretPos(self.CaretPos)
	end
end

function PANEL:OnDraw(size)
	surface.Color(0.1, 0.1, 0.1, 1)
	surface.SetWhiteTexture()
	surface.DrawRect(0, 0, size.w, size.h)

	surface.SetFont(self.Font)

	if not self.markup then return end

	local first_line_selected
	local last_line_selected

	local select_start = self.select_start
	local select_end = self.select_end
	
	if 
		select_start and select_end and 
		(
			select_start.y > select_end.y or 
			select_start.y == select_end.y and select_start.x > select_end.x
		)
	then
		local temp = select_end
		select_end = select_start
		select_start = temp
	end

	if self.mouse_selecting then
		self.select_end = self:PixelToCaretPos(self:GetMousePos() - Vec2(self.margin_width, 0))
	elseif self.shift_selecting then
		self.select_end = self.CaretPos * 1
	end
	
	if self.LineNumbers then
		surface.Color(1,1,1,0.5)
		surface.DrawLine(self.margin_width-2, 0, self.margin_width-2, size.h)
		surface.Translate(self.margin_width, 0)
	end
	
	for i, data in pairs(self.markup.data) do
	
		if select_start and select_end then
			if select_end.y == select_start.y and select_start.y == i then
				check_char_table_cache(data, self.Font)

				local x = select_start.x == 0 and 0 or data.tbl[math.clamp(select_start.x, 1, #data.tbl)].x
				local w = data.tbl[select_end.x] and (data.tbl[select_end.x].x - x) or 0

				surface.SetWhiteTexture()
				surface.Color(1, 1, 1, 0.25)
				surface.DrawRect(x, data.y, w, data.h)
			-- skip the last line and first line if we're selecting multiple lines
			elseif i >= select_start.y and i <= select_end.y then

				local w = 0
				local x = 0
				local first_char
				
				check_char_table_cache(data, self.Font)

				if not first_line_selected then
					local x = select_start.x == 0 and 0 or data.tbl[math.clamp(select_start.x, 1, #data.tbl)].x
					local w = data.w - x

					first_line_selected = {str = data.str, x = x, y = data.y, w = w, h = data.h}
				else
					last_line_selected = self.markup.data[i]

					if (select_end.y - select_start.y) > 1 and i ~= select_end.y then
						surface.SetWhiteTexture()
						surface.Color(1, 1, 1, 0.25)
						surface.DrawRect(data.x, data.y, data.w, data.h)
					end
				end
			end
		end

		if data.y < size.y then
			-- draw the text
			surface.Color(1, 1, 1, 1)
			surface.SetTextPos(data.x, data.y)
			surface.DrawText(data.str)
			
			if self.LineNumbers then
				surface.SetTextPos(-self.margin_width, data.y)
				if self.last_pos ~= data.pos then
					surface.DrawText(data.pos)
					self.last_pos = data.pos
				end
			end
		end
	end

	if first_line_selected then
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.25)
		surface.DrawRect(first_line_selected.x, first_line_selected.y, first_line_selected.w, first_line_selected.h)
	end
	
	if last_line_selected then
		check_char_table_cache(last_line_selected, self.Font)

		local x = 0
		local w = 0

		for pos, char in pairs(last_line_selected.tbl) do
			if select_end.x+1 > pos then
				w = w + char.w
			end
		end

		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.25)
		surface.DrawRect(x, last_line_selected.y, w, last_line_selected.h)

		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.125)
		surface.DrawRect(w, last_line_selected.y, size.w - w, last_line_selected.h)

	elseif self.selected_line then
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.125)
		surface.DrawRect(self.selected_line.x, self.selected_line.y, size.w, self.selected_line.h)
				
		if self.selected_char then
			local x = self.selected_char.x - 2

			surface.SetWhiteTexture()
			surface.Color(1, 1, 1, (math.sin(os.clock()*16)+1)^4)

			if self.CaretPos.x == 0 then
				x = 0
			end
			
			surface.DrawRect(x, self.selected_line.y, 1, self.selected_line.h)
		end
	end
	
	if self.LineNumbers then
		surface.Translate(-self.margin_width, 0)
	end
end

aahh.RegisterPanel(PANEL)