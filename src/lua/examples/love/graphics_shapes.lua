local image = love.graphics.newImage("textures/pac.png")
local quad = love.graphics.newQuad(0, 0, 128, 64, image:getWidth(), image:getHeight())

local function CreateTexturedCircle(image, segments)
	segments = segments or 40
	local vertices = {}

	-- The first vertex is at the center, and has a red tint. We're centering the circle around the origin (0, 0).
	table.insert(vertices, {0, 0, 0.5, 0.5, 255, 0, 0})

	-- Create the vertices at the edge of the circle.
	for i=0, segments do
		local angle = (i / segments) * math.pi * 2

		-- Unit-circle.
		local x = math.cos(angle)
		local y = math.sin(angle)

		-- Our position is in the range of [-1, 1] but we want the texture coordinate to be in the range of [0, 1].
		local u = (x + 1) * 0.5
		local v = (y + 1) * 0.5

		-- The per-vertex color defaults to white.
		table.insert(vertices, {x, y, u, v})
	end

	-- The "fan" draw mode is perfect for our circle.
	local mesh = love.graphics.newMesh(vertices, "fan")
	mesh:setTexture(image)

	return mesh
end

--local mesh = CreateTexturedCircle(image)
local font = love.graphics.newFont()
font:setLineHeight(1)
event.AddListener("PreDrawGUI", "lol", function()
	love.graphics.setColor(50,50,50)
	local w,h = love.window.getMode()
	love.graphics.rectangle("fill", 0,0,w,h)

 	--love.graphics.draw(mesh, 600, 450, 0, 100, 100)

	love.graphics.setLineWidth(5)

	love.graphics.setColor(255,255,0)
	love.graphics.arc( "fill", "pie", 100, 100, 50, math.pi / 6, (math.pi * 2) - math.pi / 6 )
	love.graphics.setColor(255,255,255)
	love.graphics.arc( "fill", "open", 200, 100, 50, math.pi / 6, (math.pi * 2) - math.pi / 6 )
	love.graphics.arc( "fill", "closed", 300, 100, 50, math.pi / 6, (math.pi * 2) - math.pi / 6 )

	love.graphics.arc( "line", "pie", 100, 210, 50, math.pi / 6, (math.pi * 2) - math.pi / 6 )
	love.graphics.arc( "line", "open", 200, 210, 50, math.pi / 6, (math.pi * 2) - math.pi / 6 )
	love.graphics.arc( "line", "closed", 300, 210, 50, math.pi / 6, (math.pi * 2) - math.pi / 6 )

	love.graphics.setPointSize(10)
	love.graphics.points({{10,50,1,0,1}, {50,50,1,1,1}})

	love.graphics.setColor(255, 255, 255)
    love.graphics.ellipse("fill", 300, 300, 75, 50, 100) -- Draw white ellipse with 100 segments.
    love.graphics.setColor(255, 0, 0)
    love.graphics.ellipse("fill", 300, 300, 75, 50, 5)   -- Draw red ellipse with five segments.


	love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", 500, 300, 50, 100) -- Draw white circle with 100 segments.
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", 500, 300, 50, 5)   -- Draw red circle with five segments.

	love.graphics.setLineWidth(10)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("none")
	love.graphics.push()
		love.graphics.translate(200, 500)
		love.graphics.line(-20,0, 0,-50, 20,0)
	love.graphics.pop()

	love.graphics.setLineJoin("bevel")
	love.graphics.push()
		love.graphics.translate(300, 500)
		love.graphics.line(-20,0, 0,-50, 20,0)
	love.graphics.pop()

	love.graphics.setLineJoin("miter")
	love.graphics.push()
		love.graphics.translate(400, 500)
		love.graphics.line(-20,0, 0,-50, 20,0)
	love.graphics.pop()

	love.graphics.rectangle("fill", 500, 50, 60, 120 )
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.rectangle("line", 500, 50, 60, 120, 5)

	love.graphics.draw(image, quad, 100, 100)
	love.graphics.printf(("hello world "):rep(10), 200, 500, 50)

	local w = font:getWidth("hello world")
	local h = font:getHeight("hello world")
	love.graphics.setFont(font)
	love.graphics.print("hello world", 0, 400)
	love.graphics.print(("%s, %s"):format(w,h), 100, 400)
	love.graphics.rectangle("fill", 0, 400, w, h)

end)