local META = (...) or prototype.GetRegistered("markup")

local function set_font(self, font)
	if self.FixedSize == 0 then
		surface.SetFont(font)
	end
end

local function get_text_size(self, text)
	if self.FixedSize > 0 then
		return self.FixedSize, self.FixedSize
	else
		return surface.GetTextSize(text)
	end
end

local function prepare_chunks(self)
	-- this is needed when invalidating the chunks table again
	-- anything that need to add more chunks need to store the
	-- old chunk as old_chunk key


	local out = {}
	local found = {}

	local last_type
	local offset = 0
	local last_char_class

	for i, chunk in ipairs(self.chunks) do
		if chunk.internal or chunk.type == "string" and chunk.val == "" then goto continue_ end

		if last_type == chunk.type and (last_type == "font" or last_type == "color") then
		--	print(last_type)
		else
			local old = chunk.old_chunk


			if old then
				if not found[old] then
					table.insert(out, old)
					found[old] = true
				end
			else
				table.insert(out, chunk)
			end

			offset = 0
		end

		last_type = chunk.type

		::continue_::
	end

	table.insert(out, 1, {type = "font", val = surface.GetDefaultFont(), internal = true})
	table.insert(out, 1, {type = "color", val = Color(1, 1, 1, 1), internal = true})
	table.insert(out, {type = "string", val = "", internal = true})

	return out
end

local function split_by_space_and_punctation(self, chunks)
	-- solve white space and punctation

	local out = {}

	for i, chunk in ipairs(chunks) do
		if chunk.type == "string" and chunk.val:find("%s") and not chunk.internal then

			if self.LineWrap then
				local str = {}

				for i, char in ipairs(utf8.totable(chunk.val)) do
					if char:find("%s") then
						if #str ~= 0 then
							table.insert(out, {type = "string", val = table.concat(str)})
							if table.clear then
								str = {}
							else
								table.clear(str)
							end
						end

						if char == "\n" then
							table.insert(out, {type = "newline"})
						else
							table.insert(out, {type = "string", val = char, whitespace = true})
						end
					else
						table.insert(str, char)
					end
				end

				if #str ~= 0 then
					table.insert(out, {type = "string", val = table.concat(str)})
				end
			else
				if chunk.val:find("\n", nil, true) then
					for line in chunk.val:gmatch("(.-)\n") do
						table.insert(out, {type = "string", val = line})
						table.insert(out, {type = "newline"})
					end

						local rest = chunk.val:match(".*\n(.+)")
						if rest then
							table.insert(out, {type = "string", val = rest})
						end
					else
					table.insert(out, {type = "string", val = chunk.val})
				end
			end
		else
			table.insert(out, chunk)
		end
	end

	return out
end

local function get_size_info(self, chunks)
	-- get the size of each object
	for i, chunk in ipairs(chunks) do


		if chunk.type == "font" then
			-- set the font so GetTextSize will be correct
			set_font(self, chunk.val)
		elseif chunk.type == "string" then
			local w, h = get_text_size(self, chunk.val)

			chunk.w = w
			chunk.h = h + self.HeightSpacing

			if chunk.internal then
				chunk.w = 0
				chunk.h = 0
				chunk.real_h = h + self.HeightSpacing
				chunk.real_w = w
			end
		elseif chunk.type == "newline" then
			local w, h = get_text_size(self, "|")

			chunk.w = w
			chunk.h = h + self.HeightSpacing
		elseif chunk.type == "custom" and not chunk.val.stop_tag  then
			local ok, w, h = self:CallTagFunction(chunk, "get_size")
			if h then h = h + self.HeightSpacing end
			chunk.w = w
			chunk.h = h

			chunk.pre_called = false
		end

		-- for consistency everything should have x y w h

		chunk.x = chunk.x or 0
		chunk.y = chunk.y or 0
		chunk.w = chunk.w or 0
		chunk.h = chunk.h or 0
	end

	return chunks
end


