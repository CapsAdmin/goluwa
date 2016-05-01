local surface = (...) or _G.surface

--[[
todo:
	caret real_x should prioritise pixel width
	y axis caret movement when the text is being wrapped
	divide this up in cells (new object?)
	proper tag stack
	the ability to edit (remove and copy) custom tags that have a size (like textures)
]]

local META = prototype.CreateTemplate("markup")

META.tags = {}

META:GetSet("Table", {})
META:GetSet("MaxWidth", 500)
META:GetSet("ControlDown", false)
META:GetSet("LineWrap", true)
META:GetSet("ShiftDown", false)
META:GetSet("Editable", true)
META:GetSet("Multiline", true)
META:GetSet("MousePosition", Vec2())
META:GetSet("SelectionColor", Color(1, 1, 1, 0.5))
META:GetSet("CaretColor", Color(1, 1, 1, 1))
META:IsSet("Selectable", true)
META:GetSet("MinimumHeight", 10)
META:GetSet("HeightSpacing", 2)
META:GetSet("LightMode", false)
META:GetSet("SuperLightMode", false)
META:GetSet("CopyTags", true)

if SERVER then
	META:GetSet("FixedSize", 14) -- sigh
else
	META:GetSet("FixedSize", 0)
end

function surface.CreateMarkup()
	local self = prototype.CreateObject(META, {
		w = 0,
		h = 0,
		chunks = {},

		cull_x = 0,
		cull_y = 0,
		cull_w = math.huge,
		cull_h = math.huge,
		blink_offset = 0,
		remove_these = {},
		started_tags = {},
	})

	self:Invalidate()

	return self
end

function META:SetMaxWidth(w)
	if self.lastmw ~= w then
		self.MaxWidth = w
		self.need_layout = true
		self.lastmw = w
	end
end

function META:SetLineWrap(b)
	self.LineWrap = b
	self.need_layout = true
end

function META:SetEditable(b)
	self.Editable = b
	self:Unselect()
end

function META:Clear(skip_invalidate)
	table.clear(self.chunks)
	table.clear(self.remove_these)
	table.clear(self.started_tags)
	if not skip_invalidate then
		self:Invalidate()
	end
end

function META:SetTable(tbl, tags)
	self.Table = tbl

	self:Clear()

	for _, var in ipairs(tbl) do
		self:Add(var, tags)
	end
end

function META:AddTable(tbl, tags)
	for _, var in ipairs(tbl) do
		self:Add(var, tags)
	end
end

function META:BeginLifeTime(time)
	table.insert(self.chunks, {type = "start_fade", val = system.GetElapsedTime() + time})
end

function META:EndLifeTime()
	table.insert(self.chunks, {type = "end_fade", val = true})
end

function META:AddTagStopper()
	table.insert(self.chunks, {type = "tag_stopper", val = true})
end

function META:AddColor(color)
	table.insert(self.chunks, {type = "color", val = color})
	self.need_layout = true
end

function META:AddString(str, tags)
	str = tostring(str)

	if tags then
		for _, chunk in pairs(self:StringTagsToTable(str)) do
			table.insert(self.chunks, chunk)
		end
	else
		table.insert(self.chunks, {type = "string", val = str})
	end

	self.need_layout = true
end

function META:AddFont(font)
	table.insert(self.chunks, {type = "font", val = font})
	self.need_layout = true
end

function META:Add(var, tags)
	local t = typex(var)

	if t == "color" then
		self:AddColor(var)
	elseif t == "string" or t == "number" then
		self:AddString(var, tags)
	elseif t == "table" and var.type and var.val then
		table.insert(self.chunks, var)
	elseif t ~= "cdata" then
		llog("tried to parse unknown type %q", t)
	end

	self.need_layout = true
end

function META:TagPanic()
	for _, v in pairs(self.chunks) do
		if v.type == "custom" then
			v.panic = true
		end
	end
end

function META:CallTagFunction(chunk, name, ...)
	if not chunk.val.tag then return end

	if chunk.type == "custom" and not chunk.panic then

		local func = chunk.val.tag and chunk.val.tag[name]

		if func then
			local args = {self, chunk, ...}

			for i, t in pairs(chunk.val.tag.arg_types) do
				local val = chunk.val.args[i]

				if type(val) == "function" then
					local ok, v = pcall(val, chunk.exp_env)
					if ok then
						val = v
					end
				end

				-- type isn't right? revert to default!
				if type(val) ~= t then
					val = chunk.val.tag.arguments[k]

					if type(v) == "table" then
						val = v.default
					end
				end

				table.insert(args, val)
			end

			args = {system.pcall(func, unpack(args))}

			if not args[1] then
				llog("tag error %s", args[2])
			end

			return unpack(args)
		end
	end
end

