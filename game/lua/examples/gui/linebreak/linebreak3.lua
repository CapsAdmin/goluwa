local font = fonts.CreateFont({path = "fonts/vera.ttf", size = 50})

local text = string.randomwords(10)

local boxes = {}

for i, word in ipairs(text:split(" ")) do
	local w, h = font:GetTextSize(word)
	table.insert(boxes, {
		width = w,
		word  = word,
	})
	table.insert(boxes, {
		space = true,
		width = font:GetTextSize(" "),
		word = " ",
	})
end

local function additional_split(word, max_width, out)
	out = out or {}

	local left_word, right_word = word:umidsplit()

	local left_width = font:GetTextSize(left_word)

	if left_width >= max_width and left_word:ulength() > 1 then
		additional_split(left_word, max_width, out)
	else
		table.insert(out, 1, {
			width = left_width,
			word = left_word,
		})
	end

	local right_width = font:GetTextSize(right_word)

	if right_width >= max_width and right_word:ulength() > 1 then
		additional_split(right_word, max_width, out)
	else
		table.insert(out, 1, {
			width = right_width,
			word = right_word,
		})
	end

	return out
end

local function layout(boxes, max_width)
	for i, box in ipairs(boxes) do
		if box.word:ulength() > 1 then
			if box.width > max_width then
				table.remove(boxes, i)
				for _, box in ipairs(additional_split(box.word, max_width)) do
					table.insert(boxes, i, box)
				end
			end
		end
	end

	local x = 0
	local y = 0
	local prev_line_i = 1

	for i, box in ipairs(boxes) do
		if not box.space then
			if x + box.width > max_width then
				local left_over_space = x - max_width

				y = y + 20
				x = 0

				-- go backwards and stretch all the words so
				-- it fits the line using the leftover space
				local x = max_width
				local space = left_over_space/(i-prev_line_i)
				for i2 = i-1, prev_line_i, -1 do
					local box = boxes[i2]
					x = x - box.width + space
					box.x = x
				end

				prev_line_i = i
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

	local boxes = table.copy(boxes)
	layout(boxes, w)

	for i, box in ipairs(boxes) do
		if not box.space then
			font:DrawString(box.word, box.x, box.y)
		end
	end
end