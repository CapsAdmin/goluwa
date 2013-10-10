

effect = {}

--white effect
local fade_in_white = {r=-80,g=-80,b=-80,a=-80}
local fade_out_black = {r=255,g=255,b=255,a=255}

effect_type = ''

function effect:update(dt)
	if effect_type == 'white' and gamestate == 'intro' then 
		fade_in_white.r = fade_in_white.r + 70*dt
		fade_in_white.g = fade_in_white.g + 70*dt
		fade_in_white.b = fade_in_white.b + 70*dt
		fade_in_white.a = fade_in_white.a + 70*dt
		if (fade_in_white.r or fade_in_white.g or fade_in_white.b or fade_in_white.a) >= 255 then 
			fade_in_white.r = 255
			fade_in_white.g = 255
			fade_in_white.b = 255
			fade_in_white.a = 255
		end
		love.graphics.setColor(fade_in_white.r,fade_in_white.g,fade_in_white.b,fade_in_white.a)
	end
	if effect_type == 'black' and gamestate == 'intro' then 
		fade_out_black.r = fade_out_black.r - 90*dt
		fade_out_black.g = fade_out_black.g - 90*dt
		fade_out_black.b = fade_out_black.b - 90*dt
		if (fade_out_black.r or fade_out_black.g or fade_out_black.b or fade_out_black.a) <= 0 then 
			fade_out_black.r = 0
			fade_out_black.g = 0
			fade_out_black.b = 0
		end
		love.graphics.setColor(fade_out_black.r,fade_out_black.g,fade_out_black.b,fade_out_black.a)
		love.graphics.setBackgroundColor(fade_out_black.r,fade_out_black.g,fade_out_black.b,fade_out_black.a)
	end

end

function effect:draw()
end