local function solve_max_width(self, chunks)
	local out = {}

	-- solve max width
	local current_x = 0
	local current_y = 0

	local chunk_height = 0 -- the height to advance y in

	for i, chunk in ipairs(chunks) do
		local split = false

		if chunk.type == "font" then
			-- set the font so GetTextSize will be correct
			set_font(self, chunk.val)
		end

		if true or chunk.type ~= "newline" then

			-- is the previous line a newline?
			local newline = chunks[i - 1] and chunks[i - 1].type == "newline"

			-- figure out the tallest chunk before going to a new line
			if chunk.h > chunk_height then
				chunk_height = chunk.h
			end

			-- is this a new line or are we going to exceed the maximum width?
			if newline or (self.LineWrap and current_x + chunk.w >= self.MaxWidth) then

				-- does the string's width exceed the max width?
				-- if it does we need to split the string up
				if self.LineWrap and chunk.type == "string" and chunk.w > self.MaxWidth then
					-- start from the chunk's y
					local current_x = chunk.x
					local current_y = chunk.y
					local chunk_height = 0 -- the height to advance y in

					local str = {}

					for i, char in ipairs(utf8.totable(chunk.val)) do
						local w, h = get_text_size(self, char)

						if h > chunk_height then
							chunk_height = h
						end

						table.insert(str, char)
						current_x = current_x + w

						if current_x + w > self.MaxWidth then
							table.insert(out, {type = "string", val = table.concat(str, ""), x = 0, y = current_y, w = current_x, h = chunk_height, old_chunk = chunk.old_chunk or chunk})
							current_y = current_y + chunk_height

							current_x = 0
							chunk_height = 0
							split = true
							str = {}
						end
					end

					if split then
						table.insert(out, {type = "string", val = table.concat(str, ""), x = 0, y = current_y, w = current_x, h = chunk_height, old_chunk = chunk.old_chunk or chunk})
					end
				end

				-- reset the width
				current_x = 0

				-- advance y with the height of the tallest chunk
				current_y = current_y + chunk_height

				chunk_height = chunk.h
			end

			chunk.x = current_x
			chunk.y = current_y

			current_x = current_x + chunk.w
		end

		if not split then
			-- i don't know why i need this
			-- if i don't have this the chunk table will
			-- continue to grow when invalidating itself
			--chunk.old_chunk = chunk

			table.insert(out, chunk)
		end
	end

	return out
end

local function build_chars(chunk)
	if not chunk.chars then
		set_font(chunk.markup, chunk.font)
		chunk.chars = {}
		local width = 0

		local str = chunk.val

		if str == "" and chunk.internal then
			str = " "
		end

		for i, char in ipairs(utf8.totable(str)) do
			local char_width, char_height = get_text_size(chunk.markup, char)
			local x = chunk.x + width
			local y = chunk.y

			chunk.chars[i] = {
				x = x,
				y = chunk.y,
				w = char_width,
				h = char_height,
				right = x + char_width,
				top = y + char_height,
				char = char,
				i  = i,
				chunk = chunk,
			}

			chunk.chars[i].unicode = #char > 1
			chunk.chars[i].length = #char

			width = width + char_width
		end

		if str == " " and chunk.internal then
			chunk.chars[1].char = ""
			chunk.chars[1].w = 0
			chunk.chars[1].h = 0
			chunk.chars[1].x = 0
			chunk.chars[1].y = 0
			chunk.chars[1].top = 0
			chunk.chars[1].right = 0
		end
	end
end

