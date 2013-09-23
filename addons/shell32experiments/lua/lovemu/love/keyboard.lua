love.keyboard={}

function love.keyboard.isDown(key)
	return input.IsKeyDown(key)
end

event.AddListener("OnKeyInput","lovemu_keyboard",function(key,press)
	if press then
		love.keypressed(key)
	else
		love.keyreleased(key)
	end
end) 