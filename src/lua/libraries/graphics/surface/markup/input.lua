local META = (...) or prototype.GetRegistered("markup")

function META:OnCharInput(char)
	if not self.Editable then return end

	self:InsertString(char)
end

local is_caret_move = {
	up = true,
	down = true,
	left = true,
	right = true,

	home = true,
	["end"] = true,
}

function META:OnKeyInput(key, press)
	if not self.Editable or #self.chunks == 0 then return end

	if not self.caret_pos then return end

	do
		local x, y = 0, 0

		if key == "up" and self.Multiline then
			y = -1
		elseif key == "down" and self.Multiline then
			y = 1
		elseif key == "left" then
			x = -1
		elseif key == "right" then
			x = 1
		elseif key == "home" then
			x = -math.huge
		elseif key == "end" then
			x = math.huge
		elseif key == "page_up" and self.Multiline then
			y = -10
		elseif key == "page_down" and self.Multiline then
			y = 10
		end

		self:AdvanceCaret(x, y)
	end

	if is_caret_move[key] then
		if not self.ShiftDown then
			self:Unselect()
		end
	end

	if key == "tab" then
		self:Indent(self.ShiftDown)
	elseif key == "enter" and self.Multiline then
		self:Enter()
	end

	if self.ControlDown then
		if key == "c" then
			window.SetClipboard(self:Copy())
		elseif key == "x" then
			window.SetClipboard(self:Cut())
		elseif key == "v" and window.GetClipboard() then
			self:Paste(window.GetClipboard())
		elseif key == "a" then
			self:SelectAll()
		elseif key == "t" then
			local str = self:GetSelection()
			self:DeleteSelection()

			for i, chunk in pairs(self:StringTagsToTable(str)) do
				table.insert(self.chunks, self.caret_pos.char.chunk.i + i - 1, chunk)
			end

			self:Invalidate()
		end
	end

	if key == "backspace" then
		self:Backspace()
	elseif key == "delete" then
		self:Delete()
	end

	do -- selecting
		if key ~= "tab" then
			if self.ShiftDown then
				if self.caret_shift_pos then
					self:SelectStart(self.caret_pos.x, self.caret_pos.y)
					self:SelectStop(self.caret_shift_pos.x, self.caret_shift_pos.y)
				end
			elseif is_caret_move[key] then
				self:Unselect()
			end
		end
	end
end

function META:OnMouseInput(button, press)
	if #self.chunks == 0 then return end

	if button == "mwheel_up" or button == "mwheel_down" then return end

	local x, y = self:GetMousePosition():Unpack()

	local chunk = self:CaretFromPixels(x, y).char.chunk

	if chunk.type == "string" and chunk.chunks_inbetween then
		chunk = chunk.chunks_inbetween[1]
	end

	if chunk.type == "custom" and chunk.console and press then
		commands.RunString(str)
		return
	end
	if
		chunk.type == "custom" and
		self:CallTagFunction(chunk, "mouse", button, press, x, y) == false
	then
		return
	end

	if button == "button_1" then


		if press then
			if self.last_click and self.last_click > os.clock() then
				self.times_clicked = (self.times_clicked or 1) + 1
			else
				self.times_clicked = 1
			end

			if self.times_clicked == 2 then
				self.caret_pos = self:CaretFromPixels(x, y)

				if self.caret_pos and self.caret_pos.char then
					self.real_x = self.caret_pos.x
				end

				self:SelectCurrentWord()
			elseif self.times_clicked == 3  then
				self:SelectCurrentLine()
			end

			self.last_click = os.clock() + 0.2
			if self.times_clicked > 1 then return end
		end

		if press then
			local caret = self:CaretFromPixels(x, y)

			self.select_start = self:CaretFromPixels(x + caret.w / 2, y)
			self.select_stop = nil
			self.mouse_selecting = true

			self.caret_pos = self:CaretFromPixels(x + caret.w / 2, y)

			if self.caret_pos and self.caret_pos.char then
				self.real_x = self.caret_pos.char.data.x
			end
		else
			if not self.Editable then
				local str = self:Copy(self.CopyTags)
				if str ~= "" then
					window.SetClipboard(str)
					self:Unselect()
				end
			end

			self.mouse_selecting = false
		end
	end
end

prototype.UpdateObjects(META)