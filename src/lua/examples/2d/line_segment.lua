local points = {
	Vec2(200,50),Vec2(400,50),
	Vec2(500,300),Vec2(100,300),
	Vec2(200,50),
}

local lines = surface.CreatePoly((#points) * 6)
lines.mesh:SetMode("triangles")

function line(i, a, b, w)
	local dx = a.y - b.y
	local dy = b.x - a.x
	local L = math.sqrt(dx*dx+dy*dy)
	dx=dx/L
	dy=dy/L

	local tx = dx * w
	local ty = dy * w

	i = i * 6

	local btm_lft_x, btm_lft_y = b.x-tx+dy, b.y-ty-dx -- down left
	local btm_rgt_x, btm_rgt_y = a.x-tx+dy, a.y-ty-dx -- down right
	local top_rgt_x, top_rgt_y = a.x+tx+dy, a.y+ty-dx -- up right
	local top_lft_x, top_lft_y = b.x+tx-dy, b.y+ty+dx -- up left

	lines:SetVertex(i + 0, btm_rgt_x, btm_rgt_y)
	lines:SetVertex(i + 1, top_rgt_x, top_rgt_y)
	lines:SetVertex(i + 2, btm_lft_x, btm_lft_y)

	lines:SetVertex(i + 3, btm_lft_x, btm_lft_y)
	lines:SetVertex(i + 4, top_lft_x, top_lft_y)
	lines:SetVertex(i + 5, top_rgt_x, top_rgt_y)
end

local function close_lines(a, b)
	local a_top_rgt = lines.Vertices[(a * 6) - 5]
	local b_top_lft = lines.Vertices[(b * 6) - 2]
	local a_top_rgt2 = lines.Vertices[(a * 6) - 1]

	local new_x = math.lerp(0.5, a_top_rgt.pos.A, b_top_lft.pos.A)
	local new_y = math.lerp(0.5, a_top_rgt.pos.B, b_top_lft.pos.B)

	a_top_rgt.pos.A = new_x
	a_top_rgt.pos.B = new_y

	b_top_lft.pos.A = new_x
	b_top_lft.pos.B = new_y

	a_top_rgt2.pos.A = new_x
	a_top_rgt2.pos.B = new_y


	local a_btm_rgt = lines.Vertices[(a * 6) - 6]
	local b_btm_lft = lines.Vertices[(b * 6) - 3]
	local b_btm_lft2 = lines.Vertices[(b * 6) - 4]

	local new_x = math.lerp(0.5, a_btm_rgt.pos.A, b_btm_lft.pos.A)
	local new_y = math.lerp(0.5, a_btm_rgt.pos.B, b_btm_lft.pos.B)

	a_btm_rgt.pos.A = new_x
	a_btm_rgt.pos.B = new_y

	b_btm_lft.pos.A = new_x
	b_btm_lft.pos.B = new_y

	b_btm_lft2.pos.A = new_x
	b_btm_lft2.pos.B = new_y
end

local luwa = render.CreateTextureFromPath("http://www.filterforge.com/filters/9129.jpg")

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(luwa)

	local i = 0

	local last_point

	--for _, point in ipairs(points) do
	for _ = 1, #points + 1 do
		local point = points[_]


		if not point then
			point = points[1]
		end
	if _ == #points then
			point = Vec2(surface.GetMousePosition())
		end

		if last_point then
			line(i, point, last_point, 20)

			if i > 1 then
				close_lines(i - 1, i)
			end

			i = i + 1
		end
		last_point = point
	end

	close_lines(i - 1, 1)

	lines:Draw()
end)