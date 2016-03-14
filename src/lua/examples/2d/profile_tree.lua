profiler.EnableStatisticalProfiling(true)

local root
local count = 0
local drawn = {}
local max_calls = 1

local function draw_branch(node)
	if drawn[node] then return end
	drawn[node] = true

	if node.times_called then
		local r,g,b = HSVToColor(0, (node.times_called / root.times_called), 1):Unpack()
		surface.SetColor(r,g,b,1)
	end

	local w, h = surface.GetTextSize(node.name)

	surface.PushMatrix(h*0.5, -w, 1, 1, 90)
	surface.DrawText(node.name)
	surface.PopMatrix()

	for key, child in pairs(node.children) do
		math.randomseed(tonumber(tostring(child):match("(0x.+)")))

		surface.PushMatrix(0, -w, 1, 1, math.randomf(-45, 45))
			draw_branch(child)
		surface.PopMatrix()
		count = count + 1
	end
end

event.AddListener("Draw2D", "lol", function()
	if wait(1) then
		local top = profiler.GetBenchmark("statistical")
		for k, v in pairs(top) do
			if not next(v.parents) then
				root = v
				break
			end
		end
		--table.print(root.parents, 1)
	end

	if not root then return end

	local w, h = surface.GetSize()
	local x, y = w / 2, h

	surface.SetFont("default")
	surface.SetWhiteTexture()
	surface.SetColor(1,1,1,1)
	surface.DrawText(count)
	count = 0

	surface.PushMatrix(x, y, 0.25, 0.25, 0)
		draw_branch(root)
	surface.PopMatrix()

	drawn = {}
end)