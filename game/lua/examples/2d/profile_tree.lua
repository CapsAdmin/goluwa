profiler.EnableStatisticalProfiling(true)

local root
local count = 0
local drawn = {}

local function draw_branch(node)
	if drawn[node] then return end
	drawn[node] = true

	if node.times_called then
		local r,g,b = ColorHSV(0, (node.times_called / root.times_called), 1):Unpack()
		render2d.SetColor(r,g,b,1)
	end

	local w, h = gfx.GetTextSize(node.name)

	render2d.PushMatrix(h*0.5, -w, 1, 1, math.rad(90))
	gfx.DrawText(node.name)
	render2d.PopMatrix()

	for _, child in pairs(node.children) do
		math.randomseed(tonumber(tostring(child):match("(0x.+)")))

		render2d.PushMatrix(0, -w, 1, 1, math.randomf(math.rad(-45), math.rad(45)))
			draw_branch(child)
		render2d.PopMatrix()
		count = count + 1
	end
end

function goluwa.PreDrawGUI()
	if wait(1) then
		local top = profiler.GetBenchmark("statistical")
		for _, v in pairs(top) do
			if not next(v.parents) then
				root = v
				break
			end
		end
		--table.print(root.parents, 1)
	end

	if not root then return end

	local w, h = render2d.GetSize()
	local x, y = w / 2, h

	gfx.SetFont()
	render2d.SetTexture()
	render2d.SetColor(1,1,1,1)
	gfx.DrawText(count)
	count = 0

	render2d.PushMatrix(x, y, 0.25, 0.25, 0)
		draw_branch(root)
	render2d.PopMatrix()

	drawn = {}
end