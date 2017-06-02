local gfx = (...) or _G.gfx

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

function gfx.CreateMarkup(str)
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

	if str then
		self:SetText(str)
	end

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
		for _, chunk in ipairs(self:StringTagsToTable(str)) do
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
	for _, v in ipairs(self.chunks) do
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

			for i, t in ipairs(chunk.val.tag.arg_types) do
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

					if type(val) == "table" then
						val = val.default
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
				return 1
			end
		end
	end

	return 0
end

do -- tags
	local function set_font(self, font)
		if self.FixedSize == 0 then
			gfx.SetFont(font)
		end
	end

	META.tags.click =
	{
		arguments = {},

		mouse = function(markup, self, button, press, x, y)
			if button == "button_1" and press then
				local str = ""
				for i = self.i+1, math.huge do
					local chunk = markup.chunks[i]
					if chunk.type == self.type or i > #markup.chunks then
						system.OpenURL(str)
						break
					elseif chunk.type == "string" then
						str = str .. chunk.val
					end
				end
				return false
			end
		end,

		post_draw_chunks = function(markup, self, chunk)
			gfx.DrawLine(chunk.x, chunk.top, chunk.right, chunk.top)
		end,
	}
	META.tags.console =
	{
		arguments = {},

		mouse = function(markup, self, button, press, x, y)
			if button == "button_1" and press then
				local str = ""
				for i = self.i+1, math.huge do
					local chunk = markup.chunks[i]
					if chunk.type == self.type or i > #markup.chunks then
						commands.RunString(str)
						break
					elseif chunk.type == "string" then
						str = str .. chunk.val
					end
				end
				return false
			end
		end,

		post_draw_chunks = function(markup, self, chunk)

			gfx.DrawLine(chunk.x, chunk.top, chunk.right, chunk.top)
		end,
	}

	if string.anime then
		META.tags.anime =
		{
			arguments = {},
			modify_text = function(markup, self, str)
				return str:anime()
			end,
		}
	end

	META.tags.wrong =
	{
		arguments = {},
		post_draw_chunks = function(markup, self, chunk)
			render2d.PushColor(1, 0, 0, 1)
			-- todo: LOL
			for x = chunk.x, chunk.right do
				gfx.DrawLine(x, chunk.top + math.sin(x), x+1, chunk.top +math.sin(x))
			end

			render2d.PopColor()
		end,
	}

	META.tags.background =
	{
		arguments = {1,1,1,1},
		pre_draw = function(markup, self, x,y, r,g,b,a)
			render2d.PushColor(r,g,b,a)
			local w, h = self.tag_width, self.tag_height
			if h > self.h then y = y - h end
			render2d.SetTexture()
			render2d.DrawRect(x, y, w, h)
			render2d.PopColor()
		end,

		post_draw = function()
			-- if we don't have this we don't get tag_center_x and stuff due to performance reasons
		end,
	}

	META.tags.mark =
	{
		arguments = {},
		post_draw_chunks = function(markup, self, chunk)
			render2d.PushColor(1, 1, 0, 0.25)
			render2d.SetTexture()
			render2d.DrawRect(chunk.x, chunk.y, chunk.w, chunk.h)
			render2d.PopColor()
		end,
	}

	META.tags.hsv =
	{
		arguments = {0, 1, 1},

		pre_draw = function(markup, self, x,y, h, s, v)
			local r,g,b = ColorHSV(h,s,v):Unpack()
			render2d.SetColor(r, g, b, 1)
		end,
	}

	META.tags.color =
	{
		arguments = {1, 1, 1, 1},

		pre_draw = function(markup, self, x,y, r,g,b,a)
			render2d.SetColor(r, g, b, a)
		end,
	}

	META.tags.alpha =
	{
		arguments = {1},

		pre_draw = function(markup, self, x, y, alpha)
			render2d.SetAlphaMultiplier(alpha)
		end,

		post_draw = function(markup, self)
			render2d.SetAlphaMultiplier(1)
		end,
	}

	META.tags.blackhole = {
		arguments = {1},

		pre_draw = function(markup, self, x,y, force)
			local delta = system.GetFrameTime() * 2

			for _,v in ipairs(markup.chunks) do
				if v ~= self and v.w > 0 and v.h > 0 then
					if not v.phys then
						v.phys = {
							pos = {x = v.x, y = v.y},
							vel = {x = 0, y = 0},
						}
					end

					local phys = v.phys

					phys.vel.x = phys.vel.x + ((self.x - phys.pos.x) * 0.01 * force)
					phys.vel.y = phys.vel.y + ((self.y - phys.pos.y) * 0.01 * force)

					-- velocity
					phys.pos.x = phys.pos.x + (phys.vel.x * delta)
					phys.pos.y = phys.pos.y + (phys.vel.y * delta)

					-- friction
					phys.vel.x = phys.vel.x * 0.97
					phys.vel.y = phys.vel.y * 0.97

					v.x = phys.pos.x
					v.y = phys.pos.y
				end
			end
		end,
	}

	META.tags.physics =
	{
		arguments = {1, 0, 0, 0, 0.997, 0.1},

		init = function(markup, self, gx, gy, vx, vy, drag, rand_mult)
			local part = {}

			part =
			{
				pos = {x = 0, y = 0},
				vel = {x = vx, y = vy},
				siz = {x = self.tag_width, y = self.tag_height},
				rand_mult = rand_mult,
				drag = drag,
			}

			self.part = part
		end,

		pre_draw = function(markup, self, x,y, gravity_y, gravity_x, vx, vy, drag, rand_mult)
			local delta = system.GetFrameTime() * 5

			local part = self.part

			local W, H = markup.width, markup.height
			W = W - self.x
			H = H - self.y + part.siz.y

			--local xvel = (self.last_world_x or markup.current_x) - markup.current_x
			--local yvel = (self.last_world_y or markup.current_y) - markup.current_y

			--self.last_world_x = markup.current_x or 0
			--self.last_world_y = markup.current_y or 0

			-- random velocity for some variation
			part.vel.y = part.vel.y + gravity_y + (math.randomf(-1,1) * rand_mult) --+ yvel
			part.vel.x = part.vel.x + gravity_x + (math.randomf(-1,1) * rand_mult) --+ xvel

			-- velocity
			part.pos.x = part.pos.x + (part.vel.x * delta)
			part.pos.y = part.pos.y + (part.vel.y * delta)

			-- friction
			part.vel.x = part.vel.x * part.drag
			part.vel.y = part.vel.y * part.drag

			-- collision
			if part.pos.x + part.siz.x < 0 then
				part.pos.x = -part.siz.x
				part.vel.x = part.vel.x * -part.drag
			end

			if part.pos.x + part.siz.x > W then
				part.pos.x = W - part.siz.x
				part.vel.x = part.vel.x * -part.drag
			end

			if part.pos.y + part.siz.y < 0 then
				part.pos.y = -part.siz.y
				part.vel.y = part.vel.y * -part.drag
			end

			if part.pos.y + part.siz.y > H then
				part.pos.y = H - part.siz.y
				part.vel.y = part.vel.y * -part.drag
			end

			render2d.PushMatrix()


			local center_x = self.tag_center_x
			local center_y = self.tag_center_y

			render2d.Translate(part.pos.x, part.pos.y)


			render2d.Translate(center_x, center_y)
				render2d.Rotate(math.deg(math.atan2(part.vel.y, part.vel.x)))
			render2d.Translate(-center_x, -center_y)


		end,

		post_draw = function()
			render2d.PopMatrix()
		end,
	}

	META.tags.font =
	{
		arguments = {},

		pre_draw = function(markup, self, x,y, font)
			set_font(self, fonts.FindFont(font))
		end,

		init = function(markup, self, font)
			set_font(self, fonts.FindFont(font))
		end,
	}

	META.tags.texture =
	{
		arguments = {"error", {default = 16, min = 4, max = 128}},

		init = function(markup, self, path)
			self.mat = render.CreateTextureFromPath(path)
		end,

		get_size = function(markup, self, path, size)
			if not self.mat or not self.mat:IsValid() then self.mat = render.CreateTextureFromPath(path) end
			if self.mat:IsLoading() then return 16, 16 end
			return self.mat.Size.x or size, self.mat.Size.y or size
		end,

		pre_draw = function(markup, self, x,y, path, size)
			if not self.mat or not self.mat:IsValid() then return end
			render2d.SetTexture(self.mat)
			render2d.DrawRect(x, y, self.mat.Size.x or size, self.mat.Size.y or size)
		end,
	}

	META.tags.silkicon =
	{
		arguments = {"world", {default = 1}},

		init = function(markup, self, path)
			self.mat = render.CreateTextureFromPath("textures/silkicons/" .. path .. ".png")
		end,

		get_size = function(markup, self, path, size_mult)
			return 16, 16
		end,

		pre_draw = function(markup, self, x,y, path)
			render2d.SetTexture(self.mat)
			render2d.DrawRect(x, y, self.w, self.h)
		end,
	}
