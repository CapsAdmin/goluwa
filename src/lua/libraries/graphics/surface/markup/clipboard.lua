local META = (...) or prototype.GetRegistered("markup")

function META:Copy(tags)
	return self:GetSelection(tags)
end

function META:Cut()
	local str = self:GetSelection()
	self:DeleteSelection()
	return str
end

function META:Paste(str)
	str = str:gsub("\r", "")

	self:DeleteSelection()

	if #str > 0 then
		self:InsertString(str, (str:find("\n")))
		self:InvalidateEditedText()

		if str:find("\n") then
			self:SetCaretPosition(math.huge, self.caret_pos.y + string.count(str, "\n"), true)
		end
	end
end

prototype.UpdateObjects(META)