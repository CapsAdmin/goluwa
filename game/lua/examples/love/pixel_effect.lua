local effect = love.graphics.newPixelEffect [[
	extern number time;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		return vec4((1.0+sin(time))/2.0, abs(cos(time)), abs(sin(time)), 1.0);
	}
]]

function love.draw()
    -- boring white
    love.graphics.setPixelEffect()
    love.graphics.rectangle('fill', 10,10,790,285)

    -- LOOK AT THE PRETTY COLORS!
    love.graphics.setPixelEffect(effect)
    love.graphics.rectangle('fill', 10,305,790,285)
end

local t = 0
function love.update(dt)
    t = t + dt
    effect:send("time", t)
end

