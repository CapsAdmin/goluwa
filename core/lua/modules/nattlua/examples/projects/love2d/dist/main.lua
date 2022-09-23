_G.IMPORTS = _G.IMPORTS or {}
IMPORTS['src/love_api.nlua'] = function() 













































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































return love end
IMPORTS['src/maze.nlua'] = function() local Maze = {}
Maze.__index = Maze


function Maze:__tostring()
	local out = {}
	table.insert(out, "Maze " .. self.width .. "x" .. self.height .. "\n")

	for y = 0, self.height - 1 do
		for x = 0, self.width - 1 do
			if self:Get(x, y) == 0 then
				table.insert(out, " ")
			else
				table.insert(out, "█")
			end
		end

		table.insert(out, "\n")
	end

	return table.concat(out)
end

function Maze:Get(x, y)
	return self.grid[y * self.width + x]
end

function Maze:Set(x, y, v)
	self.grid[y * self.width + x] = v
end

function Maze:Build(seed)
	math.randomseed(seed)

	local function build(x, y)
		local r = math.random(0, 3)
		self:Set(x, y, 0)

		for i = 0, 3 do
			local d = (i + r) % 4
			local dx = 0
			local dy = 0

			if d == 0 then
				dx = 1
			elseif d == 1 then
				dx = -1
			elseif d == 2 then
				dy = 1
			else
				dy = -1
			end

			local nx = x + dx
			local ny = y + dy
			local nx2 = nx + dx
			local ny2 = ny + dy

			if self:Get(nx, ny) == 1 then
				if self:Get(nx2, ny2) == 1 then
					self:Set(nx, ny, 0)
					build(nx2, ny2)
				end
			end
		end
	end

	build(2, 2)
	self.grid[self.width + 2] = 0
	self.grid[(self.height - 2) * self.width + self.width - 3] = 0
end