function META:GetNextCharacterClassPosition(delta, next_space)

	if next_space == nil then
		next_space = not self.caret_shift_pos
	end

	local pos = self.caret_pos.i

	if delta > 0 then
		pos = pos + 1
	end

	if delta > 0 then

		if pos > 0 and self.chars[pos-1] then
			local type = string.getchartype(self.chars[pos-1].str)

			while pos > 0 and self.chars[pos] and string.getchartype(self.chars[pos].str) == type do
				pos = pos + 1
			end
		end

		if pos >= #self.chars then
			return pos, 1
		end

		if next_space then
			while pos > 0 and self.chars[pos] and string.getchartype(self.chars[pos].str) == "space" and self.chars[pos].str ~= "\n" do
				pos = pos + 1
			end
		end

		return self.chars[pos-1].x, self.chars[pos-1].y
	else

		-- this isn't really scintilla behaviour but I think it makes sense
		if next_space then
			while pos > 1 and string.getchartype(self.chars[pos - 1].str) == "space" and self.chars[pos - 1].str ~= "\n" do
				pos = pos - 1
			end
		end

		if self.chars[pos - 1] then
			local type = string.getchartype(self.chars[pos - 1].str)

			while pos > 1 and string.getchartype(self.chars[pos - 1].str) == type do
				pos = pos - 1
			end
		end

		if pos == 1 then
			return 0, 1
		end

		return self.chars[pos+1].x, self.chars[pos+1].y
	end
end

function META:InsertString(str, skip_move, start_offset, stop_offset)

	start_offset = start_offset or 0
	stop_offset = stop_offset or 0

	local sub_pos = self:GetCaretSubPosition()

	self:DeleteSelection(true)

	do
		local x, y = self.caret_pos.x, self.caret_pos.y

		for _ = 1, start_offset do
			x = x - 1

			if x <= 0 then
				y = y - 1
				x = utf8.length(self.lines[y])
			end
		end

		self:SelectStart(x, y)

		x, y = self.caret_pos.x, self.caret_pos.y

		for _ = 1, stop_offset do
			x = x + 1

			if x >= utf8.length(self.lines[y]) then
				y = y + 1
				x = 0
			end
		end

		self:SelectStop(x, y)

		self:DeleteSelection(true)
	end

	self.text = utf8.sub(self.text, 1, sub_pos - 1) .. str .. utf8.sub(self.text, sub_pos)

	do -- fix chunks
		local sub_pos = self.caret_pos.char.data.i
		local chunk = self.caret_pos.char.chunk

		-- if we're in a sea of non strings we need to make one
		if chunk.internal or chunk.type ~= "string" and ((self.chunks[chunk.i-1] and self.chunks[chunk.i-1].type ~= "string") or (self.chunks[chunk.i+1] and self.chunks[chunk.i+1].type ~= "string")) then
			table.insert(self.chunks, chunk.internal and #self.chunks or chunk.i , {type = "string", val = str})
		else
			do -- sub the start
				local pos = chunk.i

				while chunk.type ~= "string" and pos > 1 do
					pos = pos - 1
					chunk = self.chunks[pos]
				end
			end

			if chunk.type == "string" then
				if not sub_pos then
					sub_pos = #chunk.chars + 1
				end

				chunk.val = utf8.sub(chunk.val, 1, sub_pos - 1) .. str .. utf8.sub(chunk.val, sub_pos)
			else
				table.remove(self.chunks, chunk.i)
			end
		end

		self:Invalidate()
	end

	if not skip_move then
		local x = self.caret_pos.x + utf8.length(str)
		local y = self.caret_pos.y + string.count(str, "\n")

		if self.caret_pos.char.str == "\n" then
			x = x + 1
		end

		self.real_x = x

		self:SetCaretPosition(x, y)
	end

	self:InvalidateEditedText()

	self.caret_shift_pos = nil
end

function META:InvalidateEditedText()
	if self.text ~= self.last_text and self.OnTextChanged then
		self:OnTextChanged(self.text)
		self.last_text = self.text
	end
end

function META:GetSubPosFromPosition(x, y)

	if x == math.huge and y == math.huge then
		return #self.chars
	end

	if x == 0 and y == 0 then
		return 0
	end

	for sub_pos, char in ipairs(self.chars) do
		if char.x == x and char.y == y then
			return sub_pos
		end
	end

	if x == math.huge then
		for sub_pos, char in ipairs(self.chars) do
			if char.y == y and char.str == "\n" then
				return sub_pos - 1
			end
		end
		return self.chars[#self.chars]
	end

	if y == math.huge then
		for i = 1, self.chars do
			i = -i + #self.chars
			local char = self.chars[i]

			if char.x == x then
				return sub_pos - 1
			end
		end
	end

	return 0
end

include("tags.lua", META)
include("tags_matrix.lua", META)

include("tag_parse.lua", META)
include("invalidate.lua", META)

include("shortcuts.lua", META)
include("caret.lua", META)
include("selection.lua", META)
include("clipboard.lua", META)

include("input.lua", META)
include("drawing.lua", META)
include("test.lua", META)

prototype.Register(META)