local love = ... or love

function love.load()
end

function love.update(dt)
end

function love.draw()
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

do -- error screen
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
end