local function constructor(_, width, height)
	local self = setmetatable(
		{
			grid = {},
			--[[ lie to the typesystem since we're just about to fill the grid with numbers ]] width = width,
			height = height,
		},
		Maze
	)

	for y = 0, height - 1 do
		for x = 0, width - 1 do
			self.grid[y * width + x] = 1
		end

		self.grid[y * width + 0] = 0
		self.grid[y * width + width - 1] = 0
	end

	for x = 0, width - 1 do
		self.grid[0 * width + x] = 0
		self.grid[(height - 1) * width + x] = 0
	end

	return self
end

setmetatable(Maze, {__call = constructor})
return Maze end
IMPORTS['src/vec2.nlua'] = function() local Vec2 = {}
Vec2.__index = Vec2




function Vec2:__tostring()
	return ("Vec2(%f, %f)"):format(self.x, self.y)
end

local function constructor(_, x, y)
	return setmetatable({x = x, y = y}, Vec2)
end

local op = {
	__add = "+",
	__sub = "-",
	__mul = "*",
	__div = "/",
}

for key, op in pairs(op) do
	local code = [[
        local Vec2 = ...
        function Vec2.]] .. key .. [[(a--[=[#: Vec2.@Self]=], b--[=[#: number | Vec2.@Self]=])
            if type(b) == "number" then
                return Vec2(a.x ]] .. op .. [[ b, a.y ]] .. op .. [[ b)
            end
            return Vec2(a.x ]] .. op .. [[ b.x, a.y ]] .. op .. [[ b.y)
        end
    ]]
	assert(loadstring(code))(Vec2)
end

function Vec2.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

function Vec2:GetLength()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

Vec2.__len = Vec2.GetLength

function Vec2.GetDot(a, b)
	return a.x * b.x + a.y * b.y
end

function Vec2:GetNormalized()
	local len = self:GetLength()

	if len == 0 then return Vec2(0, 0) end

	return self / len
end

function Vec2:GetRad()
	return math.atan2(self.x, self.y)
end

function Vec2:Copy()
	return Vec2(self.x, self.y)
end

function Vec2:Floor()
	return Vec2(math.floor(self.x), math.floor(self.y))
end

function Vec2.Lerp(a, b, t)
	return a + (b - a) * t
end

function Vec2:GetRotated(angle)
	local self = self:Copy()
	local cs = math.cos(angle)
	
	local sn = math.sin(angle)
	
	local xx = self.x * cs - self.y * sn
	
	local yy = self.x * sn + self.y * cs
	
	self.x = xx
	self.y = yy
	return self
end

function Vec2:GetReflected(normal)
	local proj = self:GetNormalized()
	local dot = proj:GetDot(normal)
	return Vec2(2 * (-dot) * normal.x + proj.x, 2 * (-dot) * normal.y + proj.y) * self:GetLength()
end

setmetatable(Vec2, {__call = constructor})
return Vec2 end

-- these imports will be bundled
local Maze = IMPORTS['src/maze.nlua']("./maze.nlua")
local Vec2 = IMPORTS['src/vec2.nlua']("./vec2.nlua")


local maze_width = 13
local maze_height = 13
local cell_size = 30
local grid = {}

do
	local maze = Maze(maze_width, maze_height)
	maze:Build(3)
	local neighbours = {Vec2(-1, 0), Vec2(0, -1), Vec2(1, 0), Vec2(0, 1)}

	local function get_neighbours(pos)
		local tbl = {}

		for _, xy in ipairs(neighbours) do
			local offset = xy + pos
			local found = grid[offset.y] and grid[offset.y][offset.x]

			if found then table.insert(tbl, found) end
		end

		return tbl
	end

	local stop

	for y = 1, maze.height do
		grid[y] = grid[y] or {}

		for x = 1, maze.width do
			local state = {
				pos = Vec2(x, y),
				wall = maze:Get(x - 1, y - 1) == 1,
			}

			if x > 1 and y > 5 and x < 10 and y < 8 then state.wall = false end

			if x == maze.width and y == maze.height then
				stop = state
				stop.goal = true
			end

			grid[y][x] = state
		end
	end

	stop.distance = 0
	local to_visit = {stop}

	for _, node in ipairs(to_visit) do
		if node.wall then
			node.distance = 100000
			node.visited = true
		else
			if node.distance then
				local neighbours = get_neighbours(node.pos)

				for _, n in ipairs(neighbours) do
					if not n.visited then
						n.visited = true
						n.distance = node.distance + 1
						table.insert(to_visit, n)
					end
				end
			end
		end
	end

	for y = 1, #grid do
		for x = 1, #grid[y] do
			local center = grid[y][x]

			if not center.wall then
				local neighbours = get_neighbours(center.pos)
				local pos = Vec2(0, 0)

				for _, n in ipairs(neighbours) do
					if n.distance and center.distance and not n.wall then
						local dir = n.pos - center.pos
						pos = pos + (dir * (center.distance - n.distance))
					end
				end

				center.direction = pos:GetNormalized()
			end
		end
	end
end

function love.load()
	love.window.setMode(
		cell_size * maze_width,
		cell_size * maze_height,
		{resizable = true, vsync = true, x = 0, y = 0}
	)
end

local function draw_arrow(x1, y1, x2, y2, arrlen, angle)
	love.graphics.line(x1, y1, x2, y2)
	local a = math.atan2(y1 - y2, x1 - x2)
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a + angle), y2 + arrlen * math.sin(a + angle))
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a - angle), y2 + arrlen * math.sin(a - angle))
end

local function cell2pix(pos)
	local x = (pos.x - 1) * cell_size
	local y = (pos.y - 1) * cell_size
	return Vec2(x, y)
end

function love.draw()
	for y = 1, #grid do
		for x = 1, #grid[y] do
			local state = grid[y][x]

			if state.wall then
				love.graphics.setColor(1, 1, 1, 1)
			elseif state.goal then
				love.graphics.setColor(0, 1, 0, 1)
			else
				love.graphics.setColor(1, 0, 0, state.distance and 10 / state.distance or 1)
			end

			local px = (x - 1) * cell_size
			local py = (y - 1) * cell_size
			love.graphics.rectangle("fill", px, py, cell_size, cell_size)
			love.graphics.setColor(0.5, 0.5, 0.5)
		end
	end

	for y = 1, #grid do
		for x = 1, #grid[y] do
			local cell = grid[y][x]
			local dir = cell.direction

			if dir then
				local s = cell_size / 2
				local pixel_pos = cell2pix(cell.pos)
				local start = pixel_pos - dir * s / 2
				local stop = pixel_pos + dir * s / 2
				-- center the arrow
				start = start + Vec2(s, s)
				stop = stop + Vec2(s, s)
				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				draw_arrow(start.x, start.y, stop.x, stop.y, cell_size / 10, math.pi / 4)
			end
		end
	end
end

_G.hot_reload_last_modified = os.time() + 1

function love.update()
	local info = love.filesystem.getInfo("main.lua")

	if info and _G.hot_reload_last_modified < info.modtime then
		

		assert(love.filesystem.load("main.lua"))()
		print("RELOAD")
	end
end