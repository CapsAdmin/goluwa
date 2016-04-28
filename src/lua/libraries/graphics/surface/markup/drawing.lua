local META = (...) or prototype.GetRegistered("markup")

local function set_font(self, font)
	if self.FixedSize == 0 then
		surface.SetFont(font)
	end
end

function META:Update()
	if self.need_layout then
		self:Invalidate()
		self.need_layout = false
	end

	if self.Selectable and self.chunks[1] then
		if self.mouse_selecting then
			local x, y = self:GetMousePosition():Unpack()
			local caret = self:CaretFromPixels(x, y)

			if x > caret.char.data.x + caret.char.data.w / 2 then
				caret = self:CaretFromPixels(x + caret.w / 2, y)
			end

			if caret then
				self.select_stop = caret
			end
		end

		if self.ShiftDown then
			if not self.caret_shift_pos then
				local START = self:GetSelectStart()
				local END = self:GetSelectStop()

				if START and END then
					if self.caret_pos.i < END.i then
						self.caret_shift_pos = self:CaretFromPosition(END.x, END.y)
					else
						self.caret_shift_pos = self:CaretFromPosition(START.x, START.y)
					end
				else
					self.caret_shift_pos = self:CaretFromPosition(self.caret_pos.x, self.caret_pos.y)
				end
			end
		else
			self.caret_shift_pos = nil
		end
	end
end

local start_remove = false
local remove_these = false
local started_tags = false

