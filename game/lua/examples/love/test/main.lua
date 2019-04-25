-- create canvas
local canvas = love.graphics.newCanvas()

-- direct drawing operations to the canvas
love.graphics.setCanvas(canvas)

-- draw colored square to canvas
love.graphics.setColor(230,240,120)
love.graphics.rectangle('fill',0,0,100,100)

-- re-enable drawing to the main screen
love.graphics.setCanvas()

function love.draw()
    -- draw scaled canvas to screen
    love.graphics.setColor(255,255,255)
    love.graphics.draw(canvas, 200,100, 0, .5,.5)
end