end

do -- tags matrix
	local function set_cull_clockwise()
		-- ???
	end

	local function detM2x2 (m11, m12, m21, m22)
		return m11 * m22 - m12 * m21
	end

	local function mulM2x2V2 (m11, m12, m21, m22, v1, v2)
		return v1 * m11 + v2 * m12, v1 * m21 + v2 * m22
	end

	local function normalizeV2(x, y)
		local length = math.sqrt(x * x + y * y)
		return x / length, y / length
	end

	local function scaleV2(v1, v2, k)
		return v1 * k, v2 * k
	end

	local function eigenvector2(l, a, d)
		-- (a - ?) u1 + d u2 = 0
		if a - l == 0 then return 1, 0 end
		if     d == 0 then return 0, 1 end

		return normalizeV2(-d / (a - l), 1)
	end

	local function orthonormalM2x2ToVMatrix(m11, m12, m21, m22)
		local det = detM2x2(m11, m12, m21, m22)

		if det < 0 then
			render2d.Scale(1, -1)
		end

		local angle = math.atan2 (m21, m11)
		render2d.Rotate(math.deg(angle))
	end

	META.tags.translate =
	{
		arguments = {0, 0},

		pre_draw = function(markup, self, x, y, dx, dy)
			render2d.PushMatrix()

			render2d.Translate(dx, dy)


		end,

		post_draw = function()
			render2d.PopMatrix()
		end,
	}

	META.tags.scale =
	{
		arguments = {1, 1},

		init = function()

		end,

		pre_draw = function(markup, self, x, y, scaleX, scaleY)
			render2d.PushMatrix()

			self.matrixDeterminant = scaleX * scaleY

			if math.abs (self.matrixDeterminant) > 10 then
				scaleX, scaleY = normalizeV2(scaleX, scaleY)
				scaleX, scaleY = scaleV2(scaleX, scaleY, 10)
			end

			local centerY = y - self.tag_height / 2

			render2d.Translate(x, centerY)
				render2d.Scale(scaleX, scaleY)

				if scaleX < 0 then
					render2d.Translate(-self.tag_width, 0)
				end
			render2d.Translate(-x, -centerY)



			set_cull_clockwise(self.matrixDeterminant < 0)
		end,

		post_draw = function(markup, self)
			if self.matrixDeterminant < 0 then
				set_cull_clockwise(false)
			end

			render2d.PopMatrix()
		end,
	}

	META.tags.size =
	{
		arguments = {1},

		pre_draw = function(markup, self, x, y, size)
			markup.tags.scale.pre_draw(markup, self, x, y, size, size)
		end,

		post_draw = function(markup, self)
			markup.tags.scale.post_draw(markup, self)
		end,
	}

	META.tags.rotate =
	{
		arguments = {45},

		pre_draw = function(markup, self, x, y, deg)
			render2d.PushMatrix()

			local center_x = self.tag_center_x
			local center_y = self.tag_center_y

			render2d.Translate(center_x, center_y)
				render2d.Rotate(math.rad(deg))
			render2d.Translate(-center_x, -center_y)


		end,

		post_draw = function()
			render2d.PopMatrix()
		end,
	}

	META.tags.matrixez =
	{
		arguments = {0,0,1,1,0},

		pre_draw = function(markup, self, x, y, X, Y, scaleX, scaleY, angleInDegrees)
			self.matrixDeterminant = scaleX * scaleY

			if math.abs (self.matrixDeterminant) > 10 then
				scaleX, scaleY = normalizeV2(scaleX, scaleY)
				scaleX, scaleY = scaleV2(scaleX, scaleY, 10)
			end

			local centerX = self.tag_center_x
			local centerY = self.tag_center_y

			render2d.PushMatrix()

			render2d.Translate(x, centerY)
				render2d.Translate(X,Y)
				render2d.Scale(scaleX, scaleY)
				if scaleX < 0 then
					render2d.Translate(-self.tag_width, 0)
				end
				if angleInDegrees ~= 0 then
					render2d.Translate(centerX)
						render2d.Rotate(angleInDegrees)
					render2d.Translate(-centerX)
				end
			render2d.Translate(x, -centerY)



			set_cull_clockwise(self.matrixDeterminant < 0)
		end,

		post_draw = function(markup, self)
			if self.matrixDeterminant < 0 then
				set_cull_clockwise(false)
			end

			render2d.PopMatrix()
		end,
	}

	META.tags.matrix =
	{
		arguments = {1, 0, 0, 1, 0, 0},

		pre_draw = function(markup, self, x, y, a11, a12, a21, a22, dx, dy)
			-- Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn

			-- A = Q1 ? Q2

			-- B = transpose (A) * A
			local b11 = a11 * a11 + a21 * a21
			local b12 = a11 * a12 + a21 * a22
			local b21 = a12 * a11 + a22 * a21
			local b22 = a12 * a12 + a22 * a22
			local trB  = b11 + b22
			local detB = detM2x2(b11, b12, b21, b22)

			-- Finding eigenvalues of B...
			-- det (B - ?I) = 0
			-- | a - ?        b | = 0
			-- |     c    d - ? |
			--
			-- (a - ?) (d - ?) - bc = 0
			-- ?² + (-a - d) ? + ad - bc = 0
			--
			--     a + d ± sqrt ((a + d)² - 4 (ad - bc))
			-- ? = -------------------------------------
			--                      2

			-- This is never negative
			local sqrtInside = trB * trB - 4 * detB
			local eigenvalue1 = 0.5 * (trB + math.sqrt(sqrtInside))
			local eigenvalue2 = 0.5 * (trB - math.sqrt(sqrtInside))

			-- (B - ?I) u = 0
			--
			-- [ a - ?        b ] [ u1 ] = [ 0 ]
			-- [     c    d - ? ] [ u2 ]   [ 0 ]
			--
			-- (a - ?) u1 +      b  u2 = 0
			local q211, q221 = eigenvector2(eigenvalue1, b11, b12)
			local q212, q222 = eigenvector2(eigenvalue2, b11, b12)

			if eigenvalue1 == eigenvalue2 then
				-- Make up an eigenvector
				q212, q222 = q221, -q211
			end

			-- Those will never be negative as well #yolo
			local scaleX = math.sqrt (eigenvalue1)
			local scaleY = math.sqrt (eigenvalue2)

			local q111, q121 = mulM2x2V2(a11, a12, a21, a22, q211, q221)
			local q112, q122 = mulM2x2V2(a11, a12, a21, a22, q212, q222)
			q111, q121 = scaleV2(q111, q121, (scaleX ~= 0) and (1 / scaleX) or 0)

			if scaleY == 0 then
				q112, q122 = q121, -q111
			else
				-- DOES THIS WORK LOL
				q112, q122 = scaleV2(q112, q122, (scaleY ~= 0) and (1 / scaleY) or 0)
			end

			-- transpose Q2
			q212, q221 = q221, q212

			-- End of Cthulhu summoning

			self.matrixDeterminant = detM2x2(a11, a12, a21, a22)

			render2d.PushMatrix()

			render2d.Translate(x, y)
				render2d.Translate(dx, dy)

				orthonormalM2x2ToVMatrix(q211, q212, q221, q222)
					render2d.Scale(scaleX, scaleY)
				orthonormalM2x2ToVMatrix(q111, q112, q121, q122)

			render2d.Translate(-x, -y)



			set_cull_clockwise(self.matrixDeterminant < 0)
		end,

		post_draw = function(markup, self)
			if self.matrixDeterminant < 0 then
				set_cull_clockwise(false)
			end

			render2d.PopMatrix()
		end,
	}
