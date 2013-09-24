love.keyboard={}

function love.keyboard.isDown(key)
	return input.IsKeyDown(key)
end

event.AddListener("OnKeyInput","lovemu_keyboard",function(key,press)
	if press then
		if love.keypressed then
			love.keypressed(key)
		end
	else
		if love.keyreleased then
			love.keyreleased(key)
		end
	end
end) 