function META:Draw(max_w)
	if self.LightMode or self.SuperLightMode and self.light_mode_obj then
		self.light_mode_obj:Draw(max_w)

		if self.Selectable then
			self:DrawSelection()
		end

		if self.SuperLightMode then
			return
		end
	end

	if self.chunks[1] then
		-- reset font and color for every line
		set_font(self, surface.GetDefaultFont())
		surface.SetColor(1, 1, 1, 1)

		start_remove = false
		remove_these = false
		started_tags = false

		--[[if
			self.cull_x ~= self.last_cull_x or
			self.cull_y ~= self.last_cull_y or
			self.cull_w ~= self.last_cull_w or
			self.cull_h ~= self.last_cull_h
		then



			self.last_cull_x = self.cull_x
			self.last_cull_y = self.cull_y
			self.last_cull_w = self.cull_w
			self.last_cull_h = self.cull_h
		end]]

		for i, chunk in ipairs(self.chunks) do

			if not chunk.internal then
				if not chunk.x then return end -- UMM

				if
					(
						chunk.x + chunk.w >= self.cull_x and
						chunk.y + chunk.h >= self.cull_y and

						chunk.x - self.cull_x <= self.cull_w and
						chunk.y - self.cull_y <= self.cull_h
					) or
					-- these are important since they will remove anything in between
					(chunk.type == "start_fade" or chunk.type == "end_fade") or
					start_remove
				then
					if chunk.type == "start_fade" then
						chunk.alpha = math.min(math.max(chunk.val - os.clock(), 0), 1) ^ 5
						surface.SetAlphaMultiplier(chunk.alpha)

						if chunk.alpha <= 0 then
							start_remove = true
						end
					end

					if start_remove then
						self.remove_these[i] = true
						remove_these = true
					end

					if chunk.type == "string" and not self.LightMode then
						set_font(self, chunk.font)

						local c = chunk.color
						surface.SetColor(c.r, c.g, c.b, c.a)

						surface.DrawText(chunk.val, chunk.x, chunk.y, max_w)
					elseif chunk.type == "tag_stopper" then
						for _, chunks in pairs(self.started_tags) do
							local fix = false

							for key, chunk in pairs(chunks) do
								--print("force stop", chunk.val.type, chunk.i)
								if next(chunks) then
									self:CallTagFunction(chunk, "post_draw", chunk.x, chunk.y)
									chunks[key] = nil
								end
							end

							if fix then
								table.fixindices(chunks)
							end
						end
					elseif chunk.type == "custom" then

						-- init
						if not chunk.init_called and not chunk.val.stop_tag then
							self:CallTagFunction(chunk, "init")
							chunk.init_called = true
						end

						-- we need to make sure post_draw is called on tags to prevent
						-- engine matrix stack inbalance with the matrix tags
						self.started_tags[chunk.val.type] = self.started_tags[chunk.val.type] or {}

						started_tags = true

						-- draw_under
						if chunk.tag_start_draw then
							if self:CallTagFunction(chunk, "pre_draw", chunk.x, chunk.y) then
								--print("pre_draw", chunk.val.type, chunk.i)

								-- only if there's a post_draw
								if self.tags[chunk.val.type].post_draw then
									table.insert(self.started_tags[chunk.val.type], chunk)
								end
							end

							if chunk.chunks_inbetween then
								--print("pre_draw_chunks", chunk.val.type, chunk.i, #chunk.chunks_inbetween)
								for i, other_chunk in ipairs(chunk.chunks_inbetween) do
									self:CallTagFunction(chunk, "pre_draw_chunks", other_chunk)
								end
							end
						end

						-- draw_over
						if chunk.tag_stop_draw then
							if table.remove(self.started_tags[chunk.val.type]) then
								--print("post_draw", chunk.val.type, chunk.i)
								self:CallTagFunction(chunk.start_chunk, "post_draw", chunk.start_chunk.x, chunk.start_chunk.y)
							end
						end
					end

					-- this is not only for tags. a tag might've been started without being ended
					if chunk.tag_stop_draw then
						--print("post_draw_chunks", chunk.type, chunk.i, chunk.chunks_inbetween, chunk.start_chunk.val.type)

						if table.remove(self.started_tags[chunk.start_chunk.val.type]) then
							--print("post_draw", chunk.start_chunk.val.type, chunk.i)
							self:CallTagFunction(chunk.start_chunk, "post_draw", chunk.start_chunk.x, chunk.start_chunk.y)
						end

						for i, other_chunk in ipairs(chunk.chunks_inbetween) do
							self:CallTagFunction(chunk.start_chunk, "post_draw_chunks", other_chunk)
						end
					end

					if chunk.type == "end_fade" then
						surface.SetAlphaMultiplier(1)
						start_remove = false
					end

					chunk.culled = false
				else
					chunk.culled = true
				end
			end
		end

		if started_tags then
			for _, chunks in pairs(self.started_tags) do
				for _, chunk in pairs(chunks) do
					--print("force stop", chunk.val.type, chunk.i)

					self:CallTagFunction(chunk, "post_draw", chunk.x, chunk.y)
				end
			end

			table.clear(self.started_tags)
		end

		if remove_these then
			table.clear(self.remove_these)
			table.fixindices(self.chunks)
			self:Invalidate()
		end

		if self.Selectable then
			self:DrawSelection()
		end
	end
end

function META:DrawSelection()
	local START = self:GetSelectStart()
	local END = self:GetSelectStop()

	if START and END then
		surface.SetWhiteTexture()
		surface.SetColor(self.SelectionColor:Unpack())

		for i = START.i, END.i - 1 do
			local char = self.chars[i]
			if char then
				local data = char.data
				surface.DrawRect(data.x, data.y, data.w, data.h)
			end
		end

		if self.Editable then
			self:DrawLineHighlight(self.select_stop.y)
		end
	elseif self.Editable then
		self:DrawCaret()
		self:DrawLineHighlight(self.caret_pos.char.y)
	end
end

function META:DrawLineHighlight(y)
	do return end
	local start_chunk = self:CaretFromPosition(0, y).char.chunk
	surface.SetColor(1, 1, 1, 0.1)
	surface.DrawRect(start_chunk.x, start_chunk.y, self.width, start_chunk.line_height)
end

function META:IsCaretVisible()
	return self.Editable and (system.GetElapsedTime() - self.blink_offset)%0.5 > 0.25
end

function META:DrawCaret()
	if self.caret_pos then
		local x = self.caret_pos.px
		local y = self.caret_pos.py
		local h = self.caret_pos.h

		if self.caret_pos.char.chunk.internal then
			local chunk = self.chunks[self.caret_pos.char.chunk.i - 1]
			if chunk then
				x = chunk.right
				y = chunk.y
				h = chunk.h
			else
				x = 0
				y = 0
				h = self.caret_pos.char.chunk.real_h
			end
		end

		if h < self.MinimumHeight then
			h = self.MinimumHeight
		end

		surface.SetWhiteTexture()
		surface.SetColor(self.CaretColor.r, self.CaretColor.g, self.CaretColor.b, self:IsCaretVisible() and self.CaretColor.a or 0)
		surface.DrawRect(x, y, 1, h)
	end
end

prototype.UpdateObjects(META)