end

do -- parse tags
		local function parse_tag_arguments(self, arg_line)
		local out = {}
		local str = {}
		local in_lua = false

		for _, char in ipairs(utf8.totable(arg_line)) do
			if char == "[" then
				in_lua = true
			elseif in_lua and char == "]" then -- todo: longest match
				in_lua = false
				local exp = table.concat(str, "")
				local ok, func = expression.Compile(exp)
				if ok then
					table.insert(out, func)
				else
					logf(exp)
					logf("markup expression error: %s", func)
				end
				str = {}
			elseif char == "," and not in_lua then
				if #str > 0 then
					table.insert(out, table.concat(str, ""))
					str = {}
				end
			else
				table.insert(str, char)
			end
		end

		if #str > 0 then
			table.insert(out, table.concat(str, ""))
			str = {}
		end

		for k,v in ipairs(out) do
			if tonumber(v) then
				out[k] = tonumber(v)
			end
		end

		return out
	end

	function META:StringTagsToTable(str)

		str = tostring(str)

		str = str:gsub("<rep=(%d+)>(.-)</rep>", function(count, str)
			count = math.min(math.max(tonumber(count), 1), 500)

			if #str:rep(count):gsub("<(.-)=(.-)>", ""):gsub("</(.-)>", ""):gsub("%^%d","") > 500 then
				return "rep limit reached"
			end

			return str:rep(count)
		end)

		local chunks = {}
		local found = false

		local in_tag = false
		local current_string = {}
		local current_tag = {}

		local last_font
		local last_color

		for _, char in ipairs(utf8.totable(str)) do
			if char == "<" then

				-- if we've been parsing a string add it
				if current_string then
					table.insert(chunks, {type = "string", val = table.concat(current_string, "")})
				end

				-- stat a new tag
				current_tag = {}
				in_tag = true
			elseif char == ">" and in_tag then
				-- maybe the string was "sdasd :> sdsadasd <color123>..."
				if current_tag then
					local tag_str = table.concat(current_tag, "") .. ">"
					local tag, arg_str = tag_str:match("<(.-)=(.+)>")
					local stop_tag = false

					if not tag or not self.tags[tag] then
						tag = tag_str:match("<(.-)>")
					end

					if not tag or not self.tags[tag] then
						tag = tag_str:match("</(.-)>")
						stop_tag = true
					end

					local info = self.tags[tag]
					local is_expression = false

					if info then
						local args = {}

						if not stop_tag then
							info.arg_types = {}

							args = parse_tag_arguments(self, arg_str or "")

							for i = 1, #info.arguments do
								local arg = args[i]
								local default = info.arguments[i]
								local t = type(default)

								info.arg_types[i] = t == "table" and "number" or t

								if t == "number" then
									local num = tonumber(arg)

									if not num and type(arg) == "function" then
										is_expression = true
										num = arg
									end

									args[i] = num or default
								elseif t == "string" then
									if not arg or arg == "" then
										arg = default
									end

									args[i] = arg
								elseif t == "table" then
									if default.min or default.max or default.default then
										local num = tonumber(arg)

										if num then
											if default.min and default.max then
												args[i] = math.min(math.max(num, default.min), default.max)
											elseif default.min then
												args[i] = math.min(num, default.min)
											elseif default.max then
												args[i] = math.max(num, default.max)
											end
										else
											if type(arg) == "function" then
												if default.min and default.max then
													args[i] = function(...) return math.min(math.max(arg(...) or default.default, default.min), default.max) end
												elseif default.min then
													args[i] = function(...) return math.min(arg(...) or default.default, default.min) end
												elseif default.max then
													args[i] = function(...) return math.max(arg(...) or default.default, default.max) end
												end
												is_expression = true
											else
												args[i] = default.default
											end
										end
									end
								end
							end
						end

						found = true

						-- if this is a string tag just put color and font as if they were var args for better performance
						if not is_expression and tag == "font" then
							if stop_tag then
								if last_font then
									table.insert(chunks, {type = "font", val = last_font})
								end
							else
								local font = fonts.FindFont(args[1])
								table.insert(chunks, {type = "font", val = font})
								last_font = font
							end
						elseif not is_expression and tag == "color" then
							if stop_tag then
								if last_color then
									table.insert(chunks, {type = "color", val = Color(unpack(last_color))})
								end
							else
								table.insert(chunks, {type = "color", val = Color(unpack(args))})
								last_color = args
							end
						else
							table.insert(chunks, {type = "custom", val = {tag = info, type = tag, args = args, stop_tag = stop_tag}})
						end

					end
				end

				current_string = {}
				in_tag = false
			end

			if in_tag then
				table.insert(current_tag, char)
			elseif char ~= ">" then
				table.insert(current_string, char)
			end
		end

		if found then
			table.insert(chunks, {type = "string", val = table.concat(current_string, "")})
		else
			chunks = {{type = "string", val = str}}
		end


		-- text modifiers
		-- this wont work if you do markup:AddTable({"<strmod>sada  sad ad wad d asdasd", Color(1,1,1,1), "</strmod>"})
		-- since it can only be applied to one markup.AddString(str, true) call
		for i, chunk in ipairs(chunks) do
			if chunk.type == "custom" and self.tags[chunk.val.type].modify_text then
				local start_chunk = chunk
				local func = self.tags[start_chunk.val.type].modify_text

				for i = i, #chunks do
					local chunk = chunks[i]

					if chunk.type == "string" then
						chunk.val = func(self, chunk, chunk.val, unpack(start_chunk.val.args)) or chunk.val
					end

					if chunk.type == "tag_stopper" or (chunk.type == "custom" and chunk.val.type == start_chunk.val.type and chunk.val.stop_tag) then
						break
					end
				end
			end
		end

		return chunks
	end
