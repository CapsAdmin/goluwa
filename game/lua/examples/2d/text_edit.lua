local font = gfx.GetDefaultFont()
local grid = {}
local w, h = 10, 15
local caret_pos = Vec2(1, 1)
local select_start

local function get_caret_char(ox, oy)
	ox = ox or 0
	oy = oy or 0
	return grid[caret_pos.y + oy] and grid[caret_pos.y + oy][caret_pos.x + ox]
end

local function get_char(x, y)
	return grid[y] and grid[y][x]
end

local function move(x, y)
	if input.IsKeyDown("left_control") then
		local info = get_caret_char(math.min(x, 0), math.min(y, 0))

		if info then
			local type = info.char:get_char_type()

			if x ~= 0 then
				local i = 0
				local dir = x > 0 and 1 or -1

				while true do
					i = i + dir
					local info = get_char(caret_pos.x + i, caret_pos.y)

					if not info or info.char:get_char_type() ~= type then
						x = i

						break
					end
				end

				if dir < 0 then x = x + 1 end
			end

			if y ~= 0 then
				local i = 0
				local dir = y > 0 and 1 or -1

				while true do
					i = i + dir
					info = get_char(caret_pos.x, caret_pos.y + i)

					if not info or info.char:get_char_type() ~= type then
						y = i

						break
					end
				end

				if dir < 0 then y = y + 1 end
			end
		else
			if x ~= 0 then
				local dir = x > 0 and 1 or -1
				local i = 0

				for _ = 1, 100 do
					i = i + dir

					if get_char(caret_pos.x + i, caret_pos.y) then
						x = i

						break
					end
				end
			end

			if y ~= 0 then
				local dir = y > 0 and 1 or -1
				local i = 0

				for _ = 1, 100 do
					i = i + dir

					if get_char(caret_pos.x, caret_pos.y + i) then
						y = i

						break
					end
				end
			end
		end
	end

	caret_pos.x = math.max(caret_pos.x + x, 1)
	caret_pos.y = math.max(caret_pos.y + y, 1)
end

local poly = gfx.CreatePolygon2D(4096 * 6)
poly:SetColor(1, 1, 1, 1)

local function invalidate()
	local draw_i = 1

	for y, line in ipairs(grid) do
		for x, info in ipairs(line) do
			if info.char:get_char_type() ~= "space" then
				--gfx.DrawText(info.char, x*w, y*h)
				font:SetPolyChar(poly, draw_i, x * w, y * h, info.char)
				draw_i = draw_i + 1
			end
		end
	end
end

local function draw()
	local k, v = next(font.texture_atlas.textures)

	if v.page then
		render2d.SetTexture(v.page.texture)
		--render2d.SetTexture(render.GetErrorTexture())
		--render.SetCullMode("front")
		poly:Draw()
	--render.SetCullMode("front")
	end
end

function goluwa.PreDrawGUI()
	render2d.PushMatrix(50, 50)
	render2d.SetTexture()
	render2d.SetColor(1, 1, 1, 0.75)
	render2d.DrawRect(caret_pos.x * w, caret_pos.y * h, w / 8, h)
	render2d.SetColor(1, 1, 1, 1)

	if select_start then
		render2d.SetTexture()
		render2d.SetColor(1, 1, 1, 0.75)
		local x, y, w, h = select_start.x * w, select_start.y * h, (caret_pos.x * w) + w, (caret_pos.y * h) + h
		render2d.DrawRect(x, y, w - x, h - y)
		render2d.SetColor(1, 1, 1, 1)
	end

	draw()
	render2d.PopMatrix()
end

function goluwa.CharInput(char)
	font:DrawString(char)
	local line = grid[caret_pos.y]

	if not line then
		line = {}
		list.insert(grid, caret_pos.y, line)
	end

	if not line[caret_pos.x] then
		for _ = #line, caret_pos.x do
			list.insert(line, {char = " "})
		end
	end

	list.insert(line, caret_pos.x, {char = char})
	move(1, 0)
	invalidate()
end

function goluwa.KeyInputRepeat(key, press)
	if key == "left_shift" then
		if press then
			select_start = caret_pos:Copy()
		else
			select_start = nil
		end
	end

	if not press then return end

	if key == "left" then move(-1, 0) elseif key == "right" then move(1, 0) end

	if key == "up" then move(0, -1) elseif key == "down" then move(0, 1) end

	if key == "backspace" then
		local line = grid[caret_pos.y]

		if line and line[caret_pos.x] then
			list.remove(line, caret_pos.x - 1)
			invalidate()
			move(-1, 0)
		end
	elseif key == "delete" then
		local line = grid[caret_pos.y]

		if line and line[caret_pos.x] then
			list.remove(line, caret_pos.x)
			invalidate()
		--move(-1, 0)
		end
	end
end

do
	local lua = assert(vfs.Read("lua/examples/2d/text_edit.lua"))
	font:DrawString(lua)
	local x, y = 1, 1

	for i, char in ipairs(utf8.to_list(lua)) do
		if char == "\n" then
			y = y + 1
			x = 1
		end

		grid[y] = grid[y] or {}
		grid[y][x] = {char = char, i = i}
		x = x + 1
	end

	invalidate()
end