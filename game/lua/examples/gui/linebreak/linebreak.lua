local font = fonts.CreateFont({path = "fonts/vera.ttf", size = 25})

local text = string.randomwords(500)

local boxes = {}
for i, word in ipairs(text:split(" ")) do
	local w, h = font:GetTextSize(word)
	table.insert(boxes, {
		width = w,
		height = h,
		word  = word,
	})
	table.insert(boxes, {
		space = true,
		width = font:GetTextSize(" "),
		height = h,
		word = " ",
	})
end

local function layout(max_width)
	local x = 0
	local y = 0
	for i, box in ipairs(boxes) do
		if not box.space then
			if x + box.width > max_width then
				y = y + 20
				x = 0
			end
		end

		box.x = x
		box.y = y

		x = x + box.width
	end
end

function goluwa.PreDrawGUI()
	local w = gfx.GetMousePosition()
	gfx.DrawLine(w, 0, w, select(2, render2d.GetSize()))
	layout(w)

	for i, box in ipairs(boxes) do
		font:DrawString(box.word, box.x, box.y)
	end
end