local love = ... or _G.love
local line = line -- line_update and line_draw

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

function love.line_update(dt)
	if not love.update then return end

	if love._line_env.love_game_update_draw_hack == false then
		love._line_env.love_game_update_draw_hack = true -- this is stupid but it's because some games rely on update being called before draw
	end

	line.pcall(love, love.update, dt)
end

function love.line_draw(dt)
	if not love.draw then return end

	if love._line_env.love_game_update_draw_hack == false then return end

	render2d.PushMatrix()
	render2d.SetTexture()

	love.graphics.setShader()

	love.graphics.clear()
	love.graphics.setColor(love.graphics.getColor())
	love.graphics.setFont(love.graphics.getFont())

	line.pcall(love, love.draw, dt)

	render2d.PopMatrix()

	if love._line_env.error_message and not love._line_env.no_error then
		love.errhand(love._line_env.error_message)
	end
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

	love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
end

event.AddListener("LoveNewIndex", "line_love", function(love, key, val)
	if key == "update" then
		if val then
			event.AddListener("Update", "line", function()
				for i = 1, line.speed do
					line.CallEvent("line_update", system.GetFrameTime())
				end
			end)
		else
			event.RemoveListener("Update", "line")
		end
	elseif key == "draw" then
		if val then
			event.AddListener("PreDrawGUI", "line", function(dt)
				if menu and menu.IsVisible() then
					render2d.PushHSV(1,0,1)
				end

				line.CallEvent("line_draw", dt)

				if menu and menu.IsVisible() then
					render2d.PopHSV()
				end
			end)
		else
			event.RemoveListener("PreDrawGUI", "line")
		end
	elseif key == "resize" then
		if val then
			event.AddListener("WindowResize", "line", function(_,w,h)
				line.CallEvent("resize",w,h)
			end)
		else
			event.RemoveListener("WindowResize", "line")
		end
	end
end)