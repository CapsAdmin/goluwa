local function content()
	love.graphics.setColor(255, 0, 0, 120)
	love.graphics.circle("fill", 300, 300, 150, 50)
	love.graphics.setColor(0, 255, 0, 120)
	love.graphics.circle("fill", 500, 300, 150, 50)
	love.graphics.setColor(0, 0, 255, 120)
	love.graphics.circle("fill", 400, 400, 150, 50)
end

local function nested_stencil()
	render2d.PushMatrix()
	render2d.Translate(270, 250)
	render2d.Scale(0.3, 0.3)
	render2d.PushStencil(225, 200, 350, 300)
	content()
	render2d.PopStencil()
	render2d.PopMatrix()
end

function goluwa.PreDrawGUI()
	render2d.PushStencil(225, 200, 350, 300)
	content()
	nested_stencil()
	render2d.PopStencil()
end