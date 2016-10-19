profiler.EnableStatisticalProfiling(true)

local root
local drawn = {}

local function draw_branch(node, level, i, max, px, py, ppos, pw, ph)
	if not node.ready then return end

	max = max or 1
	i = i or 0
	level = level or 2
	px = px or 0
	py = py or 0
	ppos = ppos or 0
	pw = pw or 0
	ph = ph or 0

	local frac = -(node.times_called / root.times_called) + 1

	frac = math.clamp(frac, 0, 1)

	local r,g,b = ColorHSV(frac, 1, 1):Unpack()
	render2d.SetColor(r,g,b,0.5)

	local pos = (i / max)
	local x, y = math.sin(pos * math.pi * 2) * math.random(600, 1000)* level, math.cos(pos * math.pi * 2) * math.random(600, 1000) * level

	x = x + px
	y = y + py

	if node == root then
		x, y = 0, 0
	end

	--x = math.lerp(0.5, x, px)
	--y = math.lerp(0.5, y, py)
	local w, h = gfx.GetTextSize(node.name)
	w = w + 8
	h = h * 4

	if drawn[node] then
		x = node.px
		y = node.py
	end

	gfx.DrawLine(
		x + (math.random() > 0.5 and w or 0) - w*0.5,
		y + (math.random() > 0.5 and h or 0) - h*0.5,

		px + (math.random() > 0.5 and pw or 0) - pw*0.5,
		py + (math.random() > 0.5 and ph or 0) - ph*0.5
	)

	if not drawn[node] then
		drawn[node] = true

		node.px = x
		node.py = y

		render2d.DrawRect(x,y,w,h, nil, w*0.5, h*0.5)

		max = table.count(node.children)
		i = 0

		for _, child in pairs(node.children) do
			math.randomseed(tonumber(tostring(child):match("(0x.+)")))
			draw_branch(child, level + 1, i, max, x, y, pos, w, h)
			i = i + 1
		end

		local offset = h/4
		local x, y = x + 4 - w*0.5, y - h*0.5
		render2d.SetColor(1,1,1,1)

		gfx.SetTextPosition(x, y)
		gfx.DrawText(node.name)

		gfx.SetTextPosition(x, y + offset)
		gfx.DrawText("samples: " .. node.times_called)

		gfx.SetTextPosition(x, y + offset * 2)
		gfx.DrawText("children: " .. max)

		gfx.SetTextPosition(x, y + offset * 3)
		gfx.DrawText("parents: " .. table.count(node.parents))
	end
end

event.AddListener("PreDrawGUI", "lol", function()
	if wait(5) then
		for _, v in pairs(profiler.GetBenchmark("statistical")) do
			if not next(v.parents) then
				root = v
			end
		end
	end

	if not root then return end

	gfx.SetFont("impact")
	render2d.SetTexture()

	local w, h = render2d.GetSize()
	local x, y = w / 2, h / 2

	render2d.PushMatrix(x, y, 1, 1, 0)
		draw_branch(root)
	render2d.PopMatrix()

	table.clear(drawn)
end)
