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

function love.conf(t) --partial

end

function love.getVersion()
	return 0, 9, 1, "goluwa"
end

function love.lovemu_update(dt)
	if not love.update then return end

	local ok, msg = system.pcall(love.update, dt)

	if not ok then
		ENV.errored = true
		ENV.error_msg = msg
	end
end

event.AddListener("Update", "love", function(dt)
	for i = 1, lovemu.speed do
		lovemu.CallEvent("lovemu_update", dt)
	end
end)

function love.lovemu_draw(dt)
	if not love.draw then return end

	surface.PushMatrix()
	surface.SetFont("lovemu")
	surface.SetWhiteTexture()

	love.graphics.clear()
	love.graphics.setColor(love.graphics.getColor())
	love.graphics.setFont(love.graphics.getFont())

	local ok, msg = system.pcall(love.draw, dt)

	if not ok then
		ENV.errored = true
		ENV.error_msg = msg
	end

	if ENV.errored then
		love.errhand(ENV.error_msg)
	end

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
