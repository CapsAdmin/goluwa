local META = (...) or prototype.GetRegistered("markup")

function META:SelectStart(x, y)
	self.select_start = self:CaretFromPosition(x, y)
end

function META:SelectStop(x, y)
	self.select_stop = self:CaretFromPosition(x, y)
end

function META:GetSelectStart()
	if self.select_start and self.select_stop then
		if self.select_start.i == self.select_stop.i  then return end

		if self.select_start.i < self.select_stop.i then
			return self.select_start
		else
			return self.select_stop
		end
	end
end

function META:GetSelectStop()
	if self.select_start and self.select_stop then
		if self.select_start.i == self.select_stop.i then return end

		if self.select_start.i > self.select_stop.i then
			return self.select_start
		else
			return self.select_stop
		end
	end
end

function META:SelectAll()
	self:SetCaretPosition(0, 0)
	self:SelectStart(0, 0)
	self:SelectStop(math.huge, math.huge)
end

function META:SelectCurrentWord()
	local x, y = self:GetNextCharacterClassPosition(-1, false)
	self:SelectStart(x - 1, y)

	x, y = self:GetNextCharacterClassPosition(1, false)
	self:SelectStop(x + 1, y)

	self:SetCaretPosition(x + 1, y)
end

function META:SelectCurrentLine()
	self:SelectStart(0, self.caret_pos.y)
	self:SelectStop(math.huge, self.caret_pos.y)
	self:SetCaretPosition(math.huge, self.caret_pos.y)
end

function META:Unselect()
	self.select_start = nil
	self.select_stop = nil
	self.caret_shift_pos = nil
end

function META:GetText(tags)
	local start, stop = self:GetSelectStart(), self:GetSelectStop()
	local caret = self.caret_pos

	self:SelectAll()
	local str = self:GetSelection(tags)

	if start and stop then
		self:SelectStart(start.x, start.y)
		self:SelectStop(stop.x, stop.y)
	else
		self:Unselect()
	end

	self:SetCaretPosition(caret.x, caret.y)

	return str
end

function META:SetText(str, tags)
	self:Clear()
	self:AddString(str, tags)
	self:Invalidate() -- do it right now
end

function META:GetSelection(tags)
	local out = {}

	local START = self:GetSelectStart()
	local STOP = self:GetSelectStop()

	if START and STOP then
		if not tags then
			return utf8.sub(self.text, START.sub_pos, STOP.sub_pos - 1)
		else
			local last_font
			local last_color

			for i = START.i, STOP.i do
				local char = self.chars[i]
				local chunk = char.chunk

				-- this will ensure a clean output
				-- but maybe this should be cleaned in the invalidate function instead?
				if chunk.font and last_font ~= chunk.font then
					table.insert(out, ("<font=%s>"):format(chunk.font))
					last_font = chunk.font
				end

				if chunk.color and last_color ~= chunk.color then
					table.insert(out, ("<color=%s,%s,%s,%s>"):format(math.round(chunk.color.r, 2), math.round(chunk.color.g, 2), math.round(chunk.color.b, 2), math.round(chunk.color.a, 2)))
					last_color = chunk.color
				end

				table.insert(out, char.str)

				if chunk.type == "custom" then
					if chunk.val.type == "texture" then
						table.insert(out, ("<texture=%s>"):format(chunk.val.args[1]))
					end
				end
			end
		end
	end

	return table.concat(out, "")
end

function META:DeleteSelection(skip_move)
	local start = self:GetSelectStart()
	local stop = self:GetSelectStop()

	if start then

		if not skip_move then
			self:SetCaretPosition(start.x, start.y)
		end

		self.text = utf8.sub(self.text, 1, start.sub_pos - 1) .. utf8.sub(self.text, stop.sub_pos)

		self:Unselect()

		do -- fix chunks

			local need_fix = false
			for i = start.char.chunk.i + 1, stop.char.chunk.i - 1 do
				if not self.chunks[i].internal then
					self.chunks[i] = nil
					need_fix = true
				end
			end

			local start_chunk = start.char.chunk
			local stop_chunk = stop.char.chunk

			if start_chunk.type == "string" then
				if stop_chunk == start_chunk then
					start_chunk.val = utf8.sub(start_chunk.val, 1, start.char.data.i - 1) .. utf8.sub(start_chunk.val, stop.char.data.i)
				else
					start_chunk.val = utf8.sub(start_chunk.val, 1, start.char.data.i - 1)
				end
			elseif not self.chunks[start_chunk.i].internal then
				self.chunks[start_chunk.i] = nil
				need_fix = true
			end

			if stop_chunk ~= start_chunk then
				if stop_chunk.type == "string" then
					local sub_pos = stop.char.data.i
					stop_chunk.val = utf8.sub(stop_chunk.val, sub_pos)
				elseif stop_chunk.type ~= "newline" and not stop_chunk.internal and stop_chunk.type ~= "custom" then
					self.chunks[stop_chunk.i] = nil
					need_fix = true
				end
			end

			if need_fix then
				table.fixindices(self.chunks)
			end

			self:Invalidate()
		end

		self:InvalidateEditedText()

		return true
	end

	return false
end

prototype.UpdateObjects(META)