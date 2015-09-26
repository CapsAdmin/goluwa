local love = ... or love

love.event = {}

local queue = {}

function love.event.clear()
	table.clear(queue)
end

function love.event.push(e, a, b, c, d) --partial
	table.insert(queue, {e, a, b, c, d})
end

function love.event.poll() --partial
	return function()
		return love.event.wait()
	end
end

function love.event.pump() --partial

end

function love.event.quit() --partial
	logn("love.event.quit")
end

function love.event.wait() --partial
	local val = table.remove(queue, 1)

	if val then
		return unpack(val)
	end
end

love.handlers = {}