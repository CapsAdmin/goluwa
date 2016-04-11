local love = ... or _G.love
local ENV = love._lovemu_env

function love.load()
end

function love.mousepressed()
end

function love.mousereleased()
end

function love.keypressed()
end

function love.keyreleased()
end

function love.conf(t)

end

function love.getVersion()
	return 0, 9, 1, "goluwa"
end

function love.lovemu_update(dt)
	if not love.update then return end

	if ENV.love_game_update_draw_hack == false then
		ENV.love_game_update_draw_hack = true -- this is stupid but it's because some games rely on update being called before draw
	end

	lovemu.pcall(love, love.update, dt)
end

event.AddListener("Update", "love", function()
	for i = 1, lovemu.speed do
		lovemu.CallEvent("lovemu_update", system.GetFrameTime())
	end
end)

function love.lovemu_draw(dt)
	if not love.draw then return end

	if ENV.love_game_update_draw_hack == false then return end

	surface.PushMatrix()
	surface.SetWhiteTexture()

	love.graphics.clear()
	love.graphics.setColor(love.graphics.getColor())
	love.graphics.setFont(love.graphics.getFont())

	lovemu.pcall(love, love.draw, dt)

	surface.PopMatrix()
end

function love.errhand(msg)
	love.graphics.setFont()
	msg = tostring(msg)
	love.graphics.setBackgroundColor(89, 157, 220)
	love.graphics.setColor(255, 255, 255, 255)

	local trace = debug.traceback()

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
	end

	draw()
end
