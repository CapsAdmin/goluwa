local img = love.graphics.newImage("http://www.flutedmushroom.com/assets/img/mushroom-64x64.png")

local top_left = love.graphics.newQuad(0, 0, 32, 32, img:getDimensions())
local bottom_left = love.graphics.newQuad(0, 32, 32, 32, img:getDimensions())
local top_right = love.graphics.newQuad(32, 0, 32, 32, img:getDimensions())
local bottom_right = love.graphics.newQuad(32, 32, 32, 32, img:getDimensions())


local q = love.graphics.newQuad(0,0, 900, 600, 1024, 1024)
local img2 = love.graphics.newImage("/media/caps/ssd_840_120gb/goluwa/love_games/lovers/sienna/art/titlescreen.png")

function love.draw()
	love.graphics.draw(img, top_left, 32, 32)
	love.graphics.draw(img, bottom_left, 32, 32*2)
	love.graphics.draw(img, top_right, 32*2, 32)
	love.graphics.draw(img, bottom_right, 32*2, 32*2)

	love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("This is a pretty lame example.", 10, 200)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print("This lame example is twice as big.", 10, 250, 0, 2, 2)
    love.graphics.setColor(0, 0, 255, 255)
    love.graphics.print("This example is lamely vertical.", 300, 30, math.pi/2)

	love.graphics.draw(img2, q, 0,0, 0, 300/900)

	-- v0.8:
	-- love.graphics.drawq(img, top_left, 50, 50)
	-- love.graphics.drawq(img, bottom_left, 50, 200)
end

