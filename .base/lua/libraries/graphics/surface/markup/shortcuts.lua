local META = (...) or prototype.GetRegistered("markup")

function META:Backspace()
	local sub_pos = self:GetCaretSubPosition()

	if not self:DeleteSelection() and sub_pos ~= 1 then
		if self.ControlDown then

			local x, y = self:GetNextCharacterClassPosition(-1, true)
			x = x - 1

			if x <= 0 and #self.lines > 1 then
				x = math.huge
				y = y - 1
			end

			self:SelectStart(self.caret_pos.x, self.caret_pos.y)
			self:SelectStop(x, y)
			self:DeleteSelection()

			self.real_x = x
		else
			local x, y = self.caret_pos.x, self.caret_pos.y

			if self.chars[self.caret_pos.i - 1] then
				x = self.chars[self.caret_pos.i - 1].x
				y = self.chars[self.caret_pos.i - 1].y

				self:SelectStart(self.caret_pos.x, self.caret_pos.y)
				self:SelectStop(x, y)

				self:DeleteSelection()
			end
		end
	end

	self:InvalidateEditedText()
end

function META:Delete()
	if not self:DeleteSelection() then
		local ok = false

		if self.ControlDown then
			local x, y = self:GetNextCharacterClassPosition(1, true)

			x = x + 1

			self:SelectStart(self.caret_pos.x, self.caret_pos.y)
			self:SelectStop(x, y)

			ok = self:DeleteSelection()
		end

		if not ok then
			local x, y = self.caret_pos.x, self.caret_pos.y

			if self.chars[self.caret_pos.i + 1] then
				x = self.chars[self.caret_pos.i + 1].x
				y = self.chars[self.caret_pos.i + 1].y

				self:SelectStart(self.caret_pos.x, self.caret_pos.y)
				self:SelectStop(x, y)
				self:DeleteSelection()
			end
		end
	end

	self:InvalidateEditedText()
end

function META:Indent(back)
	local sub_pos = self:GetCaretSubPosition()

	local select_start = self:GetSelectStart()
	local select_stop = self:GetSelectStop()

	if select_start and select_start.y ~= select_stop.y then

		-- first select everything
		self:SelectStart(0, select_start.y)
		self:SelectStop(math.huge, select_stop.y)

		-- and move the caret to bottom
		self:SetCaretPosition(select_stop.x, select_stop.y)

		local select_start = self:GetSelectStart()
		local select_stop = self:GetSelectStop()

		local text = utf8.sub(self.text, select_start.sub_pos, select_stop.sub_pos)

		if back then
			if text:usub(1, 1) == "\t" then
				text = text:usub(2)
			end
			text = text:gsub("\n\t", "\n")
		else
			text = "\t" .. text
			text = text:gsub("\n", "\n\t")

			-- ehhh, don't add \t at the next line..
			if text:usub(-1) == "\t" then
				text = text:usub(0, -2)
			end
		end

		self.text = utf8.sub(self.text, 1, select_start.sub_pos - 1) .. text .. utf8.sub(self.text, select_stop.sub_pos + 1)

		do -- fix chunks
			for i = select_start.char.chunk.i-1, select_stop.char.chunk.i-1 do
				local chunk = self.chunks[i]
				if chunk.type == "newline" then
					if not back and self.chunks[i+1].type ~= "string" then
						table.insert(self.chunks, i+1, {type = "string", val = "\t"})
					else
						local pos = i

						while chunk.type ~= "string" and pos < #self.chunks do
							chunk = self.chunks[pos]
							pos = pos + 1
						end

						if back then
							if chunk.val:usub(1,1) == "\t" then
								chunk.val = chunk.val:usub(2)
							end
						else
							chunk.val = "\t" .. chunk.val
						end

					end
				end
			end

			self:Invalidate()
		end
	else
		-- TODO
		--print(self.text:usub(sub_pos-1, sub_pos-1), back)
		if back and self.text:usub(sub_pos-1, sub_pos-1) == "\t" then
			self:Backspace()
		else
			self:InsertString("\t")
		end
	end

	self:InvalidateEditedText()
end

function META:Enter()
	self:DeleteSelection(true)

	local x = 0
	local y = self.caret_pos.y

	local cur_space = utf8.sub(self.lines[y], 1, self.caret_pos.x):match("^(%s*)") or ""
	x = x + #cur_space

	if x == 0 and #self.lines == 1 then
		cur_space = " " .. cur_space
	end

	self:InsertString("\n" .. cur_space, true)


	self:InvalidateEditedText()

	self.real_x = x

	self:SetCaretPosition(x, y + 1, true)
end

prototype.UpdateObjects(META)