end

do -- invalidate
		local function set_font(self, font)
		if self.FixedSize == 0 then
			gfx.SetFont(font)
		end
	end

	local function get_text_size(self, text)
		if self.FixedSize > 0 then
			return self.FixedSize, self.FixedSize
		else
			return gfx.GetTextSize(text)
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

		for _, chunk in ipairs(self.chunks) do
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

		table.insert(out, 1, {type = "font", val = gfx.GetDefaultFont(), internal = true})
		table.insert(out, 1, {type = "color", val = Color(1, 1, 1, 1), internal = true})
		table.insert(out, {type = "string", val = "", internal = true})

		return out
	end

	local function split_by_space_and_punctation(self, chunks)
		-- solve white space and punctation

		local out = {}

		for _, chunk in ipairs(chunks) do
			if chunk.type == "string" and chunk.val:find("%s") and not chunk.internal then

				if self.LineWrap then
					local str = {}

					for _, char in ipairs(utf8.totable(chunk.val)) do
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
		for _, chunk in ipairs(chunks) do


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
				local _, w, h = self:CallTagFunction(chunk, "get_size")
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

						for _, char in ipairs(utf8.totable(chunk.val)) do
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

		local font = gfx.GetDefaultFont()
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

				for _, chunk in ipairs(chunk_line) do
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

						for _, chunk in ipairs(line) do
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

		for _, chunk in ipairs(chunk_line) do
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
				for _, char in ipairs(chunk.chars) do
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
		local data

		for _, chunk in ipairs(self.chunks) do
			if chunk.type == "string" or chunk.type == "newline" then
				if chunk.font then

					if not chunk.font:IsReady() then
						return nil, "fonts not ready"
					end

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

		local W, H = 0, 0

		for i, v in ipairs(strings) do
			local obj, w,h = v.font:CompileString(v.data)
			strings[i] = obj
			W = math.max(W, w)
			H = H + h
		end

		local obj = {}

		function obj:Draw(max_w)
			for _, v in ipairs(strings) do
				v:Draw(0, 0, max_w)
			end
		end
		self.width = W
		self.height = H

		return obj
	end

