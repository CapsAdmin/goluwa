-- https://github.com/michalove/closed_loop/blob/master/scripts/shape.lua~

local colors = {
	{170,0,0},
	{33,68,120},
	{0,128,0},
	{255,204,0},
	{255,102,0},
	{0,212,170},
	{233,221,175},
	{136,0,170},
}
local outline = {}
-- rectangle
outline[1] = {-.8,-.8,-.8,.8,.8,.8,.8,-.8}
-- triangle
outline[2] = {0,-.8,-0.8,0.8,0.8,0.8}
-- star
outline[3] = {}
for i=0,4 do
	local factor = 0.9
	local ratio = 0.49
	outline[3][4*i+1] = math.sin(i*math.pi*2/5) * factor
	outline[3][4*i+2] = -math.cos(i*math.pi*2/5) * factor
	outline[3][4*i+3] = ratio*math.sin((i+0.5)*math.pi*2/5) * factor
	outline[3][4*i+4] = ratio*-math.cos((i+0.5)*math.pi*2/5)		 * factor
end
-- circle
outline[4] = {}
local nSeg = 40
local factor = 0.9
for i=0,nSeg-1 do
	outline[4][2*i+1] = math.sin(i*math.pi*2/nSeg) * factor
	outline[4][2*i+2] = -math.cos(i*math.pi*2/nSeg) * factor
end
-- diamond
outline[5] = {0.9,0,0,0.9,-0.9,0,0,-0.9}
-- cross
outline[6] = {0.9,0.6,0.6,0.9,0,0.3
						,-0.6,0.9,-0.9,0.6,-0.3,0
						,-0.9,-0.6,-0.6,-0.9,0,-0.3
						,0.6,-0.9,0.9,-0.6,0.3,0}
-- heart
outline[7] = {}
local curve = love.math.newBezierCurve(
	0,0.9,0.4,0.5,1.08,-0.07,0.85,-0.65)
for k,v in ipairs(curve:render()) do
	if k>2 then
		table.insert(outline[7],v)
	end
end
curve = love.math.newBezierCurve(
	0.85,-0.65,0.62,-1,0.13,-.8,0.,-0.6)
for k,v in ipairs(curve:render()) do
	if k>2 then
		table.insert(outline[7],v)
	end
end
curve = love.math.newBezierCurve(
	0,-0.6,-.13,-0.8,-0.62,-1,-0.85,-0.65)
for k,v in ipairs(curve:render()) do
	if k>2 then
		table.insert(outline[7],v)
	end
end
curve = love.math.newBezierCurve(
-0.85,-0.65,-1.08,-0.07,-0.4,0.5,-0,0.9)
for k,v in ipairs(curve:render()) do
	if k>2 then
		table.insert(outline[7],v)
	end
end

-- half-moon
outline[8] = {}
local nSeg = 20
local r = 0.9
for i=1,2*nSeg do
	local angle = i/nSeg*4*math.pi/3/2 + math.pi/6
	table.insert(outline[8],r*math.cos(angle))
	table.insert(outline[8],r*math.sin(angle))
end
local cx = r*math.cos(-math.pi/6)
local cy = r*math.sin(-math.pi/6)
for i=1,nSeg do
	local angle = i*2*math.pi/3/nSeg + math.pi*5/6
	table.insert(outline[8],cx + r*math.cos(angle))
	table.insert(outline[8],cy -r*math.sin(angle))
end

local insides = {}
for i=1,#outline do
	if love.math.isConvex(outline[i]) then
	insides[i] = {outline[i]}
	else
	insides[i] = love.math.triangulate(outline[i])
	end
end

local function drawShape(shapeIdx, x,y,scale,r,g,b)
	local lineWidth = 5

	love.graphics.push()
	love.graphics.translate(x,y)
	love.graphics.scale(scale,scale)
	love.graphics.setLineWidth(0.2)

	-- inside, half mixed with white
	love.graphics.setColor(0.5*r+127,0.5*g+127,0.5*b+127)
	for k,v in ipairs(insides[shapeIdx]) do
		love.graphics.polygon('fill',v)
	end

	-- outside, solid
	love.graphics.setColor(r,g,b)
	love.graphics.polygon('line',outline[shapeIdx])
	love.graphics.pop()
end

event.AddListener("PostDrawGUI", "lol", function()
	local scale = 200
	local x, y = scale, scale
	for i=1,#outline do
		drawShape(i, x, y, scale/3, unpack(colors[i]))
		x = x + scale
		if i%4 == 0 then
			x = scale
			y = y + scale
		end
	end

	love.graphics.setLineWidth(10)
	love.graphics.push()
	love.graphics.translate(500,600)
	love.graphics.polygon("line", {-50,0, 0,-50, 50,0})
	love.graphics.pop()
end)