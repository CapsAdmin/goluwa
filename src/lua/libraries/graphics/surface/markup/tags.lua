local META = (...) or prototype.GetRegistered("markup")

local function set_font(self, font)
	if self.FixedSize == 0 then
		surface.SetFont(font)
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
		surface.DrawLine(chunk.x, chunk.top, chunk.right, chunk.top)
	end,
}
META.tags.console =
{
	arguments = {},

	mouse = function(markup, self, button, press, x, y) print'hi'
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

		surface.DrawLine(chunk.x, chunk.top, chunk.right, chunk.top)
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
		surface.PushColor(1, 0, 0, 1)
		-- todo: LOL
		for x = chunk.x, chunk.right do
			surface.DrawLine(x, chunk.top + math.sin(x), x+1, chunk.top +math.sin(x))
		end

		surface.PopColor()
	end,
}

META.tags.background =
{
	arguments = {1,1,1,1},
	pre_draw = function(markup, self, x,y, r,g,b,a)
		surface.PushColor(r,g,b,a)
		local w, h = self.tag_width, self.tag_height
		if h > self.h then y = y - h end
		surface.SetWhiteTexture()
		surface.DrawRect(x, y, w, h)
		surface.PopColor()
	end,

	post_draw = function()
		-- if we don't have this we don't get tag_center_x and stuff due to performance reasons
	end,
}

META.tags.mark =
{
	arguments = {},
	post_draw_chunks = function(markup, self, chunk)
		surface.PushColor(1, 1, 0, 0.25)
		surface.SetWhiteTexture()
		surface.DrawRect(chunk.x, chunk.y, chunk.w, chunk.h)
		surface.PopColor()
	end,
}

META.tags.hsv =
{
	arguments = {0, 1, 1},

	pre_draw = function(markup, self, x,y, h, s, v)
		local r,g,b = HSVToColor(h,s,v):Unpack()
		surface.SetColor(r, g, b, 1)
	end,
}

META.tags.color =
{
	arguments = {1, 1, 1, 1},

	pre_draw = function(markup, self, x,y, r,g,b,a)
		surface.SetColor(r, g, b, a)
	end,
}

META.tags.alpha =
{
	arguments = {1},

	pre_draw = function(markup, self, x, y, alpha)
		surface.SetAlphaMultiplier(alpha)
	end,

	post_draw = function(markup, self)
		surface.SetAlphaMultiplier(1)
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
			siz = {w = self.tag_width, h = self.tag_height},
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

		surface.PushMatrix()


		local center_x = self.tag_center_x
		local center_y = self.tag_center_y

		surface.Translate(part.pos.x, part.pos.y)


		surface.Translate(center_x, center_y)
			surface.Rotate(math.deg(math.atan2(part.vel.y, part.vel.x)))
		surface.Translate(-center_x, -center_y)


	end,

	post_draw = function()
		surface.PopMatrix()
	end,
}

META.tags.font =
{
	arguments = {},

	pre_draw = function(markup, self, x,y, font)
		set_font(self, font)
	end,

	init = function(markup, self, font)
		set_font(self, font)
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
		surface.SetTexture(self.mat)
		surface.DrawRect(x, y, self.mat.Size.x or size, self.mat.Size.y or size)
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
		surface.SetTexture(self.mat)
		surface.DrawRect(x, y, self.w, self.h)
	end,
}

prototype.UpdateObjects(META)