end

do -- shortcuts
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
end

do -- caret
	function META:SetCaretPosition(x, y)
		self.caret_pos = self:CaretFromPosition(x, y)
	end

	function META:GetCaretPosition()
		return self.caret_pos
	end

	function META:GetCaretSubPosition()
		local caret = self.caret_pos
		return self:GetSubPosFromPosition(caret.x, caret.y)
	end

	function META:CaretFromPixels(x, y)
		local CHAR
		local POS

		for i, char in ipairs(self.chars) do
			if
				x >= char.data.x and
				y >= char.data.y and

				x <= char.data.right and
				y <= char.data.top
			then
				POS = i
				CHAR = char
				break
			end
		end

		-- if nothing was found we need to check things differently

		if not CHAR then
			local line = {}

			for i, char in ipairs(self.chars) do
				if y > char.data.y and y < char.data.top + 1 then -- todo: remove +1
					table.insert(line, {i, char})
				end
			end

			if #line == 0 then
				for i, char in ipairs(self.chars) do
					if char.chunk.line == #self.lines then
						if y > char.data.y then
							table.insert(line, {i, char})
						end
					end
				end
			end

			if #line > 0 and x > line[#line][2].data.right then
				POS, CHAR = unpack(line[#line])
			end

			if not CHAR then
				for _, v in ipairs(line) do
					local i, char = unpack(v)
					if x < char.data.x then
						POS = i - 1
						CHAR = self.chars[POS]
						break
					end
				end
			end
		end

		if not CHAR then
			CHAR = self.chars[#self.chars]
			POS = #self.chars
		end

		local data = CHAR.data

		return {
			px = data.x,
			py = data.y,
			x = CHAR.x,
			y = CHAR.y,
			w = data.w,
			h = data.h,
			i = POS,
			char = CHAR,
			sub_pos = self:GetSubPosFromPosition(CHAR.x, CHAR.y),
		}
	end

	function META:CaretFromPosition(x, y)
		x = x or 0
		y = y or 0

		y = math.min(math.max(y, 1), #self.lines)
		x = math.min(math.max(x, 0), self.lines[y] and utf8.length(self.lines[y]) or 0)

		local CHAR
		local POS

		for i, char in ipairs(self.chars) do
			if char.y == y and char.x == x then
				CHAR = char
				POS = i
				break
			end
		end

		if not CHAR then
			if x == utf8.length(self.lines[#self.lines]) then
				POS = #self.chars
				CHAR = self.chars[POS]
			end
		end

		if not CHAR then
			if y <= 1 then
				if x <= 0 then
					CHAR = self.chars[1]
					POS = 1
				else
					CHAR = self.chars[x + 1]
					POS = x + 1
				end
			elseif y >= #self.lines then
				local i = #self.chars - utf8.length(self.lines[#self.lines]) + x + 1
				CHAR = self.chars[i]
				POS = i
			end
		end

		if not CHAR then
			CHAR = self.chars[#self.chars] -- something is wrong!
		end


		local data = CHAR.data

		return {
			px = data.x,
			py = data.y,
			x = CHAR.x,
			y = CHAR.y,
			h = data.h,
			w = data.w,
			i = POS,
			char = CHAR,
			sub_pos = self:GetSubPosFromPosition(CHAR.x, CHAR.y),
		}
	end

	function META:AdvanceCaret(X, Y)

		if self.ControlDown then
			if X < 0 then
				self:SetCaretPosition(self:GetNextCharacterClassPosition(-1))
			elseif X > 0 then
				self:SetCaretPosition(self:GetNextCharacterClassPosition(1))
			end
		end

		local line = self.lines[self.caret_pos.y]
		local x, y = self.caret_pos.x or 0, self.caret_pos.y or 0

		if Y ~= 0 then
			local pixel_y = self.caret_pos.char.data.y

			if Y > 0 then
				pixel_y = pixel_y + self.caret_pos.char.data.h + Y * 2
			else
				pixel_y = pixel_y + Y
			end

			local pcaret = self:CaretFromPixels(
				(self.real_x or self.caret_pos.char.data.x) + self.caret_pos.char.data.w / 2,
				pixel_y
			)

			x = pcaret.x
			y = pcaret.y
		elseif X ~= math.huge and X ~= -math.huge then
			x = x + X

			self.real_x = self:CaretFromPosition(x, y).char.data.x

			-- move to next or previous line
			if X > 0 and x > utf8.length(line) and #self.lines > 1 then
				x = 0
				y = y + 1

				if self.ControlDown then
					local line = self.lines[self.caret_pos.y + 1] or ""
					x = line:find("%s-%S", 0) or 1
					x = x - 1
				end
			elseif X < 0 and x < 0 and y > 0 and self.lines[self.caret_pos.y - 1] then
				x = utf8.length(self.lines[self.caret_pos.y - 1])
				y = y - 1
			end

		else
			if X == math.huge then
				x = utf8.length(line)
			elseif X == -math.huge then
				local pos = #(line:match("^(%s*)") or "")

				if x == pos then
					pos = 0
				end

				x = pos
			end
		end

		if x ~= self.caret_pos.x or y ~= self.caret_pos.y then
			if x < self.caret_pos.x then
				self.suppress_end_char = true
			end

			self:SetCaretPosition(x, y)

			self.suppress_end_char = false
		end

		self.blink_offset = system.GetElapsedTime() + 0.25
	end
end

do -- selection
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
		if tags and self.cached_gettext_tags then
			return self.cached_gettext_tags
		elseif self.cached_gettext then
			return self.cached_gettext
		end

		local str = self:GetSelection(tags, self:CaretFromPosition(0, 0), self:CaretFromPosition(math.huge, math.huge))

		if tags then
			self.cached_gettext_tags = str
		else
			self.cached_gettext_tags = str
		end

		return str
	end

	function META:GetWrappedText()
		local out = {}
		local i = 1
		local last_y = 0

		for _, chunk in ipairs(self.chunks) do
			if chunk.type == "string" then
				if last_y ~= chunk.y then
					out[i] = "\n"
					i = i + 1
				end

				out[i] = chunk.val
				i = i + 1
				last_y = chunk.y
			elseif chunk.type == "newline" then
				out[i] = "\n"
				i = i + 1
			end
		end

		return table.concat(out)
	end

	function META:SetText(str, tags)
		self:Clear()
		self:AddString(str, tags)
		self:Invalidate() -- do it right now
	end

	function META:GetSelection(tags, start, stop)
		local out = {}

		local START = start or self:GetSelectStart()
		local STOP = stop or self:GetSelectStop()

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
end
do -- clipboard
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
end

do -- input
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

	function META:OnKeyInput(key)
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

				for i, chunk in ipairs(self:StringTagsToTable(str)) do
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

		if
			chunk.type == "custom" and
			self:CallTagFunction(chunk, "mouse", button, press, x, y) == false
		then
			return
		end

		if button == "button_1" then


			if press then
				if self.last_click and self.last_click > system.GetElapsedTime() then
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

				self.last_click = system.GetElapsedTime() + 0.2
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
end

do -- drawing
	local function set_font(self, font)
		if self.FixedSize == 0 then
			gfx.SetFont(font)
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
		if (self.LightMode or self.SuperLightMode) and self.light_mode_obj then
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
			set_font(self, gfx.GetDefaultFont())
			render2d.SetColor(1, 1, 1, 1)

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
							chunk.alpha = math.min(math.max(chunk.val - system.GetElapsedTime(), 0), 1) ^ 5
							render2d.SetAlphaMultiplier(chunk.alpha)

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
							render2d.SetColor(c.r, c.g, c.b, c.a)

							gfx.DrawText(chunk.val, chunk.x, chunk.y, max_w)
						elseif chunk.type == "tag_stopper" then
							for _, chunks in ipairs(self.started_tags) do
								local fix = false

								for key, chunk in ipairs(chunks) do
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
									for _, other_chunk in ipairs(chunk.chunks_inbetween) do
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

							for _, other_chunk in ipairs(chunk.chunks_inbetween) do
								self:CallTagFunction(chunk.start_chunk, "post_draw_chunks", other_chunk)
							end
						end

						if chunk.type == "end_fade" then
							render2d.SetAlphaMultiplier(1)
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
					for _, chunk in ipairs(chunks) do
						--print("force stop", chunk.val.type, chunk.i)

						self:CallTagFunction(chunk, "post_draw", chunk.x, chunk.y)
					end
				end

				table.clear(self.started_tags)
			end

			if remove_these then
				for i in pairs(self.remove_these) do
					self.chunks[i] = nil
				end
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
			render2d.SetTexture()
			render2d.SetColor(self.SelectionColor:Unpack())

			for i = START.i, END.i - 1 do
				local char = self.chars[i]
				if char then
					local data = char.data
					render2d.DrawRect(data.x, data.y, data.w, data.h)
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
		render2d.SetColor(1, 1, 1, 0.1)
		render2d.DrawRect(start_chunk.x, start_chunk.y, self.width, start_chunk.line_height)
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

			render2d.SetTexture()
			render2d.SetColor(self.CaretColor.r, self.CaretColor.g, self.CaretColor.b, self:IsCaretVisible() and self.CaretColor.a or 0)
			render2d.DrawRect(x, y, 1, h)
		end
	end
end

META:Register()