local function store_tag_info(self, chunks)
	local line = 0
	local width = 0
	local height = 0
	local last_y

	local font = surface.GetDefaultFont()
	local color = Color(1,1,1,1)

	local chunk_line = {}
	local line_height = 0
	local line_width = 0

	self.chars = {}
	self.lines = {}

	local char_line = 1
	local char_line_pos = 0
	local char_line_str = {}

	for i, chunk in ipairs(chunks) do

		-- this is for expressions to be use d like line.i+time()
		chunk.exp_env = {
			i = chunk.real_i,
			w = chunk.w,
			h = chunk.h,
			x = chunk.x,
			y = chunk.y,
			rand = math.random()
		}

		if chunk.type == "font" then
			font = chunk.val
		elseif chunk.type == "color" then
			color = chunk.val
		elseif chunk.type == "string" then
			chunk.font = font
			chunk.color = color
		end

		local w = chunk.x + chunk.w
		if w > width then
			width = w
		end

		local h = chunk.y + chunk.h
		if h > height then
			height = h
		end

		if chunk.h > line_height then
			line_height = chunk.h
		end

		line_width = line_width + chunk.w

		if chunk.y ~= last_y then
			line =  line + 1
			last_y = chunk.y

			for i, chunk in ipairs(chunk_line) do
				--if type(chunk.val) == "string" and chunk.val:find("bigtable") then print("\n\n",chunk,"\n\n")  end
		--		log(chunk.type == "string" and chunk.val or ( "<"..  chunk.type .. ">"))
				chunk.line_height = line_height
				chunk.line_width = line_width
			end

			table.clear(chunk_line)

	--		log(chunk.y - chunks[i+1].y, "\n")

			line_height = chunk.h
			line_width = chunk.w
		end

		chunk.line = line
		chunk.markup = self
		chunk.build_chars = build_chars
		chunk.i = i
		chunk.real_i = chunk.real_i or i -- expressions need this

		if chunk.type == "custom" and not chunk.val.stop_tag then

			-- only bother with this if theres post_draw or post_draw_chunks for performance
			if self.tags[chunk.val.type].post_draw or self.tags[chunk.val.type].post_draw_chunks or self.tags[chunk.val.type].pre_draw_chunks then

				local current_width = 0
				local current_height = 0
				local width = 0
				local height = 0
				local last_y

				local tag_type = chunk.val.type
				local start_chunk = chunk
				local line = {}

				local start_found = 1
				local stops = {}

				for i = i+1, math.huge do
					local chunk = chunks[i]

					if chunk then

						if not last_y then last_y = chunk.y end

						current_width = current_width + chunk.w

						if chunk.h > current_height then
							current_height = chunk.h
						end

						if last_y ~= chunk.y then
							if current_width > width then
								width = current_width
							end

							height = height + current_height
							current_height = 0
							current_width = 0
							last_y = chunk.y
						end

						chunk.i = i

						if chunk.type == "tag_stopper" then
							break
						elseif chunk.type == "custom" and chunk.val.type == tag_type then
							if not chunk.val.stop_tag then
								start_found = start_found + 1
							else
								table.insert(stops, chunk)
								if start_found == 1 then
									break
								end
							end
						else
							table.insert(line, chunk)
						end
					else
						break
					end
				end

				height = height + current_height

				if current_width > width then
					width = current_width
				end

				local stop_chunk = stops[start_found] or line[#line]

				if stop_chunk then
					stop_chunk.chunks_inbetween = line
					stop_chunk.start_chunk = chunk
					stop_chunk.tag_stop_draw = true

					local center_x = chunk.x + width / 2
					local center_y = chunk.y + height / 2

					chunk.tag_start_draw = true
					chunk.tag_center_x = center_x
					chunk.tag_center_y = center_y
					chunk.tag_height = height
					chunk.tag_width = width
					chunk.chunks_inbetween = line

					for i, chunk in pairs(line) do
						--print(chunk.type, chunk.val)
						chunk.tag_center_x = center_x
						chunk.tag_center_y = center_y
						chunk.tag_height = height
						chunk.tag_width = width
						chunk.chunks_inbetween = line
					end

				end
			else
				chunk.tag_start_draw = true
			end
		end

		do
			chunk.chars = nil

			if chunk.type == "string" then
				chunk:build_chars()

				for _, char in ipairs(chunk.chars) do
					table.insert(self.chars, {
						chunk = chunk,
						i = i,
						str = char.char,
						data = char,
						y = char_line,
						x = char_line_pos,
						unicode = char.unicode,
						length = char.length,
						internal = char.internal,
					})

					char_line_pos = char_line_pos + 1

					table.insert(char_line_str, char.char)
				end

			elseif chunk.type == "newline" then
				local data = {}

				data.w = chunk.w
				data.h = line_height
				data.x = chunk.x
				data.y = chunk.y
				data.right = chunk.x + chunk.w
				data.top = chunk.y + chunk.h

				table.insert(self.chars, {chunk = chunk, i = i, str = "\n", data = data, y = char_line, x = char_line_pos})
				char_line = char_line + 1
				char_line_pos = 0

				table.insert(self.lines, table.concat(char_line_str, ""))

				table.clear(char_line_str)
			elseif chunk.w > 0 and chunk.h > 0 then
				table.insert(self.chars, {
					chunk = chunk,
					i = i,
					str = " ",
					data = {
						char = " ",
						w = chunk.w,
						h = chunk.h,

						x = chunk.x,
						y = chunk.y,

						top = chunk.y + chunk.h,
						right = chunk.x + chunk.w,
					},
					y = char_line,
					x = char_line_pos,
					unicode = 0,
					length = 0,
				})

				char_line_pos = char_line_pos + 1

				table.insert(char_line_str, " ")
			end

			chunk.tag_center_x = chunk.tag_center_x or 0
			chunk.tag_center_y = chunk.tag_center_y or 0
			chunk.tag_width = chunk.tag_width or 0
			chunk.tag_height = chunk.tag_height or 0
		end

		table.insert(chunk_line, chunk)
	end

	for i, chunk in ipairs(chunk_line) do
--		log(chunk.type == "string" and chunk.val or ( "<"..  chunk.type .. ">"))

		chunk.line_height = line_height
		chunk.line_width = line_width
	end

	-- add the last line since there's probably not a newline at the very end
	table.insert(self.lines, table.concat(char_line_str, ""))

	self.text = table.concat(self.lines, "\n")
	--timer.Measure("chars build")

--	log(line_height, "\n")

	self.line_count = line
	self.width = width
	self.height = height


	if self.height < self.MinimumHeight then
		self.height = self.MinimumHeight
	end
end

local function align_y_axis(self, chunks)
	for _, chunk in ipairs(chunks) do
		-- mouse testing
		chunk.y = chunk.y + chunk.line_height - chunk.h

		if chunk.chars then
			for i, char in ipairs(chunk.chars) do
				char.top = char.y + chunk.line_height
				char.h = chunk.line_height
			end
		end

		chunk.right = chunk.x + chunk.w
		chunk.top = chunk.y
	end

end

function META:SuppressLayout(b)
	self.suppress_layout = b
end

function META:Invalidate()
	self.cached_gettext_tags = nil
	self.cached_gettext_tags = nil

	if self.suppress_layout then return end
	local chunks = prepare_chunks(self)
	chunks = split_by_space_and_punctation(self, chunks)
	chunks = get_size_info(self, chunks)

	chunks = solve_max_width(self, chunks)

	if self.LineWrap then
		chunks = solve_max_width(self, chunks)
	end

	store_tag_info(self, chunks)

	align_y_axis(self, chunks)

	self.chunks = chunks

	-- preserve caret positions
	if self.caret_pos then
		self:SetCaretPosition(self.caret_pos.x, self.caret_pos.y)
	else
		self:SetCaretPosition(0, 0)
	end

	if self.select_start then
		self:SelectStart(self.select_start.x, self.select_start.y)
	end

	if self.select_stop then
		self:SelectStop(self.select_stop.x, self.select_stop.y)
	end

	if self.LightMode or self.SuperLightMode then
		self.light_mode_obj = self:CompileString()
	end

	if self.OnInvalidate then
		self:OnInvalidate()
	end
end

function META:CompileString()
	local last_font

	local strings = {}
	local current_font
	local data

	local X, Y = 0,0

	for i, chunk in ipairs(self.chunks) do
		if chunk.type == "string" or chunk.type == "newline" then
			if chunk.font then
				if chunk.font ~= last_font then
					data = {}
					table.insert(strings, {font = chunk.font, data = data})
				end
			end

			table.insert(data, Vec2(chunk.x, chunk.y))
			table.insert(data, chunk.color)
			table.insert(data, chunk.val or "\n")

			if chunk.font then
				last_font = chunk.font
			end
		end
	end

	for k,v in ipairs(strings) do
		strings[k] = v.font:CompileString(v.data)
	end

	local obj = {}

	function obj:Draw(max_w)
		for k,v in ipairs(strings) do
			v:Draw(0, 0, max_w)
		end
	end

	return obj
end

prototype.UpdateObjects(META)