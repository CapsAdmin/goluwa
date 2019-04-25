local img = love.graphics.newImage("http://www.flutedmushroom.com/assets/img/mushroom-64x64.png")

local top_left = love.graphics.newQuad(0, 0, 32, 32, img:getDimensions())
local bottom_left = love.graphics.newQuad(0, 32, 32, 32, img:getDimensions())
local top_right = love.graphics.newQuad(32, 0, 32, 32, img:getDimensions())
local bottom_right = love.graphics.newQuad(32, 32, 32, 32, img:getDimensions())


local q = love.graphics.newQuad(0,0, 900, 600, 1024, 1024)
local img2 = love.graphics.newImage("http://image.shutterstock.com/z/stock-vector-lol-87079871.jpg")

local text=[[
 LINE WRAP TEST! ~~~~~~~~~~

 The classic hello world program can be written as follows:

	print 'Hello World!'

 Comments use the following syntax, similar to that of Ada, Eiffel, Haskell, SQL and VHDL:

	-- A comment in Lua.


 The factorial function is implemented as a function in this example:

	function factorial(n)
        local x = 1
        for i = 2,n do
			x = x * i
        end
        return x
	end

Lua's treatment of functions as first-class values is shown in the following example, where the print function's behavior is modified:

	do
		local oldprint = print
		function print(s)
			if s == "foo" then
				oldprint("bar")
			else
				oldprint(s)
			end
		end
	end
.....................................................
]]

love.window.setMode(1280, 720)
local time_now=love.timer.getTime()
function goluwa.PreDrawGUI()
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

	love.graphics.printf(
		string.sub(text,1,(love.timer.getTime()-time_now)*100),
		(1280/2)-(720/2),50,
		640
	)
end

